Using DockerImage https://hub.docker.com/r/mysql/mysql-cluster/ built from https://github.com/mysql/mysql-docker/tree/mysql-cluster.

All "DockerContainer"s in this example will use "--net=host", such that `inter-process & inter-OS ipaddr routing` is handled by "DockerHostOS", as explained in https://github.com/genxium/Ubuntu14InitScripts/tree/master/database/mysql/docker-innodb-cluster.
