# Make RTPengine user
rtpengine_group:
    group.present:
        - name: rtpengine
        - gid: 3333
    user.present:
        - name: rtpengine
        - fullname: rtpengine
        - uid: 3333 
        - gid: 3333
        - allow_uid_change: True
        - allow_gid_change: True
        - shell: /bin/false
        - require:
            - group: rtpengine
    file.directory:
        - name: /home/rtpengine 
        - user: rtpengine 
        - group: rtpengine 
        - dir_mode: 750 
        - require:
            - user: rtpengine  

rtpengine_sudoers_file:
    file.managed:
        - name: /etc/sudoers.d/rtpengine
        - source: salt://{{ slspath }}/files/rtpengine_sudoers_file
        - template: jinja
        - user: root
        - group: root
        - mode: 0440
        - require:
            - user: rtpengine

