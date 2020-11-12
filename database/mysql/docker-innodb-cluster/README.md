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
That'd require manual works, the most common use case would be to setup a slave/replica for a master instance with existing data.
