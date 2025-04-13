base:
    '*':
        - mine
        - homer
        - dbnode
        - pip

    'G@roles:carrier':
        - match: compound
        - carrier

    'G@roles:coturn':
        - match: compound
        - coturn

    'G@roles:freeswitch':
        - match: compound
        - freeswitch

    'G@roles:kamailio':
        - match: compound
        - kamailio
        - redis

    'G@roles:rtpengine':
        - match: compound
        - rtpengine

    'G@roles:sipp':
        - match: compound
        - sipp
