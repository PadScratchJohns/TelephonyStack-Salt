{% set pip = salt['pillar.get']('pip:proxy') %}
{% set osf = salt['grains.get']('oscodename') %}
# Kamailio Repos: 5.8 here - change the below if you need a version bump or add an env block if you want to test in others envs before going to prod.
{% if not salt['file.file_exists']('/etc/apt/sources.list.d/kamailio.list') %}
    {% if (osf == 'jammy') %}
kamailio_jammy_repo_list:
  cmd.run:
    - name: |
        wget -O- https://deb.kamailio.org/kamailiodebkey.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/kamailio.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio58 jammy main" > /etc/apt/sources.list.d/kamailio.list
        echo "deb-src [signed-by=/etc/apt/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio58 jammy main" >> /etc/apt/sources.list.d/kamailio.list
        apt update
    {% elif (osf == 'noble') %}
# Noble not yet supported as of 180924 - this will be added in time though. 
Kamailio_noble_repo_list:
  cmd.run:
    - name: |
        wget -O- https://deb.kamailio.org/kamailiodebkey.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/kamailio.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio58 noble main" > /etc/apt/sources.list.d/kamailio.list
        echo "deb-src [signed-by=/etc/apt/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio58 noble main" >> /etc/apt/sources.list.d/kamailio.list
        apt update
    {% endif %}
{% endif %}

kamailio_packages.install:
    pkg.installed:
        - refresh: true
        - pkgs:
            - kamailio
            - kamailio-python3-modules
            - kamailio-postgres-modules
            #- python3-pip
            - sngrep
            - mtr
            - jq
            - net-tools
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