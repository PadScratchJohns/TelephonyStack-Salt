# Install and run freeswitch
{% if not salt['file.file_exists']('/usr/local/freeswitch/bin/freeswitch') %}
# Install deps
freeswitch_deps_install:
    pkg.installed:
        - refresh: True
        - pkgs:
            - build-essential
            - pkg-config
            - uuid-dev
            - zlib1g-dev
            - libjpeg-dev
            - libsqlite3-dev
            - libcurl4-openssl-dev
            - libpcre3-dev
            - libspeexdsp-dev
            - libldns-dev
            - libedit-dev
            - libtiff5-dev
            - yasm
            - libopus-dev
            - libsndfile1-dev
            - unzip 
            - libavformat-dev
            - libswscale-dev
            - liblua5.2-dev
            - liblua5.2-0
            - cmake
            - libpq-dev
            - unixodbc-dev
            - autoconf
            - automake
            - ntpdate
            - libxml2-dev
            - libpq-dev
            - libpq5
            - sngrep
            - lua5.2
            - lua5.2-doc
            - libreadline-dev
            - libshout3-dev
            - ffmpeg
            - libmpg123-dev
            - libmp3lame-dev
            - libhiredis-dev
            - libtool
            - mtr
            - jq

# SpanDSP 
# locked at comit - 0d2e6ac due to compiling issues after this removing something that GCC needs to use in the sudo make install on FS.  
git_clone_spandsp:
    cmd.run:
        - name: |
            cd /usr/local/src/
            sudo git clone https://github.com/freeswitch/spandsp /usr/local/src/spandsp
            sudo chown -R freeswitch:freeswitch /usr/local/src/spandsp
            cd /usr/local/src/spandsp && git checkout 0d2e6ac
            sudo ./bootstrap.sh
            sudo ./configure
            sudo make
            sudo make install
# Install sofia-sip
git_clone_sofia_sip:
    cmd.run:
        - name: |
            cd /usr/local/src/
            sudo git clone https://github.com/freeswitch/sofia-sip.git /usr/local/src/sofia-sip-master
            sudo chown -R freeswitch:freeswitch /usr/local/src/sofia-sip-master/
            cd /usr/local/src/sofia-sip-master/
            sudo ./bootstrap.sh
            sudo ./configure
            sudo make
            sudo make install
# Locked at v1.10.12 - if you change the version sudo make sure you replace all!
get_freeswitch_tar:
    cmd.run:
        - cwd: /usr/local/src/
        - name: wget -O /usr/local/src/freeswitch.tar.gz https://files.freeswitch.org/releases/freeswitch/freeswitch-1.10.12.-release.tar.gz
extract_freeswitch_tar:
    archive.extracted:
        - name: /usr/local/src
        - enforced_toplevel: false
        - source: /usr/local/src/freeswitch.tar.gz
        - archive_format: tar
        - user: freeswitch
        - group: freeswitch
delete_old_freeswitch_tar_archieve:
    file.absent:
        - name: /usr/local/src/freeswitch.tar.gz
# Module support before compiling.
# The below has curl/hiredis/shout modules and removed signalwire and verto modules.
sed_for_compiling:
    cmd.run:
        - cwd: /usr/local/src/
        - name: |
            sed -i 's/#applications\/mod\_curl/applications\/mod\_curl/g' /usr/local/src/freeswitch-1.10.12.-release/modules.conf
            sed -i 's/#applications\/mod\_hiredis/applications\/mod\_hiredis/g' /usr/local/src/freeswitch-1.10.12.-release/modules.conf
            sed -i 's/#formats\/mod\_shout/formats\/mod\_shout/g' /usr/local/src/freeswitch-1.10.12.-release/modules.conf
            sed -i 's/applications\/mod\_signalwire/#applications\/mod\_signalwire/g' /usr/local/src/freeswitch-1.10.12.-release/modules.conf
            sed -i 's/endpoints\/mod\_verto/#endpoints\/mod\_verto/g' /usr/local/src/freeswitch-1.10.12.-release/modules.conf
configure_make_and_install:
    cmd.run:
        - cwd: /usr/local/src/freeswitch-1.10.12.-release/
        - name: | 
            sudo ./configure
            sudo make
            sudo make install 
            sudo make cd-sounds-install
            sudo make cd-moh-install
mkdirs_for_fs_log:
    file.directory:
        - name: /var/log/freeswitch
        - user: freeswitch
        - group: freeswitch
        - makedirs: True
        - mode: 0750
mkdirs_for_fs_pid:
    file.directory:
        - name: /var/run/freeswitch
        - user: freeswitch
        - group: freeswitch
        - makedirs: True
        - mode: 0750
simlinks_for_fs:
    cmd.run:
        - name: | 
            ln -s /usr/local/freeswitch/conf /etc/freeswitch
            ln -s /usr/local/freeswitch/bin/fs_cli /usr/bin/fs_cli
            ln -s /usr/local/freeswitch/bin/freeswitch /usr/sbin/freeswitch
            ln -s /usr/local/lib/libspandsp.so.3.0.0 /usr/local/freeswitch/bin/libspandsp.so.3.0.0
            ln -s /usr/local/lib/libspandsp.so.3 /usr/local/freeswitch/bin/libspandsp.so.3
            ln -s /usr/local/lib/libspandsp.so /usr/local/freeswitch/bin/libspandsp.so
chowns_for_fs:
    cmd.run:
        - name: | 
            chown -R freeswitch:freeswitch /usr/local/freeswitch/ 
            chmod -R ug=rwX,o= /usr/local/freeswitch/ 
            chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/*
ldconfig_for_spandsp_sofia:
    cmd.run:
        - name: | 
            ldconfig && ldconfig -p | grep spandsp
            ldconfig && ldconfig -p | grep sofia
# The above only needs to run once.

# Script to compile - not needed anymore but here for if you need to reference it.
# Manual install script
freeswitch_install_script:
  file.managed:
    - name: /cfg/freeswitch.sh
    - source: salt://{{ slspath }}/files/freeswitch.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 0755
    - require:
      - pkg: freeswitch_deps_install
#run_install_freeswitch:
#    cmd.run:
#        - name: /cfg/freeswitch.sh
{% endif %}
# sudo make sure the partition is mounted here - this is a safe script to run on prod boxes. 
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
