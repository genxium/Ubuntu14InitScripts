# To list the filter chains (containing INPUT) 

```
root@~> iptables -L --line-number -v -n -t filter
```


# To add rules that allow whitelisted access to redis-server 

Mind that the order of rules is important.
```
root@~> iptables -A INPUT -p tcp --dport 6379 --in-interface lo -j ACCEPT 
root@~> iptables -A INPUT -p tcp --dport 6379 -s <your src IP addr to allow, e.g. 172.10.22.0/24 or 172.10.22.8/32> -j ACCEPT 
root@~> iptables -A INPUT -p tcp --dport 6379 -j DROP
```


# To remove rules 

Just change the "-A" option to "-D" in any of the commands above.


# To enable redis-server remote access 

Edit `/etc/redis/redis.conf`, and change
```
bind 127.0.0.1
```

to

```
bind 0.0.0.0
```

then do `service redis-server restart`.

Now find a client machine to ping for verification. Assume that your redis-server runs on a machine at 172.10.22.15 whilst the client machine is at 172.10.22.8.
```
user@~> redis-cli -h 172.10.22.15 ping
```


# Extras 

Refer to https://github.com/genxium/CentOS6InitScripts/tree/master/iptables for more information, e.g. when multiple src/dst ports are concerned and how to backup/restore the runtime rules in RAM. 

Refer to https://app.yinxiang.com/shard/s61/nl/13267014/d39d6b72-a8f1-44ee-bbbc-c4ada8cb63e2/ and https://en.wikipedia.org/wiki/Netfilter for more information, e.g. about "iptables" being the user-space counterpart of the kernel-space module "netfilter" of Linux. 
