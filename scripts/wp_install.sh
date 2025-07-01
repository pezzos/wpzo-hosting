#!/bin/bash
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
PURPLE='\033[35m'
NC='\033[0;39m' # No Color
SERVERDIR="/path/to/servers"
WORKDIR="/path/to/work"

function readPass {
  printf "WP admin pass:\n"
  read -s wppass
}

function testHost {
  if [ -d /path/to/servers/${DOMAIN}/${SUB}/webroot ]; then
    printf "${GREEN}Host is installed${NC}\n"
  else
    printf "${RED}[err] Host is not installed${NC}\n"
    exit 1
  fi
  
  cat /path/to/servers/${DOMAIN}/${SUB}/webroot/index.php | grep "Welcome to ${SUB}.${DOMAIN}" 2>&1>/dev/null
  if [ $? == 0 ]
  then
    rm /path/to/servers/${DOMAIN}/${SUB}/webroot/index.php
    printf "${YELLOW}[info] Default index.php was present, it is now removed${NC}\n"
  fi
  
  if [ -z "$(ls -A /path/to/servers/${DOMAIN}/${SUB}/webroot)" ]; then
    printf "${GREEN}Webdir is empty${NC}\n"
  else
    printf "${RED}[err] Not empty: /path/to/servers/${DOMAIN}/${SUB}/webroot ${NC}\n"
    #TODO: if only index.php, offer to remove it
    exit 1
  fi
}

function testDb {
  cat ${WORKDIR}/conf/site.conf | grep ${SUB}.${DOMAIN} 2>&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Db: The database doesn't exist.\nPlease run ${WORKDIR}/scripts/db_create.sh ${DOMAIN} ${SUB}${NC}\n"
    exit 1
  fi
}

function installBoilerplate {
  composer create-project roots/bedrock -d /path/to/servers/${DOMAIN}/${SUB}/webroot/
}

function removeUselessFiles {
  rm /path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/.env.example
  rm /path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/license.txt
  rm /path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/readme.html
  printf "${GREEN}Useless files are removed${NC}\n"
}

function generateEnv {
  envsubst < ${WORKDIR}/scripts/template/env.php > /path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/.env
  printf "${GREEN}index.php is generated${NC}\n"
}

function updateNginx {
  sed -E -i "s/(root.*)webroot;/\1webroot\/bedrock\/web;/g" ${WORKDIR}/nginx/sites-available/${TECHNAME}.conf
  sed -E -i "s/#<WP>//g" ${WORKDIR}/nginx/sites-available/${TECHNAME}.conf
  printf "${GREEN}Nginx conf is updated${NC}\n"
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

function initWp {
  /usr/local/bin/wp core install --url=adm${DOMSHORT}.${SUB}.${DOMAIN} --title=${SUB}.${DOMAIN} --admin_user=admin --admin_password=${wppass} --admin_email=admin@example.com --quiet --path=/path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/
}

# function installComposerPlugin {
#   composer require grrr-amsterdam/simply-static-deploy -d /path/to/servers/${DOMAIN}/${SUB}/webroot/ && printf "${GREEN}simply-static-deploy is installed${NC}\n" || printf "${RED}Error : can't install simply-static-deploy${NC}\n"
# }

function installWpPlugin {
  /usr/local/bin/wp plugin install simply-static --activate --quiet --path=/path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/ && printf "${GREEN}simply-static is installed${NC}\n" || printf "${RED}Error : can't install simply-static${NC}\n"
  /usr/local/bin/wp plugin install wordpress-seo --activate --quiet --path=/path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/ && printf "${GREEN}wordpress-seoc is installed${NC}\n" || printf "${RED}Error : can't install wordpress-seoc${NC}\n"
  /usr/local/bin/wp plugin install redirection --quiet --path=/path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/ && printf "${GREEN}redirection is installed${NC}\n" || printf "${RED}Error : can't install redirection${NC}\n"
  /usr/local/bin/wp plugin install wp-super-cache --quiet --path=/path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/ && printf "${GREEN}wp-super-cache is installed${NC}\n" || printf "${RED}Error : can't install wp-super-cache${NC}\n"
  /usr/local/bin/wp plugin install wps-bidouille --quiet --path=/path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/ && printf "${GREEN}wps-bidouille is installed${NC}\n" || printf "${RED}Error : can't install wps-bidouille${NC}\n"
  /usr/local/bin/wp plugin install contact-form-7 --activate --quiet --path=/path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/ && printf "${GREEN}contact-form-7 is installed${NC}\n" || printf "${RED}Error : can't install contact-form-7${NC}\n"
  /usr/local/bin/wp plugin install imagify --quiet --path=/path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/ && printf "${GREEN}imagify is installed${NC}\n" || printf "${RED}Error : can't install imagify${NC}\n"
  /usr/local/bin/wp plugin install elementor --quiet --path=/path/to/servers/${DOMAIN}/${SUB}/webroot/bedrock/web/wp/ && printf "${GREEN}elementor is installed${NC}\n" || printf "${RED}Error : can't install elementor${NC}\n"
}

function updatePermissions {
  chown -R nginx:nginx /path/to/servers/${DOMAIN}/${SUB}/webroot/
  #TODO: chmod on files and dirs
  printf "${GREEN}Permissions are updated${NC}\n"
}

#TODO: update plugin
#TODO: update theme
#TODO: remove first comment, first article
#TODO: remove unused menu items

if [[ -n $1 && -n $2 ]]
then
  DOMAIN=$1
  DOMAIN_STRIP=$(echo $1 | tr -d '.')
  SUB=$2
  DOMSHORT=${DOMAIN::3}${SUB::1}
  TECHNAME=${DOMAIN_STRIP}_${SUB}
  DBNAME=$(cat ${WORKDIR}/conf/site.conf | grep ${SUB}.${DOMAIN} | cut -f2 -d:)
  DBPASS=$(cat ${WORKDIR}/conf/site.conf | grep ${SUB}.${DOMAIN} | cut -f3 -d:)
  SALT=$(curl -s -L https://api.wordpress.org/secret-key/1.1/salt/ | sed "s/define('//g" | sed "s/',[[:blank:]]*/=/g" | sed "s/);//g")
  
  export DOMAIN SUB DOMSHORT TECHNAME DBNAME DBPASS SALT
  printf "${PURPLE} # Host and db test${NC}\n"
  testHost
  testDb
  readPass
  printf "${PURPLE} # Install the boilerplate${NC}\n"
  installBoilerplate
  removeUselessFiles
  generateEnv
  printf "${PURPLE} # Update Nginx conf${NC}\n"
  updateNginx
  testServerNginx
  reloadServerNginx
  printf "${PURPLE} # Initialize WP${NC}\n"
  initWp
  printf "${PURPLE} # Install the wp plugins${NC}\n"
  installComposerPlugin
  installWpPlugin
  printf "${PURPLE} # Update permissions${NC}\n"
  updatePermissions
  printf "${PURPLE} # Info${NC}\n"
  printf "Your new WP is accessible here:\n"
  printf "http://adm${DOMSHORT}.${SUB}.${DOMAIN}\n"
  printf "${GREEN}Well done!${NC}\n"
  exit 0
else
  printf "${RED}[err] Syntax: ${0} dom.tld subdom${NC}\n"
  exit 1
fi



