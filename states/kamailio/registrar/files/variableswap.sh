#!/bin/sh
# This script grabs the data that the pipeline puts in individual files in /cfg/ path and uses sed to swap it out. 
# Mainly passwords that we don't want going outside of the box or in a repo etc, plus it makes it easier to swap out if it were ever to get breached. 
dbpass=$(cat /cfg/dbpass)
dbun=$(cat /cfg/dbun) # This is also the DB's name as well. 
dbhost=$(cat /cfg/dbhost)
homervar=$(cat /cfg/homerip)
# Print this to console in salt master as a test.
echo $dbun
# Wait for a few seconds
sleep 3
# Assign via sed to cfg
sed -i "s/dbhostvar/$dbhost/g" /etc/kamailio/kamailio.cfg
sed -i "s/dbpwvar/$dbpass/g" /etc/kamailio/kamailio.cfg
sed -i "s/dbunvar/$dbun/g" /etc/kamailio/kamailio.cfg
sed -i "s/varhomer/$homervar/g" /etc/kamailio/kamailio.cfg
sed -i "s/dbhostvar/$dbhost/g" /etc/kamailio/kamctlrc
sed -i "s/dbpwvar/$dbpass/g" /etc/kamailio/kamctlrc
sed -i "s/dbunvar/$dbun/g" /etc/kamailio/kamctlrc
exit 0 