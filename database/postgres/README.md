As of pgpool2-3.4.3 on Ubuntu 14.04, the pcp config file is located at `/etc/pgpool2/pcp.conf`, which might vary w.r.t. versions and platforms.

Please refer to [pgpool user manual](http://www.pgpool.net/docs/latest/tutorial-en.html#pcp-config) for pcp commands. Upon attaching (bringing up) inconsistent backends by [pcp_attach_node](http://pgpool.net/docs/latest/pgpool-en.html#pcp_attach_node), please refer to [online recovery manual](http://pgpool.net/docs/latest/pgpool-en.html#online-recovery) for more information.

Note that [pcp_promote_node](http://pgpool.net/docs/latest/pgpool-en.html#pcp_promote_node) is used by [master/slave mode](http://pgpool.net/docs/latest/pgpool-en.html#master_slave_mode) + [streaming replication](http://pgpool.net/docs/latest/pgpool-en.html#stream) only, thus NOT applicable to [replication mode](http://pgpool.net/docs/latest/pgpool-en.html#replication_mode).
