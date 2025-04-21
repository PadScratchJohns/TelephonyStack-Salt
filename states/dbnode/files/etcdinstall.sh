#!/bin/bash
# logging the output
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/etcdinstalllog.out 2>&1
# mkdirs for config and libs - should be done in salt already - add an etcd user
sudo mkdir -p /pg/data01/datafiles
sudo mkdir -p /pg/data01/patroni
sudo mkdir -p /pg/data01/postgres
sudo mkdir -p /pg/index01/indexes/
sudo mkdir -p /pg/log/pg_log/
sudo mkdir -p /pg/log/patroni_log/
sudo mkdir -p /pg/wal/archive
sudo mkdir -p /pg/wal/pg_wal
sudo mkdir -p /pg/wal/etcd
sudo mkdir -p /etc/etcd
sudo mkdir -p /var/lib/etcd 
sudo useradd --system --home /var/lib/etcd --shell /bin/false etcd
# etcd installs
sudo wget https://github.com/etcd-io/etcd/releases/download/v3.5.17/etcd-v3.5.17-linux-amd64.tar.gz 
sudo tar xvf etcd-v3.5.17-linux-amd64.tar.gz
sudo mv etcd-v3.5.17-linux-amd64 etcd
sudo mv etcd/etcd* /usr/local/bin/
# change ownership recursively - should be done in salt already 
sudo chown -R etcd:etcd /root/etcd
sudo chown -R etcd:etcd /usr/local/bin/etcd*
sudo chown -R etcd:etcd /var/lib/etcd
sudo chown -R etcd:etcd /etc/etcd
