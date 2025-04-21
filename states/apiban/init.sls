{% set ins = salt['grains.get']('instance') %}
# GO and APIBAN installs.
# installs deps first:
apiban_deps_install:
    pkg.installed:
        - pkgs:
            - wget
            - tar
# Only runt he below if the folder - go does NOT exist in /usr/local path
{% if not salt['file.directory_exists']('/usr/local/go') %}
# GO install. Locked at 1.24
get_go_tar:
    cmd.run:
        - name: wget -O /tmp/go1.24.0.linux-amd64.tar.gz https://go.dev/dl/go1.24.0.linux-amd64.tar.gz
extract_go_tar:
    archive.extracted:
        - name: /tmp
        - enforced_toplevel: false
        - source: /tmp/go1.24.0.linux-amd64.tar.gz
        - archive_format: tar
        - user: root
        - group: root
move_go_tar:
    file.rename:
        - name: /usr/local/go
        - source: /tmp/go
delete_old_go_tar_folder:
    file.absent:
        - name: /tmp/go
delete_old_go_tar_archieve:
    file.absent:
        - name: /tmp/go1.24.0.linux-amd64.tar.gz
# Adding $PATH so the users on the system can use GO - aka maxsupport user.
adding_path_to_profile:
    cmd.run:
        - name: echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
# test with: go version
# go version go1.24.0 linux/amd64

# apiban install. Locked at 1.20
# mkdirs
api_ban_data_dir:
    file.directory:
        - name: /usr/local/bin/apiban/
        - user: root
        - group: root
        - makedirs: True
        - mode: 0750
get_apiban_tar:
    cmd.run:
        - name: wget -O /tmp/apiban-iptables-client https://github.com/apiban/apiban-client-go/raw/v1.0/apiban-iptables-client  
move_apiban_tar:
    file.rename:
        - name: /usr/local/bin/apiban/apiban-iptables-client
        - source: /tmp/apiban-iptables-client

delete_old_apiban_tar_archieve:
    file.absent:
        - name: /tmp/apiban-iptables-client
# mkdirs and perms
execute_perms_abi_ban:
    cmd.run:
        - name: chmod +x /usr/local/bin/apiban/apiban-iptables-client
{% endif %}

apiban_config:
    file.managed:
        - name: /usr/local/bin/apiban/config.json
        - source: salt://{{ slspath }}/files/config.json
        - template: jinja
        - user: root
        - group: root
        - mode: 0755
# cron to run the job 
apiban_cron_script:
    file.managed:
        - name: /cfg/apiban.sh
        - source: salt://{{ slspath }}/files/apiban.sh
        - template: jinja
        - user: root
        - group: root
        - mode: 0755
# Cron start script hourly +1/2/3/etc minutes for the instance number. 
# Any timing arguments not specified take a value of *
/cfg/apiban.sh:
    cron.present:
        - identifier: APIBAN Cron
        - user: root
        #- special: '@hourly'
        - minute: {{ ins }}