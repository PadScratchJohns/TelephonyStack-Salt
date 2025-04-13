#!/usr/bin/python3
# -*- coding: utf-8 -*-
# When using Salt >v3004 use the stacks own python interpreter under /opt/saltstack/bin/python I think
# test this
from __future__ import absolute_import, print_function, unicode_literals
import re
import salt.utils.network
import urllib.request
from pathlib import Path
from salt.utils.network import get_fqhostname
from salt.utils.network import interfaces

# Needs the hostname set in /etc/hostname before running this script. 
def env_grain():
    fqdn = get_fqhostname() or 'localhost.localdomain'
    interfaces = salt.utils.network.interfaces()

# parse FQDN into components - removed the domain split and added a straight variable.
    hostname, domain = fqdn.split('.', 1)
    if len(hostname.split('-')) == 6:
        (
            location,
            env,
            role,
            srvtype,
            instance,
            zone,
            ) = hostname.split('-')

    else:
        (location, env, role, instance, zone) = hostname.split('-')
        srvtype = None

#setting the platform delimeter is "." currently but could be anything
    hostname, domain = fqdn.split('.', 1)
    if len(domain.split('-')) == 2:
        (
            product,
            platform,
            ) = domain.split('-')
    else:
        (product) = domain.split('.')
        platform = None

    roles = [role]

    if role:
        roles.append(role)

# defining the public address
    public_ipv4= urllib.request.urlopen('https://ident.me').read().decode('utf8')
# define the "moniker" for product targetting and recognition in saltmaster - so SIPRec/Loadtest/Telcostack etc
    #moniker = Path('/cfg/moniker').read_text().splitlines()
    return {
        'location': location,
        'environment': env,
        'roles': role,
        'srvtype': srvtype,
        'instance': instance,
        'zone': zone,
        'public_ipv4': public_ipv4,
        'platform': platform,
        'product': product,
        }

if __name__ == '__main__':
    grains = env_grain()
    print(grains)
