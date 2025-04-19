janus_service_file_change:
    file.managed:
        - name: /lib/systemd/system/janus.service
        - source: salt://{{ slspath }}/files/janus.service
        - template: jinja
        - user: root
        - group: root
        - mode: 0644

janus.service:
    service.running:
        - name: janus
        - enable: True
