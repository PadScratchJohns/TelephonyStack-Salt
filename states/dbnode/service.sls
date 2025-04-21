# Service file - in lib as apt package download
etcd_service_file:
  file.managed:
      - name: /lib/systemd/system/etcd.service
      - source: salt://{{ slspath }}/files/compiledetcd.service.jinja2
      - template: jinja
      - user: root
      - group: root
      - mode: 0644
# managed by a script due to sequencing issues
etcd.service:
    service.running:
        - name: etcd
        - enable: True
        - reload: True

# Patroni service file - in lib as apt package download
patroni_service_file:
  file.managed:
    - name: /lib/systemd/system/patroni.service
    - source: salt://{{ slspath }}/files/patroni.service
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
# managed by a script due to sequencing issues
patroni.service:
    service.running:
        - name: patroni
        - enable: True
        - reload: True
