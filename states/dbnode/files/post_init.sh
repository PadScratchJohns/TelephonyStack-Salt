#!/bin/sh
pospassword=$(cat /cfg/pospassword)
reppassword=$(cat /cfg/reppassword)
bacpassword=$(cat /cfg/bacpassword)

# DB user stuff.
sudo -u postgres psql -c "CREATE TABLESPACE data01 LOCATION '/data01';"
sudo -u postgres psql -c "CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '$reppassword';"
sudo -u postgres psql -c "CREATE ROLE postgres WITH CREATEDB CREATEROLE LOGIN PASSWORD '$pospassword';"
sudo -u postgres psql -c "CREATE ROLE backup_user WITH REPLICATION LOGIN PASSWORD '$bacpassword';"
