linux:
  network:
    enabled: true
    hostname: linux
    fqdn: linux.ci.local
  system:
    enabled: true
    at:
      enabled: true
      user:
        root:
          enabled: true
        testuser:
          enabled: true
    cron:
      enabled: true
      user:
        root:
          enabled: true
        testuser:
          enabled: true
    cluster: default
    name: linux
    domain: ci.local
    environment: prd
    purge_repos: true
    selinux: permissive
    directory:
      /tmp/test:
        makedirs: true
    apparmor:
      enabled: false
    haveged:
      enabled: true
    prompt:
      default: "linux.ci.local$"
    kernel:
      isolcpu: 1,2,3,4
      elevator: deadline
      transparent_hugepage: always
      boot_options:
        - pti=off
        - spectre_v2=auto
      module:
        module_1:
          install:
            command: /bin/true
          remove:
            enabled: false
            command: /bin/false
        module_2:
          install:
            enabled: false
            command: /bin/false
          remove:
            command: /bin/true
        module_3:
          blacklist: true
        module_4:
          blacklist: false
          alias:
            "module*":
              enabled: true
            "module_*":
              enabled: false
        module_5:
          softdep:
            pre:
              1:
                value: module_1
              2:
                value: module_2
                enabled: false
            post:
              1:
                value: module_3
              2:
                value: module_4
                enabled: false
        module_6:
          option:
            opt_1: 111
            opt_2: 222
        module_7:
          option:
            opt_3:
              value: 333
            opt_4:
              enabled: true
              value: 444
            opt_5:
              enabled: false
    cgroup:
      group:
        group_1:
          controller:
            cpu:
              shares:
                value: 250
          mapping:
            subjects:
            - '@group1'
    sysfs:
      enable_apply: true
      scheduler:
        block/sda/queue/scheduler: deadline
      power:
        mode:
          power/state: 0660
        owner:
          power/state: "root:power"
        devices/system/cpu/cpu0/cpufreq/scaling_governor: powersave
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
        maxdays: 365
      testuser:
        enabled: true
        name: testuser
        password: passw0rd
        sudo: true
        uid: 9999
        full_name: Test User
        home: /home/test
        unique: false
        groups:
          - db-ops
          - salt-ops
      salt_user1:
        enabled: true
        name: saltuser1
        sudo: false
        uid: 9991
        full_name: Salt User1
        home: /home/saltuser1
        home_dir_mode: 755
      salt_user2:
        enabled: true
        name: saltuser2
        sudo: false
        uid: 9992
        full_name: Salt Sudo User2
        home: /home/saltuser2
        groups:
          - sudogroup1
    group:
      testgroup:
        enabled: true
        name: testgroup
        gid: 9999
        system: true
        addusers:
          - salt_user1
          - salt_user2
      db-ops:
        enabled: true
        delusers:
          - salt_user1
          - dontexistatall
      salt-ops:
        enabled: true
        name: salt-ops
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
        user: testuser
        minute: 0
        hour: 13
    package:
      htop:
        version: latest
    repo:
      disabled_repo:
        source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
        enabled: false
      disabled_repo_left_proxy:
        source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
        enabled: false
        proxy:
          enabled: true
          https: https://127.0.5.1:443
      saltstack:
        source: "deb [arch=amd64] http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2017.7/ xenial main"
        key_url: "http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2017.7/SALTSTACK-GPG-KEY.pub"
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
      opencontrail:
        source: "deb http://ppa.launchpad.net/tcpcloud/contrail-3.0/ubuntu xenial main"
        keyid: E79EE90C
        keyserver: keyserver.ubuntu.com
        architectures: amd64
        proxy:
          enabled: true
          https: https://127.0.5.1:443
          #http: http://127.0.5.2:8080
      apt-salt:
        source: "deb http://apt.mirantis.com/xenial stable salt"
        #key_url: http://apt.mirantis.com/public.gpg
        # pub   4096R/A76882D3 2015-06-17
        key: |
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          Version: GnuPG v1

          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
          jtcwJrHue5Xn8UPSLkE=
          =SWiA
          -----END PGP PUBLIC KEY BLOCK-----
        architectures: amd64
        proxy:
          enabled: true
      apt-salt-nightly:
        source: "deb http://apt.mirantis.com/xenial nightly salt"
        key_url: http://apt.mirantis.com/public.gpg
        architectures: amd64
        proxy:
          enabled: false
      apt-extra-nightly:
        source: "deb http://apt.mirantis.com/xenial nightly extra"
        key_url: http://apt.mirantis.com/public.gpg
        architectures: amd64
    locale:
      en_US:
        enabled: true
        default: true
      cs_CZ:
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
    login_defs:
      PASS_MAX_DAYS:
        value: 99
    shell:
      umask: '027'
      timeout: 900
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
    atop:
      enabled: true
      interval: 20
      logpath: "/var/mylog/atop"
      outfile: "/var/mylog/atop/daily.log"
    mcelog:
      enabled: true
      logging:
        syslog: true
        syslog_error: true
