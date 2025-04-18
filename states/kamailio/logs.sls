kamailio_log_folder:
    file.directory:
        - name: /var/log/kamailio
        - makedirs: True
        - user: root
        - group: root
        - mode: 777

# Syslog local files to parse into different files
kamailio_rsyslogd_config:
    file.managed:
        - name: /etc/rsyslog.d/locale-kamailio.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - source: salt://{{ slspath }}/files/locale-kamailio.conf
kamailio_logrotate_config:
    file.managed:
        - name: /etc/logrotate.d/kamailiologrotate
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - source: salt://{{ slspath }}/files/kamailiologrotate