linux:
  system:
    enabled: true
    cluster: default
    name: linux
    domain: local
    environment: prd
    hostname: system.pillar.local
    purge_repos: true
    apparmor:
      enabled: false
    haveged:
      enabled: true
    prompt:
      default: "linux.ci.local$"
    kernel:
      isolcpu: 1,2,3,4
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
        source: "deb http://ppa.launchpad.net/tcpcloud/contrail-3.0/ubuntu xenial main"
        keyid: E79EE90C
        keyserver: keyserver.ubuntu.com
        architectures: amd64
        proxy:
          enabled: true
          https: https://127.0.5.1:443
          #http: http://127.0.5.2:8080
      apt-mk-salt:
        source: "deb http://apt-mk.mirantis.com/xenial stable salt"
        key_url: http://apt-mk.mirantis.com/public.gpg
        architectures: amd64
        proxy:
          enabled: true
      apt-mk-salt-nightly:
        source: "deb http://apt-mk.mirantis.com/xenial nightly salt"
        key_url: http://apt-mk.mirantis.com/public.gpg
        architectures: amd64
        proxy:
          enabled: false
      apt-mk-extra-nightly:
        source: "deb http://apt-mk.mirantis.com/xenial nightly extra"
        key_url: http://apt-mk.mirantis.com/public.gpg
        architectures: amd64
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
    env:
      BOB_VARIABLE: Alice
      BOB_PATH:
        - /srv/alice/bin
        - /srv/bob/bin
      HTTPS_PROXY: https://127.0.4.1:443
      http_proxy: http://127.0.4.2:80
      ftp_proxy: ftp://127.0.4.3:2121
      no_proxy:
        - 192.168.0.1
        - 192.168.0.2
        - .saltstack.com
        - .ubuntu.com
        - .mirantis.com
        - .launchpad.net
        - .dummy.net
        - .local
      LANG: C
      LC_ALL: C
    profile:
      vi_flavors.sh: |
        export PAGER=view
        alias vi=vim
      locales: |
        export LANG=en_US
        export LC_ALL=en_US.UTF-8

    # pillar for proxy configuration
    proxy:
      # for package managers
      pkg:
        enabled: true
        https: https://127.0.2.1:4443
        #http: http://127.0.2.2
        ftp: none
      # fallback, system defaults
      https: https://127.0.1.1:443
      #http: http://127.0.1.2
      ftp: ftp://127.0.1.3
      noproxy:
        - host1
        - host2
        - .local

    # pillars for netconsole setup
    netconsole:
      enabled: true
      port: 514
      loglevel: debug
      target:
        192.168.0.1:
          mac: "ff:ff:ff:ff:ff:ff"
          interface: bond0
