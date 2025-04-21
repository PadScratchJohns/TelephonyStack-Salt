{% set ins = salt['grains.get']('instance') %}
{% set zone = salt['grains.get']('zone') %}
# mkdirs for postgres - check further below for backups and blobmount  - /var/lib/postgresql/data
patroni_data_dir:
    file.directory:
        - name: /var/lib/postgresql/data
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0750
pg_data_disk:
    file.directory:
        - name: /data01
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0777
wal_data_disk:
    file.directory:
        - name: /data01/wal
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0777
datafiles_mkdir_data_disk:
    file.directory:
        - name: /data01/datafiles
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0751
patroni_mkdir_data_disk:
    file.directory:
        - name: /data01/patroni
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0751
postgres_mkdir_data_disk:
    file.directory:
        - name: /data01/postgres
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0751
pg_log_mkdir_data_disk:
    file.directory:
        - name: /data01/log/pg_log
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0751
patroni_log_mkdir_data_disk:
    file.directory:
        - name: /data01/log/patroni_log
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0751
wal_archive_mkdir_data_disk:
    file.directory:
        - name: /data01/wal/archive
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0751
pg_wal_mkdir_data_disk:
    file.directory:
        - name: /data01/wal/pg_wal
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0751
etcd_mkdir_data_disk:
    file.directory:
        - name: /data01/wal/etcd 
        - user: etcd
        - group: etcd
        - makedirs: True
        - mode: 0751
etcd_mkdir_data_dir:
    file.directory:
        - name: /etc/etcd 
        - user: etcd
        - group: etcd
        - makedirs: True
        - mode: 0751
lib_etcd_mkdir_data_dir:
    file.directory:
        - name: /var/lib/etcd
        - user: etcd
        - group: etcd
        - makedirs: True
        - mode: 0700
patroni_mkdir_config_dir:
    file.directory:
        - name: /etc/patroni
        - user: postgres
        - group: postgres
        - makedirs: True
        - mode: 0751
# Postgres config is handled with patroni
# Config file: patroni controls - max_connections, max_locks_per_transaction, max_worker_processes, max_prepared_transactions, wal_level, track_commit_timestamp
# Commented this as this breaks patroni if you update the config without doing a patronictl command to update the config.
# On first provision comment out the patroni install then once quorum is achived in etcd then install and restart thje patroni service to get the pg_loc
patroni_config_yml:
  file.managed:
    - name: /etc/patroni/config.yml 
    #- name: /cfg/patroniconfig.yml
    - source: salt://{{ slspath }}/files/patroniconfig.yml.jinja2
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 0644
# etcd config - newetcd.env is the same file but cluster state is new - this is needed for initial cluster quorum.
# As in - it needs "new" to initialise and "existing" to add in new nodes to an already existing quorum.
# New cluster setup - run automation - restart etcd service - run automation - This will get you fully up and working. 
etcd_config_env:
  file.managed:
    - name: /etc/etcd/etcd.env
{% if not salt['file.file_exists']('/etc/etcd/etcd.env') %}
    - source: salt://{{ slspath }}/files/newetcd.env.jinja2
{% else %}
    - source: salt://{{ slspath }}/files/etcd.env.jinja2
{% endif %}    
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
# Leader check - manual
leader_check_script:
    file.managed:
        - name: /cfg/checkleader.sh
        - source: salt://{{ slspath }}/files/checkleader.sh.jinja2
        - template: jinja
        - user: root
        - group: root
        - mode: 0755
# watchdog rules
watchdog_rules_script:
    file.managed:
        - name: /etc/udev/rules.d/60-watchdog.rules
        - source: salt://{{ slspath }}/files/60-watchdog.rules
        - template: jinja
        - user: root
        - group: root
        - mode: 0644
# hosts.allow
Hosts_allow_file:
    file.managed:
        - name: /etc/hosts.allow
        - source: salt://{{ slspath }}/files/hosts.allow.jinja2
        - template: jinja
        - user: root
        - group: root
        - mode: 0644
# Variable swap for postgres and replication passwords
variable_swap_script:
    file.managed:
        - name: /cfg/variableswap.sh
        - source: salt://{{ slspath }}/files/variableswap.sh
        - template: jinja
        - user: root
        - group: root
        - mode: 0755

# Blob Fuse linked storage account. 
# Make blob dir
blobfuse_conf_mkdir:
    file.directory:
        - name: /etc/blobfuse/
        - user: root
        - group: root
        - mode: 0755
        - makedirs: True
# tmp_cache will only contain tmp files whilst uploading to blob
tmp_blob_cache_mkdir:
    file.directory:
        - name: /data01/tmp_cache
        - user: root
        - group: root
        - mode: 0777
        - makedirs: True
# blobmount is chmod 0777 as this is set and cannot be changed once mounted. 
blob_mount_mkdir:
    file.directory:
        - name: /data01/backups
        - user: root
        - group: root
        - mode: 0777
        - makedirs: True
# fuse.conf file - allows other linux users other than file owners to access the fuse mount - required file
fuse_conf_file:
    file.managed:
        - name: /etc/fuse.conf
        - source: salt://{{ slspath }}/files/fuse.conf
        - template: jinja
        - user: root
        - group: root
        - mode: 0644
# Blob mount config file - holds sensitive info so using a script to input that from ADO library so its not in this repo
blob_config_file:
    file.managed:
        - name: /etc/blobfuse/blobfuse.yaml
        - source: salt://{{ slspath }}/files/blobfuse.yaml.jinja2
        - template: jinja
        - user: root
        - group: root
        - mode: 0600
{% if not salt['file.file_exists']('/var/log/blobfuse2.log') %}
# Place the file if not already placed. 
record_to_blob_log_file:
    file.managed:
        - name: /var/log/blobfuse2.log
        - source: salt://{{ slspath }}/files/blobfuse2.log
        - template: jinja
        - user: root
        - group: root
        - mode: 0644
# Mounting for persistance
persistant_mount_blobfuse:
    cmd.run:
        - name: echo "blobfuse2 /data01/backups fuse3 defaults,_netdev,--config-file=/etc/blobfuse/blobfuse.yaml,allow_other 0 0" >> /etc/fstab
        - require: 
            - file: /var/log/blobfuse2.log
{% endif %}

# Needs the script before it runs.
variable_swap_execute:
    cmd.run:
        - name: /cfg/variableswap.sh
        - require: 
            - file: /cfg/variableswap.sh

patroni_post_init_script:
    file.managed:
        - name: /cfg/post_init.sh
        - source: salt://{{ slspath }}/files/post_init.sh
        - template: jinja
        - user: postgres
        - group: postgres
        - mode: 0755
# Backup script and cron job for it:
# Script to create and place backups in blob mounted path 
backups_move_to_blob_mount:
    file.managed:
        - name: /cfg/pg_dump.sh
        - source: salt://{{ slspath }}/files/pg_dump.sh.jinja2
        - template: jinja
        - user: root
        - group: root
        - mode: 0755
# Cron start script every hour at the {{ zone }}{{ ins }} int value - so vm1 backs up at 11 min past the hour, vm2 at 22 etc etc - vm4 is 14 mins, vm7 is 17 mins ...
/cfg/pg_dump.sh:
    cron.present:
        - user: root
        - minute: {{ zone }}{{ ins }}