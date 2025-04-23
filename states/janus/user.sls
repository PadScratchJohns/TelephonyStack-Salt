# Make janus user
janus_group:
    group.present:
        - name: janus
        - gid: 5555
    user.present:
        - name: janus
        - fullname: janus
        - uid: 5555 
        - gid: 5555
        - allow_uid_change: True
        - allow_gid_change: True
        - shell: /bin/false
        - require:
            - group: janus
    file.directory:
        - name: /usr/local/janus
        - user: janus 
        - group: janus 
        - dir_mode: 750 
        - require:
            - user: janus  

janus_sudoers_file:
    file.managed:
        - name: /etc/sudoers.d/janus
        - source: salt://{{ slspath }}/files/janus_sudoers_file
        - template: jinja
        - user: root
        - group: root
        - mode: 0440
        - require:
            - user: janus

