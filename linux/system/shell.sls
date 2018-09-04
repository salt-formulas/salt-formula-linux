{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}
  {%- if system.shell is defined %}

    {%- if system.shell.umask is defined %}
etc_bash_bashrc_umask:
  file.blockreplace:
    - name: /etc/bash.bashrc
    - marker_start: "# BEGIN CIS 5.4.4 default user umask"
    - marker_end: "# END CIS 5.4.4 default user umask"
    - content: "umask {{ system.shell.umask }}"
    - append_if_not_found: True
    - onlyif: test -f /etc/bash.bashrc

etc_profile_umask:
  file.blockreplace:
    - name: /etc/profile
    - marker_start: "# BEGIN CIS 5.4.4 default user umask"
    - marker_end: "# END CIS 5.4.4 default user umask"
    - content: "umask {{ system.shell.umask }}"
    - append_if_not_found: True
    - onlyif: test -f /etc/profile
    {%- endif %}

    {%- if system.shell.timeout is defined %}
etc_bash_bashrc_timeout:
  file.blockreplace:
    - name: /etc/bash.bashrc
    - marker_start: "# BEGIN CIS 5.4.5 default user shell timeout"
    - marker_end: "# END CIS 5.4.5 default user shell timeout"
    - content: "TMOUT={{ system.shell.timeout }}"
    - append_if_not_found: True
    - onlyif: test -f /etc/bash.bashrc

etc_profile_timeout:
  file.blockreplace:
    - name: /etc/profile
    - marker_start: "# BEGIN CIS 5.4.5 default user shell timeout"
    - marker_end: "# END CIS 5.4.5 default user shell timeout"
    - content: "TMOUT={{ system.shell.timeout }}"
    - append_if_not_found: True
    - onlyif: test -f /etc/profile
    {%- endif %}
  {%- endif %}
{%- endif %}
