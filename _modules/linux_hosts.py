# -*- coding: utf-8 -*-
'''
Module for defining new filter for sorting
host names/alias by FQDN first and alphabetically
'''

from jinja2 import Undefined

def __virtual__():
    return 'linux_hosts'

def fqdn_sort_fn(n1, n2):
    l1 = n1.split('.')
    l2 = n2.split('.')
    if len(l1) > len(l2):
        return -1
    if len(l1) < len(l2):
        return 1
    for i1, i2 in zip(l1, l2):
        if i1 < i2:
            return -1
        if i1  > i2:
            return 1
    return 0

def fqdn_sort_filter(iterable):
    if iterable is None or isinstance(iterable, Undefined):
        return iterable
    # Do effective custom sorting of iterable here
    return sorted(set(iterable), cmp=fqdn_sort_fn)
