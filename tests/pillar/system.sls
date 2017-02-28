linux:
  system:
    enabled: true
    cluster: default
    name: linux
    #timezone: Europe/Prague
    domain: local
    environment: prd
    hostname: system.pillar.local
    apparmor:
      enabled: false
    haveged:
      enabled: true
    #console:
    #  tty0:
    #    autologin: root
    #  ttyS0:
    #    autologin: root
    #    rate: 115200
    #    term: xterm
    prompt:
      default: "linux.ci.local$"
    kernel:
      #sriov: True
      isolcpu: 1,2,3,4
      #hugepages:
      #    large:
      #    default: true
      #    size: 1G
      #    count: 210
      #    mount_point: /mnt/hugepages_1GB
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
      salt_user2:
        enabled: true
        name: saltuser2
        sudo: false
        uid: 9990
        full_name: Salt Sudo User2
        home: /home/sudouser2
        groups:
          - sudouser2
    group:
      test:
        enabled: true
        name: test
        gid: 9999
        system: true
      testdisabled:
        enabled: true
        name: tdisabled
      sudouser0:
        enabled: true
        name: sudouser0
        sudo:
          enabled: false
          commands:
            - ALL
      sudouser1:
        enabled: true
        name: sudouser1
        sudo:
          enabled: true
          commands:
            - ALL
          hosts: localhost
          user: test
          nopasswd: false
      sudouser2:
        enabled: true
        name: sudouser2
        sudo:
          enabled: true
          aliases:
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
          commands:
            - /bin/cat *
            - /bin/less *
            - /bin/ls *
            - SUDO_SALT_SAFE
            - '!SUDO_SHELLS'
            - '!SUDO_RESTRICTED_SU'
      sudouser3:
        enabled: false
        name: sudouser3
        sudo:
          enabled: true
          commands:
            - ALL
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
    #policyrcd:
      #- package: cassandra
        #action: exit 101
      #- package: '*'
        #action: switch
    locale:
      en_US.UTF-8:
        enabled: true
        default: true
      "cs_CZ.UTF-8 UTF-8":
        enabled: true
    autoupdates:
      enabled: true
