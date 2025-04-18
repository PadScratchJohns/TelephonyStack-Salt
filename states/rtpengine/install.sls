# Install and run RTPengine
{% set osf = salt['grains.get']('oscodename') %}
{% set srv = salt['grains.get']('srvtype') %}

{% if not salt['file.file_exists']('/etc/apt/sources.list.d/rtpengine.list') %}
    {% if (osf == 'jammy') %}
rtpengine_jammy_repo_list:
  cmd.run:
    - name: |
        wget -O- http://kamailio.sipwise.com/debian/kamailiodebkey.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/rtpengine.gpg
        echo "deb [signed-by=/etc/apt/keyrings/rtpengine.gpg] http://kamailio.sipwise.com/debian/rtpengine-mr12.5 jammy  main" > /etc/apt/sources.list.d/rtpengine.list
        echo "deb-src [signed-by=/etc/apt/keyrings/rtpengine.gpg] http://kamailio.sipwise.com/debian/rtpengine-mr12.5 jammy  main" >> /etc/apt/sources.list.d/rtpengine.list
        apt update
    {% elif (osf == 'noble') %}
rtpengine_noble_repo_list:
  cmd.run:
    - name: |
        wget -O- http://kamailio.sipwise.com/debian/kamailiodebkey.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/rtpengine.gpg
        echo "deb [signed-by=/etc/apt/keyrings/rtpengine.gpg] http://kamailio.sipwise.com/debian/rtpengine-mr12.5 noble  main" > /etc/apt/sources.list.d/rtpengine.list
        echo "deb-src [signed-by=/etc/apt/keyrings/rtpengine.gpg] http://kamailio.sipwise.com/debian/rtpengine-mr12.5 noble  main" >> /etc/apt/sources.list.d/rtpengine.list
        apt update
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

# Install deps
Install_tools_deps:
    pkg.installed:
        - pkgs:
            - sngrep
            - net-tools
            - unzip 
            - jq
            - mtr

# apt install here 
rtpengine_software_install:
    pkg.installed:
        - refresh: True
        - pkgs:
            - rtpengine
