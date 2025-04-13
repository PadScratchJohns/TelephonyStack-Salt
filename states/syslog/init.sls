rsyslog.install:
  pkg.installed:
    - name: rsyslog

rsyslog.service:
  service.running:
    - name: rsyslog
    - enable: True
    - require:
      - pkg: rsyslog
