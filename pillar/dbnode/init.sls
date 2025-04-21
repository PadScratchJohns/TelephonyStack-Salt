{% set env = salt['grains.get']('environment') %}
# Mostly static stuff, IP space for the nodes should be somewhere else but dumped here. 
dbnode:
{% if (env == 'prd') %}
    haproxylist: |
        server pg1 10.10.10.1:5432 port 8008 check verify none
        server pg2 10.10.10.2:5432 port 8008 check verify none
        server pg3 10.10.10.3:5432 port 8008 check verify none
    privlbip: 10.10.10.21
    lbip: 1.2.3.4
    ipstart: 10.10.10.0
    cidr: 255.255.255.128
    dbnode1: 10.10.10.1
    dbnode2: 10.10.10.2
    dbnode3: 10.10.10.3
{% else %}
    haproxylist: |
        server pg1 10.10.20.10:5432 port 8008 check verify none
        server pg2 10.10.20.20:5432 port 8008 check verify none
        server pg3 10.10.20.30:5432 port 8008 check verify none
    privlbip: 10.10.20.251
    lbip: 1.1.1.1
    ipstart: 10.10.20.0
    cidr: 255.255.255.128
    dbnode1: 10.10.20.10
    dbnode2: 10.10.20.20
    dbnode3: 10.10.20.30
{% endif %}
    homerfqdn: {{ env }}-homer.example.com
