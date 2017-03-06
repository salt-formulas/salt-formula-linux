describe command('grep "" /etc/sudoers.d/*') do
    its('stdout') { should_not match /sudogroup0/  }
    its('stdout') { should match /salt-ops ALL=\(DBA\) NOPASSWD/  }
    its('stdout') { should match /sudogroup2.*localhost=/  }
    its('stdout') { should match /db-ops.*less/  }
    its('stdout') { should_not match /sudogroup0/  }
    its('stdout') { should_not match /sudogroup1 .* !SUDO_RESTRICTED_SU/  }
end
