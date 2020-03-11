# Go-learning-With-Hack
# 7.语言详解--并发
[7.1 Goroutine](7.1Goroutine)  
[7.2 2222](#7.2Channel)  

## 7.1Goroutine

* Go 在语言层面对并发编程提供支持，一种类似协程，称作 goroutine 的机制。
* 只需在函数调用语句前添加 go 关键字，就可创建并发执行单元。
* 开发人员无需了解任何执行细节，调度器会自动将其安排到合适的系统线程上执行。
* goroutine 是一种非常轻量级的实现，可在单个进程里执行成千上万的并发任务。
* 入口函数 main 就以 goroutine 运行。另有与之配套的 channel 类型，用以实现 "以通讯来共享内存" 的 CSP 模式。


```go
go func() {
println("Hello, World!")
}()
```

* 调度器不能保证多个 goroutine 执行次序，且进程退出时不会等待它们结束。
* 默认情况下，进程启动后仅允许一个系统线程服务于 goroutine。可使用环境变量或标准库函数 runtime.GOMAXPROCS 修改，让调度器用多个线程实现多核并行，而不仅仅是并发。

```go
func sum(id int) {
    var x int64
    for i := 0; i < math.MaxUint32; i++ {
    x += int64(i)
  }
    println(id, x)
}

func main() {
    wg := new(sync.WaitGroup)
    wg.Add(2)    
for i := 0; i < 2; i++ {
  go func(id int) {
  defer wg.Done()
    sum(id)
  }(i)
}
  wg.Wait()
}
```

输出：

```
$ go build -o test
$ time -p ./test
0 9223372030412324865
1 9223372030412324865
real 7.70 // 程序开始到结束时间差 (非 CPU 时间)
user 7.66 // 用户态所使用 CPU 时间片 (多核累加)
sys 0.01 // 内核态所使用 CPU 时间片
$ GOMAXPROCS=2 time -p ./test
0 9223372030412324865
1 9223372030412324865
real 4.18
user 7.61 // 虽然总时间差不多，但由 2 个核并行，real 时间自然少了许多。
sys 0.02
```

* 调用 runtime.Goexit 将立即终止当前 goroutine 执行，调度器确保所有已注册 defer延迟调用被执行。

```go
func main() {
    wg := new(sync.WaitGroup)
    wg.Add(1)

    go func() {
      defer wg.Done()
      defer println("A.defer")

        func() {
          defer println("B.defer")
          runtime.Goexit() // 终止当前 goroutine
          println("B") // 不会执行
        }()
      println("A") // 不会执行
    }()
    wg.Wait()
}

```

输出：
```
B.defer
A.defer
```

* 和协程 yield 作用类似，Gosched 让出底层线程，将当前 goroutine 暂停，放回队列等待下次被调度执行。

```go
func main() {
  wg := new(sync.WaitGroup)
  wg.Add(2)

  go func() {
    defer wg.Done()
    for i := 0; i < 6; i++ {
      println(i)
      if i == 3 { runtime.Gosched() }
  }
  }()

  go func() {
    defer wg.Done()
    println("Hello, World!")
  }()
  wg.Wait()
}

```

输出：

```
$ go run main.go
0
1
2
3
Hello, World!
4
5
```
## 7.2Channel  

* 引用类型 channel 是 CSP 模式的具体实现，用于多个 goroutine 通讯。其内部实现了同步，确保并发安全。
* 默认为同步模式，需要发送和接收配对。否则会被阻塞，直到另一方准备好后被唤醒。

```go
func main() {
  data := make(chan int) // 数据交换队列
  exit := make(chan bool) // 退出通知

  go func() {
    for d := range data { // 从队列迭代接收数据，直到 close 。
      fmt.Println(d)
    }
    fmt.Println("recv over.")
    exit <- true // 发出退出通知。
  }()

  data <- 1 // 发送数据。
  data <- 2
  data <- 3
  close(data) // 关闭队列。
  fmt.Println("send over.")
  <-exit // 等待退出通知。
}
```

输出：
```
1
2
3
send over.
recv over.
```

* 异步方式通过判断缓冲区来决定是否阻塞。如果缓冲区已满，发送被阻塞；缓冲区为空，接收被阻塞。
* 通常情况下，异步 channel 可减少排队阻塞，具备更高的效率。但应该考虑使用指针规避大对象拷贝，将多个元素打包，减小缓冲区大小等。

```go
func main() {
  data := make(chan int, 3) // 缓冲区可以存储 3 个元素
  exit := make(chan bool)

  data <- 1 // 在缓冲区未满前，不会阻塞。
  data <- 2
  data <- 3

  go func() {
    for d := range data { // 在缓冲区未空前，不会阻塞。
      fmt.Println(d)
    }
    exit <- true
  }()

  data <- 4 // 如果缓冲区已满，阻塞。
  data <- 5
  close(data)
  <-exit
}
```

* 缓冲区是内部属性，并非类型构成要素。

```
var a, b chan int = make(chan int), make(chan int, 3)
```

* 除用 range 外，还可用 ok-idiom 模式判断 channel 是否关闭。

```go
for {
  if d, ok := <-data; ok {
    fmt.Println(d)
  } else {
    break
  }
}
```

* 向 closed channel 发送数据引发 panic 错误，接收立即返回零值。而 nil channel无论收发都会被阻塞。
* 内置函数 len 返回未被读取的缓冲元素数量，cap 返回缓冲区大小。

```go
d1 := make(chan int)
d2 := make(chan int, 3)
d2 <- 1
fmt.Println(len(d1), cap(d1)) // 0 0
fmt.Println(len(d2), cap(d2)) // 1 3

```


## 7.2.1 单向


* 可以将 channel 隐式转换为单向队列，只收或只发。

```go
c := make(chan int, 3)
var send chan<- int = c // send-only
var recv <-chan int = c // receive-only
send <- 1
// <-send // Error: receive from send-only type chan<- int
<-recv
// recv <- 2 // Error: send to receive-only type <-chan int
```

* 不能将单向 channel 转换为普通 channel。

```go
d := (chan int)(send) // Error: cannot convert type chan<- int to type chan int
d := (chan int)(recv) // Error: cannot convert type <-chan int to type chan int
```


## 7.2.2 选择
* 如果需要同时处理多个 channel，可使用 select 语句。它随机选择一个可用 channel 做收发操作，或执行 default case。

```go
func main() {
  a, b := make(chan int, 3), make(chan int)

  go func() {
      v, ok, s := 0, false, ""
    for {
      select { // 随机选择可用 channel，接收数据。
        case v, ok = <-a: s = "a"
        case v, ok = <-b: s = "b"
      }
      if ok {
        fmt.Println(s, v)
      } else {
        os.Exit(0)
      }
    }
  }()
  for i := 0; i < 5; i++ {
    select { // 随机选择可用 channel，发送数据。
      case a <- i:
      case b <- i:
    }
  }
  close(a)
  select {} // 没有可用 channel，阻塞 main goroutine。
}
```

输出：
```
b 3
a 0
a 1
a 2
b 4
```

* 在循环中使用 select default case 需要小心，避免形成洪水。


## 7.2.3 模式


* 用简单工厂模式打包并发任务和 channel。

```go
func NewTest() chan int {
    c := make(chan int)
    rand.Seed(time.Now().UnixNano())

    go func() {
      time.Sleep(time.Second)
      c <- rand.Int()
    }()
    return c
}

func main() {
    t := NewTest()
    println(<-t) // 等待 goroutine 结束返回。
}
```

* 用 channel 实现信号量 (semaphore)。

```go
func main() {
    wg := sync.WaitGroup{}
    wg.Add(3)
    sem := make(chan int, 1)

    for i := 0; i < 3; i++ {
        go func(id int) {
        defer wg.Done()
        sem <- 1 // 向 sem 发送数据，阻塞或者成功。
        for x := 0; x < 3; x++ {
            fmt.Println(id, x)
        }
        <-sem // 接收数据，使得其他阻塞 goroutine 可以发送数据。
        }(i)
    }
    wg.Wait()
}
```

输出：

```
$ GOMAXPROCS=2 go run main.go
0 0
0 1
0 2
1 0
1 1
1 2
2 0
2 1
2 2
```

* 用 closed channel 发出退出通知。

```go
func main() {
    var wg sync.WaitGroup
    quit := make(chan bool)
    for i := 0; i < 2; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            task := func() {
                println(id, time.Now().Nanosecond())
                time.Sleep(time.Second)
            }
            for {
                select {
                    case <-quit: // closed channel 不会阻塞，因此可用作退出通知。
                    return
                    default: // 执行正常任务。
                    task()
                }
            }
        }(i)
    }
    time.Sleep(time.Second * 5) // 让测试 goroutine 运行一会。
    close(quit) // 发出退出通知。
    wg.Wait()
}
```


* 用 select 实现超时 (timeout)。

```go
func main() {
    w := make(chan bool)
    c := make(chan int, 2)

    go func() {
        select {
            case v := <-c: fmt.Println(v)
            case <-time.After(time.Second * 3): fmt.Println("timeout.")
        }
        w <- true
    }()
    // c <- 1 // 注释掉，引发 timeout。
    <-w
}
```

* channel 是第一类对象，可传参 (内部实现为指针) 或者作为结构成员。

```go
type Request struct {
    data []int
    ret  chan int
}

func NewRequest(data ...int) *Request {
    return &Request{ data, make(chan int, 1) }
}

func Process(req *Request) {
    x := 0
    for _, i := range req.data {
        x += i
    }
    req.ret <- x
}

func main() {
    req := NewRequest(10, 20, 30)
    Process(req)
    fmt.Println(<-req.ret)
}
```

其实学完并发，就可以开始写项目了，算是完成go比较关键的部分了。
