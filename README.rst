
=====
Linux
=====

Linux Operating Systems.

* Ubuntu
* CentOS
* RedHat
* Fedora
* Arch

Sample pillars
==============

Linux system
------------

Basic Linux box

.. code-block:: yaml

    linux:
      system:
        enabled: true
        name: 'node1'
        domain: 'domain.com'
        cluster: 'system'
        environment: prod
        timezone: 'Europe/Prague'
        utc: true

Linux with system users, sowe with password set

.. code-block:: yaml

    linux:
      system:
        ...
        user:
          jdoe:
            name: 'jdoe'
            enabled: true
            sudo: true
            shell: /bin/bash
            full_name: 'Jonh Doe'
            home: '/home/jdoe'
            email: 'jonh@doe.com'
          jsmith:
            name: 'jsmith'
            enabled: true
            full_name: 'Password'
            home: '/home/jsmith'
            password: userpassword

Linux with package, latest version

.. code-block:: yaml

    linux:
      system:
        ...
        package:
          package-name:
            version: latest

Linux with package from certail repo, version with no upgrades

.. code-block:: yaml

    linux:
      system:
        ...
        package:
          package-name:
            version: 2132.323
            repo: 'custom-repo'
            hold: true

Linux with package from certail repo, version with no GPG verification

.. code-block:: yaml

    linux:
      system:
        ...
        package:
          package-name:
            version: 2132.323
            repo: 'custom-repo'
            verify: false

Linux with cron jobs

.. code-block:: yaml

    linux:
      system:
        ...
        job:
          cmd1:
            command: '/cmd/to/run'
            enabled: true
            user: 'root'
            hour: 2
            minute: 0

Linux security limits (limit sensu user memory usage to max 1GB):

.. code-block:: yaml

    linux:
      system:
        ...
        limit:
          sensu:
            enabled: true
            domain: sensu
            limits:
              - type: hard
                item: as
                value: 1000000

Enable autologin on tty1 (may work only for Ubuntu 14.04):

.. code-block:: yaml

    linux:
      system:
        console:
          tty1:
            autologin: root

To disable set autologin to `false`.

Repositories
~~~~~~~~~~~~

RedHat based Linux with additional OpenStack repo

.. code-block:: yaml

    linux:
      system:
        ...
        repo:
          rdo-icehouse:
            enabled: true
            source: 'http://repos.fedorapeople.org/repos/openstack/openstack-icehouse/epel-6/'
            pgpcheck: 0

Ensure system repository to use czech Debian mirror (``default: true``)
Also pin it's packages with priority 900.

.. code-block:: yaml

   linux:
     system:
       repo:
         debian:
           default: true
           source: "deb http://ftp.cz.debian.org/debian/ jessie main contrib non-free"
           # Import signing key from URL if needed
           key_url: "http://dummy.com/public.gpg"
           pin:
             - pin: 'origin "ftp.cz.debian.org"'
               priority: 900
               package: '*'

Linux network
-------------

Linux with network manager

.. code-block:: yaml

    linux:
      network:
        enabled: true
        network_manager: true

Linux with default static network interfaces, default gateway interface and DNS servers

.. code-block:: yaml

    linux:
      network:
        enabled: true
        interface:
          eth0:
            enabled: true
            type: eth
            address: 192.168.0.102
            netmask: 255.255.255.0
            gateway: 192.168.0.1
            name_servers:
            - 8.8.8.8
            - 8.8.4.4
            mtu: 1500

Linux with bonded interfaces

.. code-block:: yaml

    linux:
      network:
        enabled: true
        interface:
          eth0:
            type: eth
            ...
          eth1:
            type: eth
            ...
          bond0:
            enabled: true
            type: bond
            address: 192.168.0.102
            netmask: 255.255.255.0
            mtu: 1500
            use_in:
            - interface: ${linux:interface:eth0}
            - interface: ${linux:interface:eth0}

Linux with wireless interface parameters

.. code-block:: yaml

    linux:
      network:
        enabled: true
        gateway: 10.0.0.1
        default_interface: eth0 
        interface:
          wlan0:
            type: eth
            wireless:
              essid: example
              key: example_key
              security: wpa
              priority: 1

Linux networks with routes defined

.. code-block:: yaml

    linux:
      network:
        enabled: true
        gateway: 10.0.0.1
        default_interface: eth0 
        interface:
          eth0:
            type: eth
            route:
              default:
                address: 192.168.0.123
                netmask: 255.255.255.0
                gateway: 192.168.0.1

Native Linux Bridges

.. code-block:: yaml

    linux:
      network:
        interface:
          eth1:
            enabled: true
            type: eth
            proto: manual
            up_cmds:
            - ip address add 0/0 dev $IFACE
            - ip link set $IFACE up
            down_cmds:
            - ip link set $IFACE down
          br-ex:
            enabled: true
            type: bridge
            address: ${linux:network:host:public_local:address}
            netmask: 255.255.255.0
            use_interfaces:
            - eth1

OpenVswitch Bridges

.. code-block:: yaml

    linux:
      network:
        bridge: openvswitch
        interface:
          eth1:
            enabled: true
            type: eth
            proto: manual
            up_cmds:
            - ip address add 0/0 dev $IFACE
            - ip link set $IFACE up
            down_cmds:
            - ip link set $IFACE down
          br-ex:
            enabled: true
            type: bridge
            address: ${linux:network:host:public_local:address}
            netmask: 255.255.255.0
            use_interfaces:
            - eth1

Linux with proxy

.. code-block:: yaml

    linux:
      network:
        ...
        proxy:
          host: proxy.domain.com
          port: 3128

Linux with hosts

.. code-block:: yaml

    linux:
      network:
        ...
        host:
          node1:
            address: 192.168.10.200
            names:
            - node2.domain.com
            - service2.domain.com
          node2:
            address: 192.168.10.201
            names:
            - node2.domain.com
            - service2.domain.com

Linux storage pillars
---------------------

Linux with mounted Samba

.. code-block:: yaml

    linux:
      storage:
        enabled: true
        mount:
          samba1:
          - path: /media/myuser/public/
          - device: //192.168.0.1/storage
          - file_system: cifs
          - options: guest,uid=myuser,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm

Linux with file swap

.. code-block:: yaml

    linux:
      storage:
        enabled: true
        swap:
          file:
            enabled: true
            engine: file
            device: /swapfile
            size: 1024

LVM group `vg1` with one device and `data` volume mounted into `/mnt/data`

.. code-block:: yaml

    parameters:
      linux:
        storage:
          mount:
            data:
              device: /dev/vg1/data
              file_system: ext4
              path: /mnt/data
          lvm:
            vg1:
              enabled: true
              devices:
                - /dev/sdb
              volume:
                data:
                  size: 40G
                  mount: ${linux:storage:mount:data}

Usage
=====

Set mtu of network interface eth0 to 1400

.. code-block:: bash

    ip link set dev eth0 mtu 1400

Read more
=========

* https://www.archlinux.org/
* http://askubuntu.com/questions/175172/how-do-i-configure-proxies-in-ubuntu-server-or-minimal-cli-ubuntu
