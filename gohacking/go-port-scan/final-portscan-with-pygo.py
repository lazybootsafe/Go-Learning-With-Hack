#! -*- coding:utf-8 -*-
from ctypes import *
#其实也可以直接模仿kunpeng的写法,但是没必要.爽了就行.
lib = cdll.LoadLibrary(u'./scan.so')
lib.Scan("10.0.0.1","1-1024","eth0") # ip,端口范围，网卡
