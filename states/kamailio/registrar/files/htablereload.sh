#!/bin/sh 
# Simple script to reload the number location htable from DB. 
# Needs a cron job every x minutes. 
kamcmd htable.reload numloc
sleep 1
kamcmd permissions.addressReload
sleep 1
kamctl dispatcher reload 
# add more here here for any more htables in use
# example: You have added a new customer IP to the DB and need to update the Kamailio's:
# kamcmd htable.reload address
exit 0 