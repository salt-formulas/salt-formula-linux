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
        name: vg0-dummy
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
      user: nobody
      group: nogroup
      mode: 755
