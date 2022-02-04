# -*- coding: utf-8 -*-
'''
Module for defining new filter for sorting
host names/alias by FQDN first and alphabetically
'''

from jinja2 import Undefined

def __virtual__():
    return 'linux_hosts'

def fqdn_sort_fn(n1):
    length = len(n1)
    return length

def fqdn_sort_filter(iterable):
    if iterable is None or isinstance(iterable, Undefined):
        return iterable
    # Do effective custom sorting of iterable here
    return sorted(set(iterable), key=fqdn_sort_fn)
