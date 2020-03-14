### go实现端口扫描器

### 说明

现在已经存在很多python版本或者其他语言版本的端口扫描器,那go语言有什么优势呢?  

首先是python,  
python的socket模块可以创建套接字,创建tcp的三次握手连接,以此探测目标端口是否存活.本篇将使用socket模块编写tcp端口扫描器和syn端口扫描器,对比差异.  

#### socket-tcp-scan PYTHON版
[代码](socket-tcp-portscan.py)  

```python
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

```
#### socket实现sock_raw tcp syn scan  
[代码](syn-portscan.py)

```python
# -*- coding: UTF-8 -*-
import time
import random
import socket
import sys
from struct import *
'''
Warning:must run it as root
yum install python-devel libpcap-devel
pip install pcap
'''
def checksum(msg):
    ''' Check Summing '''
    s = 0
    for i in range(0,len(msg),2):
        w = (ord(msg[i]) << 8) + (ord(msg[i+1]))
        s = s+w
    s = (s>>16) + (s & 0xffff)
    s = ~s & 0xffff
    return s
def CreateSocket(source_ip,dest_ip):
    ''' create socket connection '''
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_TCP)
    except socket.error, msg:
        print 'Socket create error: ',str(msg[0]),'message: ',msg[1]
        sys.exit()
    ''' Set the IP header manually '''
    s.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL, 1)

    return s
def CreateIpHeader(source_ip, dest_ip):
    ''' create ip header '''
    # packet = ''
    # ip header option
    headerlen = 5
    version = 4
    tos = 0
    tot_len = 20 + 20
    id = random.randrange(18000,65535,1)
    frag_off = 0
    ttl = 255
    protocol = socket.IPPROTO_TCP
    check = 10
    saddr = socket.inet_aton ( source_ip )
    daddr = socket.inet_aton ( dest_ip )
    hl_version = (version << 4) + headerlen
    ip_header = pack('!BBHHHBBH4s4s', hl_version, tos, tot_len, id, frag_off, ttl, protocol, check, saddr, daddr)
    return ip_header
def create_tcp_syn_header(source_ip, dest_ip, dest_port):
    ''' create tcp syn header function '''
    source = random.randrange(32000,62000,1) # randon select one source_port
    seq = 0
    ack_seq = 0
    doff = 5

    ''' tcp flags '''
    fin = 0
    syn = 1
    rst = 0
    psh = 0
    ack = 0
    urg = 0
    window = socket.htons (8192)    # max windows size
    check = 0
    urg_ptr = 0
    offset_res = (doff << 4) + 0
    tcp_flags = fin + (syn<<1) + (rst<<2) + (psh<<3) + (ack<<4) + (urg<<5)
    tcp_header = pack('!HHLLBBHHH', source, dest_port, seq, ack_seq, offset_res, tcp_flags, window, check, urg_ptr)

    ''' headers option '''
    source_address = socket.inet_aton( source_ip )
    dest_address = socket.inet_aton( dest_ip )
    placeholder = 0
    protocol = socket.IPPROTO_TCP
    tcp_length = len(tcp_header)
    psh = pack('!4s4sBBH', source_address, dest_address, placeholder, protocol, tcp_length);
    psh = psh + tcp_header;
    tcp_checksum = checksum(psh)
    ''' Repack the TCP header and fill in the correct checksum '''
    tcp_header = pack('!HHLLBBHHH', source, dest_port, seq, ack_seq, offset_res, tcp_flags, window, tcp_checksum, urg_ptr)

    return tcp_header
def syn_scan(source_ip, dest_ip, des_port) :
    s = CreateSocket(source_ip, dest_ip)
    ip_header = CreateIpHeader(source_ip, dest_ip)
    tcp_header = create_tcp_syn_header(source_ip, dest_ip, des_port)
    packet = ip_header + tcp_header
    s.sendto(packet, (dest_ip, 0))
    data = s.recvfrom(1024) [0][0:]
    ip_header_len = (ord(data[0]) & 0x0f) * 4
    # ip_header_ret = data[0: ip_header_len - 1]
    tcp_header_len = (ord(data[32]) & 0xf0)>>2
    tcp_header_ret = data[ip_header_len:ip_header_len+tcp_header_len - 1]
    ''' SYN/ACK flags '''
    if ord(tcp_header_ret[13]) == 0x12:
        print  "%s:%s is open" % (dest_ip,des_port)
    else:
        print "%s:%s is not open" % (dest_ip,des_port)
if __name__=="__main__":
    t_s = time.time()
    source_ip = '' # 填写本机ip
    dest_ip = '10.0.0.1'#目标ip
    for des_port in range(1024):
        syn_scan(source_ip, dest_ip, des_port)
    t_e = time.time()
    print "time is ",(t_e-t_s)
```
### 使用python的scapy模块模拟发包的形式

