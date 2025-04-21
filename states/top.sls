# Added to all in the automation.
base:
    '*':
        - chrony
        - syslog
        - motd
        #- node_exporter commented for now
# Role specific configs.
# Proxy for carrier traffic
    'G@roles:carrier':
        - match: compound
        - carrier
        - apiban
# STUN/TURN service
    'G@roles:coturn':
        - match: compound
        - coturn
# Postgres with Patroni/Etcd setup
    'G@roles:dbnode':
        - match: compound
        - dbnode
# B2BUA FreeSWITCH
    'G@roles:b2bua':
        - match: compound
        - freeswitch.b2bua
        - freeswitch
# Conference FreeSWITCH
    'G@roles:conference':
        - match: compound
        - freeswitch.conference
        - freeswitch
# For in front of the DBNodes
    'G@roles:haproxy':
        - match: compound
        - haproxy
# Monitoring and logging SIP traffic
    'G@roles:homer':
        - match: compound
        - homer
# SIP Proxy for carrier traffic - handles NAT
    'G@roles:kamailio and G@srvtype:core':
        - match: compound
        - kamailio.core
        - kamailio
        - apiban
        #- keepalived
# SIP Proxy for customer traffic - handles registration and NAT
    'G@roles:kamailio and G@srvtype:reg':
        - match: compound
        - kamailio.reg
        - kamailio
        - apiban
        #- keepalived
# For the LGTM stack - should be a containerised service really. 
    'G@roles:prometheus':
        - match: compound
        - prometheus
# RTP proxy
    'G@roles:rtpengine':
        - match: compound
        - rtpengine
# Loadtesting and simulation tool
    'G@roles:sipp':
        - match: compound
        - sipp

