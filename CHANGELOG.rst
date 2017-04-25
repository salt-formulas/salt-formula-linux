=========
Changelog
=========

Version 2017.4.1
=============================

commit df84869f9c5d46e450a27eefafe952d560c9acb2 (HEAD -> master)
Author: Filip Pytloun <filip@pytloun.cz>

    Fix makefile

commit 09820f1bbbe2ad32b82a4a44f2370be8508aa605
Author: Filip Pytloun <filip@pytloun.cz>

    Version 2017.4

commit 34a29b491de30bd541bee2726794874127942be6
Author: Jiri Broulik <jiribroulik@gmail.com>

    README fix for purging repos

commit 1e47abe149328eb7c5c5585979bb63849d0246af
Author: Damian Szeluga <damian.szeluga@gmail.com>

    Add option to parametrize checks

commit 0792a9bcf338738c11def7e078ab6f2f7cc17c14
Author: Jiri Broulik <jiribroulik@gmail.com>

    mkdirs in netconsole fix

commit f05e7d4eefeca9b7ed2a986656b4d1ba3f429b89
Author: Tatyana Leontovich <tleontovich@mirantis.com>

    Fix mistake in kernel.sls

commit 25839cca97f12ffba38b8ca63bff3f83330f9cb8
Author: Jiri Broulik <jiribroulik@gmail.com>

    purging repos

commit 361d69943b777aaaff12f7c70ae68f07ac633240
Merge: 9ed3403 ccf2884
Author: Filip Pytloun <fpytloun@mirantis.com>

    Merge "netconsole remote kernel logger"

commit ccf28849b017296fb9a5f6b48b1809660786ef4e
Author: Vladimir Eremin <veremin@mirantis.com>

    netconsole remote kernel logger

commit 459da2bc650d38a219c218d3374d6547f37f4db6 (origin/pr/preinstall-apt-https-tranpsort2)
Author: Petr Michalec <epcim@apealive.net>

    avoid install system pkgs before repo configured

commit 6969322bee652d0991a7f2e65325b01f279beaad (origin/pr/preinstall-apt-https-tranpsort)
Author: Petr Michalec <epcim@apealive.net>

    preinstall apt https transport

commit 9ed340364a2f430442903a96a17930c14f7991e7
Author: Marek Celoud <mceloud@mirantis.com>

    add package include into repo state

commit 6357299ee2d2019ec5ed1ec7646f55647254cf5a
Author: Aleš Komárek <github@newt.cz>

    Update README.rst

commit 0bd8565876a43d17ed1b4306c1af59ac8516c02b
Author: Bartosz Kupidura <bkupidura@mirantis.com>

    Add support for prometheus

commit df9b40d973dc821c13b5798e53c0613d3a23d599
Author: Bartosz Kupidura <bkupidura@mirantis.com>

    Add telegraf support

commit b845058fe5cf6d50c86a18ceb35c6c1fdb926c85
Author: Jiri Broulik <jiribroulik@gmail.com>

    nfs filesystem mount fix

commit b017f93ade687a25a1af61d6fbec31f4c14254df
Author: Jiri Broulik <jiribroulik@gmail.com>

    nfs storage mount

commit f0d157b0a946e76219d0f380cf8858aa0cda5876
Author: Martin Polreich <polreichmartin@gmail.com>

    Update .travis.yml and notififcations

Version 2017.4
=============================

commit d1126613407a6c2ca2e409b55fc73532d5c0288b (tag: 2017.4)
Author: Filip Pytloun <filip@pytloun.cz>

    Version 2017.4

commit 75f97238183857a2fb9a1bd698d218b7028fffd2
Author: Filip Pytloun <filip@pytloun.cz>

    Fix profile.d permissions again

commit 41d775d60acf038619c63079353bdbde2d45d100
Author: Filip Pytloun <filip@pytloun.cz>

    Fix /etc/profile.d permissions

commit 914eff9e0f30184c5c0bf88190fcb4697326712c
Author: Filip Pytloun <filip@pytloun.cz>

    Cleanup reponame.list to remove obsolete entries

commit 2896b7297c0eb23e5317211ecf7d2c4c990d42bc
Author: Alexander Noskov <noskovao@users.noreply.github.com>

    Update etc_environment

commit 10462bba7f4d927d34dbfe13d8720405b6fa38ec (origin/pr_proxy_advance2)
Author: Petr Michalec <epcim@apealive.net>

    Add system.env, system.profile, system.proxy and configure proxy under system.repo

commit a4a6f16bbe5d89c58f203a9fe4d1ca39c685af34
Author: Simon Pasquier <spasquier@mirantis.com>

    Fix severity for the linux_system_cpu_warning alarm

