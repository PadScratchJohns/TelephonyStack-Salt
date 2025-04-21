{% set osf = salt['grains.get']('oscodename') %}
# We want Postgresql 17 specifically installed via APT. So adding the postgres repo.
{% if not salt['file.file_exists']('/etc/apt/sources.list.d/pgdg.list') %}
Postgresql_repo_list:
  cmd.run:
    - name: |
        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
        curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
        apt update
{% endif %}
# MS repo for blobfuse repo
{% if not salt['file.file_exists']('/etc/apt/sources.list.d/microsoft-prod.list') %}
    {% if (osf == 'jammy') %}
ms_jammy_repo_list:
  cmd.run:
    - name: |
        curl -sSL -O https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update
    {% elif (osf == 'noble') %}
ms_noble_repo_list:
  cmd.run:
    - name: |
        curl -sSL -O https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update
    {% endif %}
{% endif %}
# make sure the partition is mounted here - this is a safe script to run on prod boxes. 
fstab_mount_script:
    file.managed:
        - name: /cfg/fstab_mount.sh
        - source: salt://{{ slspath }}/files/fstab_mount.sh
        - template: jinja
        - user: root
        - group: root
        - mode: 0755
# Needs the script before it runs. This is a production safe script that backs up and reverts if errors are found with mounting. 
run_fstab_script:
    cmd.run:
        - name: /cfg/fstab_mount.sh
        - require: 
            - file: /cfg/fstab_mount.sh

postgresql_install:
    pkg.installed:
        - refresh: true
        - pkgs:
            - gnupg2
            - python3-pip
            - python3-dev
            - libpq-dev
            - python3-testresources
            - net-tools
            - mtr
            - wget
            - curl
            - gcc
            - build-essential
            - zlib1g-dev
            - libreadline-dev
            - libicu-dev
            - pkg-config
            - postgresql-contrib
            - postgresql
{% if salt['file.file_exists']('/etc/patroni/config.yml') %}
            #- etcd # compiled manually for a version lock on v3.5 
            - patroni 
# automation breaks the quorum so install patroni seperate on a 2nd install. You do need to restart etcd to get quorum first though to gte the cluster going. 
# config and mkdirs still put on the box, but after quorum is reached on etcd, install patroni on where the leader is and bring the other nodes into it after it is up. 
{% endif %}
{% if not salt['file.file_exists']('/usr/sbin/postgres') %}
symlink_run_postgres:
    cmd.run:
        - name: sudo ln -s /usr/lib/postgresql/17/bin/* /usr/sbin/
        - require: 
            - pkg: postgresql_install
{% endif %}
{% if salt['file.file_exists']('/lib/systemd/system/postgresql.service') %}
# Patroni handles the posgres life cycle
stop_disable_postgres:
    cmd.run:
        - name: systemctl stop postgresql && systemctl disable postgresql
        - require: 
            - pkg: postgresql_install
{% endif %}
# Manual compile of etcd
etcd_install_script:
    file.managed:
        - name: /cfg/etcdinstall.sh
        - source: salt://{{ slspath }}/files/etcdinstall.sh
        - template: jinja
        - user: root
        - group: root
        - mode: 0755
{% if not salt['file.file_exists']('/lib/systemd/system/etcd.service') %}
# Patroni handles the posgres life cycle
run_etcd_install_scripts:
    cmd.run:
        - name: /cfg/etcdinstall.sh
        - require: 
            - file: /cfg/etcdinstall.sh
{% endif %}
# Direct to blob backups
direct_to_blob_software_install:
    pkg.installed:
        - refresh: True
        - pkgs:
            - fuse3
            - blobfuse2
