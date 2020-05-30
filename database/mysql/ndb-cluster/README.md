Using DockerImage https://hub.docker.com/r/mysql/mysql-cluster/ built from https://github.com/mysql/mysql-docker/tree/mysql-cluster.

In practical use cases, all "DockerContainer"s are recommended to use "--net=host", such that `inter-process & inter-OS ipaddr routing` is handled by "DockerHostOS", as explained in https://github.com/genxium/Ubuntu14InitScripts/tree/master/database/mysql/docker-innodb-cluster.

In this example however, we're constrained by https://github.com/mysql/mysql-docker/blob/mysql-cluster/7.6/cnf/mysql-cluster.cnf to use the "subnet 192.168.0.0/16".

# To verify that we're using "instances of NDBEngine w/ `ndbd`"
The following steps work whether or not each "DockerContainer" has a mounted volume. 

- docker exec -it mysql1 mysql -uroot
```
/*Data example from https://dev.mysql.com/doc/mysql-cluster-excerpt/5.7/en/mysql-cluster-install-example-data.html.*/ 

CREATE DATABASE test
USE test
CREATE TABLE `City` (   `ID` int(11) NOT NULL auto_increment,   `Name` char(35) NOT NULL default '',   `CountryCode` char(3) NOT NULL default '',   `District` char(20) NOT NULL default '',   `Population` int(11) NOT NULL default '0',   PRIMARY KEY  (`ID`) ) ENGINE=NDBCLUSTER DEFAULT CHARSET=latin1;
INSERT INTO `City` VALUES (1,'Kabul','AFG','Kabol',1780000); 
INSERT INTO `City` VALUES (2,'Qandahar','AFG','Qandahar',237500); 
INSERT INTO `City` VALUES (3,'Herat','AFG','Herat',186800);

SELECT * FROM City;

/*Should succeed in obtaining data.*/ 
```
- docker stop ndb1
- docker stop ndb2
- docker exec -it mysql1 mysql -uroot
```
SELECT * FROM City;

/*Should fail to obtain data.*/ 
```
- docker start ndb1
- docker start ndb2
- docker exec -it mysql1 mysql -uroot
```
SELECT * FROM City;

/*Should succeed in obtaining data.*/ 
```
