# generic OS based install.
{% set osf = salt['grains.get']('oscodename') %}
{% set rol = salt['grains.get']('roles') %}
# setting the repo in apt
{% if (osf == 'jammy') %}

{% if (osf == 'noble') %}
{% if not salt['file.file_exists']('/etc/apt/sources.list.d/freeswitch.list') %}