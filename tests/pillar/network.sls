linux:
  system:
    enabled: true
    domain: ci.local
    name: linux.ci.local
  network:
    enabled: true
    hostname: linux
    fqdn: linux.ci.local
    network_manager: false
    #interface:
      #eth0:
        #enabled: true
        #type: eth
        #address: 192.168.0.102
        #netmask: 255.255.255.0
        #gateway: 192.168.0.1
        #name_servers:
        #- 8.8.8.8
        #- 8.8.4.4
        #mtu: 1500
      #vlan69:
        #enabled: true
        #type: vlan
        #use_interfaces:
        #- interface: ${linux:interface:eth0}
    dhclient:
      enabled: true
      backoff_cutoff: 15
      initial_interval: 10
      reboot: 10
      retry: 60
      select_timeout: 0
      timeout: 120
      send:
        - option: host-name
          declaration: "= gethostname()"
      supersede:
        - option: host-name
          declaration: linux
        - option: domain-name
          declaration: ci.local
        #- option: arp-cache-timeout
        #  declaration: 20
      prepend:
        - option: domain-name-servers
          declaration:
            - 8.8.8.8
            - 8.8.4.4
        - option: domain-search
          declaration:
            - example.com
            - eng.example.com
      # ip or subnet to reject dhcp offer from
      reject:
        - 10.0.2.0/24
      request:
        - subnet-mask
        - broadcast-address
        - time-offset
        - routers
        - domain-name
        - domain-name-servers
        - domain-search
        - host-name
        - dhcp6.name-servers
        - dhcp6.domain-search
        - dhcp6.fqdn
        - dhcp6.sntp-servers
        - netbios-name-servers
        - netbios-scope
        - interface-mtu
        - rfc3442-classless-static-routes
        - ntp-servers
      require:
        - subnet-mask
        - domain-name-servers
      # if per interface configuration required add below
      # interface:
      #   ens2:
      #     initial_interval: 11
      #     request:
      #       - subnet-mask
      #       - broadcast-address
      #     reject:
      #       - 10.0.3.0/24
      #   ens3:
      #     initial_interval: 12
      #     reject:
      #       - 10.0.4.0/24
    systemd:
      link:
        10-iface-dmz:
          match:
            type: eth
            # MACAddress: c8:5b:7f:a5:1a:da
            # OriginalName: eth0
          link:
            name: dmz0
      netdev:
        20-bridge:
          NetDev:
             Name: br0
             Kind: bridge
        20-bridge-dmz:
        # test all lowercase
          match:
            name: dmz0
          network:
            description: bridge
            bridge: br-dmz0
      network:
        40-dhcp:
          Match:
            Name: '*'
          Network:
            DHCP: yes
