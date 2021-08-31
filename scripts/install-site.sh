#!/bin/bash

create host nginx
create php fpm pool
create dir domain/sub/www
create logs
composer wordpress

problem droit user db all table
CREATE USER 'pezzos'@'localhost' IDENTIFIED BY '69!!PezMar!!69';
GRANT ALL PRIVILEGES ON *.* TO 'pezzos'@'localhost' WITH GRANT OPTION;
CREATE USER 'pezzos'@'%' IDENTIFIED BY '69!!PezMar!!69';
GRANT ALL PRIVILEGES ON *.* TO 'pezzos'@'%' WITH GRANT OPTION;