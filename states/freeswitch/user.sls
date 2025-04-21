# Make freeswitch user
freeswitch_group:
    group.present:
        - name: freeswitch
        - gid: 4444
    user.present:
        - name: freeswitch
        - fullname: freeswitch
        - uid: 4444 
        - gid: 4444
        - allow_uid_change: True
        - allow_gid_change: True
        - shell: /bin/false
        - require:
            - group: freeswitch
    file.directory:
        - name: /usr/local/freeswitch
        - user: freeswitch 
        - group: freeswitch 
        - dir_mode: 750 
        - require:
            - user: freeswitch  

freeswitch_sudoers_file:
    file.managed:
        - name: /etc/sudoers.d/freeswitch
        - source: salt://{{ slspath }}/files/freeswitch_sudoers_file
        - template: jinja
        - user: root
        - group: root
        - mode: 0440
        - require:
            - user: freeswitch