tcp-syn-portscan  
[代码](scapy-tcp-syn-portscan.py)  

```python
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


```


### 使用nmap
[代码](python-nmap-portscan.py)
```python
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

```
### 本文重点:使用go+python

#### 前文一直在介绍使用python语言开发端口扫描器，然而由于python在多线程方面的弱势，扫描器的性能可想而知，因此我又利用go语言的高并发性优势，尝试开发端口扫描器。

[代码](go-tcp-portscan.go)  
#### tcp版本go-portscan:  
```go
package main
// port tcp scan
import (
    "fmt"
    "net"
    "os"
    "runtime"
    "strconv"
    "sync"
    "time"
)
func loop(inport chan int, startport, endport int) {
    for i := startport; i <= endport; i++ {
        inport <- i
    }
    close(inport)
}
type ScanSafeCount struct {
    // 结构体
    count int
    mux   sync.Mutex
}
var scanCount ScanSafeCount
func scanner(inport int, outport chan int, ip string, endport int) {
    // 扫描函数
    in := inport // 定义要扫描的端口号
    // fmt.Printf(" %d ", in) // 输出扫描的端口
    host := fmt.Sprintf("%s:%d", ip, in) // 类似（ip,port）
    tcpAddr, err := net.ResolveTCPAddr("tcp4", host) // 根据域名查找ip
    if err != nil {
        // 域名解析ip失败
        outport <- 0
    } else {
        conn, err := net.DialTimeout("tcp", tcpAddr.String(), 10*time.Second) //建立tcp连接
        if err != nil {
            // tcp连接失败
            outport <- 0
        } else {
            // tcp连接成功
            outport <- in // 将端口写入outport信号
            fmt.Printf("\n *************( %d 可以 )*****************\n", in)
            conn.Close()
        }
    }
    // 线程锁
    scanCount.mux.Lock()
    scanCount.count = scanCount.count - 1
    if scanCount.count <= 0 {
        close(outport)
    }
    scanCount.mux.Unlock()
}
func main() {
    runtime.GOMAXPROCS(runtime.NumCPU()) // 设置最大可使用的cpu核数
    // 定义变量
    inport := make(chan int) // 信号变量，类似python中的queue
    outport := make(chan int)
    collect := []int{} // 定义一个切片变量，类似python中的list
    // fmt.Println(os.Args, len(os.Args)) // 获取命令行参数并输出
    if len(os.Args) != 4 {
        // 命令行参数个数有误
        fmt.Println("使用方式： port_scanner IP startport endport")
        os.Exit(0)
    }
    s_time := time.Now().Unix()
    // fmt.Println("扫描开始：") // 获取当前时间
    ip := string(os.Args[1]) // 获取参数中的ip
    startport, _ := strconv.Atoi(os.Args[2]) // 获取参数中的启始端口
    endport, _ := strconv.Atoi(os.Args[3]) // 获取参数中的结束端口
    if startport > endport {
        fmt.Println("Usage: scanner IP startport endport")
        fmt.Println("Endport must be larger than startport")
        os.Exit(0)
    } else {
        // 定义scanCount变量为ScanSafeCount结构体，即计算扫描的端口数量
        scanCount = ScanSafeCount{count: (endport - startport + 1)}
    }
    fmt.Printf("扫描 %s：%d----------%d\n", ip, startport, endport)
    go loop(inport, startport, endport)  // 执行loop函数将端口写入input信号
    for v := range inport {
        // 开始循环input
        go scanner(v, outport, ip, endport)
    }
    // 输出结果
    for port := range outport {
        if port != 0 {
            collect = append(collect, port)
        }
    }
    fmt.Println("--")
    fmt.Println(collect)
    e_time := time.Now().Unix()
    fmt.Println("扫描时间:", e_time-s_time)
}
```
测试代码运行,  
go run go-tcp-portscan.go 10.0.0.1 0 1024

