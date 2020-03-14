#! -*- coding:utf-8 -*-
'''
pip install python-nmap
直接调用即可
'''
import nmap
nm =nmap.PortScanner()
def scan(ip,port,arg):
    try:
        nm.scan(ip, arguments=arg+str(port))
    except nmap.nmap.PortScannerError:
        print "Please run -O method for root privileges"
    else:
        for host in nm.all_hosts():
            for proto in nm[host].all_protocols():
                lport = nm[host][proto].keys()
                lport.sort()
                for port in lport:
                    print ('port : %s\tstate : %s' % (port, nm[host][proto][port]['state']))
if __name__=="__main__":
    port="80,443,22,21"
    scan(ip="14.215.177.38",port=port,arg="-sS -Pn -p")
    # tcp scan -sT
    # tcp syn scan -sS
