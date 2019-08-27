
linux:
  network:
    enabled: true
    hostname: linux
    fqdn: linux.ci.local
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
    enabled: true
    cluster: default
    name: linux
    timezone: Europe/Prague
    console:
      tty0:
        autologin: root
      ttyS0:
        autologin: root
        rate: 115200
        term: xterm
    kernel:
      sriov: True
      isolcpu: 1,2,3,4
      hugepages:
        large:
          default: true
          size: 1G
          count: 210
          mount_point: /mnt/hugepages_1GB
    policyrcd:
      - package: cassandra
        action: exit 101
      - package: '*'
        action: switch
