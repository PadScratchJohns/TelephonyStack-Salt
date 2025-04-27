janus_log_folder:
    file.directory:
        - name: /var/log/janus
        - makedirs: True
        - user: root
        - group: root
        - mode: 777

# Syslog local files to parse into different files
janus_rsyslogd_config:
    file.managed:
        - name: /etc/rsyslog.d/locale-janus.conf
        - source: salt://{{ slspath }}/files/locale-janus.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja

janus_logrotate_config:
    file.managed:
        - name: /etc/logrotate.d/januslogrotate
        - source: salt://{{ slspath }}/files/januslogrotate
        - user: root
        - group: root
        - mode: 644
        - template: jinja