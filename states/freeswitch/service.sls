freeswitch_service_file_change:
    file.managed:
        - name: /lib/systemd/system/freeswitch.service
        - source: salt://{{ slspath }}/files/freeswitch.service
        - template: jinja
        - user: root
        - group: root
        - mode: 0644

freeswitch.service:
    service.running:
        - name: freeswitch
        - enable: True
