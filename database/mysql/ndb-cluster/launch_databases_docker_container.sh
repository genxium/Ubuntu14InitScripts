#!/bin/bash

dockerNetworkName=ndb_cluster
mysqlClusterVersion=latest
dockerImageFullname=mysql/mysql-cluster:$mysqlClusterVersion

cmd1="docker network create $dockerNetworkName --subnet=192.168.0.0/16" 

# Note that the default "configuration file(s) for `ndb_mgmd` in $dockerImageFullname assumes that `ndb_mgmd` runs in a subnet 192.168.0.0/16 and will bind to 192.168.0.2". See https://github.com/mysql/mysql-docker/blob/mysql-cluster/7.6/cnf/mysql-cluster.cnf for details.

# The "datadir" of each "DockerContainer" is specified in https://github.com/mysql/mysql-docker/blob/mysql-cluster/7.6/cnf/mysql-cluster.cnf as well.
#docker volume create shared_mysql_cluster_mgmd_datadir
cmd2="docker run -d --net=$dockerNetworkName --name=management1 --mount 'type=volume,src=shared_mysql_cluster_mgmd_datadir,dst=/var/lib/mysql' --ip=192.168.0.2 $dockerImageFullname ndb_mgmd"

#docker volume create shared_mysql_cluster_ndbd_datadir_1
cmd3="docker run -d --net=$dockerNetworkName --name=ndb1 --mount 'type=volume,src=shared_mysql_cluster_ndbd_datadir_1,dst=/var/lib/mysql' --ip=192.168.0.3 $dockerImageFullname ndbd"
#docker volume create shared_mysql_cluster_ndbd_datadir_2
cmd4="docker run -d --net=$dockerNetworkName --name=ndb2 --mount 'type=volume,src=shared_mysql_cluster_ndbd_datadir_2,dst=/var/lib/mysql' --ip=192.168.0.4 $dockerImageFullname ndbd"

cmd5="docker run -e MYSQL_ROOT_HOST=% -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d --net=$dockerNetworkName --name=mysql1 --ip=192.168.0.10 $dockerImageFullname mysqld"

#####
# If some named "DockerContainer"s are exited, and should be removed->rerun with new parameters, try 
# ```
# docker container rm $(docker container ls -a | grep Exited | awk '{print $1}') 
# ```
# to clean up.
#####

echo $cmd1
echo $cmd2
echo $cmd3
echo $cmd4
echo $cmd5

cmd6="docker run -it --net=$dockerNetworkName mysql/mysql-cluster:$mysqlClusterVersion ndb_mgm"
printf "\nUse the following command to connect to ndb_mgmd...\n$cmd6\n\n"
