{% set env = salt['grains.get']('environment') %}
{% set srv = salt['grains.get']('srvtype') %}
# core Kamailio config files are kept here 
core_kamailio_config:
    file.managed:
        - name: /etc/kamailio/kamailio.cfg
        - source: salt://{{ slspath }}/files/kamailio.cfg.jinja2
        - user: kamailio
        - group: kamailio
        - template: jinja
        - mode: 0644
# contains routing logic for both proxy and recording - this is done in file with jinja templating. 
core_kamailio_kemi_config:
    file.managed:
        - name: /etc/kamailio/kamailio.py
        - source: salt://{{ slspath }}/files/kamailio.py.jinja2
        - template: jinja
        - user: kamailio
        - group: kamailio
        - mode: 0644

core_kemivars_config:
    file.managed:
        - name: /etc/kamailio/kemivars.py
        - source: salt://{{ slspath }}/files/kemivars.py.jinja2
        - user: kamailio
        - group: kamailio
        - template: jinja
        - mode: 0644

core_kamailio_default_file:
    file.managed:
        - name: /etc/default/kamailio
        - source: salt://{{ slspath }}/files/kamailio.jinja2
        - template: jinja
        - user: kamailio
        - group: kamailio
        - mode: 0644

core_kamctlrc_file:
    file.managed:
        - name: /etc/kamailio/kamctlrc
        - source: salt://{{ slspath }}/files/kamctlrc
        - template: jinja
        - user: root
        - group: root
        - mode: 0644
       
# Needs the cfg before it manages the file
db_pass_core:
    file.managed:
        - name: /cfg/variableswap.sh
        - source: salt://{{ slspath }}/files/variableswap.sh
        - mode: 0744
        - require: 
            - file: /etc/kamailio/kamailio.cfg
# Neess the script before it runs. 
run_db_pass_core:
    cmd.run:
        - name: /cfg/variableswap.sh
        - require: 
            - file: /cfg/variableswap.sh

reload_htable_script:
    file.managed:
        - name: /cfg/htablereload.sh
        - source: salt://{{ slspath }}/files/htablereload.sh
        - template: jinja
        - user: kamailio
        - group: kamailio
        - mode: 0755

# Needs to be done with crontab -e othjerwise parse errors happen with cron
# Cron start script hourly
/cfg/htablereload.sh:
    cron.present:
        - user: root
        - special: '@hourly'

# Netbind conf file - enables floating IP 
netbind_config_for_application:
    file.managed:
        - name: /etc/sysctl.d/98-non-local-bind.conf
        - source: salt://{{ slspath }}/files/98-non-local-bind.conf
        - template: jinja
        - user: root
        - group: root
        - mode: 0644