# -*- coding: utf-8 -*-
'''
Management of Open vSwitch configuration
========================================

The OVS config can be managed with the ovs_config state module:

.. code-block:: yaml

    other_config:dpdk-init:
      ovs_config.present:
        - value: True

    other_config:dpdk-extra:
      ovs_config.present:
        - value: -n 12 --vhost-owner libvirt-qemu:kvm --vhost-perm 0664

    external_ids:
      ovs_config.absent
'''


def __virtual__():
    '''
    Only make these states available if Open vSwitch is installed.
    '''
    return 'ovs_config.list' in __salt__


def present(name, value, wait=True):
    '''
    Ensures that the named config exists, eventually creates it.

    Args:
        name/value: The name/value of the config entry.
        wait: Whether wait for ovs-vswitchd to reconfigure itself according to the modified database.
    '''
    ret = {'name': name, 'changes': {}, 'result': False, 'comment': ''}
    ovs_config = __salt__['ovs_config.list']()

    if name in ovs_config and ovs_config[name] == str(value).lower():
        ret['result'] = True
        ret['comment'] = '{0} is already set to {1}.'.format(name, value)
    else:
        config_updated = __salt__['ovs_config.set'](name, value, wait)
        if config_updated:
            ret['result'] = True
            ret['comment'] = '{0} is updated.'.format(name)
            ret['changes'] = { name: 'Updated to {0}'.format(value) }
        else:
            ret['result'] = False
            ret['comment'] = 'Unable to update config of {0}.'.format(name)

    return ret


def absent(name):
    '''
    Ensures that the named config does not exist, eventually deletes it.

    Args:
        name: The name of the config entry.

    '''
    ret = {'name': name, 'changes': {}, 'result': False, 'comment': ''}
    ovs_config = __salt__['ovs_config.list']()

    if ':' in name and name not in ovs_config:
        ret['result'] = True
        ret['comment'] = '{0} does not exist.'.format(name)
    else:
        config_removed = __salt__['ovs_config.remove'](name)
        if config_removed:
            ret['result'] = True
            ret['comment'] = '{0} is removed.'.format(name)
            ret['changes'] = { name: '{0} removed'.format(name) }
        else:
            ret['result'] = False
            ret['comment'] = 'Unable to delete config of {0}.'.format(name)

    return ret
