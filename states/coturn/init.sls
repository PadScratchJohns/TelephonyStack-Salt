# Install CoTURN and other softwares
Install_coturn:
    pkg.installed:
        - name: coturn
        #- version: 4.5.2 # use latest in apt

Install_other:
    pkg.installed:
        - refresh: True
        - pkg:
            - jq
            - mtr

# mkdir and placeholder.log is for filebeat and coturn logging oddness.
coturn_log_folder:
    file.directory:
        - name: /var/log/coturn
        - user: turnserver
        - group: turnserver
        - makedirs: True
        - mode: 0755

coturn_config:
    file.managed:
        - name: /etc/turnserver.conf
        - source: salt://{{ slspath }}/files/turnserver.conf.jinja2
        - template: jinja
        - user: turnserver
        - group: turnserver
        - mode: 0644

listener_systemd_coturn:
    file.managed:
        - name: /etc/systemd/system/coturn.service
        - source: salt://{{ slspath }}/files/coturn.service
        - user: root
        - group: root
        - mode: 0644

coturn:
    service.running:
        - enable: True

turn_logrotate_config:
    file.managed:
        - name: /etc/logrotate.d/turnlogrotate
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - source: salt://{{ slspath }}/files/turnlogrotate
# Installing enables root:root on the log so chown back to turnsever for logging
coturn_log_chown:
    cmd.run:
      - name: sudo chown turnserver:turnserver /var/log/coturn/coturn.log