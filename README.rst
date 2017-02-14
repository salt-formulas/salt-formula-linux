
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
          # Enable serial console
          ttyS0:
            autologin: root
            rate: 115200
            term: xterm

To disable set autologin to `false`.

Set ``policy-rc.d`` on Debian-based systems. Action can be any available
command in ``while true`` loop and ``case`` context.
Following will disallow dpkg to stop/start services for cassandra package automatically:

.. code-block:: yaml

    linux:
      system:
        policyrcd:
          - package: cassandra
            action: exit 101
          - package: '*'
            action: switch

Set system locales:

.. code-block:: yaml

    linux:
      system:
        locale:
          en_US.UTF-8:
            default: true
          "cs_CZ.UTF-8 UTF-8":
            enabled: true

Kernel
~~~~~~

Install always up to date LTS kernel and headers from Ubuntu trusty:

.. code-block:: yaml

    linux:
      system:
        kernel:
          type: generic
          lts: trusty
          headers: true

Install specific kernel version and ensure all other kernel packages are
not present. Also install extra modules and headers for this kernel:

.. code-block:: yaml

    linux:
      system:
        kernel:
          type: generic
          extra: true
          headers: true
          version: 4.2.0-22

Systcl kernel parameters

.. code-block:: yaml

    linux:
      system:
        kernel:
          sysctl:
            net.ipv4.tcp_keepalive_intvl: 3
            net.ipv4.tcp_keepalive_time: 30
            net.ipv4.tcp_keepalive_probes: 8


CPU
~~~

Disable ondemand cpu mode service:

.. code-block:: yaml

    linux:
      system:
        cpu:
          governor: performance

Huge Pages
~~~~~~~~~~~~

Huge Pages give a performance boost to applications that intensively deal
with memory allocation/deallocation by decreasing memory fragmentation.

.. code-block:: yaml

    linux:
      system:
        kernel:
          hugepages:
            small:
              size: 2M
              count: 107520
              mount_point: /mnt/hugepages_2MB
              mount: false/true # default false
            large:
              default: true # default automatically mounted
              size: 1G
              count: 210
              mount_point: /mnt/hugepages_1GB

Note: not recommended to use both pagesizes in concurrently.

Intel SR-IOV
~~~~~~~~~~~~

PCI-SIG Single Root I/O Virtualization and Sharing (SR-IOV) specification defines a standardized mechanism to virtualize PCIe devices. The mechanism can virtualize a single PCIe Ethernet controller to appear as multiple PCIe devices.

.. code-block:: yaml

    linux:
      system:
        kernel:
          sriov: True
        rc:
          local: |
            #!/bin/sh -e
            # Enable 7 VF on eth1
            echo 7 > /sys/class/net/eth1/device/sriov_numvfs; sleep 2; ifup -a
            exit 0


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

rc.local example

.. code-block:: yaml

   linux:
     system:
       rc:
         local: |
           #!/bin/sh -e
           #
           # rc.local
           #
           # This script is executed at the end of each multiuser runlevel.
           # Make sure that the script will "exit 0" on success or any other
           # value on error.
           #
           # In order to enable or disable this script just change the execution
           # bits.
           #
           # By default this script does nothing.
           exit 0

Prompt
~~~~~~

Setting prompt is implemented by creating ``/etc/profile.d/prompt.sh``. Every
user can have different prompt.

