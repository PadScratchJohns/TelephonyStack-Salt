kamailio_service_file_change:
    file.managed:
        - name: /lib/systemd/system/kamailio.service
        - source: salt://{{ slspath }}/files/kamailio.service
        - template: jinja
        - user: root
        - group: root
        - mode: 0644

kamailio.service:
    service.running:
        - name: kamailio
        - enable: True