commit 16f928f5dfc3efad20c9efd243c697f15bf73ed6
Author: Petr Jediný <pjediny@mirantis.com>

    Workaround for salt network interfaces bug

commit c146f18e8f86d8dbcf15495a5c92cfca71773753 (origin/pr_advanced_repo_options)
Author: Petr Michalec <epcim@apealive.net>

    Add consolidate/clean_file/refresh_db pkgrepo options

commit 735761d3e57ac599661a33adcc6c41b6a1321374
Author: Andrii Petrenko <aplsms@gmail.com>

    Feature: automatically set txqueuelen for all tap* network interfaces
    Config:

commit 8578aafdde632702e1c52dd5fef368f6b5747b6b
Author: Filip Pytloun <filip@pytloun.cz>

    Fix typo and test

commit 28d7a54e9b2eb07ede8944dc3830d3e1c11eda7a
Merge: d390985 e9bcd2d
Author: Filip Pytloun <filip@pytloun.cz>

    Merge "Setup LV before mkfs"

commit d390985ef1cb428ff2fcfa481f9334f8a10ef06e
Merge: aa75906 89b9764
Author: Ales Komarek <akomarek@mirantis.com>

    Merge "Report swap metrics in bytes"

commit aa75906e0b7f6c1409fb869c3afc03b3f55e9720
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    Linux OVS dpdk vxlan tunnel endpoint ip address

commit 89b97640d0bc8c89b20e68fa14196b25d7c7f5bd
Author: Simon Pasquier <spasquier@mirantis.com>

    Report swap metrics in bytes

commit e9bcd2d6dd6face7405f46df27ae200236000fa5
Author: Filip Pytloun <filip@pytloun.cz>

    Setup LV before mkfs

commit d549b454c9d7cf8a1eb7927e3178c82bd8874450
Author: Filip Pytloun <filip@pytloun.cz>

    Fix ipv6 hosts entries

commit 5ca7ca15f2288541bb30801a37dc7381edc61f6f
Merge: b67aee9 21ca215
Author: Marek Celoud <mceloud@mirantis.com>

    Merge "Linux OVS-dpdk and multiqueue support"

commit 21ca2159b28abb44326cfc79d41eea14aefe9be8
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    Linux OVS-dpdk and multiqueue support

commit 352775376d56dc4d82be96aba1b0f96351d99c6f (origin/pr_add_validation)
Author: Petr Michalec <epcim@apealive.net>

    Add kitchen tests + travis ci

commit 159d381e0f43cbde66fdd96191b8eacf8fc5a592
Author: Marek Celoud <mceloud@mirantis.com>

    require linux_packages install in repo state

commit 8904d6039f5f3d3bc02c76bedb82b4e7bc519ba3
Author: Marek Celoud <mceloud@mirantis.com>

    disable restart of networking service without reboot

commit 1c4c8d8932361709ea7bc36d68fa5b4de9f84f07 (origin/pr_sudo_for_groups)
Author: Petr Michalec <epcim@apealive.net>

    Add sudo state, salt-managed aliases,users,groups
    - apply review comments
    - add visudo check cmd

commit f0864a09450e0c3c00ee281b4236703c51c8b939
Author: Marek Celoud <mceloud@mirantis.com>

    add master option for bond slaves

commit aeb7e6f2f172ff92dba8a2eb9d15b1d9ad96b439
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    Fix hugepages mount user rights

