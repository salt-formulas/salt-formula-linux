# -*- coding: utf-8 -*-

import re

_alphanum_re = re.compile(r'^[a-z0-9]+$')
_lo_re = re.compile(r'^lo$')


def _filter(interface):
    return _alphanum_re.match(interface) and not _lo_re.match(interface)


def ls():
    """
    Provide a list of network interfaces.
    """
    return filter(_filter, __salt__['grains.get']('ip_interfaces', {}).keys())
