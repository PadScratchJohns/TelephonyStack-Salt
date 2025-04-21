# mkdir for logging local for FS and acconting.
freeswitch_mkdir:
    file.directory:
        - name: /var/log/freeswitch
        - user: freeswitch
        - group: freeswitch
        - mode: 0777
        - makedirs: True

freeswitch_rsyslogd_config:
  file.managed:
    - name: /etc/rsyslog.d/99-freeswitch.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source:
      - salt://{{ slspath }}/files/rsyslog.d/freeswitch.conf

freeswitch_logrotate_config:
    file.managed:
        - name: /etc/logrotate.d/freeswitch
        - user: root
        - group: root
        - mode: 644
        - source:
            - salt://{{ slspath }}/files/rsyslog.d/freeswitchlogrotate
