from os import listdir, path
from subprocess import Popen,PIPE
from re import findall as refindall
from re import search as research
import salt.utils
import socket, struct, fcntl
import logging

logger = logging.getLogger(__name__)
stream = logging.StreamHandler()
logger.addHandler(stream)

def get_ip(iface='ens2'):

    ''' Get ip address from an interface if applicable

    :param iface: Interface name. Type: str

    '''

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sockfd = sock.fileno()
    SIOCGIFADDR = 0x8915
    ifreq = struct.pack('16sH14s', iface, socket.AF_INET, '\x00'*14)

    try:
        res = fcntl.ioctl(sockfd, SIOCGIFADDR, ifreq)
    except:
        logger.debug("No ip addresses assigned to %s" % iface)
        return None

    ip = struct.unpack('16sH2x4s8x', res)[2]
    return socket.inet_ntoa(ip)

def get_nics():

    ''' List nics '''

    nics = []
    nics_list = listdir('/sys/class/net/')
    for nic_name in nics_list:
        if research('(br|bond|ens|enp|eth|one|ten|fourty)[0-9]+', nic_name):

            # Interface should be in "up" state in order to get carrier status
            Popen("ip li set dev " + nic_name + " up", shell=True, stdout=PIPE)

            with open("/sys/class/net/" + nic_name + "/carrier", 'r') as f:
                try:
                    carrier = int(f.read())
                except:
                    carrier = 0

            bond = ""
            if path.isfile("/sys/class/net/" + nic_name + "/master/uevent"):
                with open("/sys/class/net/" + nic_name + "/master/uevent", 'r') as f:
                    for line in f:
                        sline = line.strip()
                        if 'INTERFACE=bond' in sline:
                            bond = sline.split('=')[1]
            if len(bond) == 0:
                with open("/sys/class/net/" + nic_name + "/address", 'r') as f:
                    macaddr = f.read().strip()
            else:
                with open("/proc/net/bonding/" + bond, 'r') as f:
                    line = f.readline()
                    if_struct = False
                    while line:
                        sline = line.strip()
                        if 'Slave Interface: ' + nic_name in sline and not if_struct:
                            if_struct = True
                        if 'Permanent HW addr: ' in sline and if_struct:
                            macaddr = sline.split()[3]
                            break
                        line = f.readline()

            with open("/sys/class/net/" + nic_name + "/mtu", 'r') as f:
                mtu = f.read()

            ip = str(get_ip(nic_name))

            nics.append([nic_name, ip, macaddr, carrier, mtu])

    return sorted(nics)

def get_ten_pci():

    ''' List ten nics pci addresses '''

    nics = []
    nics_list = listdir('/sys/class/net/')
    for nic_name in nics_list:
        if research('ten[0-9]+', nic_name):
            with open("/sys/class/net/" + nic_name + "/device/uevent", 'r') as f:
                for line in f:
                    sline = line.strip()
                    if "PCI_SLOT_NAME=" in sline:
                        nics.append([nic_name , sline.split("=")[1]])

    return sorted(nics)

def mesh_ping(mesh):

    ''' One to many ICMP check

    :param hosts: Target hosts. Type: list of ip addresses

    '''

    io = []
    minion_id = __salt__['config.get']('id')

    for host, hostobj in mesh:
        if host == minion_id:
            for mesh_net, addr, targets in hostobj:
                if addr in targets:
                    targets.remove(addr)
                for tgt in targets:
                    # This one will run in parallel with everyone else
                    worker = Popen("ping -c 1 -w 1 -W 1 " + str(tgt), \
                        shell=True, stdout=PIPE, stderr=PIPE)
                    ping_out = worker.communicate()[0]
                    if worker.returncode != 0:
                        io.append(mesh_net + ': ' + addr + ' -> ' + tgt + ': Failed')

    return io

def minion_list():

    ''' List registered minions '''

    return listdir('/etc/salt/pki/master/minions/')

def verify_addresses():

    ''' Verify addresses taken from pillars '''

    nodes = nodes_addresses()
    verifier = {}
    failed = []

    for node, nodeobj in nodes:
        for item in nodeobj:
            addr = item[1]
            if addr in verifier:
                failed.append([node,verifier[addr],addr])
            else:
                verifier[addr] = node

    if failed:
        logger.error("FAILED. Duplicates found")
        logger.error(failed)
        return False
    else:
        logger.setLevel(logging.INFO)
        logger.info(["PASSED"])
        return True

def nodes_addresses():

    ''' List servers addresses '''

    compound = 'linux:network:interface'
    out = __salt__['saltutil.cmd']( tgt='I@' + compound,
                                    tgt_type='compound',
                                    fun='pillar.get',
                                    arg=[compound],
                                    timeout=10
                                  ) or None

    servers = []
    for minion in minion_list():
        addresses = []
        if minion in out:
            ifaces = out[minion]['ret']
            for iface in ifaces:
                ifobj = ifaces[iface]
                if ifobj['enabled'] and 'address' in ifobj:
                    if 'mesh' in ifobj:
                        mesh = ifobj['mesh']
                    else:
                        mesh = 'default'
                    addresses.append([mesh, ifobj['address']])
            servers.append([minion,addresses])

    return servers

def get_mesh():

    ''' Build addresses mesh '''

    full_mesh = {}
    nodes = nodes_addresses()

    for node, nodeobj in nodes:
        for item in nodeobj:
            mesh = item[0]
            addr = item[1]
            if not mesh in full_mesh:
                full_mesh[mesh] = []
            full_mesh[mesh].append(addr)

    for node, nodeobj in nodes:
        for item in nodeobj:
            mesh = item[0]
            tgts = full_mesh[mesh]
            item.append(tgts)

    return nodes

def ping_check():

    ''' Ping addresses in a mesh '''

    mesh = get_mesh()
    out = __salt__['saltutil.cmd']( tgt='*',
                                    tgt_type='glob',
                                    fun='net_checks.mesh_ping',
                                    arg=[mesh],
                                    timeout=10
                                  ) or None

    failed = []

    if out:
        for minion in out:
            ret = out[minion]['ret']
            if ret:
                failed.append(ret)
    else:
        failed = ["No response from minions"]

    if failed:
        logger.error("FAILED")
        logger.error('\n'.join(str(x) for x in failed))
        return False
    else:
        logger.setLevel(logging.INFO)
        logger.info(["PASSED"])
        return True

def get_nics_csv(delim=","):

    ''' List nics in csv format

    :param delim: Delimiter char. Type: str

    '''

    header = "server,nic_name,ip_addr,mac_addr,link,chassis_id,chassis_name,port_mac,port_descr\n"
    io = ""

    # Try to reuse lldp output if possible
    try:
        lldp_info = Popen("lldpcli -f keyvalue s n s", shell=True, stdout=PIPE).communicate()[0]
    except:
        lldp_info = ""

    for nic in get_nics():
        lldp = ""
        nic_name = nic[0]
        if research('(one|ten|fourty)[0-9]+', nic_name):
            # Check if we can fetch lldp data for that nic
            for line in lldp_info.splitlines():
                chassis = 'lldp.' + nic[0] + '.chassis'
                port = 'lldp.' + nic[0] + '.port'
                if chassis in line or port in line:
                    lldp += delim + line.split('=')[1]
        if not lldp:
            lldp = delim + delim + delim + delim

        io += __salt__['config.get']('id') + \
              delim + nic_name + \
              delim + str(nic[1]).strip() + \
              delim + str(nic[2]).strip() + \
              delim + str(nic[3]).strip() + \
              delim + str(nic[4]).strip() + \
              lldp + "\n"

    return header + io
