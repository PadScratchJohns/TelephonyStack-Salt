# Edit the logfile.conf file to point to where you want to save it. The log file is in conf/autoload_configs/logfile.conf.xml. 
# The line to change is
# <param name="logfile" value="/var/log/freeswitch/freeswitch.log"/>
freeswitch_log_folder:
    file.directory:
        - name: /var/log/freeswitch
        - makedirs: True
        - user: freeswitch
        - group: freeswitch
        - mode: 777
{% if not salt['file.file_exists']('/var/log/freeswitch/freeswitch.log') %}
create_log_file:
  cmd.run:
    - name: |
        touch /var/log/freeswitch/freeswitch.log 
        chown freeswitch:freeswitch /var/log/freeswitch/freeswitch.log
{% endif %}
# Syslog local files to parse into different files
freeswitch_rsyslogd_config:
    file.managed:
        - name: /etc/rsyslog.d/locale-freeswitch.conf
        - user: freeswitch
        - group: freeswitch
        - mode: 644
        - template: jinja
        - source: salt://{{ slspath }}/files/locale-freeswitch.conf
freeswitch_logrotate_config:
    file.managed:
        - name: /etc/logrotate.d/freeswitchlogrotate
        - user: freeswitch
        - group: freeswitch
        - mode: 644
        - template: jinja
        - source: salt://{{ slspath }}/files/freeswitchlogrotate