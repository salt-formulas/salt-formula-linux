linux:
  storage:
    enabled: true
    swap:
      file:
        enabled: true
        engine: file
        device: /swapfile
        size: 512
    lvm:
      vg0:
        enabled: true
        devices:
          - /dev/vdb
        volume:
          lv01:
            size: 512M
            mount:
              path: /srv
    disk1:
      enabled: true
      device: /dev/dummy
      path: /srv/dummy
      file_system: xfs
      options: "noatime,nobarrier,logbufs=8"
