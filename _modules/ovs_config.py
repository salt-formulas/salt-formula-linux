# -*- coding: utf-8 -*-
'''
Support for Open vSwitch database configuration.

'''
from __future__ import absolute_import

import logging
import salt.utils.path

log = logging.getLogger(__name__)


def __virtual__():
    '''
    Only load the module if Open vSwitch is installed
    '''
    if salt.utils.path.which('ovs-vsctl'):
        return 'ovs_config'
    return False


def _retcode_to_bool(retcode):
    '''
    Evaulates ovs-vsctl command`s retcode value.

    Args:
        retcode: Value of retcode field from response.
    '''
    return True if retcode == 0 else False


def set(cfg, value, wait=True):
    '''
    Updates a specified configuration entry.

    Args:
        cfg/value: a config entry to update
        wait: wait or not for ovs-vswitchd to reconfigure itself before it exits.

    CLI Example:
    .. code-block:: bash

        salt '*' ovs_config.set other_config:dpdk-init true
    '''
    wait = '' if wait else '--no-wait '

    cmd = 'ovs-vsctl {0}set Open_vSwitch . {1}="{2}"'.format(wait, cfg, str(value).lower())
    result = __salt__['cmd.run_all'](cmd)
    return _retcode_to_bool(result['retcode'])


def remove(cfg):
    '''
    Removes a specified configuration entry.

    Args:
        cfg: a config entry to remove

    CLI Example:
    .. code-block:: bash

        salt '*' ovs_config.remove other_config
    '''
    if ':' in cfg:
        section, key = cfg.split(':')
        cmd = 'ovs-vsctl remove Open_vSwitch . {} {}'.format(section, key)
    else:
        cmd = 'ovs-vsctl clear Open_vSwitch . ' + cfg

    result = __salt__['cmd.run_all'](cmd)
    return _retcode_to_bool(result['retcode'])


def list():
    '''
    Return a current config of Open vSwitch

    CLI Example:

    .. code-block:: bash

        salt '*' ovs_config.list
    '''
    cmd = 'ovs-vsctl list Open_vSwitch .'
    result = __salt__['cmd.run_all'](cmd)

    if result['retcode'] == 0:
        config = {}
        for l in result['stdout'].splitlines():
            cfg, value = map((lambda x: x.strip()), l.split(' : '))
            if value.startswith('{') and len(value) > 2:
                for i in value[1:-1].replace('"', '').split(', '):
                    _k, _v = i.split('=')
                    config['{}:{}'.format(cfg,_k)] = _v
            else:
                config[cfg] = value

        return config
    else:
        return False
