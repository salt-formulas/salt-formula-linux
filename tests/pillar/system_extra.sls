
linux:
  system:
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