#### syn版本go-portscan:

[代码](go-syn-portscan.go)  

```go
package main
// port tcp syn scan
import (
    "bytes"
    "encoding/binary"
    "flag"
    "fmt"
    "log"
    "math/rand"
    "net"
    "os"
    "strconv"
    "strings"
    "time"
    "errors"
)
//TCPHeader test
type TCPHeader struct {
    SrcPort       uint16
    DstPort       uint16
    SeqNum        uint32
    AckNum        uint32
    Flags         uint16
    Window        uint16
    ChkSum        uint16
    UrgentPointer uint16
}
//TCPOption test
type TCPOption struct {
    Kind   uint8
    Length uint8
    Data   []byte
}
type scanResult struct {
    Port   uint16
    Opened bool
}
type scanJob struct {
    Laddr string
    Raddr string
    SPort uint16
    DPort uint16
    Stop  uint8
}
var stopFlag = make(chan uint8, 1)
func main() {
    rate := time.Second / 400
    throttle := time.Tick(rate)
    jobs := make(chan *scanJob, 65536)
    results := make(chan *scanResult, 1000)
    for w := 0; w < 10; w++ {
        go worker(w, jobs, throttle, results)
    }
    // 获取命令行参数
    ifaceName := flag.String("i", "eth0", "Specify network")
    remote := flag.String("r", "", "remote address")
    portRange := flag.String("p", "1-1024", "port range: -p 1-1024")
    flag.Parse()
    // ifaceName := &interfaceName_
    // remote := &remote_
    // portRange := &portRange_
    s_time := time.Now().Unix()
    laddr := interfaceAddress(*ifaceName) //
    raddr := *remote
    minPort , maxPort := portSplit(portRange)
    // fmt.Println(laddr, raddr) // 输出源ip地址，目标ip地址
    go func(num int){
        for i := 0; i < num; i++ {
            recvSynAck(laddr, raddr, results)
        }
    }(10)
    go func(jobLength int) {
        for j := minPort; j < maxPort + 1; j++ {
            s := scanJob{
                Laddr: laddr,
                Raddr: raddr,
                SPort: uint16(random(10000, 65535)),
                DPort: uint16(j + 1),
            }
            jobs <- &s
        }
        jobs <- &scanJob{Stop: 1}
    }(1024)
    for {
        select {
        case res := <-results:
            fmt.Println("扫描到开放的端口:",res.Port)
        case <-stopFlag:
            e_time := time.Now().Unix()
            fmt.Println("总共用了多少时间(s):",e_time-s_time)
            os.Exit(0)
        }
    }
}
func worker(id int, jobs <-chan *scanJob, th <-chan time.Time, results chan<- *scanResult) {
    for j := range jobs {
        if j.Stop != 1 {
            sendSyn(j.Laddr, j.Raddr, j.SPort, j.DPort)
        } else {
            stopFlag <- j.Stop
        }
        <-th
    }
}
func checkError(err error) {
    // 错误check
    if err != nil {
        log.Println(err)
    }
}
//CheckSum test
func CheckSum(data []byte, src, dst [4]byte) uint16 {
    pseudoHeader := []byte{
        src[0], src[1], src[2], src[3],
        dst[0], dst[1], dst[2], dst[3],
        0,
        6,
        0,
        byte(len(data)),
    }
    totalLength := len(pseudoHeader) + len(data)
    if totalLength%2 != 0 {
        totalLength++
    }
    d := make([]byte, 0, totalLength)
    d = append(d, pseudoHeader...)
    d = append(d, data...)
    return ^mySum(d)
}
func mySum(data []byte) uint16 {
    var sum uint32
    for i := 0; i < len(data)-1; i += 2 {
        sum += uint32(uint16(data[i])<<8 | uint16(data[i+1]))
    }
    sum = (sum >> 16) + (sum & 0xffff)
    sum = sum + (sum >> 16)
    return uint16(sum)
}
func sendSyn(laddr, raddr string, sport, dport uint16) {
    conn, err := net.Dial("ip4:tcp", raddr)
    checkError(err)
    defer conn.Close()
    op := []TCPOption{
        TCPOption{
            Kind:   2,
            Length: 4,
            Data:   []byte{0x05, 0xb4},
        },
        TCPOption{
            Kind: 0,
        },
    }
    tcpH := TCPHeader{
        SrcPort:       sport,
        DstPort:       dport,
        SeqNum:        rand.Uint32(),
        AckNum:        0,
        Flags:         0x8002,
        Window:        8192,
        ChkSum:        0,
        UrgentPointer: 0,
    }
    buff := new(bytes.Buffer)
    err = binary.Write(buff, binary.BigEndian, tcpH)
    checkError(err)
    for i := range op {
        binary.Write(buff, binary.BigEndian, op[i].Kind)
        binary.Write(buff, binary.BigEndian, op[i].Length)
        binary.Write(buff, binary.BigEndian, op[i].Data)
    }
    binary.Write(buff, binary.BigEndian, [6]byte{})
    data := buff.Bytes()
    checkSum := CheckSum(data, ipstr2Bytes(laddr), ipstr2Bytes(raddr))
    //fmt.Printf("CheckSum 0x%X\n", checkSum)
    tcpH.ChkSum = checkSum
    buff = new(bytes.Buffer)
    binary.Write(buff, binary.BigEndian, tcpH)
    for i := range op {
        binary.Write(buff, binary.BigEndian, op[i].Kind)
        binary.Write(buff, binary.BigEndian, op[i].Length)
        binary.Write(buff, binary.BigEndian, op[i].Data)
    }
    binary.Write(buff, binary.BigEndian, [6]byte{})
    data = buff.Bytes()
    //fmt.Printf("% X\n", data)
    _, err = conn.Write(data)
    checkError(err)
}
func recvSynAck(laddr, raddr string, res chan<- *scanResult) error {
    listenAddr, err := net.ResolveIPAddr("ip4", laddr) // 解析域名为ip
    checkError(err)
    conn, err := net.ListenIP("ip4:tcp", listenAddr)
    defer conn.Close()
    checkError(err)
    for {
        buff := make([]byte, 1024)
        _, addr, err := conn.ReadFrom(buff)
        if err != nil {
            continue
        }
        if addr.String() != raddr || buff[13] != 0x12 {
            continue
        }
        var port uint16
        binary.Read(bytes.NewReader(buff), binary.BigEndian, &port)
        res <- &scanResult{
            Port:   port,
            Opened: true,
        }
    }
}
func ipstr2Bytes(addr string) [4]byte {
    s := strings.Split(addr, ".")
    b0, _ := strconv.Atoi(s[0])
    b1, _ := strconv.Atoi(s[1])
    b2, _ := strconv.Atoi(s[2])
    b3, _ := strconv.Atoi(s[3])
    return [4]byte{byte(b0), byte(b1), byte(b2), byte(b3)}
}
func random(min, max int) int {
    return rand.Intn(max-min) + min
}
func interfaceAddress(ifaceName string ) string {
    iface, err:= net.InterfaceByName(ifaceName)
    if err != nil {
        panic(err)
    }
    addr, err := iface.Addrs()
    if err != nil {
        panic(err)
    }
    addrStr := strings.Split(addr[0].String(), "/")[0]
    return addrStr
}
func portSplit(portRange *string) (uint16, uint16) {
    ports := strings.Split(*portRange, "-")
    minPort, err := strconv.ParseUint(ports[0], 10, 16)
    if err !=nil {
        panic(err)
    }
    maxPort, err := strconv.ParseUint(ports[1], 10, 16)
    if err != nil {
        panic(err)
    }
    if minPort > maxPort {
        panic(errors.New("minPort must greater than maxPort"))
    }
    return uint16(minPort), uint16(maxPort)
}
```

