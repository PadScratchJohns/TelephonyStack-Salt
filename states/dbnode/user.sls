# Make etcd user
etcd_group:
    group.present:
        - name: etcd
        - gid: 4444
    user.present:
        - name: etcd
        - fullname: etcd
        - uid: 4444 
        - gid: 4444
        - allow_uid_change: True
        - allow_gid_change: True
        - shell: /bin/false
        - require:
            - group: etcd
    file.directory:
        - name: /usr/local/etcd
        - user: etcd 
        - group: etcd 
        - dir_mode: 750 
        - require:
            - user: etcd  

# Make patroni user
patroni_group:
    group.present:
        - name: patroni
        - gid: 5555
    user.present:
        - name: patroni
        - fullname: patroni
        - uid: 5555 
        - gid: 5555
        - allow_uid_change: True
        - allow_gid_change: True
        - shell: /bin/false
        - require:
            - group: patroni
    file.directory:
        - name: /usr/local/patroni
        - user: patroni 
        - group: patroni 
        - dir_mode: 750 
        - require:
            - user: patroni  

dbnode_sudoers_file:
    file.managed:
        - name: /etc/sudoers.d/patroni
        - source: salt://{{ slspath }}/files/dbnode_sudoers_file
        - template: jinja
        - user: root
        - group: root
        - mode: 0440
        - require:
            - user: patroni

