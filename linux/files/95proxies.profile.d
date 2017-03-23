{%- if ftp and ftp.lower() != 'none' %}
ftp_proxy="{{ ftp }}";
FTP_PROXY="{{ ftp }}";
{%- endif %}

{%- if http and http.lower() != 'none' %}
http_proxy="{{ http }}";
HTTP_PROXY="{{ http }}";
{%- endif %}

{%- if https and https.lower() != 'none' %}
https_proxy="{{ https }}";
HTTPS_PROXY="{{ https }}";
{%- endif %}

{%- if noproxy %}
no_proxy="{{ noproxy|join(',') }}";
NO_PROXY="{{ noproxy|join(',') }}";
{%- endif %}

