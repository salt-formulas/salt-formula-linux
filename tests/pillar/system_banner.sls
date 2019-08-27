linux:
  network:
    enabled: true
    hostname: linux
    fqdn: linux.ci.local
  system:
    enabled: true
    name: linux
    banner:
      enabled: true
      contents: |
        ================= WARNING =================
        This is tcpcloud network.
        Unauthorized access is strictly prohibited.
        ===========================================
