#!/bin/bash

basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
if [ $# -ne 1 ]; then 
  echo "Usage: $0 <UnifiedHostname>"
  exit 1
fi

unifiedHostname=$1

# docker pull mysql:5.7
####
# ```
# When you start the MySQL Docker container, you can pass configuration options to the server through the docker run command. For example:". 
# -- reference https://dev.mysql.com/doc/refman/5.7/en/docker-mysql-more-topics.html#docker-configuring-server 
# ```
commonMysqldOptions="--gtid-mode=ON --enforce-gtid-consistency=ON --binlog-checksum=NONE --log-bin --log-slave-updates=ON --master-info-repository=TABLE --relay-log-info-repository=TABLE --transaction-write-set-extraction=XXHASH64 --report-host=$unifiedHostname"

commonDockerContainerEnvs="-e MYSQL_ROOT_HOST=% -e MYSQL_ALLOW_EMPTY_PASSWORD=yes"

# docker volume create shared_mysql_datadir_base_1
# Can test by a mysql-client on the HostOS, e.g. "mysql --host <ip of HostOS> --port 3307 -uroot". 
port1OnHostOS=3307
portOnContainer1=3307 
# To verify "portOnContainer<X>", try 
# ```
# docker exec <DockerContainerId> mysql -e "SHOW GLOBAL VARIABLES LIKE 'PORT';"
# ``` 
cmd1="docker run $commonDockerContainerEnvs -d -p :$port1OnHostOS:$portOnContainer1 --mount 'type=volume,src=shared_mysql_datadir_base_1,dst=/var/lib/mysql' mysql:5.7 --server-id=1 --report-port=$port1OnHostOS --port=$portOnContainer1 $commonMysqldOptions"
echo $cmd1
#eval $cmd1

# docker volume create shared_mysql_datadir_base_2
# Can test by a mysql-client on the HostOS, e.g. "mysql --host <ip of HostOS> --port 3308 -uroot". 
port2OnHostOS=3308
portOnContainer2=3308
cmd2="docker run -d $commonDockerContainerEnvs -p :$port2OnHostOS:$portOnContainer2 --mount 'type=volume,src=shared_mysql_datadir_base_2,dst=/var/lib/mysql' mysql:5.7 --server-id=2 --report-port=$port2OnHostOS --port=$portOnContainer2 $commonMysqldOptions"
echo $cmd2
#eval $cmd2

################
# Exemplifying the configuration.
#
# We'd like to have `mysqlsh> dba.configureInstance("root@192.168.56.102:3307")` to report 
# ```
# This instance reports its own address as 192.168.56.102:3307
# ```
# which is an ACCESSIBLE ADDR for the "mysqlclient on `192.168.56.102:3308` a.k.a. the other `DockerContainer`" due to "overlaying", where
# - "192.168.56.102" is the "ipaddr of an `NetworkIface` other than `docker0` or `docker-gwbridge` on the `DockerHostOS`", 
# - ":3307" and "::3308" are used by 2 different "DockerContainer"s on that "DockerHostOS".  
#
# In this case, your "ipaddr of `NetworkIface`==`docker0` on the `DockerHostOS`" might be "172.17.0.1" and that the 2 different "DockerContainer"s possess "172.17.0.3" & "172.17.0.4" respectively. The communication between "DockerContainer"s MIGHT NOT go via this `NetworkIface`==`docker0`(except that it's the default route for destination=="192.168.56.102" in certain cases). 
################

################
# An alternative "--report-host" configuration.
#
# If "mysqld --report-host=<DockerContainerId>" were used, a "<DockerContainerId>" would be resolved to "172.17.0.3" or "172.17.0.4" by the "mysqld" process on each respective "<DockerContainer>", check
# ```
# docker logs -f <DockerContainerId>" 
# ```
# upon calling
# ```
# mysqlsh> dba.createCluster(...)
# ```
# for verification if such "--report-host" were expected.
###############
