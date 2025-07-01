#!/bin/bash
mysqlserver=YOUR_DB_SERVER_IP
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
PURPLE='\033[35m'
NC='\033[0;39m' # No Color
SERVERDIR="/path/to/servers"
WORKDIR="/path/to/work"

function readPass {
  echo -n "MariaDB root pass:"
  read -s mysqlpass
}
function generateUser {
  user=$(echo ${DOMAIN} | tr -d '-' | tr -d '.' | cut -c -13)$(echo ${SUB} | cut -c -2) && printf "${GREEN}Username generated ${NC}\n" || printf "${RED}[err] Can't generate username ${NC}\n"
}
function generatePass {
  pass=`date +%s | sha256sum | base64 | head -c 16 ; echo` && printf "${GREEN}Pass generated ${NC}\n" || printf "${RED}[err] Can't generate pass${NC}\n"
}
function checkDB {
  dbTestUser=`/usr/bin/mysqlshow -u root -h $mysqlserver --password=${mysqlpass} | cut -f2 -d' ' | grep $user`
  if [ $? == 1 ]
  then
    printf "${GREEN}Ok, user doesn't exist ${NC}\n"
    return 0
  else
    printf "${RED}[err] User already exists ${NC}\n"
    return 1
  fi
}
function addUser {
  /usr/bin/mysql -u root -h $mysqlserver --password=${mysqlpass} -e "CREATE DATABASE $user;"
  [ $? == 0 ] && printf "${GREEN}Database $user created on $mysqlserver ${NC}\n" || printf "${RED}Error : can't create database $user on $mysqlserver ${NC}\n"
  /usr/bin/mysql -u root -h $mysqlserver --password=${mysqlpass} -e "CREATE USER '$user'@'%' IDENTIFIED BY '$pass';"
  [ $? == 0 ] && printf "${GREEN}User $user created on $mysqlserver ${NC}\n" || printf "${RED}Error : can't create user $user on $mysqlserver ${NC}\n"
  /usr/bin/mysql -u root -h $mysqlserver --password=${mysqlpass} -e "GRANT ALL PRIVILEGES ON $user.* TO '$user'@'%';"
  [ $? == 0 ] && printf "${GREEN}Database privileges granted to $user on $mysqlserver ${NC}\n" || printf "${RED}Error : can't grant privileges to $user on $mysqlserver ${NC}\n"
  /usr/bin/mysql -u root -h $mysqlserver --password=${mysqlpass} -e "FLUSH PRIVILEGES;"
  [ $? == 0 ] && printf "${GREEN}Database privileges flushed on $mysqlserver ${NC}\n" || printf "${RED}Error : can't flush privileges on $mysqlserver ${NC}\n"
}
function saveInfo {
  mkdir -p /path/to/servers/${DOMAIN}/${SUB}/conf/
  date=$(date +%Y%m%d-%H%M)
  file="/path/to/servers/${DOMAIN}/${SUB}/conf/${date}-${user}"
  touch $file
  echo "${user}:${pass}" > $file
  mkdir -p /path/to/work/conf
  echo "${SUB}.${DOMAIN}:${user}:${pass}" >> /path/to/work/conf/site.conf
  [ $? == 0 ] && printf "${GREEN}Database info saved${NC}\n" || printf "${RED}Error : can't save database info${NC}\n"
}

function reloadServer {
  /usr/bin/mysqladmin -u root -h $mysqlserver --password=${mysqlpass} reload
  [ $? == 0 ] && printf "${GREEN}MySQL reloaded on $mysqlserver ${NC}\n" || printf "${RED}Error : can't reload MySQL on $mysqlserver ${NC}\n"
}

if [[ -n $1 && -n $2 ]]
then
  DOMAIN=$1
  DOMAIN_STRIP=$(echo ${DOMAIN} | tr -d '.')
  SUB=$2
  DOMSHORT=${DOMAIN::3}${SUB::1}
  TECHNAME=${DOMAIN_STRIP}_${SUB}
  
  export DOMAIN SUB DOMSHORT TECHNAME
  
  readPass
  printf "${PURPLE} # Generate user name from domain${NC}\n"
  generateUser
  printf "${PURPLE} # Generate pass for ${user}\n"
  generatePass
  printf "${PURPLE} # Check if user exists${NC}\n"
  checkDB
  [ $? == 1 ] && exit 1
  printf "${PURPLE} # Add MySQL User${NC}\n"
  addUser
  printf "${PURPLE} # Save info to file${NC}\n"
  saveInfo
  printf "${PURPLE} # Reload server${NC}\n"
  reloadServer
  exit 0
else
  printf "${RED}[err] Syntax: ${0} dom.tld subdom${NC}\n"
  exit 1
fi
