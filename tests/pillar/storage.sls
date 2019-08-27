linux:
  system:
    enabled: true
    name: linux
    domain: local
  network:
    enabled: true
    hostname: linux
    fqdn: linux.ci.local
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
    disk:
      first_drive:
        name: /tmp/loop_dev4
        type: gpt
        partitions:
          - size: 5
            type: fat32
          - size: 5
            type: fat32
