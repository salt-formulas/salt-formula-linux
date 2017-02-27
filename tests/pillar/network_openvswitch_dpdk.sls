linux:
  system:
    enabled: true
    domain: local
  network:
    enabled: true
    hostname: test01
    fqdn: test01.local
    network_manager: false
    bridge: openvswitch
    dpdk:
      enabled: true
      driver: uio
    openvswitch:
      pmd_cpu_mask: "0x6"
      dpdk_socket_mem: "1024"
      dpdk_lcore_mask: "0x400"
      memory_channels: "2"
    interface:
      dpdk0:
        name: enp5s0f1
        pci: "0000:05:00.1"
        driver: igb_uio
        bond: dpdkbond0
        enabled: true
        type: dpdk_ovs_port
      dpdk1:
        name: enp5s0f2
        pci: "0000:05:00.2"
        driver: igb_uio
        bond: dpdkbond0
        enabled: true
        type: dpdk_ovs_port
      dpdkbond0:
        enabled: true
        bridge: br-prv
        type: dpdk_ovs_bond
        mode: active-backup
      br-prv:
        enabled: true
        type: dpdk_ovs_bridge
