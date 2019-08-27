linux:
  system:
    enabled: true
    domain: local
    name: linux
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
      vhost_socket_dir:
        name: "openvswitch-vhost"
        path: "/run/openvswitch-vhost"
    interface:
      eth0:
        enabled: true
        type: eth
        proto: manual
        ovs_bridge: br-prv
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
      dpdk2:
        name: enp6s0f1
        pci: "0000:06:00.1"
        driver: igb_uio
        bond: dpdkbond1
        enabled: true
        type: dpdk_ovs_port
      dpdk3:
        name: enp6s0f2
        pci: "0000:06:00.2"
        driver: igb_uio
        bond: dpdkbond1
        enabled: true
        type: dpdk_ovs_port
      dpdkbond0:
        enabled: true
        bridge: br-prv
        type: dpdk_ovs_bond
        mode: active-backup
      dpdkbond1:
        enabled: true
        bridge: br-mesh
        type: dpdk_ovs_bond
        mode: balance-slb
      br-prv:
        enabled: true
        type: dpdk_ovs_bridge
      br-mesh:
        tag: 1302
        enabled: true
        type: dpdk_ovs_bridge
        address: 1.2.3.4
        netmask: 255.255.255.252
      dummy0:
        enabled: true
        name: dummy0
        proto: manual
        ovs_port_type: OVSIntPort
        type: ovs_port
        ovs_bridge: br-prv
        bridge: br-prv
