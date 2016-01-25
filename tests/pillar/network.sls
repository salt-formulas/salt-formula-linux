linux:
  system:
    enabled: true
    domain: local
  network:
    enabled: true
    hostname: test01
    fqdn: test01.local
    network_manager: false
    interface:
      eth0:
        enabled: true
        type: eth
        address: 192.168.0.102
        netmask: 255.255.255.0
        gateway: 192.168.0.1
        name_servers:
        - 8.8.8.8
        - 8.8.4.4
        mtu: 1500
      vlan69:
        enabled: true
        type: vlan
        use_interfaces:
        - interface: ${linux:interface:eth0}
