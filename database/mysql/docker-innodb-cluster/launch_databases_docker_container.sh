#!/bin/bash

basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
if [ $# -ne 1 ]; then 
  echo "Usage: $0 <UnifiedHostname>"
  exit 1
fi

unifiedHostname=$1
mysqldVersion=8.0 # Deliberately using 8.0+ instead of 5.7- here, because since 8.0+ the mysqld comes with a "MySQL Clone Plugin(https://dev.mysql.com/doc/refman/8.0/en/clone-plugin.html)" which together with "mysqlsh" significantly simplifies "Group Replication" configuring. See "README" for an example sequence of commands on "mysqlsh".  

# docker pull mysql:$mysqldVersion
####
# ```
# When you start the MySQL Docker container, you can pass configuration options to the server through the docker run command. For example:". 
# -- reference https://dev.mysql.com/doc/refman/5.7/en/docker-mysql-more-topics.html#docker-configuring-server 
# ```
####

####
# References for what mysqld options to add for "MySQL Group Replication" https://dev.mysql.com/doc/refman/5.7/en/group-replication-configuring-instances.html#group-replication-configure-replication-framework.

# Note that all command-line-args used below have its "MySQL Options File", see the MySQL doc for correspondence.
####

# GTID Reference https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/mysql-replication-gtid.html, we're deliberately disabling binlog on slave side.
commonMysqldOptions="--read-only=off --gtid-mode=OFF --enforce-gtid-consistency=OFF --master-info-repository=TABLE" 

# 1. Fix the binlog file name prefix to "MASTER"
masterOptions="--log-bin-index-=MASTER --log-bin=MASTER --binlog-format=MIXED --binlog-checksum=NONE --transaction-write-set-extraction=XXHASH64" # We need only "relay-log" on the slave side, no "slave side binlog" is necessary

# 1. Fix the relay-binlog file name prefix to "SLAVE"
slaveOptions="--relay-log-index=SLAVE --relay-log=SLAVE --relay-log-info-repository=TABLE --relay-log-recovery=ON --skip-slave-start" # According to "https://dev.mysql.com/doc/refman/5.7/en/replication-solutions-unexpected-replica-halt.html", "his setting ignores the existing relay log files, in case they are corrupted or inconsistent. The relay log recovery process starts a new relay log file and fetches transactions from the source beginning at the replication SQL thread position recorded in the applier metadata repository", where the "applier metadata repository" is hereby set to `table mysql.slave_relay_log_info` 

commonDockerContainerEnvs="-e MYSQL_ROOT_HOST=% -e MYSQL_ALLOW_EMPTY_PASSWORD=yes"

# docker volume create shared_mysql_datadir_base_1
# Can test by a mysql-client on the HostOS, e.g. "mysql --host <ip of HostOS> --port 3307 -uroot". 
port1OnHostOS=3307
portOnContainer1=3307 
# To verify "portOnContainer<X>", try 
# ```
# docker exec <DockerContainerId> mysql -e "SHOW GLOBAL VARIABLES LIKE 'PORT';"
# ``` 
cmd1="docker run $commonDockerContainerEnvs -d -p $unifiedHostname:$port1OnHostOS:$portOnContainer1 --mount 'type=volume,src=shared_mysql_datadir_base_1,dst=/var/lib/mysql' mysql:$mysqldVersion --server-id=1 --port=$portOnContainer1 $commonMysqldOptions $masterOptions"
echo $cmd1
#eval $cmd1

# docker volume create shared_mysql_datadir_base_2
# Can test by a mysql-client on the HostOS, e.g. "mysql --host <ip of HostOS> --port 3308 -uroot". 
port2OnHostOS=3308
portOnContainer2=3308
cmd2="docker run $commonDockerContainerEnvs -d -p $unifiedHostname:$port2OnHostOS:$portOnContainer2 --mount 'type=volume,src=shared_mysql_datadir_base_2,dst=/var/lib/mysql' mysql:$mysqldVersion --server-id=2 --port=$portOnContainer2 $commonMysqldOptions $slaveOptions"
echo $cmd2
#eval $cmd2
