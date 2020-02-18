============
Linux Fomula
============

Linux Operating Systems:

* Ubuntu
* CentOS
* RedHat
* Fedora
* Arch

Sample Pillars
==============

Linux System
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

Linux with system users, some with password set:

.. warning:: If no ``password`` variable is passed,
             any predifined password will be removed.

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
            home_dir_mode: 755
            email: 'jonh@doe.com'
            unique: false
          jsmith:
            name: 'jsmith'
            enabled: true
            full_name: 'With clear password'
            home: '/home/jsmith'
            hash_password: true
            password: "userpassword"
          mark:
            name: 'mark'
            enabled: true
            full_name: "unchange password'
            home: '/home/mark'
            password: false
          elizabeth:
            name: 'elizabeth'
            enabled: true
            full_name: 'With hased password'
            home: '/home/elizabeth'
            password: "$6$nUI7QEz3$dFYjzQqK5cJ6HQ38KqG4gTWA9eJu3aKx6TRVDFh6BVJxJgFWg2akfAA7f1fCxcSUeOJ2arCO6EEI6XXnHXxG10"

Configure password expiration parameters
----------------------------------------
The following login.defs parameters can be overridden per-user:

* PASS_MAX_DAYS
* PASS_MIN_DAYS
* PASS_WARN_DAYS
* INACTIVE

.. code-block:: yaml

    linux:
      system:
        ...
        user:
          jdoe:
            name: 'jdoe'
            enabled: true
            ...
            maxdays: <PASS_MAX_DAYS>
            mindays: <PASS_MIN_DAYS>
            warndays: <PASS_WARN_DAYS>
            inactdays: <INACTIVE>

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
        aliases:
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
            setenv: true # Enable sudo -E option
            runas:
            - DBA
            commands:
            - ALL
            - '!SUPPORT_SHELLS'
            - '!SUPPORT_RESTRICTED'

Linux with package, latest version:

.. code-block:: yaml

    linux:
      system:
        ...
        package:
          package-name:
            version: latest

Linux with package from certail repo, version with no upgrades:

.. code-block:: yaml

    linux:
      system:
        ...
        package:
          package-name:
            version: 2132.323
            repo: 'custom-repo'
            hold: true

Linux with package from certail repo, version with no GPG
verification:

.. code-block:: yaml

    linux:
      system:
        ...
        package:
          package-name:
            version: 2132.323
            repo: 'custom-repo'
            verify: false

Linux with autoupdates (automatically install security package
updates):

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

Managing cron tasks
-------------------

There are two data structures that are related to managing cron itself and
cron tasks:

.. code-block:: yaml

    linux:
      system:
        cron:

and

.. code-block:: yaml

    linux:
      system:
        job:

`linux:system:cron` manages cron packages, services, and '/etc/cron.allow' file.

'deny' files are managed the only way - we're ensuring they are absent, that's
a requirement from CIS 5.1.8

'cron' pillar structure is the following:

.. code-block:: yaml

    linux:
      system:
        cron:
          enabled: true
          pkgs: [ <cron packages> ]
          services: [ <cron services> ]
          user:
            <username>:
              enabled: true

To add user to '/etc/cron.allow' use 'enabled' key as shown above.

'/etc/cron.deny' is not managed as CIS 5.1.8 requires it was removed.

A user would be ignored if any of the following is true:
* user is disabled in `linux:system:user:<username>`
* user is disabled in `linux:system:cron:user:<username>`

`linux:system:job` manages individual cron tasks.

By default, it will use name as an identifier, unless identifier key is
explicitly set or False (then it will use Salt's default behavior which is
identifier same as command resulting in not being able to change it):

.. code-block:: yaml

    linux:
      system:
        ...
        job:
          cmd1:
            command: '/cmd/to/run'
            identifier: cmd1
            enabled: true
            user: 'root'
            hour: 2
            minute: 0

Added the opportunity to set a job with a special keyword like '@reboot' or '@hourly'. Quotes must be used, otherwise PyYAML will strip the '@' sign.

.. code-block:: yaml

    linux:
      system:
        ...
        job:
          cmd1:
            command: '/cmd/to/run'
            identifier: cmd1
            enabled: true
            user: 'root'
            special: '@reboot'


Managing 'at' tasks
-------------------

Pillar for managing `at` tasks is similar to one for `cron` tasks:

.. code-block:: yaml

    linux:
      system:
        at:
          enabled: true
          pkgs: [ <at packages> ]
          services: [ <at services> ]
          user:
            <username>:
              enabled: true

To add a user to '/etc/at.allow' use 'enabled' key as shown above.

'/etc/at.deny' is not managed as CIS 5.1.8 requires it was removed.

A user will be ignored if any of the following is true:
* user is disabled in `linux:system:user:<username>`
* user is disabled in `linux:system:at:user:<username>`


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

Enable autologin on ``tty1`` (may work only for Ubuntu 14.04):

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

To disable set autologin to ``false``.

Set ``policy-rc.d`` on Debian-based systems. Action can be any available
command in ``while true`` loop and ``case`` context.
Following will disallow dpkg to stop/start services for the Cassandra
package automatically:

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

Systemd settings:

.. code-block:: yaml

    linux:
      system:
        ...
        systemd:
          system:
            Manager:
              DefaultLimitNOFILE: 307200
              DefaultLimitNPROC: 307200
          user:
            Manager:
              DefaultLimitCPU: 2
              DefaultLimitNPROC: 4

Systemd journal settings:

.. code-block:: yaml

    linux:
      system:
        ...
        systemd:
          journal:
            SystemMaxUse: "50M"
            RuntimeMaxFiles: "100"
            
Ensure presence of directory:

.. code-block:: yaml

    linux:
      system:
        directory:
          /tmp/test:
            user: root
            group: root
            mode: 700
            makedirs: true

Ensure presence of file by specifying its source:

