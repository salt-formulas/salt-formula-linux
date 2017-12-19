linux:
  system:
    enabled: true
    domain: ci.local
    name: linux
  network:
    enabled: true
    hostname: linux
    fqdn: linux.ci.local
    network_manager: false
    tap_custom_txqueuelen: 10000
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
        route:
          kubernetes_internal:
            address: 10.254.0.0
            netmask: 255.255.0.0
          some_other:
            address: 10.111.0.0
            netmask: 255.255.0.0
            gateway: 1.1.1.1
      vlan69:
        enabled: true
        type: vlan
        use_interfaces:
        - interface: ${linux:interface:eth0}
