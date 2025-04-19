# install:
haproxy_install:
    pkg.installed:
        - refresh: true
        - pkgs:
            - haproxy
            - net-tools
            - mtr

# Config file:
postgres_etcd_build_script:
  file.managed:
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://{{ slspath }}/files/haproxy.cfg.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 0755
    - require:
      - pkg: haproxy_install
# IP address works for the LB 
# adding the LB IP direct to the haproxy interface:
adding_network_config:
  file.managed:
    - name: /cfg/ipadd.sh
    - source: salt://{{ slspath }}/files/ipadd.sh.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 0777
    - require:
      - pkg: haproxy_install
# Cron add on reboot
/cfg/ipadd.sh:
    cron.present:
        - user: root
        - special: '@reboot'
# service starting:
haproxy.service:
    service.running:
        - name: haproxy
        - enable: True