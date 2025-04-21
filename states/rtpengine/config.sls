{% set srv = salt['grains.get']('srvtype') %}
{% if (srv == 'recording') %}
# mkdirs for data01 disk for recording
data_dirs_mkdir:
    file.directory:
        - name: /data01/
        - user: rtpengine
        - group: rtpengine
        - mode: 0754
        - makedirs: True
# Make recordings dirs - spool
rtpengine_recordings_mkdir:
    file.directory:
        - name: /data01/rtpengine/
        - user: rtpengine
        - group: rtpengine
        - mode: 0744
        - makedirs: True
rtpengine_metadata_mkdir:
    file.directory:
        - name: /data01/recordings/
        - user: rtpengine
        - group: rtpengine
        - mode: 0744
        - makedirs: True
# tmp_cache will only contain tmp files whilst uploading to blob
tmp_blob_cache_mkdir:
    file.directory:
        - name: /var/spool/tmp_cache
        - user: root
        - group: root
        - mode: 0666
        - makedirs: True
{% endif %}
# Make conf dir
rtpengine_conf_mkdir:
    file.directory:
        - name: /etc/rtpengine/
        - user: rtpengine
        - group: rtpengine
        - mode: 0744
        - makedirs: True
# Make log dir
rtpengine_legacy_log_folder:
    file.directory:
        - name: /var/log/rtpengine
        - makedirs: True
        - user: rtpengine
        - group: rtpengine
        - mode: 0600
# Logging and rotation
rtpengine_rsyslogd_config:
    file.managed:
        - name: /etc/rsyslog.d/locale-rtpengine.conf
        - user: rtpengine
        - group: rtpengine
        - mode: 0644
        - template: jinja
        - source: salt://{{ slspath }}/files/locale-rtpengine.conf

rtpengine_logrotate_config:
    file.managed:
        - name: /etc/logrotate.d/rtpenginelogrotate
        - user: rtpengine
        - group: rtpengine
        - mode: 644
        - template: jinja
        - source: salt://{{ slspath }}/files/rtpenginelogrotate

# Config file
rtpengine_config_file:
    file.managed:
        - name: /etc/rtpengine/rtpengine.conf
        - source: salt://{{ slspath }}/files/rtpengine.conf.jinja2
        - template: jinja
        - user: rtpengine
        - group: rtpengine
        - mode: 0644
{% if (srv == 'recording') %}
# SIP Rec config file
rtpengine_call_recording_file:
    file.managed:
        - name: /etc/rtpengine/rtpengine-recording.conf
        - source: salt://{{ slspath }}/files/rtpengine-recording.conf.jinja2
        - template: jinja
        - user: rtpengine
        - group: rtpengine
        - mode: 0644
{% endif %}
var_swap_script:
    file.managed:
        - name: /cfg/variableswap.sh
        - source: salt://{{ slspath }}/files/variableswap.sh
        - mode: 0744
        - require: 
            - file: /etc/rtpengine/rtpengine.conf
# Neess the script before it runs. 
run_var_swap_script:
    cmd.run:
        - name: /cfg/variableswap.sh
        - require: 
            - file: /cfg/variableswap.sh