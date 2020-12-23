#! -*- coding:utf-8 -*-
import time
from scapy.all import *
ip = "10.0.0.1"
TIMEOUT = 0.5#自由设定timeout值
threads = 500#线程数
port_range = 1024#随手一个1024
retry = 1
def is_up(ip):
    """ Tests if host is up """
    icmp = IP(dst=ip)/ICMP()
    resp = sr1(icmp, timeout=TIMEOUT)
    if resp == None:
        return False
    else:
        return True
def reset_half_open(ip, ports):
    # Reset the connection to stop half-open connections from pooling up
    sr(IP(dst=ip)/TCP(dport=ports, flags='AR'), timeout=TIMEOUT)
def is_open(ip, ports):
    to_reset = []
    results = []
    p = IP(dst=ip)/TCP(dport=ports, flags='S')  # Forging SYN packet
    answers, un_answered = sr(p, verbose=False, retry=retry ,timeout=TIMEOUT) # Send the packets
    for req, resp in answers:
        if not resp.haslayer(TCP):
            continue
        tcp_layer = resp.getlayer(TCP)
        if tcp_layer.flags == 0x12:
            # port is open
            to_reset.append(tcp_layer.sport)
            results.append(tcp_layer.sport)
        elif tcp_layer.flags == 0x14:
            # port is open
            pass
    reset_half_open(ip, to_reset)

    return results
def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i + n]
if __name__ == '__main__':
    start_time = time.time()
    open_port_list = []
    for ports in chunks(list(range(port_range)), threads):
        results = is_open(ip, ports)
        if results:
           open_port_list += results

    end_time = time.time()
    print "%s %s" % (ip,open_port_list)
    print "%s Scan Completed in %fs" % (ip, end_time-start_time)
