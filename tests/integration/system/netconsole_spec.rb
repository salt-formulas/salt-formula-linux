
## NETCONSOLE
#
describe file('/etc/default/netconsole.conf') do
    it('should exist')
    its('content') { should match /^PORT="514"/}
    its('content') { should match /^netconsole "bond0" "192.168.0.1" "ff:ff:ff:ff:ff:ff"/}
    its('content') { should match /^dmesg -n "debug"/}
end

describe file('/etc/dhcp/dhclient-exit-hooks.d/netconsole') do
    it('should exist')
    its('content') { should match /netconsole_setup/}
end
