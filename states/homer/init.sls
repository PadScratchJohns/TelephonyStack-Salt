# using postgres 17 as of 17/12/24
# Postgres is installed on the VM that homer is. 
# TODO - create config file to allow a pillar grain to put in a connection string or pgpass file.
{% if not salt['file.file_exists']('/etc/apt/sources.list.d/pgdg.list') %}
Postgresql_repo_list:
  cmd.run:
    - name: |
        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
        curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
        apt update
{% endif %}
# make sure the partition is mounted here
homer_datadisk_mount_script:
    file.managed:
        - name: /cfg/fstab_mount.sh
        - source: salt://{{ slspath }}/files/fstab_mount.sh
        - template: jinja
        - user: root
        - group: root
        - mode: 0755
# Needs the script before it runs. This is a production safe script that backs up and reverts if errors are found with mounting. 
run_homer_datadisk_mount_script:
    cmd.run:
        - name: /cfg/fstab_mount.sh
        - require: 
            - file: /cfg/fstab_mount.sh
# Homer 7 install and config - universal 
install_dependencies:
  pkg.installed:
    - pkgs:
      - libluajit-5.1-common
      - libluajit-5.1-dev
      - lsb-release
      - wget
      - curl
      - git
      - jq
      - mtr

install_homer_script:
  file.managed:
      - name: /tmp/homer_installer.sh
      - source: salt://{{ slspath }}/files/homer_installer.sh
      - mode: 0777

{% if not salt['file.file_exists']('/lib/systemd/system/heplify-server.service') %}
homer_install_run:
    cmd.run:
      - name: sudo echo yes | /tmp/homer_installer.sh
      - require: 
          - file: /tmp/homer_installer.sh
{% endif %}
#datadisk_mkdir_etc:
#    file.directory:
#        - name: /data01
#        - user: postgres
#        - group: postgres
#        - makedirs: True
#        - mode: 0744
#        - require: 
#            - file: /tmp/homer_installer.sh

homer_web_running_and_restart:
    service.running:
      - name: homer-app.service
      - enable: True

heplify_service_file:
    file.managed:
      - name: /lib/systemd/system/heplify-server.service
      - source: salt://{{ slspath }}/files/heplify-server.service
      - user: root
      - group: root
      - mode: 0644
      - require:
          - pkg: install_dependencies

homer_service_file:
    file.managed:
      - name: /lib/systemd/system/homer-app.service
      - source: salt://{{ slspath }}/files/homer-app.service
      - user: root
      - group: root
      - mode: 0644
      - require:
          - pkg: install_dependencies

heplify_running_and_restart:
    service.running:
      - name: heplify-server.service
      - enable: True
      - reload: True

homer_running_and_restart:
    service.running:
      - name: homer-app.service
      - enable: True
      - reload: True
