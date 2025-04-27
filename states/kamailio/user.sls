# Make kamailio user
kamailio_group:
    group.present:
        - name: kamailio
        - gid: 2222
    user.present:
        - name: kamailio
        - fullname: kamailio
        - uid: 2222 
        - gid: 2222
        - allow_uid_change: True
        - allow_gid_change: True
        - shell: /bin/false
        - require:
            - group: kamailio
    file.directory:
        - name: /etc/kamailio 
        - user: kamailio 
        - group: kamailio 
        - dir_mode: 750 
        - require:
            - user: kamailio  

kamailio_sudoers_file:
    file.managed:
        - name: /etc/sudoers.d/kamailio
        - source: salt://{{ slspath }}/files/kamailio_sudoers_file
        - template: jinja
        - user: root
        - group: root
        - mode: 0440
        - require:
            - user: kamailio

