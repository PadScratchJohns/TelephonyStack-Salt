# Install and run janus
{% if not salt['file.file_exists']('/usr/local/janus/bin/janus') %}
# Install deps
janus_deps_install:
    pkg.installed:
        - refresh: True
        - pkgs:
            - pkg-config
            - glib
            - zlib
            - jansson
            - libconfig
            - libnice 
            - openssl
            - libsrtp2-dev
            - libsrtp2-1
            - libwebsockets-dev
            - cmake
            - libcurl
            - libmicrohttpd-dev
            - libjansson-dev
            - libssl-dev
            - libsofia-sip-ua-dev
            - libglib2.0-dev
            - libopus-dev
            - libogg-dev
            - libcurl4-openssl-dev
            - liblua5.3-dev
            - libconfig-dev
            - libtool
            - automake
            - libopus-dev # opus support if needed
            - libnice-dev
            - libnice10

# Install sofia-sip - for the SIP plugin.
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

clone_janus_repo:
    cmd.run:
        - cwd: /usr/local/src/
        - name: |
            sudo git clone https://github.com/meetecho/janus-gateway.git /usr/local/src/janus
            cd /usr/local/src/janus
            sh autogen.sh
            ./configure --prefix=/opt/janus
            make
            make install
            make configs
{% endif %}
