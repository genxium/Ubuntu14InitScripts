# 1. Paths

You're reading `<subproj-root>/README.md`.

# 2. Checklist

## 2.1 Remote access 

Per installation by the script `<subproj-root>/install_metapackage`, you might have to set `bindIp(under "net"): 0.0.0.0` in `/etc/mongod.conf` to allow remote access.

# 3. Access constraints imposed on the OS by other processes 

## 3.1 iptables

To list all active in-RAM rules of table `filter` by binary `iptables`, 

```
root> iptables -L -v [-t filter]
```   

and refer to https://wiki.centos.org/HowTos/Network/IPTables for details of operation.

A possible rule like `INPUT --dport 27017 ... -j DROP` or `OUTPUT --sport 27017 ... -j DROP` could be jamming remote access to a live MySQL server.  

## 3.2 ufw

To list all active in-RAM rule by `ufw`, 

```
root> ufw status
```   

Refer to https://help.ubuntu.com/community/UFW for details.
