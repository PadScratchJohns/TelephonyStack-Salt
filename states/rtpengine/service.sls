# Service file - done with apt now
rtpengine_service_file:
  file.managed:
      - name: /lib/systemd/system/rtpengine-daemon.service
      - source: salt://{{ slspath }}/files/rtpengine-daemon.service
      - template: jinja
      - user: root
      - group: root
      - mode: 0644
# RTPengine Service 
rtpengine_restart:
    service.running:
        - name: rtpengine
        - enable: True
        - reload: True
{% if (srv == 'recording') %}
# Recording Service 
rtpengine_recording_restart:
    service.running:
        - name: rtpengine-recording
        - enable: True
        - reload: True
{% endif %}