代码运行结果:  
go run go-syn-portscan.go -r 1.1.1.1 -p 1-1024  

### 总结

##### 经过前面的测试我们不难发现，在并发的性能上，go完胜python，但go不适合做复杂的逻辑处理，以及web开发之类的。因此如何整合python跟go呢？
##### 这里我想了两种方案，第一种将go语言打包成.so动态连接库，利用python的ctypes模块可以调用；第二种是go写成接口，提供python调用。写成接口的方式相对简单一些，因此这里不介绍了，说说如何打包go，即如何利用python调用go的方法或者说函数。  

将上诉go-syn-portscan.go改版一下  
[代码](go-syn-portscan2so.go)  

```go
package main
// port tcp syn scan
import (
    "C"
    "os"
    "bytes"
    "encoding/binary"
    "fmt"
    "log"
    "math/rand"
    "net"
    "strconv"
    "strings"
    "time"
    "errors"
)
//TCPHeader test
type TCPHeader struct {
    SrcPort       uint16
    DstPort       uint16
    SeqNum        uint32
    AckNum        uint32
    Flags         uint16
    Window        uint16
    ChkSum        uint16
    UrgentPointer uint16
}
//TCPOption test
type TCPOption struct {
    Kind   uint8
    Length uint8
    Data   []byte
}
type scanResult struct {
    Port   uint16
    Opened bool
}
type scanJob struct {
    Laddr string
    Raddr string
    SPort uint16
    DPort uint16
    Stop  uint8
}
var stopFlag = make(chan uint8, 1)
//export Scan
func Scan(remote_ *C.char, portRange_ *C.char, interfaceName_ *C.char) {

    rate := time.Second / 400
    throttle := time.Tick(rate)
    jobs := make(chan *scanJob, 65536)
    results := make(chan *scanResult, 1000)
    for w := 0; w < 10; w++ {
        go worker(w, jobs, throttle, results)
    }
    // 获取命令行参数
    // ifaceName := flag.String("i", "eth0", "Specify network")
    // remote := flag.String("r", "", "remote address")
    // portRange := flag.String("p", "1-1024", "port range: -p 1-1024")
    // flag.Parse()

    interfaceName_1 := C.GoString(interfaceName_)
    remote_1 := C.GoString(remote_)
    portRange_1 := C.GoString(portRange_)
    ifaceName := &interfaceName_1
    remote := &remote_1
    portRange := &portRange_1
    s_time := time.Now().Unix()

    laddr := interfaceAddress(*ifaceName) //
    raddr := *remote
    minPort , maxPort := portSplit(portRange)
    fmt.Println(laddr, raddr) // 输出源ip地址，目标ip地址
    go func(num int){
        for i := 0; i < num; i++ {
            recvSynAck(laddr, raddr, results)
        }
    }(10)
    go func(jobLength int) {
        for j := minPort; j < maxPort + 1; j++ {
            s := scanJob{
                Laddr: laddr,
                Raddr: raddr,
                SPort: uint16(random(10000, 65535)),
                DPort: uint16(j + 1),
            }
            jobs <- &s
        }
        jobs <- &scanJob{Stop: 1}
    }(1024)
    for {
        select {
        case res := <-results:
            fmt.Println("扫描到开放的端口：",res.Port) //输出开放的端口号
        case <-stopFlag:
            e_time := time.Now().Unix()
            fmt.Println("本次扫描总共耗时(s):",e_time-s_time)
            os.Exit(0)
        }
    }
}
func worker(id int, jobs <-chan *scanJob, th <-chan time.Time, results chan<- *scanResult) {
    for j := range jobs {
        if j.Stop != 1 {
            sendSyn(j.Laddr, j.Raddr, j.SPort, j.DPort)
        } else {
            stopFlag <- j.Stop
        }
        <-th
    }
}
func checkError(err error) {
    // 错误check
    if err != nil {
        log.Println(err)
    }
}
//CheckSum test
func CheckSum(data []byte, src, dst [4]byte) uint16 {
    pseudoHeader := []byte{
        src[0], src[1], src[2], src[3],
        dst[0], dst[1], dst[2], dst[3],
        0,
        6,
        0,
        byte(len(data)),
    }
    totalLength := len(pseudoHeader) + len(data)
    if totalLength%2 != 0 {
        totalLength++
    }
    d := make([]byte, 0, totalLength)
    d = append(d, pseudoHeader...)
    d = append(d, data...)
    return ^mySum(d)
}
func mySum(data []byte) uint16 {
    var sum uint32
    for i := 0; i < len(data)-1; i += 2 {
        sum += uint32(uint16(data[i])<<8 | uint16(data[i+1]))
    }
    sum = (sum >> 16) + (sum & 0xffff)
    sum = sum + (sum >> 16)
    return uint16(sum)
}
func sendSyn(laddr, raddr string, sport, dport uint16) {
    conn, err := net.Dial("ip4:tcp", raddr)
    checkError(err)
    defer conn.Close()
    op := []TCPOption{
        TCPOption{
            Kind:   2,
            Length: 4,
            Data:   []byte{0x05, 0xb4},
        },
        TCPOption{
            Kind: 0,
        },
    }
    tcpH := TCPHeader{
        SrcPort:       sport,
        DstPort:       dport,
        SeqNum:        rand.Uint32(),
        AckNum:        0,
        Flags:         0x8002,
        Window:        8192,
        ChkSum:        0,
        UrgentPointer: 0,
    }
    buff := new(bytes.Buffer)
    err = binary.Write(buff, binary.BigEndian, tcpH)
    checkError(err)
    for i := range op {
        binary.Write(buff, binary.BigEndian, op[i].Kind)
        binary.Write(buff, binary.BigEndian, op[i].Length)
        binary.Write(buff, binary.BigEndian, op[i].Data)
    }
    binary.Write(buff, binary.BigEndian, [6]byte{})
    data := buff.Bytes()
    checkSum := CheckSum(data, ipstr2Bytes(laddr), ipstr2Bytes(raddr))
    //fmt.Printf("CheckSum 0x%X\n", checkSum)
    tcpH.ChkSum = checkSum
    buff = new(bytes.Buffer)
    binary.Write(buff, binary.BigEndian, tcpH)
    for i := range op {
        binary.Write(buff, binary.BigEndian, op[i].Kind)
        binary.Write(buff, binary.BigEndian, op[i].Length)
        binary.Write(buff, binary.BigEndian, op[i].Data)
    }
    binary.Write(buff, binary.BigEndian, [6]byte{})
    data = buff.Bytes()
    //fmt.Printf("% X\n", data)
    _, err = conn.Write(data)
    checkError(err)
}
func recvSynAck(laddr, raddr string, res chan<- *scanResult) error {
    listenAddr, err := net.ResolveIPAddr("ip4", laddr) // 解析域名为ip
    checkError(err)
    conn, err := net.ListenIP("ip4:tcp", listenAddr)
    defer conn.Close()
    checkError(err)
    for {
        buff := make([]byte, 1024)
        _, addr, err := conn.ReadFrom(buff)
        if err != nil {
            continue
        }
        if addr.String() != raddr || buff[13] != 0x12 {
            continue
        }
        var port uint16
        binary.Read(bytes.NewReader(buff), binary.BigEndian, &port)
        res <- &scanResult{
            Port:   port,
            Opened: true,
        }
    }
}
func ipstr2Bytes(addr string) [4]byte {
    s := strings.Split(addr, ".")
    b0, _ := strconv.Atoi(s[0])
    b1, _ := strconv.Atoi(s[1])
    b2, _ := strconv.Atoi(s[2])
    b3, _ := strconv.Atoi(s[3])
    return [4]byte{byte(b0), byte(b1), byte(b2), byte(b3)}
}
func random(min, max int) int {
    return rand.Intn(max-min) + min
}
func interfaceAddress(ifaceName string ) string {
    iface, err:= net.InterfaceByName(ifaceName)
    if err != nil {
        panic(err)
    }
    addr, err := iface.Addrs()
    if err != nil {
        panic(err)
    }
    addrStr := strings.Split(addr[0].String(), "/")[0]
    return addrStr
}
func portSplit(portRange *string) (uint16, uint16) {
    ports := strings.Split(*portRange, "-")
    minPort, err := strconv.ParseUint(ports[0], 10, 16)
    if err !=nil {
        panic(err)
    }
    maxPort, err := strconv.ParseUint(ports[1], 10, 16)
    if err != nil {
        panic(err)
    }
    if minPort > maxPort {
        panic(errors.New("minPort must greater than maxPort"))
    }
    return uint16(minPort), uint16(maxPort)
}
func main() { }
```

#### 使用命令打包成so库

`go bulid -buildmode=c-shared -o go-syn-portscan2so.so go-syn-portscan2so.go`  
#### 打包后会得到一个go-syn-portscan2so.so和一个.h文件。然后利用下面的python代码就可以调用Go代码中的Scan()函数了，创建一个final-portscan-with-pygo.py文件

[代码](final-portscan-with-pygo.py)  

```python
#! -*- coding:utf-8 -*-
from ctypes import *
#其实也可以直接模仿kunpeng的写法,但是没必要.爽了就行.
lib = cdll.LoadLibrary(u'./scan.so')
lib.Scan("10.0.0.1","1-1024","eth0") # ip,端口范围，网卡

```
运行及结果:
