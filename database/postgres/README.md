The scripts in this directory are used for a minimum setup of `pgpool-II master/slave mode` + `PostgreSQL hot-standby with streaming replication`. 

The following references are recommended to read before using the scripts.

- [Write-Ahead-Logging](https://www.postgresql.org/docs/current/static/wal-intro.html)
- [PostgreSQL Binary Replication Tutorial](https://wiki.postgresql.org/wiki/Binary_Replication_Tutorial#PITR.2C_Warm_Standby.2C_Hot_Standby.2C_and_Streaming_Replication)
- [PostgreSQL Log-Shipping Standby Servers Documentation](https://www.postgresql.org/docs/current/static/warm-standby.html), especially the motivation, requirements and features of [Streaming Replication](https://www.postgresql.org/docs/current/static/warm-standby.html#STREAMING-REPLICATION)
- [Pgpool-II User Manual](http://pgpool.net/docs/latest/pgpool-en.html), especially the parts of [Master/Slave Mode](http://pgpool.net/docs/latest/pgpool-en.html#master_slave_mode) and [Streaming Replication Sub Mode](http://pgpool.net/docs/latest/pgpool-en.html#stream).
