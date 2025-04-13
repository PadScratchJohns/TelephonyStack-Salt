# install and enable
chrony.install:
  pkg.installed:
    - name: chrony

# This is only here for NTP
chrony.conf:
    file.managed:
        - name: /etc/chrony/chrony.conf
        - source: salt://{{ slspath }}/files/chrony.conf.jinja2
        - template: jinja
        - user: root
        - group: root
        - mode: 0644
        - require:
          - pkg: chrony

chrony.service:
  service.running:
    - name: chrony
    - enable: True
    - restart: True
    - require:
      - pkg: chrony
