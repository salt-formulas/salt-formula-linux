{%- from "linux/map.jinja" import network with context %}
export http_proxy="http://{{ network.proxy.host }}:{{ network.proxy.port }}/"
export https_proxy="http://{{ network.proxy.host }}:{{ network.proxy.port }}/"
export ftp_proxy="http://{{ network.proxy.host }}:{{ network.proxy.port }}/"
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
export HTTP_PROXY="http://{{ network.proxy.host }}:{{ network.proxy.port }}/"
export HTTPS_PROXY="http://{{ network.proxy.host }}:{{ network.proxy.port }}/"
export FTP_PROXY="http://{{ network.proxy.host }}:{{ network.proxy.port }}/"
export NO_PROXY="localhost,127.0.0.1,localaddress,.localdomain.com"