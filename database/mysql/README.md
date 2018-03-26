# 1. Paths

You're reading `<subproj-root>/README.md`.

# 2. Checklist
To grant access for a remote MySQL user 'foo' from specific IPv4 address 'bar1.bar2.bar3.bar4' (to allow remote access from all IP addresses, just replace 'bar1.bar2.bar3.bar4' by '%'),  

## 2.1 List existing grants 

Login to the live MySQL server as proper MySQL user, e.g. 'foo', from localhost or anyother accessible machine.
mysql> SHOW GRANTS for 'foo'; 

## 2.2 Grant rw access to database named 'sigma' by user 'foo' from remote IPv4 addr  

user@subproj-root> ./grant_read_write sigma foo bar1.bar2.bar3.bar4 

## 2.3 Revoke rw access to database named 'sigma' by user 'foo' from remote IPv4 addr  

user@subproj-root> ./revoke_read_write sigma foo bar1.bar2.bar3.bar4 

## 2.4 Make sure that in the major config file for mysqld, there is no `bind-address` or `skip-network` constraints 

For example under `/etc/mysql`, you should NOT have any of the followings that prevents remote access.

```
bind-address           = 127.0.0.1
skip-networking
```

# 3. Access constraints imposed on the OS by other processes 

## 3.1 iptables

To list all active in-RAM rules of table `filter` by binary `iptables`, 

```
root> iptables -L -v [-t filter]
```   

and refer to https://wiki.centos.org/HowTos/Network/IPTables for details of operation.

A possible rule like `INPUT --sport 3306 ... -j DROP` could be jamming remote access to a live MySQL server.  

## 3.2 ufw

To list all active in-RAM rule by `ufw`, 

```
root> ufw status
```   

Refer to https://help.ubuntu.com/community/UFW for details.