.. code-block:: yaml

    linux:
      system:
        file:
          /tmp/test.txt:
            source: http://example.com/test.txt
            user: root #optional
            group: root #optional
            mode: 700 #optional
            dir_mode: 700 #optional
            encoding: utf-8 #optional
            hash: <<hash>> or <<URI to hash>> #optional
            makedirs: true #optional

    linux:
      system:
        file:
          test.txt:
            name: /tmp/test.txt
            source: http://example.com/test.txt

    linux:
      system:
        file:
          test2:
            name: /tmp/test2.txt
            source: http://example.com/test2.jinja
            template: jinja

Ensure presence of file by specifying its contents:

.. code-block:: yaml

    linux:
      system:
        file:
          /tmp/test.txt:
            contents: |
              line1
              line2

    linux:
      system:
        file:
          /tmp/test.txt:
            contents_pillar: linux:network:hostname

    linux:
      system:
        file:
          /tmp/test.txt:
            contents_grains: motd

Ensure presence of file to be serialized through one of the
serializer modules (see:
https://docs.saltstack.com/en/latest/ref/serializers/all/index.html):

.. code-block:: yaml

    linux:
      system:
        file:
          /tmp/test.json:
            serialize: json
            contents:
              foo: 1
              bar: 'bar'

Kernel
~~~~~~

Install always up to date LTS kernel and headers from Ubuntu Trusty:

.. code-block:: yaml

    linux:
      system:
        kernel:
          type: generic
          lts: trusty
          headers: true

Load kernel modules and add them to ``/etc/modules``:

.. code-block:: yaml

    linux:
      system:
        kernel:
          modules:
            - nf_conntrack
            - tp_smapi
            - 8021q

Configure or blacklist kernel modules with additional options to
``/etc/modprobe.d`` following example will add
``/etc/modprobe.d/nf_conntrack.conf`` file with line
``options nf_conntrack hashsize=262144``:

'option' can be a mapping (with 'enabled' and 'value' keys) or a scalar.

Example for 'scalar' option value:

.. code-block:: yaml

    linux:
      system:
        kernel:
          module:
            nf_conntrack:
              option:
                hashsize: 262144

Example for 'mapping' option value:

.. code-block:: yaml

    linux:
      system:
        kernel:
          module:
            nf_conntrack:
              option:
                hashsize:
                  enabled: true
                  value: 262144

NOTE: 'enabled' key is optional and is True by default.

Blacklist a module:

.. code-block:: yaml

    linux:
      system:
        kernel:
          module:
            nf_conntrack:
              blacklist: true

A module can have a number of aliases, wildcards are allowed.
Define an alias for a module:

.. code-block:: yaml

    linux:
      system:
        kernel:
          module:
            nf_conntrack:
              alias:
                nfct:
                  enabled: true
                "nf_conn*":
                  enabled: true

NOTE: 'enabled' key is mandatory as there are no other keys exist.

Execute custom command instead of 'insmod' when inserting a module:

.. code-block:: yaml

    linux:
      system:
        kernel:
          module:
            nf_conntrack:
              install:
                enabled: true
                command: /bin/true

NOTE: 'enabled' key is optional and is True by default.

Execute custom command instead of 'rmmod' when removing a module:

.. code-block:: yaml

    linux:
      system:
        kernel:
          module:
            nf_conntrack:
              remove:
                enabled: true
                command: /bin/true

NOTE: 'enabled' key is optional and is True by default.

Define module dependencies:

.. code-block:: yaml

    linux:
      system:
        kernel:
          module:
            nf_conntrack:
              softdep:
                pre:
                  1:
                    enabled: true
                    value: a
                  2:
                    enabled: true
                    value: b
                  3:
                    enabled: true
                    value: c
                post:
                  1:
                    enabled: true
                    value: x
                  2:
                    enabled: true
                    value: y
                  3:
                    enabled: true
                    value: z

NOTE: 'enabled' key is optional and is True by default.


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

Systcl kernel parameters:

.. code-block:: yaml

    linux:
      system:
        kernel:
          sysctl:
            net.ipv4.tcp_keepalive_intvl: 3
            net.ipv4.tcp_keepalive_time: 30
            net.ipv4.tcp_keepalive_probes: 8

Configure kernel boot options:

.. code-block:: yaml

    linux:
      system:
        kernel:
          boot_options:
            - elevator=deadline
            - spectre_v2=off
            - nopti

Alternative way to set kernel boot options:

.. code-block:: yaml

    linux:
      system:
        kernel:
          transparent_hugepage: always
          elevator: deadline
          isolcpu: 1,2,3,4

CPU
~~~

Enable cpufreq governor for every cpu:

.. code-block:: yaml

    linux:
      system:
        cpu:
          governor: performance

SELinux
~~~~~~~

Set SELinux mode on System:

.. code-block:: yaml

    linux:
      system:
        selinux: permissive

CGROUPS
~~~~~~~

Setup linux cgroups:

.. code-block:: yaml

    linux:
      system:
        cgroup:
          enabled: true
          group:
            ceph_group_1:
              controller:
                cpu:
                  shares:
                    value: 250
                cpuacct:
                  usage:
                    value: 0
                cpuset:
                  cpus:
                    value: 1,2,3
                memory:
                  limit_in_bytes:
                    value: 2G
                  memsw.limit_in_bytes:
                    value: 3G
              mapping:
                subjects:
                - '@ceph'
            generic_group_1:
              controller:
                cpu:
                  shares:
                    value: 250
                cpuacct:
                  usage:
                    value: 0
              mapping:
                subjects:
                - '*:firefox'
                - 'student:cp'

Shared libraries
~~~~~~~~~~~~~~~~

Set additional shared library to Linux system library path:

.. code-block:: yaml

    linux:
      system:
        ld:
          library:
            java:
              - /usr/lib/jvm/jre-openjdk/lib/amd64/server
              - /opt/java/jre/lib/amd64/server

Certificates
~~~~~~~~~~~~

Add certificate authority into system trusted CA bundle:

.. code-block:: yaml

    linux:
      system:
        ca_certificates:
          mycert: |
            -----BEGIN CERTIFICATE-----
            MIICPDCCAaUCEHC65B0Q2Sk0tjjKewPMur8wDQYJKoZIhvcNAQECBQAwXzELMAkG
            A1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMTcwNQYDVQQLEy5DbGFz
            cyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTk2
            MDEyOTAwMDAwMFoXDTI4MDgwMTIzNTk1OVowXzELMAkGA1UEBhMCVVMxFzAVBgNV
            BAoTDlZlcmlTaWduLCBJbmMuMTcwNQYDVQQLEy5DbGFzcyAzIFB1YmxpYyBQcmlt
            YXJ5IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MIGfMA0GCSqGSIb3DQEBAQUAA4GN
            ADCBiQKBgQDJXFme8huKARS0EN8EQNvjV69qRUCPhAwL0TPZ2RHP7gJYHyX3KqhE
            BarsAx94f56TuZoAqiN91qyFomNFx3InzPRMxnVx0jnvT0Lwdd8KkMaOIG+YD/is
            I19wKTakyYbnsZogy1Olhec9vn2a/iRFM9x2Fe0PonFkTGUugWhFpwIDAQABMA0G
            CSqGSIb3DQEBAgUAA4GBALtMEivPLCYATxQT3ab7/AoRhIzzKBxnki98tsX63/Do
            lbwdj2wsqFHMc9ikwFPwTtYmwHYBV4GSXiHx0bH/59AhWM1pF+NEHJwZRDmJXNyc
            AA9WjQKZ7aKQRUzkuxCkPfAyAw7xzvjoyVGM5mKf5p/AfbdynMk2OmufTqj/ZA1k
            -----END CERTIFICATE-----

Sysfs
~~~~~

Install sysfsutils and set sysfs attributes:

.. code-block:: yaml

    linux:
      system:
        sysfs:
          scheduler:
            block/sda/queue/scheduler: deadline
          power:
            mode:
              power/state: 0660
            owner:
              power/state: "root:power"
            devices/system/cpu/cpu0/cpufreq/scaling_governor: powersave

Optional: You can also use list that will ensure order of items.

.. code-block:: yaml

    linux:
      system:
        sysfs:
          scheduler:
            block/sda/queue/scheduler: deadline
          power:
            - mode:
                power/state: 0660
            - owner:
                power/state: "root:power"
            - devices/system/cpu/cpu0/cpufreq/scaling_governor: powersave

Sysfs definition with disabled automatic write. Attributes are saved
to configuration, but are not applied during the run.
Thay will be applied automatically after the reboot.


.. code-block:: yaml

    linux:
      system:
        sysfs:
          enable_apply: false
          scheduler:
            block/sda/queue/scheduler: deadline

.. note:: The `enable_apply` parameter defaults to `True` if not defined.

Huge Pages
~~~~~~~~~~~~

Huge Pages give a performance boost to applications that intensively deal
with memory allocation/deallocation by decreasing memory fragmentation:

.. code-block:: yaml

    linux:
      system:
        kernel:
          hugepages:
            small:
              size: 2M
              count: 107520
              mount_point: /mnt/hugepages_2MB
              mount: false/true # default is true (mount immediately) / false (just save in the fstab)
            large:
              default: true # default automatically mounted
              size: 1G
              count: 210
              mount_point: /mnt/hugepages_1GB

.. note:: Not recommended to use both pagesizes concurrently.

Intel SR-IOV
~~~~~~~~~~~~

PCI-SIG Single Root I/O Virtualization and Sharing (SR-IOV)
specification defines a standardized mechanism to virtualize
PCIe devices. The mechanism can virtualize a single PCIe
Ethernet controller to appear as multiple PCIe devices:

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

Remove the specified CPUs, as defined by the cpu_number values, from
the general kernel SMP balancing and scheduler algroithms. The only
way to move a process onto or off an *isolated* CPU is via the CPU
affinity syscalls. ``cpu_number begins`` at ``0``, so the
maximum value is ``1`` less than the number of CPUs on the system.:

.. code-block:: yaml

    linux:
      system:
        kernel:
          isolcpu: 1,2,3,4,5,6,7 # isolate first cpu 0

Repositories
~~~~~~~~~~~~

RedHat-based Linux with additional OpenStack repo:

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
Also pin it's packages with priority ``900``:

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

If you need to add multiple pin rules for one repo, please use new,ordered definition format
('pinning' definition will be in priotity to use):

.. code-block:: yaml

  linux:
    system:
      repo:
        mcp_saltstack:
          source: "deb [arch=amd64] http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2017.7/ xenial main"
          architectures: amd64
          clean_file: true
          pinning:
            10:
              enabled: true
              pin: 'release o=SaltStack'
              priority: 50
              package: 'libsodium18'
            20:
              enabled: true
              pin: 'release o=SaltStack'
              priority: 1100
              package: '*'


.. note:: For old Ubuntu releases (<xenial)
          extra packages for apt transport, like ``apt-transport-https``
          may be required to be installed manually.
          (Chicken-eggs issue: we need to install packages to
          reach repo from where they should be installed)
          Otherwise, you still can try 'fortune' and install prereq.packages before
          any repo configuration, using list of requires in map.jinja.


Disabling any prerequisite packages installation:

You can simply drop any package pre-installation (before system.linux.repo
will be processed) via cluster lvl:

.. code-block:: yaml

   linux:
     system:
       pkgs: ~

Package manager proxy global setup:

.. code-block:: yaml

    linux:
      system:
        ...
        repo:
          apt-mk:
            source: "deb http://apt-mk.mirantis.com/ stable main salt"
        ...
        proxy:
          pkg:
            enabled: true
            ftp:   ftp://ftp-proxy-for-apt.host.local:2121
          ...
          # NOTE: Global defaults for any other componet that configure proxy on the system.
          #       If your environment has just one simple proxy, set it on linux:system:proxy.
          #
          # fall back system defaults if linux:system:proxy:pkg has no protocol specific entries
          # as for https and http
          ftp:   ftp://proxy.host.local:2121
          http:  http://proxy.host.local:3142
          https: https://proxy.host.local:3143

Package manager proxy setup per repository:

.. code-block:: yaml

    linux:
      system:
        ...
        repo:
          debian:
            source: "deb http://apt-mk.mirantis.com/ stable main salt"
        ...
          apt-mk:
            source: "deb http://apt-mk.mirantis.com/ stable main salt"
            # per repository proxy
            proxy:
              enabled: true
              http:  http://maas-01:8080
              https: http://maas-01:8080
        ...
        proxy:
          # package manager fallback defaults
          # used if linux:system:repo:apt-mk:proxy has no protocol specific entries
          pkg:
            enabled: true
            ftp:   ftp://proxy.host.local:2121
            #http:  http://proxy.host.local:3142
            #https: https://proxy.host.local:3143
          ...
          # global system fallback system defaults
          ftp:   ftp://proxy.host.local:2121
          http:  http://proxy.host.local:3142
          https: https://proxy.host.local:3143

Remove all repositories:

.. code-block:: yaml

    linux:
      system:
        purge_repos: true

Refresh repositories metada, after configuration:

.. code-block:: yaml

    linux:
      system:
        refresh_repos_meta: true

Setup custom apt config options:

.. code-block:: yaml

    linux:
      system:
        apt:
          config:
            compression-workaround:
              "Acquire::CompressionTypes::Order": "gz"
            docker-clean:
              "DPkg::Post-Invoke":
                - "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"
              "APT::Update::Post-Invoke":
                - "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"

RC
~~

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

Setting prompt is implemented by creating ``/etc/profile.d/prompt.sh``.
Every user can have different prompt:

.. code-block:: yaml

    linux:
      system:
        prompt:
          root: \\n\\[\\033[0;37m\\]\\D{%y/%m/%d %H:%M:%S} $(hostname -f)\\[\\e[0m\\]\\n\\[\\e[1;31m\\][\\u@\\h:\\w]\\[\\e[0m\\]
          default: \\n\\D{%y/%m/%d %H:%M:%S} $(hostname -f)\\n[\\u@\\h:\\w]

On Debian systems, to set prompt system-wide, it's necessary to
remove setting PS1 in ``/etc/bash.bashrc`` and ``~/.bashrc``,
which comes from ``/etc/skel/.bashrc``. This formula will do
this automatically, but will not touch existing user's
``~/.bashrc`` files except root.

Bash
~~~~

Fix bash configuration to preserve history across sessions
like ZSH does by default:

.. code-block:: yaml

    linux:
      system:
        bash:
          preserve_history: true

Login banner message
~~~~~~~~~~~~~~~~~~~~

``/etc/issue`` is a text file which contains a message or system
identification to be printed before the login prompt. It may contain
various @char and \char sequences, if supported by the getty-type
program employed on the system.

Setting logon banner message is easy:

.. code-block:: yaml

    liunx:
      system:
        banner:
          enabled: true
          contents: |
            UNAUTHORIZED ACCESS TO THIS SYSTEM IS PROHIBITED

            You must have explicit, authorized permission to access or configure this
            device. Unauthorized attempts and actions to access or use this system may
            result in civil and/or criminal penalties.
            All activities performed on this system are logged and monitored.

Message of the day
~~~~~~~~~~~~~~~~~~

``pam_motd`` from package ``libpam-modules`` is used for dynamic
messages of the day. Setting custom ``motd`` will clean up existing ones.

Setting static ``motd`` will replace existing ``/etc/motd`` and remove
scripts from ``/etc/update-motd.d``.

Setting static ``motd``:

.. code-block:: yaml

    linux:
      system:
        motd: |
          UNAUTHORIZED ACCESS TO THIS SYSTEM IS PROHIBITED

          You must have explicit, authorized permission to access or configure this
          device. Unauthorized attempts and actions to access or use this system may
          result in civil and/or criminal penalties.
          All activities performed on this system are logged and monitored.

Setting dynamic ``motd``:

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

Services
~~~~~~~~

Stop and disable the ``linux`` service:

.. code-block:: yaml

    linux:
      system:
        service:
          apt-daily.timer:
            status: dead

Possible statuses are ``dead`` (disable service by default), ``running``
(enable service by default), ``enabled``, ``disabled``:

Linux with the ``atop`` service:

.. code-block:: yaml

    linux:
      system:
        atop:
          enabled: true
          interval: 20
          logpath: "/var/log/atop"
          outfile: "/var/log/atop/daily.log"

Linux with the ``mcelog`` service:

.. code-block:: yaml

    linux:
      system:
        mcelog:
          enabled: true
          logging:
            syslog: true
            syslog_error: true

RHEL / CentOS
^^^^^^^^^^^^^
Currently, ``update-motd`` is not available
for RHEL. So there is no native support for dynamic ``motd``.
You can still set a static one, with a different pillar structure:

.. code-block:: yaml

    linux:
      system:
        motd: |
          This is [company name] network.
          Unauthorized access strictly prohibited.

Haveged
~~~~~~~

If you are running headless server and are low on entropy,
you may set up Haveged:

.. code-block:: yaml

    linux:
      system:
        haveged:
          enabled: true

Linux network
-------------

Linux with network manager:

.. code-block:: yaml

    linux:
      network:
        enabled: true
        network_manager: true

Execute linux.network.interface state without ifupdown activity:

.. code-block:: bash

   salt-call linux.network.interface pillar='{"linux":{"network":{"noifupdown":True}}}'


Linux with default static network interfaces, default gateway
interface and DNS servers:

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

Linux with bonded interfaces and disabled ``NetworkManager``:

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

Linux with VLAN ``interface_params``:

.. code-block:: yaml

    linux:
      network:
        enabled: true
        interface:
          vlan69:
            type: vlan
            use_interfaces:
            - interface: ${linux:interface:bond0}

Linux with wireless interface parameters:

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

Linux networks with routes defined:

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

Native Linux Bridges:

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

Open vSwitch Bridges:

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
          br-prv:
            enabled: true
            type: ovs_bridge
            mtu: 65000
          br-ens7:
            enabled: true
            name: br-ens7
            type: ovs_bridge
            proto: manual
            mtu: 9000
            use_interfaces:
            - ens7
          patch-br-ens7-br-prv:
            enabled: true
            name: ens7-prv
            ovs_type: ovs_port
            type: ovs_port
            bridge: br-ens7
            port_type: patch
            peer: prv-ens7
            tag: 109 # [] to unset a tag
            mtu: 65000
          patch-br-prv-br-ens7:
            enabled: true
            name: prv-ens7
            bridge: br-prv
            ovs_type: ovs_port
            type: ovs_port
            port_type: patch
            peer: ens7-prv
            tag: 109
            mtu: 65000
          ens7:
            enabled: true
            name: ens7
            proto: manual
            ovs_port_type: OVSPort
            type: ovs_port
            ovs_bridge: br-ens7
            bridge: br-ens7

Debian manual proto interfaces

When you are changing interface proto from static in up state
to manual, you may need to flush ip addresses. For example,
if you want to use the interface and the ip on the bridge.
This can be done by setting the ``ipflush_onchange`` to true.

.. code-block:: yaml

    linux:
      network:
        interface:
          eth1:
            enabled: true
            type: eth
            proto: manual
            mtu: 9100
            ipflush_onchange: true

Debian static proto interfaces

When you are changing interface proto from dhcp in up state to
static, you may need to flush ip addresses and restart interface
to assign ip address from a managed file. For example, if you wantto
use the interface and the ip on the bridge. This can be done by
setting the ``ipflush_onchange`` with combination ``restart_on_ipflush``
param set to true.

.. code-block:: yaml

    linux:
      network:
        interface:
          eth1:
            enabled: true
            type: eth
            proto: static
            address: 10.1.0.22
            netmask: 255.255.255.0
            ipflush_onchange: true
            restart_on_ipflush: true

Concatinating and removing interface files

Debian based distributions have ``/etc/network/interfaces.d/``
directory, where you can store configuration of network
interfaces in separate files. You can concatinate the files
to the defined destination when needed, this operation removes
the file from the ``/etc/network/interfaces.d/``. If you just need
to remove iface files, you can use the ``remove_iface_files`` key.

.. code-block:: yaml

    linux:
      network:
        concat_iface_files:
        - src: '/etc/network/interfaces.d/50-cloud-init.cfg'
          dst: '/etc/network/interfaces'
        remove_iface_files:
        - '/etc/network/interfaces.d/90-custom.cfg'

Configure DHCP client

None of the keys is mandatory, include only those you really need.
For full list of available options under send, supersede, prepend,
append refer to dhcp-options(5).

.. code-block:: yaml

     linux:
       network:
         dhclient:
           enabled: true
           backoff_cutoff: 15
           initial_interval: 10
           reboot: 10
           retry: 60
           select_timeout: 0
           timeout: 120
           send:
             - option: host-name
               declaration: "= gethostname()"
           supersede:
             - option: host-name
               declaration: "spaceship"
             - option: domain-name
               declaration: "domain.home"
             #- option: arp-cache-timeout
             #  declaration: 20
           prepend:
             - option: domain-name-servers
               declaration:
                 - 8.8.8.8
                 - 8.8.4.4
             - option: domain-search
               declaration:
                 - example.com
                 - eng.example.com
           #append:
             #- option: domain-name-servers
             #  declaration: 127.0.0.1
           # ip or subnet to reject dhcp offer from
           reject:
             - 192.33.137.209
             - 10.0.2.0/24
           request:
             - subnet-mask
             - broadcast-address
             - time-offset
             - routers
             - domain-name
             - domain-name-servers
             - domain-search
             - host-name
             - dhcp6.name-servers
             - dhcp6.domain-search
             - dhcp6.fqdn
             - dhcp6.sntp-servers
             - netbios-name-servers
             - netbios-scope
             - interface-mtu
             - rfc3442-classless-static-routes
             - ntp-servers
           require:
             - subnet-mask
             - domain-name-servers
           # if per interface configuration required add below
           interface:
             ens2:
               initial_interval: 11
               reject:
                 - 192.33.137.210
             ens3:
               initial_interval: 12
               reject:
                 - 192.33.137.211

Linux network systemd settings:

.. code-block:: yaml

    linux:
      network:
        ...
        systemd:
          link:
            10-iface-dmz:
              Match:
                MACAddress: c8:5b:67:fa:1a:af
                OriginalName: eth0
              Link:
                Name: dmz0
          netdev:
            20-bridge-dmz:
              match:
                name: dmz0
              network:
                mescription: bridge
                bridge: br-dmz0
          network:
          # works with lowercase, keys are by default capitalized
            40-dhcp:
              match:
                name: '*'
              network:
                DHCP: yes

Configure global environment variables

Use ``/etc/environment`` for static system wide variable assignment
after boot. Variable expansion is frequently not supported.

.. code-block:: yaml

    linux:
      system:
        env:
          BOB_VARIABLE: Alice
          ...
          BOB_PATH:
            - /srv/alice/bin
            - /srv/bob/bin
          ...
          ftp_proxy:   none
          http_proxy:  http://global-http-proxy.host.local:8080
          https_proxy: ${linux:system:proxy:https}
          no_proxy:
            - 192.168.0.80
            - 192.168.1.80
            - .domain.com
            - .local
        ...
        # NOTE: global defaults proxy configuration.
        proxy:
          ftp:   ftp://proxy.host.local:2121
          http:  http://proxy.host.local:3142
          https: https://proxy.host.local:3143
          noproxy:
            - .domain.com
            - .local

Configure the ``profile.d`` scripts

The ``profile.d`` scripts are being sourced during ``.sh`` execution
and support variable expansion in opposite to /etc/environment global
settings in ``/etc/environment``.

.. code-block:: yaml

    linux:
      system:
        profile:
          locales: |
            export LANG=C
            export LC_ALL=C
          ...
          vi_flavors.sh: |
            export PAGER=view
            export EDITOR=vim
            alias vi=vim
          shell_locales.sh: |
            export LANG=en_US
            export LC_ALL=en_US.UTF-8
          shell_proxies.sh: |
            export FTP_PROXY=ftp://127.0.3.3:2121
            export NO_PROXY='.local'


Configure login.defs parameters
-------------------------------

.. code-block:: yaml

    linux:
      system:
        login_defs:
          <opt_name>:
            enabled: true
            value: <opt_value>

<opt_name> is a configurational option defined in 'man login.defs'.
<opt_name> is case sensitive, should be UPPERCASE only!


Linux with hosts

Parameter ``purge_hosts`` will enforce whole ``/etc/hosts file``,
removing entries that are not defined in model except defaults
for both IPv4 and IPv6 localhost and hostname as well as FQDN.

We recommend using this option to verify that ``/etc/hosts``
is always in a clean state. However it is not enabled by default
for security reasons.

.. code-block:: yaml

    linux:
      network:
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

Linux with hosts collected from mine

All DNS records defined within infrastrucuture
are passed to the local hosts records or any DNS server. Only
hosts with the ``grain`` parameter set to ``true`` will be propagated
to the mine.

.. code-block:: yaml

    linux:
      network:
        purge_hosts: true
        mine_dns_records: true
        host:
          node1:
            address: 192.168.10.200
            grain: true
            names:
            - node2.domain.com
            - service2.domain.com

Set up ``resolv.conf``, nameservers, domain and search domains:

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

Set up custom TX queue length for tap interfaces:

.. code-block:: yaml

    linux:
      network:
        tap_custom_txqueuelen: 10000

Open vSwitch native bond:

.. code-block:: yaml

    bond1:
      enabled: true
      type: ovs_bond
      mode: balance-slb
      bridge: br-ex
      slaves: eno3 eno4

DPDK OVS interfaces

**DPDK OVS NIC**

.. code-block:: yaml

    linux:
      network:
        bridge: openvswitch
        dpdk:
          enabled: true
          driver: uio/vfio
        openvswitch:
          pmd_cpu_mask: "0x6"
          dpdk_socket_mem: "1024,1024"
          dpdk_lcore_mask: "0x400"
          memory_channels: 2
        interface:
          dpkd0:
            name: ${_param:dpdk_nic}
            pci: 0000:06:00.0
            driver: igb_uio/vfio-pci
            enabled: true
            type: dpdk_ovs_port
            n_rxq: 2
            pmd_rxq_affinity: "0:1,1:2"
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
          driver: uio/vfio
        openvswitch:
          pmd_cpu_mask: "0x6"
          dpdk_socket_mem: "1024,1024"
          dpdk_lcore_mask: "0x400"
          memory_channels: 2
        interface:
          dpdk_second_nic:
            name: ${_param:primary_second_nic}
            pci: 0000:06:00.0
            driver: igb_uio/vfio-pci
            bond: dpdkbond0
            enabled: true
            type: dpdk_ovs_port
            n_rxq: 2
            pmd_rxq_affinity: "0:1,1:2"
            mtu: 9000
          dpdk_first_nic:
            name: ${_param:primary_first_nic}
            pci: 0000:05:00.0
            driver: igb_uio/vfio-pci
            bond: dpdkbond0
            enabled: true
            type: dpdk_ovs_port
            n_rxq: 2
            pmd_rxq_affinity: "0:1,1:2"
            mtu: 9000
          dpdkbond0:
            enabled: true
            bridge: br-prv
            type: dpdk_ovs_bond
            mode: active-backup
          br-prv:
            enabled: true
            type: dpdk_ovs_bridge

**DPDK OVS LACP Bond with vlan tag**

.. code-block:: yaml

    linux:
      network:
        bridge: openvswitch
        dpdk:
          enabled: true
          driver: uio
        openvswitch:
          pmd_cpu_mask: "0x6"
          dpdk_socket_mem: "1024,1024"
          dpdk_lcore_mask: "0x400"
          memory_channels: "2"
        interface:
          eth3:
            enabled: true
            type: eth
            proto: manual
            name: ${_param:tenant_first_nic}
          eth4:
            enabled: true
            type: eth
            proto: manual
            name: ${_param:tenant_second_nic}
          dpdk0:
            name: ${_param:tenant_first_nic}
            pci: "0000:81:00.0"
            driver: igb_uio
            bond: bond1
            enabled: true
            type: dpdk_ovs_port
            n_rxq: 2
          dpdk1:
            name: ${_param:tenant_second_nic}
            pci: "0000:81:00.1"
            driver: igb_uio
            bond: bond1
            enabled: true
            type: dpdk_ovs_port
            n_rxq: 2
          bond1:
            enabled: true
            bridge: br-prv
            type: dpdk_ovs_bond
            mode: balance-slb
          br-prv:
            enabled: true
            type: dpdk_ovs_bridge
            tag: ${_param:tenant_vlan}
            address: ${_param:tenant_address}
            netmask: ${_param:tenant_network_netmask}

**DPDK OVS bridge for VXLAN**

If VXLAN is used as tenant segmentation, IP address must
be set on ``br-prv``.

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
            tag: 101
            mtu: 9000

**DPDK OVS bridge with Linux network interface**

.. code-block:: yaml

    linux:
      network:
        ...
        interface:
          eth0:
            type: eth
            ovs_bridge: br-prv
            ...
          br-prv:
            enabled: true
            type: dpdk_ovs_bridge
            ...

Linux storage
-------------

Linux with mounted Samba:

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

NFS mount:

.. code-block:: yaml

  linux:
    storage:
      enabled: true
      mount:
        nfs_glance:
          enabled: true
          path: /var/lib/glance/images
          device: 172.16.10.110:/var/nfs/glance
          file_system: nfs
          opts: rw,sync

File swap configuration:

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

Partition swap configuration:

.. code-block:: yaml

    linux:
      storage:
        enabled: true
        swap:
          partition:
            enabled: true
            engine: partition
            device: /dev/vg0/swap

LVM group ``vg1`` with one device and ``data`` volume mounted
into ``/mnt/data``.

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

Create partitions on disk. Specify size in MB. It expects empty
disk without any existing partitions.
Set ``startsector=1`` if you want to start partitions from ``2048``.

.. code-block:: yaml

      linux:
        storage:
          disk:
            first_drive:
              startsector: 1
              name: /dev/loop1
              type: gpt
              partitions:
                - size: 200 #size in MB
                  type: fat32
                - size: 300 #size in MB
                  mkfs: True
                  type: xfs
            /dev/vda1:
              partitions:
                - size: 5
                  type: ext2
                - size: 10
                  type: ext4

Multipath with Fujitsu Eternus DXL:

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

Multipath with Hitachi VSP 1000:

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

Multipath with IBM Storwize:

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

Multipath with multiple backends:

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

PAM LDAP integration:

.. code-block:: yaml

    parameters:
      linux:
        system:
          auth:
            enabled: true
            mkhomedir:
              enabled: true
              umask: 0027
            ldap:
              enabled: true
              binddn: cn=bind,ou=service_users,dc=example,dc=com
              bindpw: secret
              uri: ldap://127.0.0.1
              base: ou=users,dc=example,dc=com
              ldap_version: 3
              pagesize: 65536
              referrals: off
              filter:
                passwd: (&(&(objectClass=person)(uidNumber=*))(unixHomeDirectory=*))
                shadow: (&(&(objectClass=person)(uidNumber=*))(unixHomeDirectory=*))
                group:  (&(objectClass=group)(gidNumber=*))

PAM duo 2FA integration

.. code-block:: yaml

    parameters:
      linux:
        system:
          auth:
            enabled: true
            duo:
              enabled: true
              duo_host: localhost
              duo_ikey: DUO-INTEGRATION-KEY
              duo_skey: DUO-SECRET-KEY

duo package version may be specified (optional)

.. code-block:: yaml

      linux:
        system:
          package:
            duo-unix:
              version: 1.10.1-0

Disabled multipath (the default setup):

.. code-block:: yaml

    parameters:
      linux:
        storage:
          multipath:
            enabled: false

Linux with local loopback device:

.. code-block:: yaml

    linux:
      storage:
        loopback:
          disk1:
            file: /srv/disk1
            size: 50G

External config generation
--------------------------

You are able to use config support metadata between formulas
and only generate configuration files for external use, for example, Docker, and so on.

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

Netconsole Remote Kernel Logging
--------------------------------

Netconsole logger can be configured for the configfs-enabled kernels
(``CONFIG_NETCONSOLE_DYNAMIC`` must be enabled). The configuration
applies both in runtime (if network is already configured),
and on-boot after an interface initialization.

.. note::

   * Receiver can be located only on the same L3 domain
     (or you need to configure gateway MAC manually).
   * The Receiver MAC is detected only on configuration time.
   * Using broadcast MAC is not recommended.

.. code-block:: yaml

    parameters:
      linux:
        system:
          netconsole:
            enabled: true
            port: 514 (optional)
            loglevel: debug (optional)
            target:
              192.168.0.1:
                interface: bond0
                mac: "ff:ff:ff:ff:ff:ff" (optional)

Check network params on the environment
---------------------------------------

Grab nics and nics states

.. code-block:: bash

   salt osd001\* net_checks.get_nics

**Example of system output:**

.. code-block:: bash

   osd001.domain.com:
       |_
         - bond0
         - None
         - 1e:c8:64:42:23:b9
         - 0
         - 1500
       |_
         - bond1
         - None
         - 3c:fd:fe:27:3b:00
         - 1
         - 9100
       |_
         - fourty1
         - None
         - 3c:fd:fe:27:3b:00
         - 1
         - 9100
       |_
         - fourty2
         - None
         - 3c:fd:fe:27:3b:02
         - 1
         - 9100

Grab 10G nics PCI addresses for hugepages setup

.. code-block:: bash

   salt cmp001\* net_checks.get_ten_pci

**Example of system output:**

.. code-block:: bash

   cmp001.domain.com:
       |_
         - ten1
         - 0000:19:00.0
       |_
         - ten2
         - 0000:19:00.1
       |_
         - ten3
         - 0000:19:00.2
       |_
         - ten4
         - 0000:19:00.3

Grab ip address for an interface

.. code-block:: bash

   salt cmp001\* net_checks.get_ip iface=one4

**Example of system output:**

.. code-block:: bash

   cmp001.domain.com:
       10.200.177.101

Grab ip addresses map

.. code-block:: bash

   salt-call net_checks.nodes_addresses

**Example of system output:**

.. code-block:: bash

   local:
    |_
      - cid01.domain.com
      |_
        |_
          - pxe
          - 10.200.177.91
        |_
          - control
          - 10.200.178.91
    |_
      - cmn02.domain.com
      |_
        |_
          - storage_access
          - 10.200.181.67
        |_
          - pxe
          - 10.200.177.67
        |_
          - control
          - 10.200.178.67
    |_
      - cmp010.domain.com
      |_
        |_
          - pxe
          - 10.200.177.110
        |_
          - storage_access
          - 10.200.181.110
        |_
          - control
          - 10.200.178.110
        |_
          - vxlan
          - 10.200.179.110

Verify full mesh connectivity

.. code-block:: bash

   salt-call net_checks.ping_check

**Example of positive system output:**

.. code-block:: bash

   ['PASSED']
   [INFO    ] ['PASSED']
   local:
       True

**Example of system output in case of failure:**

.. code-block:: bash

   FAILED
   [ERROR   ] FAILED
   ['control: 10.0.1.92 -> 10.0.1.224: Failed']
   ['control: 10.0.1.93 -> 10.0.1.224: Failed']
   ['control: 10.0.1.51 -> 10.0.1.224: Failed']
   ['control: 10.0.1.102 -> 10.0.1.224: Failed']
   ['control: 10.0.1.13 -> 10.0.1.224: Failed']
   ['control: 10.0.1.81 -> 10.0.1.224: Failed']
   local:
       False

For this feature to work, please mark addresses with some role.
Otherwise 'default' role is assumed and mesh would consist of all
addresses on the environment.

Mesh mark is needed only for interfaces which are enabled and have
ip address assigned.

Checking dhcp pxe network meaningless, as it is used for salt
master vs minion communications, therefore treated as checked.

.. code-block:: yaml

   parameters:
     linux:
       network:
         interface:
           ens3:
             enabled: true
             type: eth
             proto: static
             address: ${_param:deploy_address}
             netmask: ${_param:deploy_network_netmask}
             gateway: ${_param:deploy_network_gateway}
             mesh: pxe

Check pillars for ip address duplicates

.. code-block:: bash

   salt-call net_checks.verify_addresses

**Example of positive system output:**

.. code-block:: bash

   ['PASSED']
   [INFO    ] ['PASSED']
   local:
       True

**Example of system output in case of failure:**

.. code-block:: bash

   FAILED. Duplicates found
   [ERROR   ] FAILED. Duplicates found
   ['gtw01.domain.com', 'gtw02.domain.com', '10.0.1.224']
   [ERROR   ] ['gtw01.domain.com', 'gtw02.domain.com', '10.0.1.224']
   local:
       False

Generate csv report for the env

.. code-block:: bash

   salt -C 'kvm* or cmp* or osd*' net_checks.get_nics_csv \
     | grep '^\ ' | sed 's/\ *//g' | grep -Ev ^server \
     | sed '1 i\server,nic_name,ip_addr,mac_addr,link,mtu,chassis_id,chassis_name,port_mac,port_descr'

**Example of system output:**

.. code-block:: bash

   server,nic_name,ip_addr,mac_addr,link,mtu,chassis_id,chassis_name,port_mac,port_descr
   cmp010.domain.com,bond0,None,b4:96:91:10:5b:3a,1,1500,,,,
   cmp010.domain.com,bond0.21,10.200.178.110,b4:96:91:10:5b:3a,1,1500,,,,
   cmp010.domain.com,bond0.22,10.200.179.110,b4:96:91:10:5b:3a,1,1500,,,,
   cmp010.domain.com,bond1,None,3c:fd:fe:34:ad:22,0,1500,,,,
   cmp010.domain.com,bond1.24,10.200.181.110,3c:fd:fe:34:ad:22,0,1500,,,,
   cmp010.domain.com,fourty5,None,3c:fd:fe:34:ad:20,0,9000,,,,
   cmp010.domain.com,fourty6,None,3c:fd:fe:34:ad:22,0,9000,,,,
   cmp010.domain.com,one1,None,b4:96:91:10:5b:38,0,1500,,,,
   cmp010.domain.com,one2,None,b4:96:91:10:5b:39,1,1500,f0:4b:3a:8f:75:40,exnfvaa18-20,548,ge-0/0/22
   cmp010.domain.com,one3,None,b4:96:91:10:5b:3a,1,1500,f0:4b:3a:8f:75:40,exnfvaa18-20,547,ge-0/0/21
   cmp010.domain.com,one4,10.200.177.110,b4:96:91:10:5b:3b,1,1500,f0:4b:3a:8f:75:40,exnfvaa18-20,546,ge-0/0/20
   cmp011.domain.com,bond0,None,b4:96:91:13:6c:aa,1,1500,,,,
   cmp011.domain.com,bond0.21,10.200.178.111,b4:96:91:13:6c:aa,1,1500,,,,
   cmp011.domain.com,bond0.22,10.200.179.111,b4:96:91:13:6c:aa,1,1500,,,,
   ...

Usage
=====

Set MTU of the eth0 network interface to 1400:

.. code-block:: bash

   ip link set dev eth0 mtu 1400

Read more
=========

* https://www.archlinux.org/
* http://askubuntu.com/questions/175172/how-do-i-configure-proxies-in-ubuntu-server-or-minimal-cli-ubuntu

Documentation and Bugs
======================

* http://salt-formulas.readthedocs.io/
   Learn how to install and update salt-formulas.

* https://github.com/salt-formulas/salt-formula-linux/issues
   In the unfortunate event that bugs are discovered, report the issue to the
   appropriate issue tracker. Use the Github issue tracker for a specific salt
   formula.

* https://launchpad.net/salt-formulas
   For feature requests, bug reports, or blueprints affecting the entire
   ecosystem, use the Launchpad salt-formulas project.

* https://launchpad.net/~salt-formulas-users
   Join the salt-formulas-users team and subscribe to mailing list if required.

* https://github.com/salt-formulas/salt-formula-linux
   Develop the salt-formulas projects in the master branch and then submit pull
   requests against a specific formula.

* #salt-formulas @ irc.freenode.net
   Use this IRC channel in case of any questions or feedback which is always
   welcome.

