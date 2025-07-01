#!/bin/bash
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
PURPLE='\033[35m'
NC='\033[0;39m' # No Color
SERVERDIR="/path/to/servers"
WORKDIR="/path/to/work"

#TODO: git pull

function testExists {
  if [ -d ${SERVERDIR}/${DOMAIN}/${SUB} ]; then
    printf "${GREEN}This host exists${NC}\n"
  else
    printf "${RED}This host doesn't exist${NC}\n"
    exit 1
  fi
}

function removeDirs {
  rm -rf ${SERVERDIR}/${DOMAIN}/${SUB}/conf/
  rm -rf ${SERVERDIR}/${DOMAIN}/${SUB}/webroot/
  rm -rf ${SERVERDIR}/${DOMAIN}/${SUB}/php/
  printf "${GREEN}Directories structure is removed${NC}\n"
  if [ -z "$(ls -A ${SERVERDIR}/${DOMAIN}/${SUB})" ]; then
    rm -rf ${SERVERDIR}/${DOMAIN}/${SUB}
    printf "${GREEN}Subdomain dir is removed${NC}\n"
    if [ -z "$(ls -A ${SERVERDIR}/${DOMAIN})" ]; then
      rm -rf ${SERVERDIR}/${DOMAIN}
      printf "${GREEN}Domain dir is removed${NC}\n"
    else
      printf "${YELLOW}[info] ${SERVERDIR}/${DOMAIN} is not empty${NC}\n"
    fi
  else
    printf "${RED}[err] ${SERVERDIR}/${DOMAIN}/${SUB} is not empty${NC}\n"
  fi
  
  printf "${GREEN}Directories structure is made${NC}\n"
}

function removePhpFpmConf {
  rm -f ${WORKDIR}/php-fpm.d/${TECHNAME}.conf
  printf "${GREEN}Php Fpm configuration is removed${NC}\n"
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
  systemctl reload php-fpm.service && printf "${GREEN}Php Fpm service is restarted ${NC}\n" || printf "${RED}Error : can't restart Php Fpm ${NC}\n"
  pgrep -fl "$TECHNAME" 2>&1>/dev/null
  if [ $? == 0 ]
  then
    printf "${RED}[err] Test: Php Fpm seems to still have the pool ${TECHNAME}${NC}\n"
    exit 1
  else
    printf "${GREEN}Php Fpm pool is removed${NC}\n"
  fi
  systemctl status php-fpm | grep running 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: Php Fpm is not running${NC}\n"
    exit 1
  else
    printf "${GREEN}Php Fpm is still running${NC}\n"
  fi
}

function removeNginxConf {
  rm -f ${WORKDIR}/nginx/sites-available/${TECHNAME}.conf
  rm -f ${WORKDIR}/nginx/sites-enabled/${TECHNAME}.conf
  printf "${GREEN}Nginx configuration is removed${NC}\n"
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
  systemctl reload nginx.service && printf "${GREEN}Nginx service is reloaded ${NC}\n" || printf "${RED}Error : can't reload Nginx ${NC}\n"
  pgrep -fl nginx | grep -v stunnel 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: Nginx doesn't unload the host ${TECHNAME}${NC}\n"
    exit 1
  else
    printf "${GREEN}Nginx remove the host${NC}\n"
  fi
  systemctl status nginx | grep running 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: Nginx is not running${NC}\n"
    exit 1
  else
    printf "${GREEN}Nginx is still running${NC}\n"
  fi
}

function pushToGithub {
  git rm -q ${WORKDIR}/nginx/sites-available/${TECHNAME}.conf && printf "${GREEN}Changes to are removed ${NC}\n" || printf "${RED}Error : can't remove files to git ${NC}"
  git rm -q ${WORKDIR}/nginx/sites-enabled/${TECHNAME}.conf && printf "${GREEN}Changes to are removed ${NC}\n" || printf "${RED}Error : can't remove files to git ${NC}"
  git rm -q ${WORKDIR}/php-fpm.d/${TECHNAME}.conf && printf "${GREEN}Changes to are removed ${NC}\n" || printf "${RED}Error : can't remove files to git ${NC}"
  git commit -q -m "[host] Remove site: ${SUB}.${DOMAIN}" && printf "${GREEN}All changes are committed ${NC}\n" || printf "${RED}Error : can't commit ${NC}"
  git push -q && printf "${GREEN}All changes are push to GitHub ${NC}\n" || printf "${RED}Error : can't push to GitHub ${NC}"
}

if [[ -n $1 && -n $2 ]]
then
  DOMAIN=$1
  DOMAIN_STRIP=$(echo $1 | tr -d '.')
  SUB=$2
  TECHNAME=${DOMAIN_STRIP}_${SUB}
  
  export DOMAIN SUB TECHNAME
  testExists
  #TODO: Ask for confirmation
  printf "${PURPLE} # Directories${NC}\n"
  removeDirs
  printf "${PURPLE} # Php Fpm${NC}\n"
  removePhpFpmConf
  testServerPhpFpm
  reloadServerPhpFpm
  printf "${PURPLE} # Nginx${NC}\n"
  removeNginxConf
  testServerNginx
  reloadServerNginx
  printf "${PURPLE} # GitHub${NC}\n"
  pushToGithub
  printf "${PURPLE} # Info${NC}\n"
  printf "You can remove these records:\n"
  #TODO: Remove directly to Route53
  printf "adm${DOMSHORT}.${SUB} 3600s A YOUR_SERVER_IP  >> ${DOMAIN}\n"
  printf "${GREEN}Well done!${NC}\n"
  exit 0
else
  printf "${RED}[err] Syntax: ${0} dom.tld subdom${NC}\n"
  exit 1
fi