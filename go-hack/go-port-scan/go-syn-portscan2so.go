package main
// go-syn-portscan2so
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
