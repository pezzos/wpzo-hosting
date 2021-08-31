#!/bin/bash
mysqlserver=127.0.0.1
RED='\033[31m'
GREEN='\033[32m'
NC='\033[0;39m' # No Color

function readPass {
  echo -n "MariaDB root pass:" 
  read -s mysqlpass
}
function generateUser {
  user=$(echo $1 | tr -d '-' | tr -d '.' | cut -c -13)$(echo $2 | cut -c -2) && printf "${GREEN}Username generated ${NC}\n" || printf "${RED}[err] Can't generate username ${NC}\n"
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
  /usr/bin/mysql -u root -h $mysqlserver --password=${mysqlpass} -e "GRANT ALL PRIVILEGES ON $user.* TO '$user'@'%' IDENTIFIED BY '$pass';"
  [ $? == 0 ] && printf "${GREEN}Database privileges granted to $user on $mysqlserver ${NC}\n" || printf "${RED}Error : can't grant privileges to $user on $mysqlserver ${NC}\n"
  /usr/bin/mysql -u root -h $mysqlserver --password=${mysqlpass} -e "FLUSH PRIVILEGES;"
  [ $? == 0 ] && printf "${GREEN}Database privileges flushed on $mysqlserver ${NC}\n" || printf "${RED}Error : can't flush privileges on $mysqlserver ${NC}\n"
}
function saveInfo {
  mkdir -p /pezzos/servers/${1}/${2}/conf/
  date=$(date +%Y%m%d-%H%M)
  file="/pezzos/servers/${1}/${2}/conf/${date}-${user}"
  touch $file
  echo "${user}:${pass}" > $file
  echo "${2}.${1}:${user}:${pass}" >> /pezzos/work/conf/db.conf
  [ $? == 0 ] && printf "${GREEN}Database info saved${NC}\n" || printf "${RED}Error : can't save database info${NC}\n"
}

function reloadServer {
  /usr/bin/mysqladmin -u root -h $mysqlserver --password=${mysqlpass} reload
  [ $? == 0 ] && printf "${GREEN}MySQL reloaded on $mysqlserver ${NC}\n" || printf "${RED}Error : can't reload MySQL on $mysqlserver ${NC}\n"
}

if [[ -n $1 && -n $2 ]]
then
  readPass
  printf "${NC}Generate user name from domain${NC}\n"
  generateUser $1 $2
  printf "${NC}Generate pass for ${user}\n"
  generatePass
  printf "${NC}Check if user exists${NC}\n"
  checkDB
  [ $? == 1 ] && exit 1
  printf "${NC}Add MySQL User${NC}\n"
  addUser $1 $2 
  printf "${NC}Save info to file${NC}\n"
  saveInfo $1 $2
  printf "${NC}Reload server${NC}\n"
  reloadServer
  exit 0
else
  printf "${RED}[err] Syntax: ${0} dom.tld subdom${NC}\n"
  exit 1
fi
