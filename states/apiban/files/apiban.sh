#!/bin/bash 
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
/usr/local/bin/apiban/apiban-iptables-client >/dev/null 2>&1
# timing is ordered in salt config template for cron