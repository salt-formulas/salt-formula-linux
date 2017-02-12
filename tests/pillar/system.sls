linux:
  system:
    enabled: true
    cluster: default
    name: test01
    timezone: Europe/Prague
    domain: local
    environment: prd
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
      default: "test01.local$"
    kernel:
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
    group:
      test:
        enabled: true
        name: test
        gid: 9999
        system: true
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
