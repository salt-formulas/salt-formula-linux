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

Linux with system users, some with password set

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

Configure sudo for users and groups under ``/etc/sudoers.d/``.
This ways ``linux.system.sudo`` pillar map to actual sudo attributes:

.. code-block:: jinja
   # simplified template:
   Cmds_Alias {{ alias }}={{ commands }}
   {{ user }}   {{ hosts }}=({{ runas }}) NOPASSWD: {{ commands }}
   %{{ group }} {{ hosts }}=({{ runas }}) NOPASSWD: {{ commands }}

   # when rendered:
   saltuser1 ALL=(ALL) NOPASSWD: ALL


.. code-block:: yaml
  linux:
    system:
      sudo:
        enabled: true
        alias:
          host:
            LOCAL:
            - localhost
            PRODUCTION:
            - db1
            - db2
          runas:
            DBA:
            - postgres
            - mysql
            SALT:
            - root
          command:
            # Note: This is not 100% safe when ALL keyword is used, user still may modify configs and hide his actions.
            #       Best practice is to specify full list of commands user is allowed to run.
            SUPPORT_RESTRICTED:
            - /bin/vi /etc/sudoers*
            - /bin/vim /etc/sudoers*
            - /bin/nano /etc/sudoers*
            - /bin/emacs /etc/sudoers*
            - /bin/su - root
            - /bin/su -
            - /bin/su
            - /usr/sbin/visudo
            SUPPORT_SHELLS:
            - /bin/sh
            - /bin/ksh
            - /bin/bash
            - /bin/rbash
            - /bin/dash
            - /bin/zsh
            - /bin/csh
            - /bin/fish
            - /bin/tcsh
            - /usr/bin/login
            - /usr/bin/su
            - /usr/su
            ALL_SALT_SAFE:
            - /usr/bin/salt state*
            - /usr/bin/salt service*
            - /usr/bin/salt pillar*
            - /usr/bin/salt grains*
            - /usr/bin/salt saltutil*
            - /usr/bin/salt-call state*
            - /usr/bin/salt-call service*
            - /usr/bin/salt-call pillar*
            - /usr/bin/salt-call grains*
            - /usr/bin/salt-call saltutil*
            SALT_TRUSTED:
            - /usr/bin/salt*
        users:
          # saltuser1 with default values: saltuser1 ALL=(ALL) NOPASSWD: ALL
          saltuser1: {}
          saltuser2:
            hosts:
            - LOCAL
          # User Alias DBA
          DBA:
            hosts:
            - ALL
            commands:
            - ALL_SALT_SAFE
        groups:
          db-ops:
            hosts:
            - ALL
            - '!PRODUCTION'
            runas:
            - DBA
            commands:
            - /bin/cat *
            - /bin/less *
            - /bin/ls *
          salt-ops:
            hosts:
            - 'ALL'
            runas:
            - SALT
            commands:
            - SUPPORT_SHELLS
          salt-ops-2nd:
            name: salt-ops
            nopasswd: false
            runas:
            - DBA
            commands:
            - ALL
            - '!SUPPORT_SHELLS'
            - '!SUPPORT_RESTRICTED'

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

Linux with autoupdates (automatically install security package updates)

.. code-block:: yaml

    linux:
      system:
        ...
        autoupdates:
          enabled: true
          mail: root@localhost
          mail_only_on_error: true
          remove_unused_dependencies: false
          automatic_reboot: true
          automatic_reboot_time: "02:00"

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

Load kernel modules and add them to `/etc/modules`:

.. code-block:: yaml

    linux:
      system:
        kernel:
          modules:
            - nf_conntrack
            - tp_smapi
            - 8021q

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
          unsafe_interrupts: False # Default is false. for older platforms and AMD we need to add interrupt remapping workaround
        rc:
          local: |
            #!/bin/sh -e
            # Enable 7 VF on eth1
            echo 7 > /sys/class/net/eth1/device/sriov_numvfs; sleep 2; ifup -a
            exit 0

Isolate CPU options
~~~~~~~~~~~~~~~~~~~

Remove the specified CPUs, as defined by the cpu_number values, from the general kernel
SMP balancing and scheduler algroithms. The only way to move a process onto or off an
"isolated" CPU is via the CPU affinity syscalls. cpu_number begins at 0, so the
maximum value is 1 less than the number of CPUs on the system.

.. code-block:: yaml

    linux:
      system:
        kernel:
          isolcpu: 1,2,3,4,5,6,7 # isolate first cpu 0

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
          - ndots: 5
          - timeout: 2
          - attempts: 2

DPDK OVS interfaces
--------------------

**DPDK OVS NIC**

.. code-block:: yaml

    linux:
      network:
        bridge: openvswitch
        dpdk:
          enabled: true
          driver: uio/vfio-pci
        openvswitch:
          pmd_cpu_mask: "0x6"
          dpdk_socket_mem: "1024,1024"
          dpdk_lcore_mask: "0x400"
          memory_channels: 2
        interface:
          dpkd0:
            name: ${_param:dpdk_nic}
            pci: 0000:06:00.0
            driver: igb_uio/vfio
            enabled: true
            type: dpdk_ovs_port
            n_rxq: 2
            bridge: br-prv
            mtu: 9000
          br-prv:
            enabled: true
            type: dpdk_ovs_bridge

**DPDK OVS Bond**

.. code-block:: yaml

    linux:
      network:
        bridge: openvswitch
        dpdk:
          enabled: true
          driver: uio/vfio-pci
        openvswitch:
          pmd_cpu_mask: "0x6"
          dpdk_socket_mem: "1024,1024"
          dpdk_lcore_mask: "0x400"
          memory_channels: 2
        interface:
          dpdk_second_nic:
            name: ${_param:primary_second_nic}
            pci: 0000:06:00.0
            driver: igb_uio/vfio
            bond: dpdkbond0
            enabled: true
            type: dpdk_ovs_port
            n_rxq: 2
            mtu: 9000
          dpdk_first_nic:
            name: ${_param:primary_first_nic}
            pci: 0000:05:00.0
            driver: igb_uio/vfio
            bond: dpdkbond0
            enabled: true
            type: dpdk_ovs_port
            n_rxq: 2
            mtu: 9000
          dpdkbond0:
            enabled: true
            bridge: br-prv
            type: dpdk_ovs_bond
            mode: active-backup
          br-prv:
            enabled: true
            type: dpdk_ovs_bridge

**DPDK OVS bridge for VXLAN**

If VXLAN is used as tenant segmentation then ip address must be set on br-prv

.. code-block:: yaml

    linux:
      network:
        ...
        interface:
          br-prv:
            enabled: true
            type: dpdk_ovs_bridge
            address: 192.168.50.0
            netmask: 255.255.255.0
            mtu: 9000

Linux storage
-------------

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

File swap configuration

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

Partition swap configuration

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
