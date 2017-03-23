describe file('/etc/environment') do
    it('should exist')
    its('content') { should match /HTTPS_PROXY="https:\/\/127.0.4.1:443"/ }
    its('content') { should match /HTTP_PROXY="http:\/\/127.0.4.2:80"/ }
    its('content') { should match /ftp.*127.0.1.3/ }
    its('content') { should match /NO_PROXY=.*192.168.0.2,.local/ }
end

# globally
describe file('/etc/apt/apt.conf.d/95proxies') do
    it('should exist')
    its('content') { should_not match /ftp/ }
    its('content') { should match /proxy "https.*127.0.2.1:4443"/ }
end

# per repo
describe file('/etc/apt/apt.conf.d/95proxies_opencontrail') do
    it('should exist')
    its('content') { should_not match /ftp/ }
    its('content') { should match /Acquire::https::proxy::ppa.launchapd.net "https:.*127.0.5.1:443"/ }
end
# per repo, parsing repo host
describe file('/etc/apt/apt.conf.d/95proxies_opencontrail-dummy') do
    it('should exist')
    its('content') { should match /ftp.*127.0.5.3/ }
    its('content') { should match /Acquire::http::proxy::ppa.dummy.net "http:.*127.0.5.2:8080"/ }
    its('content') { should match /Acquire::https::proxy::ppa.dummy.net "https:.*127.0.5.1:443"/ }
end

