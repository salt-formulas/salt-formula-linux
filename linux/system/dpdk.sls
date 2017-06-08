{%- from "linux/map.jinja" import network with context %}

{%- if network.dpdk.enabled and network.dpdk.driver == "vfio" %}
include:
  - linux.system.iommu
{%- endif %}