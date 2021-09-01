#!/bin/bash
RED='\033[31m'
GREEN='\033[32m'
NC='\033[0;39m' # No Color

function generateDirs {
  mkdir -p /pezzos/servers/${DOMAIN}/${SUB}/conf/
  mkdir -p /pezzos/servers/${DOMAIN}/${SUB}/web/
  mkdir -p /pezzos/servers/${DOMAIN}/${SUB}/php/
}

function generatePhpFpmConf {
  envsubst < ../php-fpm.d/conf.template > ../php-fpm.d/${TECHNAME}.conf
  # envsubst < /pezzos/work/php-fpm.d/conf.template > /pezzos/work/php-fpm.d/${TECHNAME}.conf
}

function reloadServerPhpFpm {
  systemctl reload php-fpm.service
  ps aux | grep php-fpm | grep -v grep | grep -v efs  | grep ${TECHNAME} 2&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: PHP FPM doesn't load the new pool ${TECHNAME}${NC}\n"
    exit 1
  fi
  systemctl status php-fpm | grep running 2&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: PHP FPM is not running${NC}\n"
    exit 1
  fi
}

function testServerPhpFpm {
  php-fpm -tt |& grep "configuration file /etc/php-fpm.conf test is successful" 2&1>/dev/null
  if [ $? == 1 ]
  then
    printf "${RED}[err] Test: PHP FPM configuration is broken${NC}\n"
    exit 1
  fi
}

if [[ -n $1 && -n $2 ]]
then
  DOMAIN=$1
  DOMAIN_STRIP=$(echo $1 | tr -d '.')
  SUB=$2
  TECHNAME=${DOMAIN_STRIP}_${SUB}

  export DOMAIN SUB TECHNAME
  # readPass
  printf "${NC}Generate directory structure${NC}\n"
  # generateDirs
    printf "${NC}Generate php fpm configuration${NC}\n"
  # generatePhpFpmConf
  testServerPhpFpm
  reloadServerPhpFpm
  testServerPhpFpm


  # [ $? == 1 ] && exit 1
  exit 0
else
  printf "${RED}[err] Syntax: ${0} dom.tld subdom${NC}\n"
  exit 1
fi

# create host nginx
# r
# create logs
# composer wordpress
# git add -u
# git commit -m "Add new site: ${SUB}.${DOMAIN}"
# git push