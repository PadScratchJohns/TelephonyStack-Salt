{% set env = salt['grains.get']('environment') %}
dbnode:
    haproxylist: |
{% if (env == 'prd') %}
        server pg1 10.10.10.1:5432 port 8008 check verify none
        server pg2 10.10.10.2:5432 port 8008 check verify none
        server pg3 10.10.10.3:5432 port 8008 check verify none
    privlbip: 172.16.0.251
    lbip: 1.2.3.4
{% else %}
        server pg1 10.10.10.10:5432 port 8008 check verify none
        server pg2 10.10.10.20:5432 port 8008 check verify none
        server pg3 10.10.10.30:5432 port 8008 check verify none
    privlbip: 172.16.1.251
    lbip: 1.1.1.1
{% endif %}