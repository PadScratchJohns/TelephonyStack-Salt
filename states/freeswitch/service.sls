freeswitch_service_file:
  file.managed:
    - name: /etc/systemd/system/freeswitch.service
    - source: salt://{{ slspath }}/files/freeswitch.service
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

# Service running 
freeswitch.service:
    service.running:
        - name: freeswitch
        - enable: True
        - reload: True