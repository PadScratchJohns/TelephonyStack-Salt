{% set osf = salt['grains.get']('osfullname') %}
{% if (osf == 'Ubuntu') %}
# MOTD Banner for Ubuntu
ubuntu_motd:
    file.managed:
        - name: /etc/motd
        - source: salt://{{ slspath }}/files/ubuntumotd
        - template: jinja
        - user: root
        - group: root
        - mode: 0644
{% endif %}