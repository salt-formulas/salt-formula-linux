linux:
  system:
    enabled: true
    cluster: default
    name: linux
    timezone: Europe/Prague
    domain: local
    environment: prd
    hostname: system.pillar.local
    apparmor:
      enabled: false
    haveged:
      enabled: true
    console:
      tty0:
        autologin: root
      ttyS0:
        autologin: root
        rate: 115200
        term: xterm
    prompt:
      default: "linux.ci.local$"
    kernel:
      sriov: True
      isolcpu: 1,2,3,4
      hugepages:
        large:
          default: true
          size: 1G
          count: 210
          mount_point: /mnt/hugepages_1GB
    motd:
      - warning: |
          #!/bin/sh
          printf "WARNING: This is tcpcloud network.\n"
          printf "  Unauthorized access is strictly prohibited.\n"
          printf "\n"
      - info: |
          #!/bin/sh
          printf -- "--[tcp cloud]---------------------------\n"
          printf " Hostname  |  ${linux:system:name}\n"
          printf " Domain    |  ${linux:system:domain}\n"
          printf " System    |  %s\n" "$(lsb_release -s -d)"
          printf " Kernel    |  %s\n" "$(uname -r)"
          printf -- "----------------------------------------\n"
          printf "\n"
    user:
      root:
        enabled: true
        home: /root
        name: root
      test:
        enabled: true
        name: test
        sudo: true
        uid: 9999
        full_name: Test User
        home: /home/test
        groups:
          - root
      salt_user1:
        enabled: true
        name: saltuser1
        sudo: false
        uid: 9991
        full_name: Salt User1
        home: /home/saltuser1
      salt_user2:
        enabled: true
        name: saltuser2
        sudo: false
        uid: 9992
        full_name: Salt Sudo User2
        home: /home/saltuser2
    group:
      test:
        enabled: true
        name: test
        gid: 9999
        system: true
      db-ops:
        enabled: true
        name: testgroup
      salt-ops:
        enabled: true
        name: sudogroup0
      sudogroup1:
        enabled: true
        name: sudogroup1
      sudogroup2:
        enabled: true
        name: sudogroup2
      sudogroup3:
        enabled: false
        name: sudogroup3
    job:
      test:
        enabled: true
        command: "/bin/sleep 3"
        user: test
        minute: 0
        hour: 13
    package:
      htop:
        version: latest
    repo:
      opencontrail:
        source: "deb http://ppa.launchpad.net/tcpcloud/contrail-2.20/ubuntu trusty main"
        architectures: amd64
    policyrcd:
      - package: cassandra
        action: exit 101
      - package: '*'
        action: switch
    locale:
      en_US.UTF-8:
        enabled: true
        default: true
      "cs_CZ.UTF-8 UTF-8":
        enabled: true
    autoupdates:
      enabled: true
    sudo:
      enabled: true
      alias:
        runas:
          DBA:
          - postgres
          - mysql
          SALT:
          - root
        host:
          LOCAL:
          - localhost
          PRODUCTION:
          - db1
          - db2
        command:
          SUDO_RESTRICTED_SU:
          - /bin/vi /etc/sudoers
          - /bin/su - root
          - /bin/su -
          - /bin/su
          - /usr/sbin/visudo
          SUDO_SHELLS:
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
          SUDO_SALT_SAFE:
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
          SUDO_SALT_TRUSTED:
          - /usr/bin/salt*
      users:
        saltuser1: {}
        saltuser2:
          hosts:
          - LOCAL
        # User Alias:
        DBA:
          hosts:
          - ALL
          commands:
          - SUDO_SALT_SAFE
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
          - SUDO_SALT_SAFE
          - '!SUDO_SHELLS'
          - '!SUDO_RESTRICTED_SU'
        salt-ops:
          hosts:
          - 'ALL'
          runas:
          - SALT
          commands:
          - SUDO_SALT_TRUSTED
        salt-ops2:
          name: salt-ops
          runas:
          - DBA
          commands:
          - SUDO_SHELLS
        sudogroup1:
          commands:
            - ALL
        sudogroup2:
          commands:
            - ALL
          hosts:
            - localhost
          users:
            - test
          nopasswd: false
        sudogroup3:
          commands:
            - ALL
