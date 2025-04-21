#!/bin/sh
# This script grabs the data that the pipeline puts in individual files in /cfg/ path and uses sed to swap it out. 
# Mainly passwords that we don't want going outside of the box or in a repo etc, plus it makes it easier to swap out if it were ever to get breached. 
homervar=$(cat /cfg/homerip)

# Print this to console in salt master as a test.
echo $homervar
# Wait for a few seconds
sleep 3
# Assign via sed to cfg
sed -i "s/varhomer/$homervar/g" /etc/rtpengine/rtpengine.conf

exit 0 