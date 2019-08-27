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
    interface:
      br-prv:
        enabled: true
        type: ovs_bridge
        mtu: 65000
      br-ens0:
        enabled: true
        type: ovs_bridge
        proto: manual
        mtu: 9000
        use_interfaces:
        - ens0
      patch-br-ens0-br-prv:
        enabled: true
        name: ens0-prv
        ovs_type: ovs_port
        type: ovs_port
        bridge: br-ens0
        port_type: patch
        peer: prv-ens0
        tag: 107
        mtu: 65000
      patch-br-prv-br-ens0:
        enabled: true
        name: prv-ens0
        bridge: br-prv
        ovs_type: ovs_port
        type: ovs_port
        port_type: patch
        peer: ens0-prv
        tag: 107
        mtu: 65000
      ens0:
        enabled: true
        proto: manual
        ovs_port_type: OVSPort
        type: ovs_port
        ovs_bridge: br-ens0
        bridge: br-ens0
      bond1:
        enabled: true
        type: ovs_bond
        mode: balance-slb
        bridge: br-ex
        slaves: eno3 eno4

