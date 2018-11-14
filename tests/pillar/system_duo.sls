linux:
  network:
    enabled: false
    hostname: linux
    fqdn: linux.ci.local
  system:
    enabled: true
    at:
      enabled: false
      user:
        root:
          enabled: true
        testuser:
          enabled: true
    cron:
      enabled: false
      user:
        root:
          enabled: false
    cluster: default
    name: linux
    domain: ci.local
    environment: prd
    purge_repos: true
    directory:
      /tmp/test:
        makedirs: true
    apparmor:
      enabled: false
    haveged:
      enabled: true
    prompt:
      default: "linux.ci.local$"
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
      apt-salt:
        source: "deb http://apt.mirantis.com/xenial stable salt"
        #key_url: http://apt.mirantis.com/public.gpg
        # pub   4096R/A76882D3 2015-06-17
        key: |
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          Version: GnuPG v1

          mQINBFWBfCIBEADf6lnsY9v4rf/x0ribkFlnHnsv1/yD+M+YgZoQxYdf6b7M4/PY
          zZ/c3uJt4l1vR3Yoocfc1VgtBNfA1ussBqXdmyRBMO1LKdQWnurNxWLW7CwcyNke
          xeBfhjOqA6tIIXMfor7uUrwlIxJIxK+jc3C3nhM46QZpWX5d4mlkgxKh1G4ZRj4A
          mEo2NduLUgfmF+gM1MmAbU8ekzciKet4TsM64WAtHyYllGKvuFSdBjsewO3McuhR
          i1Desb5QdfIU4p3gkIa0EqlkkqX4rowo5qUnl670TNTTZHaz0MxCBoYaGbGhS7gZ
          6/PLm8fJHmU/phst/QmOY76a5efZWbhhnlyYLIB8UjywN+VDqwkNk9jLUSXHTakh
          dnL4OuGoNpIzms8juVFlnuOmx+FcfbHMbhAc7aPqFK+6J3YS4kJSfeHWJ6cTGoU1
          cLWEhsbU3Gp8am5fnh72RJ7v2sTe/rvCuVtlNufi5SyBPcEUZoxFVWAC/hMeiWzy
          drBIVC73raf+A+OjH8op9XfkVj6czxQ/451soe3jvCDGgTXPLlts+P5WhgWNpDPa
          fOfTHn/2o7NwoM7Vp+BQYKAQ78phsolvNNhf+g51ntoLUbxAGKZYzQ5RPsKo+Hq6
          96UCFkqhSABk0DvM0LtquzZ+sNoipd02w8EaxQzelDJxvPFGigo1uqGoiQARAQAB
          tCx0Y3BjbG91ZCBzaWduaW5nIGtleSA8YXV0b2J1aWxkQHRjcGNsb3VkLmV1PokC
          OwQTAQIAJQIbAwYLCQgHAwIGFQgCCQoLBBYCAwECHgECF4AFAlWj4K8CGQEACgkQ
          JACFCadogtPm9xAAl1D1RUY1mttjKk+8KI3tUmgtqLaIGUcB4TPbIhQpFy23TJd6
          BnnEaGZ+HSCj3lp/dBoq1xxCqHCziKA04IpPaLpGJf8cqaKOpQpW1ErlSxT6nCQW
          FrHFxZreBTljKqW3fvRBXNAquj0krJEwv19/3SsQ+CJI2Zkq/HPDw9eJOCu0WcJM
          PVtAq2SmaDigh1jtFcFoWZ7uFFMQPIWit/RCPkDfkFaf6lbYZ/nnvWON9OAgzWci
          GJjCp5a7vMyCpTRy6bgNPqM61omCe0iQ4yIcqANXhRYS/DBnjKr9YaDKnlKNUgd1
          WRE8QzErQznH/plgISQ+df+8Iunp3SBr/jj1604yyM1Wxppn1+dAoTBU1OPFGVd3
          mCEYHUe+v0iTZ69C2c1ISmp2MjciGyE/UPbW9ejUIXtFJAJovZjn6P3glyIQB3wq
          AW6JE+xEBWH7Ix+Uv6YNAFfj3UO6vNjtuGbTCWYDCEJRkdmeE7QdTYDo7PxgPl1t
          6xMGPLOBdYNJTEojvRYBTt+6iw0eZ+MCUdUFNeaseQh0p1RgqM9/7t75QCNLl1oO
          +Cfu4vNef/Tpd3LHcUoQhQ2OViOVFbq1/Yu/natWDPDcXb3peTcNHOjmXAoboWbz
          rDkxj5z7vcJ9LMEXviP6Fb/iXDmJh74/o6Agc8efb0WTmFjPFFtMCHrinb+5Ag0E
          VYF8IgEQALUVS2GESQ+F1S4b0JIO1M2tVBXiH4N56eUzcDXxXbSZgCgx4aWhk5vJ
          Qu7M11gtqIoiRbmuFpUmDOG/kB7DxBZPn8WqcBKpky6GUP/A/emaAZTwNQdcDAhD
          foBkJdhVz0D2jnkBffYL055p/r1Ers+iTTNOas/0uc50C32xR823rQ2Nl6/ffIM6
          JqfQenhRvqUWPj9oqESHMsqEdceSwS/VC7RN4xQXJXfEWu2q4Ahs62RmvCXnTw1A
          sPcpysoBoo8IW+V1MVQEZuAJRn2AGO/Q7uY9TR4guHb3wXRfZ3k0KVUsyqqdusJi
          T3DxxBw6GcKdOH6t41Ys3eYgOrc+RcSdcHYSpxaLvEIhwzarZ+mqcp3gz/JkPlXS
          2tx2l6NZHcgReOM7IhqMuxzBbpcrsbBmLBemC+u7hoPTjUdTHKEwvWaeXL4vgsqQ
          BbEeKmXep5sZg3kHtpXzY9ZfPQrtGB8vHGrfaZIcCKuXwZWGL5GGWKw3TSP4fAIA
          jLxLf5MyyXcsugbai2OY/H4sAuvJHsmGtergGknuR+iFdt5el1wgRKP1r1KdmvMm
          wsSayc6eSEKd689x3zsmAtnhYM31oMkPdeYRbnN15gLG7vcsVe4jug0YTqQt2WGn
          hwjBA0i2qfTorXemWChsxKllvY9aB3ST8I6RMat0kS08FMD+Ced/ABEBAAGJAh8E
          GAECAAkFAlWBfCICGwwACgkQJACFCadogtNicA/9HOM402VGHlmuYPcrvEThHqMK
          KOTtNFsrrPp67dGYaT8TGTgy1OG4Oys2y+hrwqnUK6dXJxX2/RBfRuO/gw65RCfC
          9nWeMkqJTjHJCKNTYfXN4O4ag444UZPcOMq+IyiWF3/sh674zCkCm5DQ/FH8IJ8Y
          n4jMoxe7G48PCGtgcJKXo8NBzxwXJH4DCdk7rNdrbrnCwObG8h6530WrmzKuyFCJ
          QP5JA0MSx23J2OrK2YmVMhTeO0czJ8fRip9We9/qAfZGUEW+sey+nLmT5OJq04al
          Va9g2a4nXxzDy84+hRXQNUeCRYn/ys8d8q9HZNv3K36HlILcuWazNTTh0cuWupBd
          SlIEuWbIdbknYpGsmS1cPeGi0bdoLZv90BIVmdOS/vXP02fGUblyANciKcBPRhOI
          +z6hzwdZ+QvjPbxZUig5XuvqBhIHoRtMBJdf24ysFuf/d4uZzTC8T4rUQO+L29bt
          8riT0dg6cHVwC0VH89FaO1FduvsCtAwdAgxSzOMBECNOmVBThIiWdLnns107Rp4F
          ECk+l2UCjl7zwGqJqcd1BQK+UgZwVG2UV11CrhopKU5oGL84n5DaO2n6Rv8wVdrt
          MKvqi7EkgvZpY0IHJ7rp0Gzrv0qmwJaUFCWFogITNyijb1JVsUgDTMhAkEgEsIYy
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
      duo:
        key: |
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          Version: GnuPG v2.0.22 (GNU/Linux)

          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
          WbTIiN63dr6gdz7hoZJ7PFmJ
          =t1j7
          -----END PGP PUBLIC KEY BLOCK-----
        source: "deb [arch=amd64] http://pkg.duosecurity.com/Ubuntu xenial main"
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
      enabled: false
    env:
      BOB_VARIABLE: Alice
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
    auth:
      enabled: true
      duo:
        enabled: true
        duo_host: localhost
        duo_ikey: DUO-INTEGRATION-KEY
        duo_skey: DUO-SECRET-KEY

