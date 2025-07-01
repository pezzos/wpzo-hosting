#!/bin/bash
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
PURPLE='\033[35m'
NC='\033[0;39m' # No Color
SERVERDIR="/path/to/servers"
WORKDIR="/path/to/work"

function testExists {
  if [ -d ${SERVERDIR}/${DOMAIN}/${SUB}/webroot/ ]; then
    printf "${RED}This host exists${NC}\n"
    exit 1
  else
    printf "${GREEN}This host doesn't exist${NC}\n"
  fi
}

function generateDirs {
  mkdir -p ${SERVERDIR}/${DOMAIN}/${SUB}/conf/
  mkdir -p ${SERVERDIR}/${DOMAIN}/${SUB}/webroot/
  mkdir -p ${SERVERDIR}/${DOMAIN}/${SUB}/php/
  mkdir -p ${SERVERDIR}/${DOMAIN}/${SUB}/php/misc/
  mkdir -p ${SERVERDIR}/${DOMAIN}/${SUB}/php/opcache/
  mkdir -p ${SERVERDIR}/${DOMAIN}/${SUB}/php/session/
  mkdir -p ${SERVERDIR}/${DOMAIN}/${SUB}/php/upload/
  mkdir -p ${SERVERDIR}/${DOMAIN}/${SUB}/php/wsdl/
  mkdir -p /var/log/wordpress/
  chown -R nginx:nginx ${SERVERDIR}/${DOMAIN}/${SUB}/webroot/
  chown -R nginx:nginx ${SERVERDIR}/${DOMAIN}/${SUB}/php/
  printf "${GREEN}Directories structure is made${NC}\n"
}

function generatePhpFpmConf {
  envsubst < ${WORKDIR}/scripts/template/phpfpm.conf > ${WORKDIR}/php-fpm.d/${TECHNAME}.conf
  printf "${GREEN}Php Fpm configuration is generated${NC}\n"
}

function testServerPhpFpm {
  php-fpm -t |& grep "configuration file /etc/php-fpm.conf test is successful" 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: Php Fpm configuration is broken${NC}\n"
    exit 1
  else
    printf "${GREEN}Php Fpm configuration seems ok${NC}\n"
  fi
}

function reloadServerPhpFpm {
  systemctl restart php-fpm.service && printf "${GREEN}Php Fpm service is restarted ${NC}\n" || printf "${RED}Error : can't restart Php Fpm ${NC}\n"
  pgrep -fl "$TECHNAME" 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: Php Fpm doesn't load the new pool ${TECHNAME}${NC}\n"
    exit 1
  else
    printf "${GREEN}Php Fpm loads the new pool${NC}\n"
  fi
  systemctl status php-fpm | grep running 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: Php Fpm is not running${NC}\n"
    exit 1
  else
    printf "${GREEN}Php Fpm is running${NC}\n"
  fi
}

function generateNginxConf {
  envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < ${WORKDIR}/scripts/template/nginx.conf > ${WORKDIR}/nginx/sites-available/${TECHNAME}.conf
  ln -rs ${WORKDIR}/nginx/sites-available/${TECHNAME}.conf ${WORKDIR}/nginx/sites-enabled/${TECHNAME}.conf
  printf "${GREEN}Nginx configuration is generated${NC}\n"
}

function testServerNginx {
  nginx -t |& grep "configuration file /etc/nginx/nginx.conf test is successful" 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: Nginx configuration is broken${NC}\n"
    exit 1
  else
    printf "${GREEN}Nginx configuration seems ok${NC}\n"
  fi
}

function reloadServerNginx {
  systemctl restart nginx.service && printf "${GREEN}Nginx service is reloaded ${NC}\n" || printf "${RED}Error : can't reload Nginx ${NC}\n"
  pgrep -fl nginx | grep -v stunnel 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: Nginx doesn't load the host ${TECHNAME}${NC}\n"
    exit 1
  else
    printf "${GREEN}Nginx loads the new host${NC}\n"
  fi
  systemctl status nginx | grep running 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: Nginx is not running${NC}\n"
    exit 1
  else
    printf "${GREEN}Nginx is running${NC}\n"
  fi
}

function copyTemplate {
  envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < ${WORKDIR}/scripts/template/index.php > ${SERVERDIR}/${DOMAIN}/${SUB}/webroot/index.php
  printf "${GREEN}Template file is set up ${NC}\n"
}

function updatePermissions {
  chown -R nginx:nginx ${SERVERDIR}/${DOMAIN}/${SUB}/webroot/
}
function pushToGithub {
  git add ${WORKDIR}/nginx/sites-available/${TECHNAME}.conf && printf "${GREEN}Changes to are added ${NC}\n" || printf "${RED}Error : can't add files to git ${NC}"
  git add ${WORKDIR}/nginx/sites-enabled/${TECHNAME}.conf && printf "${GREEN}Changes to are added ${NC}\n" || printf "${RED}Error : can't add files to git ${NC}"
  git add ${WORKDIR}/php-fpm.d/${TECHNAME}.conf && printf "${GREEN}Changes to are added ${NC}\n" || printf "${RED}Error : can't add files to git ${NC}"
  git commit -q -m "[host] Add new site: ${SUB}.${DOMAIN}" && printf "${GREEN}All changes are committed ${NC}\n" || printf "${RED}Error : can't commit ${NC}"
  git push -q && printf "${GREEN}All changes are push to GitHub ${NC}\n" || printf "${RED}Error : can't push to GitHub ${NC}"
}

function testDb {
  cat ${WORKDIR}/conf/site.conf | grep ${SUB}.${DOMAIN} 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${YELLOW}[info] Db: The database doesn't exist.\Maybe you could run ${WORKDIR}/scripts/db_create.sh ${DOMAIN} ${SUB}${NC}\n"
    exit 1
  fi
}

if [[ -n $1 && -n $2 ]]
then
  DOMAIN=$1
  DOMAIN_STRIP=$(echo $1 | tr -d '.')
  SUB=$2
  DOMSHORT=${DOMAIN::3}${SUB::1}
  TECHNAME=${DOMAIN_STRIP}_${SUB}
  
  export DOMAIN SUB DOMSHORT TECHNAME
  testExists
  printf "${PURPLE} # Directories${NC}\n"
  generateDirs
  printf "${PURPLE} # Php Fpm${NC}\n"
  generatePhpFpmConf
  testServerPhpFpm
  reloadServerPhpFpm
  printf "${PURPLE} # Nginx${NC}\n"
  generateNginxConf
  testServerNginx
  reloadServerNginx
  printf "${PURPLE} # File and permissions${NC}\n"
  copyTemplate
  updatePermissions
  printf "${PURPLE} # GitHub${NC}\n"
  pushToGithub
  printf "${PURPLE} # Info${NC}\n"
  testDb
  printf "${NC}You can add these records:\n"
  #TODO: Add directly to Route53
  printf "adm${DOMSHORT}.${SUB} 3600s A YOUR_SERVER_IP >> ${DOMAIN}\n"
  printf "Your new site is accessible here:\n"
  printf "http://adm${DOMSHORT}.${SUB}.${DOMAIN}\n"
  printf "${GREEN}Well done!${NC}\n"
  exit 0
else
  printf "${RED}[err] Syntax: ${0} dom.tld subdom${NC}\n"
  exit 1
fi