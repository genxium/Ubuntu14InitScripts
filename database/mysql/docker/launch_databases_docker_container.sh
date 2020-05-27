#!/bin/bash

basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# docker pull mysql:5.7
# docker volume create shared_mysql_datadir_base_1
# Can test by a mysql-client on the HostOS, e.g. "mysql --host <ip of HostOS> --port 3307 -uroot". 
mysqlContainerId1=$(docker run -d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -p :3307:3306 --mount 'type=volume,src=shared_mysql_datadir_base_1,dst=/var/lib/mysql' mysql:5.7) 
docker cp $basedir/etc-mysql-confs/mysql.conf.d/mysqld-1.cnf $mysqlContainerId1:/etc/mysql/mysql.conf.d/mysqld.cnf 
docker container restart $mysqlContainerId1

# docker volume create shared_mysql_datadir_base_2
# Can test by a mysql-client on the HostOS, e.g. "mysql --host <ip of HostOS> --port 3308 -uroot". 
mysqlContainerId2=$(docker run -d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -p :3308:3306 --mount 'type=volume,src=shared_mysql_datadir_base_2,dst=/var/lib/mysql' mysql:5.7)
docker cp $basedir/etc-mysql-confs/mysql.conf.d/mysqld-2.cnf $mysqlContainerId2:/etc/mysql/mysql.conf.d/mysqld.cnf 
docker container restart $mysqlContainerId2
