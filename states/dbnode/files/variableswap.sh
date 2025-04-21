#!/bin/sh
# This script grabs the data that the pipeline puts in individual files in /cfg/ path and uses sed to swap it out. 
# Mainly passwords that we don't want going outside of the box or in a repo etc, plus it makes it easier to swap out if it were ever to get breached. 
pospassword=$(cat /cfg/pospassword)
reppassword=$(cat /cfg/reppassword)
bacpassword=$(cat /cfg/bacpassword)
# Wait for a single second
sleep 1
# Assign via sed to cfg
sed -i "s/pospassword/$pospassword/g" /etc/patroni/config.yml
sed -i "s/reppassword/$reppassword/g" /etc/patroni/config.yml
sed -i "s/bacpassword/$bacpassword/g" /etc/patroni/config.yml
sed -i "s/bacpassword/$bacpassword/g" /cfg/pg_dump.sh
# DB user stuff.
sudo -u postgres psql -c "CREATE TABLESPACE data01 LOCATION '/data01';"
sudo -u postgres psql -c "CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '$reppassword';"
sudo -u postgres psql -c "CREATE ROLE postgres WITH CREATEDB CREATEROLE LOGIN PASSWORD '$pospassword';"
sudo -u postgres psql -c "CREATE ROLE backup_user WITH REPLICATION LOGIN PASSWORD '$bacpassword';"
# forcing this here
sudo systemctl stop postgresql.service
sudo systemctl disable postgressql.service

# make sure to list users to check - sudo -u postgres psql -c "\du;"
# softdog for splitbrain protection 
sed -E -i 's/blacklist softdog/#blacklist softdog/g' /lib/modprobe.d/*
sh -c 'echo "softdog" >> /etc/modules'
modprobe softdog
chown postgres:postgres /dev/watchdog
modprobe softdog; sleep 1; chown postgres:postgres /dev/watchdog
exit 0 