.. code-block:: yaml

    linux:
      system:
        prompt:
          root: \\n\\[\\033[0;37m\\]\\D{%y/%m/%d %H:%M:%S} $(hostname -f)\\[\\e[0m\\]\\n\\[\\e[1;31m\\][\\u@\\h:\\w]\\[\\e[0m\\]
          default: \\n\\D{%y/%m/%d %H:%M:%S} $(hostname -f)\\n[\\u@\\h:\\w]

On Debian systems to set prompt system-wide it's necessary to remove setting
PS1 in ``/etc/bash.bashrc`` and ``~/.bashrc`` (which comes from
``/etc/skel/.bashrc``). This formula will do this automatically, but will not
touch existing user's ``~/.bashrc`` files except root.

Bash
~~~~

Fix bash configuration to preserve history across sessions (like ZSH does by
default).

.. code-block:: yaml

    linux:
      system:
        bash:
          preserve_history: true

Message of the day
~~~~~~~~~~~~~~~~~~

``pam_motd`` from package ``update-motd`` is used for dynamic messages of the
day. Setting custom motd will cleanup existing ones.

.. code-block:: yaml

    linux:
      system:
        motd:
          - release: |
              #!/bin/sh
              [ -r /etc/lsb-release ] && . /etc/lsb-release

              if [ -z "$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
              	# Fall back to using the very slow lsb_release utility
              	DISTRIB_DESCRIPTION=$(lsb_release -s -d)
              fi

              printf "Welcome to %s (%s %s %s)\n" "$DISTRIB_DESCRIPTION" "$(uname -o)" "$(uname -r)" "$(uname -m)"
          - warning: |
              #!/bin/sh
              printf "This is [company name] network.\n"
              printf "Unauthorized access strictly prohibited.\n"

RHEL / CentOS
^^^^^^^^^^^^^

Unfortunately ``update-motd`` is currently not available for RHEL so there's
no native support for dynamic motd.
You can still set static one, only pillar structure differs:

.. code-block:: yaml

    linux:
      system:
        motd: |
          This is [company name] network.
          Unauthorized access strictly prohibited.

Haveged
~~~~~~~

If you are running headless server and are low on entropy, it may be a good
idea to setup Haveged.

.. code-block:: yaml

    linux:
      system:
        haveged:
          enabled: true

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

Linux with bonded interfaces and disabled NetworkManager

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
        network_manager:
          disable: true

Linux with vlan interface_params

.. code-block:: yaml

    linux:
      network:
        enabled: true
        interface:
          vlan69:
            type: vlan
            use_interfaces:
            - interface: ${linux:interface:bond0}

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

Parameter purge_hosts will enforce whole /etc/hosts file, removing entries
that are not defined in model except defaults for both IPv4 and IPv6 localhost
and hostname + fqdn.
It's good to use this option if you want to ensure /etc/hosts is always in a
clean state however it's not enabled by default for safety.

.. code-block:: yaml

    linux:
      network:
        ...
        purge_hosts: true
        host:
          # No need to define this one if purge_hosts is true
          hostname:
            address: 127.0.1.1
            names:
            - ${linux:network:fqdn}
            - ${linux:network:hostname}
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


Setup resolv.conf, nameservers, domain and search domains

.. code-block:: yaml

    linux:
      network:
        resolv:
          dns:
            - 8.8.4.4
            - 8.8.8.8
          domain: my.example.com
          search:
            - my.example.com
            - example.com
          options:
            - ndots:5
            - timeout:2
            - attempts:2

Linux storage pillars
---------------------

Linux with mounted Samba

.. code-block:: yaml

    linux:
      storage:
        enabled: true
        mount:
          samba1:
          - enabled: true
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

Linux with partition swap

.. code-block:: yaml

    linux:
      storage:
        enabled: true
        swap:
          partition:
            enabled: true
            engine: partition
            device: /dev/vg0/swap

LVM group `vg1` with one device and `data` volume mounted into `/mnt/data`

.. code-block:: yaml

    parameters:
      linux:
        storage:
          mount:
            data:
              enabled: true
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


Multipath with Fujitsu Eternus DXL

.. code-block:: yaml

    parameters:
      linux:
        storage:
          multipath:
            enabled: true
            blacklist_devices:
            - /dev/sda
            - /dev/sdb
            backends:
            - fujitsu_eternus_dxl

Multipath with Hitachi VSP 1000

.. code-block:: yaml

    parameters:
      linux:
        storage:
          multipath:
            enabled: true
            blacklist_devices:
            - /dev/sda
            - /dev/sdb
            backends:
            - hitachi_vsp1000

Multipath with IBM Storwize

.. code-block:: yaml

    parameters:
      linux:
        storage:
          multipath:
            enabled: true
            blacklist_devices:
            - /dev/sda
            - /dev/sdb
            backends:
            - ibm_storwize

Multipath with multiple backends

.. code-block:: yaml

    parameters:
      linux:
        storage:
          multipath:
            enabled: true
            blacklist_devices:
            - /dev/sda
            - /dev/sdb
            - /dev/sdc
            - /dev/sdd
            backends:
            - ibm_storwize
            - fujitsu_eternus_dxl
            - hitachi_vsp1000

Disabled multipath (the default setup)

.. code-block:: yaml

    parameters:
      linux:
        storage:
          multipath:
            enabled: false

Linux with local loopback device

.. code-block:: yaml

    linux:
      storage:
        loopback:
          disk1:
            file: /srv/disk1
            size: 50G

External config generation
--------------------------

You are able to use config support metadata between formulas and only generate
config files for external use, eg. docker, etc.

.. code-block:: yaml

    parameters:
      linux:
        system:
          config:
            pillar:
              jenkins:
                master:
                  home: /srv/volumes/jenkins
                  approved_scripts:
                    - method java.net.URL openConnection
                  credentials:
                    - type: username_password
                      scope: global
                      id: test
                      desc: Testing credentials
                      username: test
                      password: test


Usage
=====

Set mtu of network interface eth0 to 1400

.. code-block:: bash

    ip link set dev eth0 mtu 1400

Read more
=========

* https://www.archlinux.org/
* http://askubuntu.com/questions/175172/how-do-i-configure-proxies-in-ubuntu-server-or-minimal-cli-ubuntu

Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-linux/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-linux

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