commit b691efe5f908c14e337d91eaeac995b9b8fa6598
Author: Bruno Binet <bruno.binet@gmail.com>

     Group packages to install/remove when possible for better performance (#62)

commit 6c9ead164d5e42919b52a94c98767eca19ac6cbc
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    Implement isolcpu grub configuration

commit c665ee25fe4b9db03cf5cf70d95dc3742cde277a
Author: Filip Pytloun <filip@pytloun.cz>

    Add autoupdates into tests

commit 8a7064c45b8fb73fe7d38c9b67c3c57a64549c7d
Author: Filip Pytloun <filip@pytloun.cz>

    Fix include of linux.system.autoupdates

commit 69a9d8d6caf6da27464edd38655829dec9b18b60
Author: Bruno Binet <bruno.binet@gmail.com>

    Add system.autoupdates state (#61)

commit ba35b215162d6da21836a0104390eea7ed0d02ec
Author: Tomáš Kukrál <tomkukral@users.noreply.github.com>

    add support for kernel modules

commit e3c04fd5353bb3614710be036e64bb3a31f3369d
Author: Bruno Binet <bruno.binet@gmail.com>

    Prefer "pkgs" rather than "names" when using pkg.installed

commit 8a6770e61e0c1b683a1fa5ac721743e443d75c8c (origin/pr_fix_hostname_template)
Author: Petr Michalec <epcim@apealive.net>

    remove trailing line, causing every deployment to update the file and trigger hostname enforce

commit 5398d873d5d2e377eb7129bffdcd130452fbbab1
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    SRIOV support

commit fe57bdd45b6fdfbba246e33d6eed59f51cd75076 (origin/pr_hostname)
Author: Petr Michalec <epcim@apealive.net>

    dont touch hostname if not needed

commit b148c8ca8ef79652115be8dcc99837ed9e6bb7c8
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    Hugepages support

commit 018f871e175821a76cfa03772504118dcba2a9cc (tag: mcp0.5)
Author: Filip Pytloun <filip@pytloun.cz>

    Unify Makefile, .gitignore and update readme

commit 6df65bbd67a1f49b430e6ecba49fdb74d5d9022d
Author: Michel Nederlof <mnederlof@cloudvps.com>

    Because it is possible to add more interfaces to the same bridge, make the salt resource name more unique.

commit 7c077f64b62a2c4c5cac980e8f61786f745b4dc3
Author: Michel Nederlof <mnederlof@cloudvps.com>

    Only add the interface to the ovs_bridge, if the name in ovs_bridge is the same.

commit fb9736ddbdc6aeb12bd6736c2573f0f1b5107433
Author: Olivier Bourdon <obourdon@mirantis.com>

    Fix issue where interface is left unconfigured

commit 279521e7d58d9f5737f427b4e2caba27a614831e
Author: Dennis Dmitriev <ddmitriev@mirantis.com>

    Remove excess records from /etc/hosts

commit 8daed52b9210355cee2990cf76df73af9ed69ddb
Merge: 8b49714 86506fe
Author: Filip Pytloun <filip@pytloun.cz>

    Merge "Allow enforcing of whole /etc/hosts"

commit f8f55a2fccbe282b8855c36abdc3c823381413a1
Author: Jiri Broulik <jiribroulik@gmail.com>

    cpu governor

commit 375001e027b64ff38dc0c52dd33ec3e21f40a8ec
Author: Simon Pasquier <spasquier@mirantis.com>

    Add linux.storage.loopback state

commit 86506fe7438bc8c01cb276968fc0364d72bd92fe
Author: Filip Pytloun <filip@pytloun.cz>

    Allow enforcing of whole /etc/hosts

commit 37837f328068c1881ac29e61e2211fcdde91e0b3
Author: vmikes <vlastimil.mikes@tcpcloud.eu>

    Revert "turn off check swap if needed"

commit a63f4053f3a16782ba1bfa1b8ffb575dcff8b6ad
Author: vmikes <vlastimil.mikes@tcpcloud.eu>

    turn off check swap if needed

commit fc60eb0668494dc0692a867fd8b7c8cef08d3249
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    OVS improvements

Version 2016.12.1
=============================

commit 6d6f5b4c000b756b30b794d853d63f4cb9e95951
Author: Éric Lemoine <elemoine@mirantis.com>

    Remove support for log_collector

commit a956bfe054fbf8de78aa39eaf7408768ea29df92
Author: Éric Lemoine <elemoine@mirantis.com>

    Remove ununused heka.conf file

Version 2016.12
=============================

commit 6c3b8b9b161573587723ca1bfa6f26d2fec8fba0
Author: Vladimir Eremin <veremin@mirantis.com>

    I believe you mean cron.absent state

commit f2720ea9eb7ecb6d8bbae63e4d4fac8d7ca95790
Author: Filip Pytloun <filip@pytloun.cz>

    Allow defining config files user, group and mode

commit f6cd1921c1d91511c8856ba026567bd92aef8f4f
Author: Marek Celoud <mceloud@mirantis.com>

    fix options setting in resolv

commit 02e681ce7fc9ecd41d3e6a2151090e904fe9c17d
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    ovs advanced options

commit 02f7761b5dde0a860b96a9a1e55d8292173e7f96
Author: Filip Pytloun <filip@pytloun.cz>

    Fix missing iteritems in loop

commit 6c6944604dc20f9692bd948627518cce135bbab4
Author: Filip Pytloun <filip@pytloun.cz>

    Support defaults in linux.system.config

commit 6b6058fd3a398df704c6eb5dd58912cd4ee87860
Author: Simon Pasquier <spasquier@mirantis.com>

    Support no volume for linux.storage.lvm state

commit a4eb313e4fcd04889cabef6ed79cce2b4521c184
Author: Simon Pasquier <spasquier@mirantis.com>

    Fix linux.storage state to support lvm

commit 376af204417b838c522c4c1a677e734428d2fa75
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    hotfix interface name

commit eec2b7c990276c1b727cf60b82b93f2c5da1d75f
Merge: 89654cc 9e5b7a1
Author: Simon Pasquier <spasquier@mirantis.com>

    Merge remote-tracking branch 'upstream/master' into stacklight

commit b4f82c60133de0c1964c1de3081404b7910f2e60
Author: Guillaume Thouvenin <gthouvenin@mirantis.com>

    Put Grafana dashboards into their own directory

commit 6086f63c3765a4c372136591df9f7a8a8f689bdb
Author: Ales Komarek <ales.komarek@newt.cz>

    Added proper OpenVswitch support

commit 2f06db9e6d6121864570046faaad67b9bec2225e
Author: Éric Lemoine <elemoine@mirantis.com>

    Add more alarms

commit e3ffd626048702040e40e7be3cca20f96a439297
Author: Filip Pytloun <filip@pytloun.cz>

    Fix variable reference

commit b2c8f858fa7c9cb1d3ce9072cb2af3471aee7609 (origin/config)
Author: Filip Pytloun <filip@pytloun.cz>

    Add support for external config generation

commit e29d0a4f7727487846d675f1f6ceadec488d08ff
Author: Guillaume Thouvenin <gthouvenin@mirantis.com>

    Provides Grafana dashboard

commit 376262a39d5cbf65ef71c949cfaeddd2dee5c33e
Author: Simon Pasquier <spasquier@mirantis.com>

    Fix mount examples in the README

commit 1f75d30237aab5bbfa196f9c6763b6e95a4548d8
Author: Simon Pasquier <spasquier@mirantis.com>

    Fix the linux.storage.mount state for tmpfs

commit 866c348d3267311033c81791698b6fca275d332b
Author: Olivier Bourdon <obourdon@mirantis.com>

    Fix for network interfaces idempotence

commit 577fbf5131a8f61fc9074e1ef72ba4257f65c5ce
Author: Olivier Bourdon <obourdon@mirantis.com>

    Fix for hosts file idempotence

commit 210e98304eb6c5333ff3ddab24c0c9690b7beb0c
Author: Swann Croiset <scroiset@mirantis.com>

    Redefine alerting property

commit 8db94b38f4495e8fe6e946f5931bedfc75c26f0c
Author: Simon Pasquier <spasquier@mirantis.com>

    Fix Syslog pattern for system logs

commit e877605126397b35d07ebc794579307f7ee62f15
Author: Simon Pasquier <spasquier@mirantis.com>

    Add timezone support for system logs

commit 1787f0b297e1a2c8d41a358bc2c36da457da1085
Author: Éric Lemoine <elemoine@mirantis.com>

    Rename netlink.py to linux_netlink.py

commit 1c39744e434fef93faa6cd64476c88ac2c93b93e
Author: Éric Lemoine <elemoine@mirantis.com>

    Use netlink collectd plugin instead of interface

commit a607e433f9062ead222e91c1eb1a887b134d0698
Author: Éric Lemoine <elemoine@mirantis.com>

    Use same collectd df options as StackLight MOS

commit 3035609caface116bd47ec0cd516d3cd07af3d96
Author: Éric Lemoine <elemoine@mirantis.com>

    Remove Heka decoder tz handling

commit c7713b13263cc8c33d6e01d8bfc9d32bc592ea3f
Merge: 26d3798 d5ba24b
Author: Daniel Cech <daniel.cech@tcpcloud.eu>

    Merge branch 'sensu' into 'master'

commit 599068289da5897e0f2d5e89224f550fef01215a (origin/feature/salt-orchestrate)
Author: Adam Tengler <a.tengler@tcpcloud.eu>

    Orchestration metadata

commit 318ebd1569eed33357de3c2395ddcaf6355414bf
Author: Simon Pasquier <spasquier@mirantis.com>

    Remove the log counter filter from meta/heka

commit 480003965f9192e5f5937a7f58c83ba90a94d892
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Sample alarms

commit 8824240cbb6b92bd61ef69c9d44d9a3ca7297f36 (origin/add-hashing-alghoritm-interface-param)
Author: Petr Michalec <epcim@apealive.net>

    xmit_hash_policy to hashing-alghoritm

commit f0a5fe4709374ed25bac0f9812f44a25b487ec8f (origin/bond_interface_params)
Author: Petr Michalec <epcim@apealive.net>

    additional bond interface params

commit b87ccd327dcc4d1fc83fa5e2111f3f2b18582fd1
Author: Éric Lemoine <elemoine@mirantis.com>

    Add timezone to syslog decoder config

commit bf02e9dede29e5d866af274a38e010ab01a89b45
Author: Éric Lemoine <elemoine@mirantis.com>

    Use the proper module directory

commit 1a1f375498cc3643bbc20672d76b7e37b3ba6d90
Author: Éric Lemoine <elemoine@mirantis.com>

    Set "hostname" in the linux_hdd_errors|counters filters

commit fb25b9d60ac8950b1d09a0dbbdfee94d5dc587e8
Author: Éric Lemoine <elemoine@mirantis.com>

    Fix decoder name

commit 48199ab618e2734a93172571cc5f2eccc2c8e9ab
Author: Éric Lemoine <elemoine@mirantis.com>

    Remove the alarm-related filters

commit b02c10f0beb83ea41aa6cd7d9a4757a9bcf03011
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Collectd fixes

commit f94e16c5698468fabf07339492b5dac81a8acdc4
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Global collectd update

commit a457359f89cb3573c63558f27f9fcd6aad9704cf
Author: vmikes <vlastimil.mikes@tcpcloud.eu>

    update warning threshold

commit 86c2311801871928d04882118aad5a081e3f39e1
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Fix the multipath condition

commit a634f4ba38e48df2217bf0f68f3fdd8ffa3a15ba
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Refactored multipath support

commit a38a3ccf1ce45ba99ee0d5d2a563ea56e4d3e5fc
Author: Filip Pytloun <filip@pytloun.cz>

    Install apt-transport-https

commit 15cd6f3376f1cf94254f49ffb68686694d2b5772
Author: Filip Pytloun <filip@pytloun.cz>

    Allow updating ca_certificates without salt-pki

commit d147ae1dd2730a8a3ab075caec8baad02940f452
Author: Filip Pytloun <filip@pytloun.cz>

    Fix repo_url definition

commit 4ad86e05e6e51dd7e8cb4e122d0f1075bcfa1aa8
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    gro parametr

commit 110e574c53d3cf306f15bf5eec04b69e3fb42c82
Author: Pavel Cizinsky <pavel.cizinsky@tcpcloud.eu>

    add parameters stp, maxwait

commit 329a31d67eddb353db69ad6abe5ef108bd8dd822
Author: Filip Pytloun <filip@pytloun.cz>

    Allow purging and removing packages

commit e7a1ef7f4c42ccf156397a6c8e8143580a13a183
Author: Filip Pytloun <filip@pytloun.cz>

    Enable contextswitch collectd plugin

commit d5ba24b4af7fcfa995bf6876f2833dafb686f1b8
Author: vmikes <vlastimil.mikes@tcpcloud.eu>

    if storage.swap is defined

commit c8548ed2a64e2b61b7ef85f9a60bc7b768ba0452
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Fix hostnames ordering fix if multiple addresses applies

commit 271ee55fde411989a275c8763a4dd77ada8e9ce1
Author: Filip Pytloun <filip@pytloun.cz>

    Disable resolvconf updates when nameservers are defined

commit b6fe1ab5322f70e4c8e99e05eeb9b4ed13c99ae5
Author: vmikes <vlastimil.mikes@tcpcloud.eu>

    never too many

commit 3a9faa53ed20eebba26b2c10d624b009a73f808a
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Container metadata

commit 0aaf5affa08286a51d5fd63bbc7881abfcf7d1a5
Author: Filip Pytloun <filip@pytloun.cz>

    Fix source dependency parsing

commit 9f3a391fbb25953573ab37445122ab069d261ac7
Author: Filip Pytloun <filip@pytloun.cz>

    Fix tests dependency fetch

commit 4a0367b14173a430f1135b36c004272b37de8658
Author: Filip Pytloun <filip@pytloun.cz>

    Add salt-master into build depends

commit 35a3833fe07f22de6e9be296ca8e2137ad8dfd36
Author: Filip Pytloun <filip@pytloun.cz>

    Add makefile, run tests during package build

commit ee1745feb875f887c867f7332f8a176610cc721f
Author: Filip Pytloun <filip@pytloun.cz>

    Fix readme of cs_CZ locales

commit c49445a4f0279a3dccb3c001edef6719dc8ed9d4
Author: Filip Pytloun <filip@pytloun.cz>

    Allow setting system locales

commit 25c9de7ced0cd50f6408114db1ccf38234eb5ced
Author: Filip Pytloun <filip@pytloun.cz>

    Revert "Don't check swap if not present"

commit 6edb3a7a68e4cc25b6f63bc6ad6d17a9f6dfbfb9
Author: Filip Pytloun <filip@pytloun.cz>

    Don't check swap if not present

commit eef11c1aa022b54dd299493f913bead2e562035f
Author: Filip Pytloun <filip@pytloun.cz>

    Option to preserve bash history

commit 96be4379cb13164fa3ac440851d3c9abc250517a
Author: Filip Pytloun <filip@pytloun.cz>

    Enhance yum repo definition

commit 5d7f35c5c62d9277263e0a30c007eb34265e8f3e
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Better localhosts reorder conditional

commit 878ea32824e0006122863aff478ec493a12e0804
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Host order fix finalisation

commit c00acb30e77d2d17b2c5dc45e075d9e45533c109
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Host order fix

commit 30ff811bce4dcec93014c73eccfb9f448c22c317
Author: Filip Pytloun <filip@pytloun.cz>

    Fix haveged resource names

commit 8296bb9c02d1e911d891145d1f3fa674ad38b26d
Author: Filip Pytloun <filip@pytloun.cz>

    Support for haveged

commit ee07210614d4cbe2976159097760efbdd8f0b910
Author: Filip Pytloun <filip@pytloun.cz>

    Fix pillar reference

commit 35a7214d1b8cefcba6297850a13546d6f1a5ec6e
Author: Filip Pytloun <filip@pytloun.cz>

    Fix endfor

commit 2f70b492e064ba0b77c2d51b1d52cdbab441c11c
Author: Filip Pytloun <filip@pytloun.cz>

    RHEL compatibility of motd and prompt

commit f27fa81952d3d43c8781c07893b581b8942809d1
Author: Filip Pytloun <filip@pytloun.cz>

    Fix typo in variable name

commit c48d0f30bf96e923ddd0b2c5570c0757191f1ac1
Author: Alena Holanova <alena.holanova@tcpcloud.eu>

    clean up

commit 48a3a1ae69580d0fc3c32e54906f708d1c966087
Author: Alena Holanova <alena.holanova@tcpcloud.eu>

    fix xfs tools

commit 92d1216546332c1ae240887b151533b2d517284e
Author: Filip Pytloun <filip@pytloun.cz>

    Redhat compatibility for proto: manual

commit 7589acdad10d74d32271a7e5285f0cff417f74da
Author: Filip Pytloun <filip@pytloun.cz>

    Doc validity check for redhat

commit 6f9326c625804fab42fca0af5cf69c9fe46130ff
Author: Filip Pytloun <filip@pytloun.cz>

    Fix installation of xfsprogs

commit a690294251b19b367daef505224a50b1ab5a80b7
Author: Filip Pytloun <filip@pytloun.cz>

    Fix previous commit

commit e1b00b85ed9d175e0d7e6a83bae984681418d7af
Author: Filip Pytloun <filip@pytloun.cz>

    Allow setting VG and LV names from parameter

commit bd3e303410db0ffa37e6ace02a3ac033d49a6388
Author: Filip Pytloun <filip@pytloun.cz>

    Allow setting mountpoint permissions

commit 3954bad18c84ed1f1af4c83ee66bd57998f56559
Author: Filip Pytloun <filip@pytloun.cz>

    Install xfsprogs when needed

commit e0ff433cf08d339888a9cfdfe28bcb9ea15b8fd1
Author: Adam Tengler <a.tengler@tcpcloud.eu>

    Description added to sphinx doc

commit 7731b8581c6ffad38ee15cbbfdf1ff615b63c3b6
Author: Filip Pytloun <filip@pytloun.cz>

    Allow setting policy-rc.d

commit e74f57b7bee30b708180cf67b86ab23aabc6860a
Merge: 9e86136 281d020
Author: Jakub Pavlik <j.pavlik@tcpisek.cz>

    Merge branch 'console' into 'master'

commit 281d020aada26203645bb01cb1d96be1760c5423
Author: Filip Pytloun <filip@pytloun.cz>

    More options for consoles

commit 9e861367cf37ae67d4ef825a97c63487719b2d46
Author: Ales Komarek <ales.komarek@tcpcloud.eu>

    Do not create fs for nfs4

commit 32ef59fecc64e169288822a8880ee80fbf33c355
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    fixes in sysctl kernel parameters

commit 116d627368b9015337704addc987129f1f624e45
Merge: 4a9a28e 32c2cb0
Author: Jakub Pavlik <j.pavlik@tcpisek.cz>

    Merge branch 'feature-sysctl' into 'master'

commit 32c2cb09f0d689481a17f9d2fbac5f4b5e5bbaf6
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    Linux sysctl kernel parameters

commit 83c06ca0dbb661801b1fda16a6ed85d86adefe18
Author: Lachlan Evenson <lachlan.evenson@lithium.com>

    fix swap file check

commit ee58c92f7a9b916d36e0f58255c0533397dc58f0
Author: Filip Pytloun <filip@pytloun.cz>

    There should be end of line in /etc/hostname

commit a189857e0fab9eeb7bee53efbada35d4c72e5194
Author: Filip Pytloun <filip@pytloun.cz>

    Add tests

commit 658b5e1d1347be4e5f85090f315d20d6dea9686d
Author: jan kaufman <jan.kaufman@tcpcloud.eu>

    add module metadata

commit 7277ba9601fde97225af84609a9674fa339ca60e
Author: Lachlan Evenson <lachlan.evenson@lithium.com>

    add onlyif statement

commit 7f83d9f0380afd91377afac002d667c5cb0d93d8
Author: Lachlan Evenson <lachlan.evenson@lithium.com>

    change to swap.device variable

commit 3067651fd35c2c4a769630ff5e5bb6ab87519787
Author: Lachlan Evenson <lachlan.evenson@lithium.com>

    add swap partition support

commit e874dfbd4a9763dca3bfadf1b4cfcba03fbd6b88
Author: Filip Pytloun <filip@pytloun.cz>

    Set message of the day

commit 973163e2ea888fe7501ebd64e552bab28f91e9d5
Author: Filip Pytloun <filip@pytloun.cz>

    Fix system-wide prompt

commit d9b68da2ed04b5c963d8773a2f1eacf0b72da538
Author: Filip Pytloun <filip@pytloun.cz>

    Ensure PS1 is enforced for root

commit 1f40dac0dfcd1dcf945a4ead92aca0fbad4c8c67
Author: Filip Pytloun <filip@pytloun.cz>

    Allow setting system-wide prompt

commit f41f161a41c846c7cae2b10f962da4576fed2bf9
Author: Filip Pytloun <filip@pytloun.cz>

    Fix unless in linux.console

commit e41663a5723c9f3f9d65640221bcc81690eba54d
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    rc.local added to linux formula - missing file

commit 7885938f957c83e4250db7e177b7df1d1c2d9372
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    rc.local added to linux formula

commit 4b983460d49db5896178a2e8434b50fe2afad532
Merge: be4e385 823e835
Author: Jakub Pavlik <j.pavlik@tcpisek.cz>

    Merge branch 'nm' into 'master'

commit 823e8354342d108bd19287988928c801bbf86b03
Author: jan kaufman <jan.kaufman@tcpcloud.eu>

    handle undefined network_manager.disable

commit c442d8e737025353af7e5a1de20a2e2af7db50d1
Author: jan kaufman <jan.kaufman@tcpcloud.eu>

    disable NetworkManager service

commit 6d30adf3256d9271282655047aaf9b3ddd891b8a
Author: jan kaufman <jan.kaufman@tcpcloud.eu>

    example usage to disable NM

commit be4e3853ac615c9dbaf75ea7846404c77f8cb9ef
Merge: 1542c3c cc4bf7c
Author: Jan Kaufman <j.kaufman@tcpcloud.eu>

    Merge branch 'rhnetwork' into 'master'

commit cc4bf7c8338ca9d30c4f12509245d685cf604300
Author: jan kaufman <jan.kaufman@tcpcloud.eu>

    set default proto: according OS default

commit 1542c3c1cc7192d74aed3028490312d296a8f32f
Author: Filip Pytloun <filip@pytloun.cz>

    Fix typo

commit c72cc618e335a15eedecafb35315f5d36e061e28
Author: Filip Pytloun <filip@pytloun.cz>

    Fix resolv when all options are not defined

commit de9bea5af55a32eefd38baf9394b0ae3141a8ee0
Author: Filip Pytloun <filip@pytloun.cz>

    Allow setting resolv.conf

commit c86086610487a33dccdd1a41ca7c6eed077585a1
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    fix for sudoers users with dot

commit d5642b6cdcb55189a01eed713ca570bfd2139aa5
Author: Jakub Pavlik <pavlk.jakub@gmail.com>

    fix linux extra package for kernel

commit 35896ff811bb8803161574edff1fabb66ba28a6d
Author: Filip Pytloun <filip@pytloun.cz>

    Remove parameter

commit 281034a655e5240f56dc75f2d96c950a7e95b446
Author: Filip Pytloun <filip@pytloun.cz>

    Make linux.system.kernel functional

commit 1200a19e6990fcb0a888e129934a40e449702f38
Author: jan kaufman <jan.kaufman@tcpcloud.eu>

    vlan - remove unneeded duplicate config

commit 44e2e19b96ef2600f691c056634cd4a9d3d1b1bb
Author: Filip Pytloun <filip@pytloun.cz>

    Fix LVM setup

commit 855e16eb98839e0f0151065bc62a8f3f0a34dbc6
Author: jan kaufman <jan.kaufman@tcpcloud.eu>

    add bond mode options

commit 11b03f7926b2a3af44f5001d33e8c29b7c948eb8
Author: Ales Komarek <mail@newt.cz>

    Proper resource identification

commit fe6f11ca38e899538a6ebd978fbde3c005d84eb0
Author: jan kaufman <jan.kaufman@tcpcloud.eu>

    Revert "Fix wrong name of requirement"

commit eaef6ec55570972f5c2f83d4ca8d48ea0ec25dd9
Author: Filip Pytloun <filip@pytloun.cz>

    Add missing collon

commit bedfa10ae683ce24c86efac968f08cd012aa88dd
Author: Filip Pytloun <filip@pytloun.cz>

    Fix wrong name of requirement

commit 0a0da4078bd228187452867e727312aedfc065c3
Merge: eeb27d4 c0bd76f
Author: Filip Pytloun <filip.pytloun@tcpcloud.eu>

    Merge branch 'vlans' into 'master'

commit c0bd76f39bcdff9dea3700b133249f7817821538
Author: jan kaufman <jan.kaufman@tcpcloud.eu>

    fix fillar syntax

commit 6a1ad71c2062d92d6e05bf3e18eda745a7409cf4
Author: Jan Kaufman <jan.kaufman@tcpcloud.eu>

    vlan networking support

commit eeb27d4212a31be75433f7b74b11362da8e27187
Merge: 252d5f2 c8a001a
Author: Jan Kaufman <j.kaufman@tcpcloud.eu>

    Merge branch 'fpy_lvm' into 'master'

commit c8a001aee1c8eb6d3045d5228f11eb0b2fb97092
Author: Filip Pytloun <filip@pytloun.cz>

    Support for LVM

commit 252d5f20b01a362b7f45efd32176dadddb0e7f9c
Author: Ales Komarek <mail@newt.cz>

    rewrite rules definition

commit 825c92716dba3cff79e2dad5ed892a2da8ed2750
Author: Ales Komarek <mail@newt.cz>

    collectd load check

commit 6080b8c87ff6bab8f5546f8fb7841493f2a1959e
Author: Ales Komarek <mail@newt.cz>

    No process check

commit 72826df0aac30afcf35d06f8e6b18681208b4ad6
Author: Ales Komarek <mail@newt.cz>

    Documentation generation fixes

commit c0e27fc96765e5b3a891a6291dfc6ccbab70cd73
Merge: 0c4ac7a f5e1777
Author: Aleš Komárek <mail@newt.cz>

    Merge branch 'feature/monitoring-syncid' into 'master'

commit f5e1777792e907dfe7b252fb918179105df0d87f
Author: Ales Komarek <mail@newt.cz>

    fix grains generation

commit 73bf156ff1942dda76469879166d567da8324512
Author: Michael Kutý <6du1ro.n@gmail.com>

    Close stream.

commit d46bee6edd690df8b71efdec13de52ffcc3baca2
Author: Ales Komarek <mail@newt.cz>

    support yaml reformat

commit 0c4ac7afd7dc3ff9a3932f842c6cb9f5b8c02161
Author: Filip Pytloun <filip@pytloun.cz>

    Fix invalid syntax in jinja file

commit d0a29e79efd0cf2fff0c950545f719bcde9d24fe
Author: Filip Pytloun <filip@pytloun.cz>

    Support for setting security limits

commit 4607477f129464e8905eaaae75cce4aae41fd592
Merge: 72acb64 29bd23a
Author: Aleš Komárek <mail@newt.cz>

    Merge branch 'feature/monitoring-syncid' into 'master'

commit 29bd23a4542aa50a989475995f38315ba27f2db3
Author: Ales Komarek <mail@newt.cz>

    Fix grains endline

commit 72acb643e78953990a3257e24d26c9e20b8ff6fd
Merge: a24b9af 2791e48
Author: Aleš Komárek <mail@newt.cz>

    Merge branch 'feature/monitoring-syncid' into 'master'

commit 2791e48cc7e20b8f272b6fcdad35bf4c1dfc8638
Author: Ales Komarek <mail@newt.cz>

    Moved support scripts around

commit cbe08a2eec71b867ff91d202cca35d6bf299d549
Author: Ales Komarek <mail@newt.cz>

    New parameteters

commit a24b9af5ec86b7feeeeab134b4358540729318cf
Author: jan kaufman <jan.kaufman@tcpcloud.eu>

    disable heka logging for now

commit d8fee8492b8489ef3b662324bcfac16a5be15c15
Author: Ales Komarek <mail@newt.cz>

    Monitoring metadata, mount dont create fs for nfs

commit 8759eee004ec1cff2b0430849adb0078934ee79b
Author: Ales Komarek <mail@newt.cz>

    Basic syslog heka inputs and decoders

commit e0849b547b567c78adfa107a4aff21b08fad2354
Author: Ales Komarek <mail@newt.cz>

    Heka logging scaffold

commit b2b404480f382f4b7d9006b53b4f0de34a6c08fd
Author: vmikes <v.mikes@tcpcloud.eu>

    update zombie count

commit d9cbe0d4d63dc7fcaa37b977b1b8bef48be05e7e
Merge: f5383a4 7fee054
Author: Aleš Komárek <mail@newt.cz>

    Merge branch 'feature/autologin' into 'master'

commit 7fee054386ce0d3123cb16db54976b4945f175c8
Author: Filip Pytloun <filip@pytloun.cz>

    Enable/disable console autologin

Version 0.2
=============================


