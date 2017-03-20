linux:
  storage:
    enabled: true
    swap:
      file:
        enabled: true
        engine: file
        device: /tmp/loop_dev2
        size: 5
    mount:
      # NOTE: simple dummy loop devices, use for test purposes only
      dev0:
        enabled: false
        device: /tmp/loop_dev0
        path: /tmp/node/dev0
        file_system: xfs
        opts: noatime,nobarrier,logbufs=8,nobootwait,nobarrier
        user: root
        group: root
        mode: 755
      dev1:
        enabled: true
        device: /tmp/loop_dev1
        path: /mnt
        file_system: ext4
        #opts: noatime,nobarrier,logbufs=8,nobootwait,nobarrier
        user: root
        group: root
    lvm:
      vg0:
        name: vg0-dummy
        enabled: true
        devices:
          - /tmp/loop_dev3
        volume:
          lv01:
            size: 5M
            mount:
              device: /dev/vg0/lv01
              path: /mnt/lv01
          lv02:
            size: 5M
            mount:
              device: /dev/vg0/lv02
              path: /mnt/lv02
              file_system: ext4
          lv03:
            size: 5M
            mount:
              device: /dev/vg0/lv03
              path: /mnt/lv03
              file_system: xfs
    disk1:
      enabled: true
      device: /dev/loop_dev4
      path: /tmp/dummy
      file_system: xfs
      options: "noatime,nobarrier,logbufs=8"
      user: nobody
      group: nogroup
      mode: 755
