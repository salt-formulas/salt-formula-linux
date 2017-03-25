
# PROXIES
#
# globally
describe file('/etc/apt/apt.conf.d/99proxies-salt') do
    it('should exist')
    its('content') { should_not match /ftp/ }
    its('content') { should match /proxy "https.*127.0.2.1:4443"/ }
end

# per repo
describe file('/etc/apt/apt.conf.d/99proxies-salt-opencontrail') do
    it('should exist')
    its('content') { should_not match /ftp/ }
    its('content') { should match /Acquire::https::proxy::ppa.launchpad.net/ }
end

