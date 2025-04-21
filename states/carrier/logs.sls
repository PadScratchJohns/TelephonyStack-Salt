{% set env = salt['grains.get']('environment') %}
# Create log folder for site 24x7 to scrape from 
carrier_proxy_log_folder:
    file.directory:
        - name: /var/log/kamailio
        - makedirs: True
        - user: root
        - group: root
        - mode: 777

# Syslog/logrotate files to parse into different files
carrier_proxy_rsyslogd_config:
    file.managed:
        - name: /etc/rsyslog.d/locale-kamailio.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - source: salt://{{ slspath }}/files/locale-kamailio.conf
carrier_proxy_logrotated_config:
    file.managed:
        - name: /etc/logrotate.d/kamailiologrotate
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - source: salt://{{ slspath }}/files/kamailiologrotate

{% if env == 'prd' %}
# Stats collector for Site 24x7 
site24x7_collector_folder:
    file.directory:
        - name: /opt/site24x7/monagent/plugins/kamailio_call_metrics
        - makedirs: True
        - user: root
        - group: root
        - mode: 777
site24x7_python_metrics_script:
    file.managed:
        - name: /opt/site24x7/monagent/plugins/kamailio_call_metrics/kamailio_call_metrics.py
        - user: site24x7-agent
        - group: site24x7-group
        - mode: 755
        - template: jinja
        - source: salt://{{ slspath }}/files/kamailio_metric_collector.py
{% endif %}