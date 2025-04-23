# Intro

Just some boilerplate installs and config for setting up a fully functional telecoms stack including: SIP/RTP proxy with monitoring - B2BUA with FreeSWITCH as well as STUN/TURN services. 

This is designed to be used with a database and as such I have the templates and installs for it in this repo and the "tf-templates" in this account. 

The tf templates should put the passwords and other sensitive env type vars in the path /cfg/ 

# Run down
Nice and easy - salt-stack is being used here and is already on the boxes and linked to the master. 
All commands are run from the salt master. 
The master know what the boxes are because of the "grains" - this including customer grains. 
Terraform sets the hostname of the boxes and a python script parses the hostname and sets the grains on each box. 
This is how the automation kows which box requires which software. 

# Data split
Grains - the VM's own data. (private ip, mac address, hostname, etc)
Mine - other VM's grain data (same as above)
Pillar - data that the VM's would not naturally know. (fqdn, external services, etc)
Custom grains - You have to run the sync_grains script. This parses the hostname in grains and adds them to the box. 
Sensitive data - this is added to the /cfg path by terraform so any passwords or fqdn's etc you need should be put in a file each, then use the bash scripts with sed as part of the install to swap them out. 

# How to run
