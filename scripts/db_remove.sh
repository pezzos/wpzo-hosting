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
  printf "MariaDB root pass:\n"
  read -s mysqlpass
}
function generateUser {
  user=$(echo ${DOMAIN} | tr -d '-' | tr -d '.' | cut -c -13)$(echo ${SUB} | cut -c -2) && printf "${GREEN}Username generated ${NC}\n" || printf "${RED}[err] Can't generate username ${NC}\n"
}

function checkDB {
  dbTestUser=`/usr/bin/mysqlshow -u root -h $mysqlserver --password=${mysqlpass} | cut -f2 -d' ' | grep $user`
  if [ $? == 0 ]
  then
    printf "${GREEN}User exists ${NC}\n"
  else
    printf "${RED}[err] User doesn't exist ${NC}\n"
    exit 1
  fi
}

function deleteUser {
  /usr/bin/mysql -u root -h $mysqlserver --password=${mysqlpass} -e "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '$user'@'%';"
  [ $? == 0 ] && printf "${GREEN}Database privileges revoked for $user on $mysqlserver ${NC}\n" || printf "${RED}Error : can't revoke privileges to $user on $mysqlserver ${NC}\n"
  /usr/bin/mysql -u root -h $mysqlserver --password=${mysqlpass} -e "DROP USER '$user'@'%';"
  [ $? == 0 ] && printf "${GREEN}User $user droped on $mysqlserver ${NC}\n" || printf "${RED}Error : can't drop user $user on $mysqlserver ${NC}\n"
  /usr/bin/mysql -u root -h $mysqlserver --password=${mysqlpass} -e "DROP DATABASE $user;"
  [ $? == 0 ] && printf "${GREEN}Database $user droped on $mysqlserver ${NC}\n" || printf "${RED}Error : can't drop database $user on $mysqlserver ${NC}\n"
  /usr/bin/mysql -u root -h $mysqlserver --password=${mysqlpass} -e "FLUSH PRIVILEGES;"
  [ $? == 0 ] && printf "${GREEN}Database privileges flushed on $mysqlserver ${NC}\n" || printf "${RED}Error : can't flush privileges on $mysqlserver ${NC}\n"
}
function removeInfo {
  rm -f /path/to/servers/${DOMAIN}/${SUB}/conf/*-${user}
  [ $? == 0 ] && printf "${GREEN}Database info removed${NC}\n" || printf "${RED}Error : can't remove database info${NC}\n"
  sed -i "/${SUB}.${DOMAIN}/d" /path/to/work/conf/site.conf
  [ $? == 0 ] && printf "${GREEN}Database info removed${NC}\n" || printf "${RED}Error : can't remove database info${NC}\n"
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
  printf "${PURPLE} # Check if user exists${NC}\n"
  checkDB
  printf "${PURPLE} # Add MySQL User${NC}\n"
  deleteUser
  printf "${PURPLE} # Remove info from file${NC}\n"
  removeInfo
  printf "${PURPLE} # Reload server${NC}\n"
  reloadServer
  exit 0
else
  printf "${RED}[err] Syntax: ${0} dom.tld subdom${NC}\n"
  exit 1
fi
