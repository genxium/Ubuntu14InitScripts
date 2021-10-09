Exemplifying the configuration.

We'd like to have `mysqlsh> dba.configureInstance("root@192.168.56.102:3307")` to report 
```
This instance reports its own address as 192.168.56.102:3307
```
which is an ACCESSIBLE ADDR for the "mysqlclient on `192.168.56.102:3308` a.k.a. the other `DockerContainer`", where
- "192.168.56.102" is the "ipaddr of an `NetworkIface` other than `docker0` or `docker-gwbridge` on the `DockerHostOS`", 
- ":3307" and "::3308" are used by 2 different "DockerContainer"s on that "DockerHostOS".  

Moreover, The subnet "192.168.56.0/24" could be provided by 
```
"a `NetworkIface of Ubuntu within VirtualBox(in turn running on Windows), e.g. enp0s8` from the `Host-only adapter of VirtualBox`"
```
, and is a common accessible network for all
- "mysqlsh" process running on "Windows",
- both "DockerContainer"s of "mysqld" running on "Ubuntu within VirtualBox(in turn running on Windows)".

In this case, your "ipaddr of `NetworkIface`==`docker0` on the `DockerHostOS`" might be "172.17.0.1" and that the 2 different "DockerContainer"s possess "172.17.0.3" & "172.17.0.4" respectively. The communication between "DockerContainer"s MIGHT NOT go via this `NetworkIface`==`docker0`(except that it's the default route for destination=="192.168.56.102" in certain cases). 

```
Gitbash> mysqlsh
MySQL  JS > \connect --mysql root@192.168.56.102:3307
MySQL  192.168.56.102:3307 ssl  JS > dba.checkInstanceConfiguration()
MySQL  192.168.56.102:3307 ssl  JS > dba.dropMetadataSchema() // If a the current session was previously added to any cluster.
MySQL  192.168.56.102:3307 ssl  JS > dba.configureInstance()
MySQL  192.168.56.102:3307 ssl  JS > var mycluster = dba.createCluster('mycluster') 
# You might call "STOP SLAVE; RESET SLAVE" by the "mysqlclient on 192.168.56.102:3307" if "[ERROR] Slave SQL for channel 'group_replication_applier': Slave failed to initialize relay log info structure from the repository, Error_code: 1872" shows up spuriously. See https://github.com/vitessio/vitess/issues/5067 for a relevant discussion.

MySQL  192.168.56.102:3307 ssl  JS > mycluster.setupAdminAccount('myclusterAdmin')
MySQL  192.168.56.102:3307 ssl  JS > \connect myclusterAdmin@192.168.56.102:3307

MySQL  192.168.56.102:3307 ssl  JS > dba.configureInstance("root@192.168.56.102:3308")
MySQL  192.168.56.102:3307 ssl  JS > mycluster.checkInstanceState("root@192.168.56.102:3308")
MySQL  192.168.56.102:3307 ssl  JS > mycluster.addInstance("root@192.168.56.102:3308")
```

## An alternative "--report-host" configuration.

If "mysqld --report-host=<DockerContainerId>" were used, a "<DockerContainerId>" would be resolved to "172.17.0.3" or "172.17.0.4" by the "mysqld" process on each respective "<DockerContainer>", check
```
docker logs -f <DockerContainerId>" 
```
upon calling
```
mysqlsh> dba.createCluster(...)
```
for verification if such "--report-host" were expected.

# Setting up a pair of Master-Slave(Replica, Readonly) MySQL instances without MySQLShell 

That'd require manual works, the most common use case would be to setup a slave/replica for a master instance with existing data. For example, assume that we allow the "SlaveInstance" to use account `'repl'@'%'` for both dumping the initiating data from "MasterInstance" as well as replicating the data.

```
master/mysql> CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';
master/mysql> GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER, RELOAD, PROCESS, USAGE, REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO 'repl'@'%';
```

## Create a datadir using Percona `xtrabackup` 
As we plan to disable GTID on both the master and slave, **before dumping data by `xtrabackup`**, the master should be turned into `gtid_mode=OFF` and had once `RESET MASTER -> restart process`, such that we're able to dump master binlog without GTID.  

```
# Dumps data
master> xtrabackup --backup --host=<MASTER_INSTANCE_ADDR> --port=<MASTER_INSTANCE_PORT> --user=repl --password=repl --target-dir=/path/to/replica_datadir

# Prepares the backup for restoring, see https://www.percona.com/doc/percona-xtrabackup/2.2/xtrabackup_bin/preparing_the_backup.html for details
slave> scp master:/path/to/replica_datadir /path/to/replica_datadir
slave> xtrabackup --prepare --target-dir=/path/to/replica_datadir 


# Starts the slave instance with /path/to/replica_datadir, example below using docker only 
slave> docker run -p 192.168.56.102:3308:3308 -e MYSQL_ROOT_HOST=% -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d --mount 'type=bind,src=/path/to/replica_datadir,dst=/var/lib/mysql' mysql:8.0 --server-id=2 --skip-slave-start --port=3308 --gtid-mode=OFF --enforce-gtid-consistency=OFF --master-info-repository=TABLE --relay-log-info-repository=TABLE --relay-log-index=SLAVE --relay-log=SLAVE --relay-log-recovery=ON --skip-grant-tables 

# Sets master info 
slave/mysql> UPDATE mysql.user SET Super_priv='Y' WHERE user='root'; 
slave/mysql> FLUSH PRIVILEGES;

# Resets mysql.slave_master_info
slave/mysql> RESET MASTER;

# Resets mysql.slave_relay_log_info
slave/mysql> RESET SLAVE;

slave/mysql> CHANGE MASTER TO MASTER_HOST='<MASTER_INSTANCE_ADDR>', MASTER_PORT=<MASTER_INSTANCE_PORT>, MASTER_USER='repl', MASTER_PASSWORD='repl', MASTER_AUTO_POSITION=0, MASTER_LOG_FILE='<1ST_IN_XTRABACKUP_BINLOG_INFO>', MASTER_LOG_POS=<2ND_IN_XTRABACKUP_BINLOG_INFO>;

slave/mysql> START SLAVE;

slave/mysql> SHOW SLAVE STATUS\G
```

## Optional steps

The "SlaveInstance" might be preferred to be "read_only" for all sessions except for the "MasterInstance", check with
```
slave> SELECT @@global.read_only, @@global.super_read_only;
```
and update with 
```
slave> SET @@global.read_only=0; 
slave> SET @@global.super_read_only=0;
```
for such status if needed.

# Partial sync options
  
Either on the master or the slave, we can choose to only send/receive part of the synchronization messages, i.e. of certain schemas, see https://dev.mysql.com/doc/refman/5.7/en/change-replication-filter.html for the slave side adjustments.
