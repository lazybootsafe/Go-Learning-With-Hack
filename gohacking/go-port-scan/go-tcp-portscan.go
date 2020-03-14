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
