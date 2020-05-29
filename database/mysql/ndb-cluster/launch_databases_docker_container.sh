#!/bin/bash

dockerNetworkName=ndb_cluster
mysqlClusterVersion=8.0
dockerImageFullname=mysql/mysql-cluster:$mysqlClusterVersion

cmd1="docker network create $dockerNetworkName --subnet=192.168.0.0/16" 

# Note that the default "configuration file(s) for `ndb_mgmd` in $dockerImageFullname assumes that `ndb_mgmd` runs in a subnet 192.168.0.0/16 and will bind to 192.168.0.2". See https://github.com/mysql/mysql-docker/blob/mysql-cluster/8.0/cnf/mysql-cluster.cnf for details.
cmd2="docker run -d --net=$dockerNetworkName --name=management1 --ip=192.168.0.2 $dockerImageFullname ndb_mgmd"
cmd3="docker run -d --net=$dockerNetworkName --name=ndb1 --ip=192.168.0.3 $dockerImageFullname ndbd"
cmd4="docker run -d --net=$dockerNetworkName --name=ndb2 --ip=192.168.0.4 $dockerImageFullname ndbd"
cmd5="docker run -e MYSQL_ROOT_HOST=% -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d --net=$dockerNetworkName --name=mysql1 --ip=192.168.0.10 $dockerImageFullname mysqld"

echo $cmd1
echo $cmd2
echo $cmd3
echo $cmd4
echo $cmd5
