#! -*- coding:utf-8 -*-
import time
import socket
socket_timeout = 0.1#根据需要调整timeout
def tcp_scan(ip,port):
    try:
        s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        s.settimeout(socket_timeout)
        c=s.connect_ex((ip,port))
        if c==0:
            print "%s:%s is open" % (ip,port)
        else:
            # print "%s:%s is not open" % (ip,port)
            pass
    except Exception,e:
        print e

    s.close()
if __name__=="__main__":
    s_time = time.time()
    ip = "10.0.0.1"#ip地址
    for port in range(0,1024):#随手写了个1024
        ''' 此处可用协作 '''
        tcp_scan(ip,port)
    e_time = time.time()
    print "scan time is ",e_time-s_time
