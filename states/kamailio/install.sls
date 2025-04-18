{% set osf = salt['grains.get']('oscodename') %}
{% set rol = salt['grains.get']('roles') %}
# setting the repo in apt
{% if not salt['file.file_exists']('/etc/apt/sources.list.d/kamailio.list') %}
    {% if (osf == 'jammy') %}
kamailio_jammy_repo_list:
  cmd.run:
    - name: |
        wget -O- https://deb.kamailio.org/kamailiodebkey.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/kamailio.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio58 jammy main" > /etc/apt/sources.list.d/kamailio.list
        echo "deb-src [signed-by=/etc/apt/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio58 jammy main" >> /etc/apt/sources.list.d/kamailio.list
        apt update
    {% elif (osf == 'noble') %}
Kamailio_noble_repo_list:
  cmd.run:
    - name: |
        wget -O- https://deb.kamailio.org/kamailiodebkey.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/kamailio.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio58 noble main" > /etc/apt/sources.list.d/kamailio.list
        echo "deb-src [signed-by=/etc/apt/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio58 noble main" >> /etc/apt/sources.list.d/kamailio.list
        apt update
    {% endif %}
{% endif %}
# Installs here for both SBC or Registrar - enables an easy way to update packages for all.
{% if (rol == 'core') %}
core_packages.install:
    pkg.installed:
        - refresh: true
        - pkgs:
            - kamailio
            - kamailio-python3-modules
            - kamailio-postgres-modules
            - python3-pip
            - sngrep
            - jq
            - mtr
            #- keepalived
            #- sipsak
{% elif (rol == 'registrar') %}
registrar_packages.install:
    pkg.installed:
        - refresh: true
        - pkgs:
            - kamailio
            - kamailio-python3-modules
            - kamailio-postgres-modules
            - kamailio-websocket-modules
            - kamailio-autheph-modules
            - kamailio-tls-modules
            - kamailio-outbound-modules
            - python3-pip
            - sngrep
            - mtr
            - jq
            #- keepalived
            #- sipsak
            #- kamailio-mqtt-modules or kamailio-rabbitmq-modules # Maybe this for a message broker? 
{% endif %}