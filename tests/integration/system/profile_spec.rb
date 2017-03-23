
describe file('/etc/profile.d/salt_profile_vi_flavors.sh') do
    it('should exist')
    its('content') { should match /EDITOR=vim/ }
    its('content') { should match /PAGER=view/ }
    its('content') { should match /alias vi=vim/ }
end

describe file('/etc/profile.d/salt_profile_locales.sh') do
    it('should exist')
    its('content') { should match /LANG=en_US/ }
end

describe file('/etc/profile.d/prompt.sh') do
    it('should exist')
end

