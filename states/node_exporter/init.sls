# Check if the bin is installed:
{% if not salt['file.file_exists']('/usr/local/bin/node_exporter') %}
# Locked at v1.8.2 - latest as of 05/12/24
get_node_exporter:
    cmd.run:
        - name: wget -O /tmp/node_exporter.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
extract_node_exporter:
    archive.extracted:
        - name: /tmp
        - enforced_toplevel: false
        - source: /tmp/node_exporter.tar.gz
        - archive_format: tar
        - user: root
        - group: root
move_node_exporter:
    file.rename:
        - name: /usr/local/bin/node_exporter
        - source: /tmp/node_exporter-1.8.2.linux-amd64/node_exporter
delete_old_node_exporter_folder:
    file.absent:
        - name: /tmp/node_exporter-1.8.2.linux-amd64
delete_old_node_exporter_archieve:
    file.absent:
        - name: /tmp/node_exporter.tar.gz
{% endif %}
# Create a user
node_exporter_group:
    group.present:
        - name: node_exporter
        - gid: 8888
    user.present:
        - name: node_exporter
        - fullname: Node Exporter
        - uid: 8888
        - gid: 8888
        - allow_uid_change: True
        - allow_gid_change: True
        - shell: /bin/false
        - require:
            - group: node_exporter
    file.directory:
        - name: /home/node_exporter
        - user: node_exporter
        - group: node_exporter
        - dir_mode: 750
        - require:
            - user: node_exporter

node_exporter_adding_user:
    group.present:
        - addusers:
            - node_exporter 
        - require:
            - user: node_exporter

/var/lib/node_exporter/textfile_collector:
    file.directory:
        - user: node_exporter
        - group: node_exporter
        - mode: 755
        - makedirs: True
        - require:
            - user: node_exporter

/etc/systemd/system/node_exporter.service:
    file.managed:
        - source: salt://{{ slspath }}/files/node_exporter.service
        - user: node_exporter
        - group: node_exporter
        - mode: 0644
/etc/systemd/system/node_exporter.socket:
    file.managed:
        - source: salt://{{ slspath }}/files/node_exporter.socket
        - user: node_exporter
        - group: node_exporter
        - mode: 0644
/etc/sysconfig:
    file.directory:
        - user: node_exporter
        - group: node_exporter
        - mode: 755
        - makedirs: True
        - require:
            - user: node_exporter
/etc/sysconfig/node_exporter:
    file.managed:
        - source: salt://{{ slspath }}/files/sysconfig.node_exporter
        - user: node_exporter
        - group: node_exporter
        - mode: 0644


node_exporter_service_reload:
    cmd.run:
        - name: systemctl daemon-reload
        - watch: 
            - file: /etc/systemd/system/node_exporter.service
node_exporter_service:
    service.running:
        - name: node_exporter
        - enable: True
