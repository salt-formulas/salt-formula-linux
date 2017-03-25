
## PROXIES
#
describe file('/etc/environment') do
    it('should exist')
    its('content') { should_not match /HTTPS_PROXY"/ }
    its('content') { should match /HTTP_PROXY="http:\/\/127.0.4.2:80"/ }
    its('content') { should match /BOB_PATH=/}
    its('content') { should match /LC_ALL="C"/ }
    its('content') { should match /ftp_proxy=.*127.0.4.3:2121/ }
    its('content') { should match /NO_PROXY=.*dummy.net,.local/ }
end
