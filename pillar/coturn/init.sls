{% set env = salt['grains.get']('environment') %}
{% set loc = salt['grains.get']('location') %}
{% set srv = salt['grains.get']('srvtype') %}
{% set ins = salt['grains.get']('instance') %}
# UN & PW for turnserver.conf or use the secret its upto you
coturn:
    secret1: agreatpassword456
    realm1: my-turn.example.com
    realm2: your-turn.example.com
