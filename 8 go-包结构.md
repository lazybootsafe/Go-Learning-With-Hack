# Go-learning
# 8.语言详解--包结构

## 8.1 工作空间

* 编译工具对源码目录有严格要求，每个工作空间 (workspace) 必须由 bin、pkg、src 三个目录组成。（参见test目录）

```
workspace
  |
  +--- bin                      // go install 安装目录。
  |     |
  |     +--- learn
  |
  |
  +--- pkg                      // go build ⽣生成静态库 (.a) 存放目录。
  |     |
  |     +--- darwin_amd64
  |     |
  |     +--- mylib.a
  |     |
  |     +--- mylib
  |     |
  |     +--- sublib.a
  |
  +--- src                    // 项目源码目录。
        |
        +--- learn
        |       |
        |       +--- main.go
        |
        |
        +--- mylib
                |
                +--- mylib.go
                |
                +--- sublib
                        |
                        +--- sublib.go
```

* 可在 GOPATH 环境变量列表中添加多个工作空间，但不能和 GOROOT 相同。

`export GOPATH=$HOME/projects/golib:$HOME/projects/go`

* 通常 go get 使用第一个工作空间保存下载的第三方库。


## 8.2 源文件

```
编码：源码文件必须是 UTF-8 格式，否则会导致编译器出错。
结束：语句以 ";" 结束，多数时候可以省略。
注释：⽀支持 "//"、"/**/" 两种注释方式，不能嵌套。
命名：采用 camelCasing 风格，不建议使用下划线。
```


## 8.3 包结构


* 所有代码都必须组织在 package 中。
* 源文件头部以 "package <name>" 声明包名称。
* 包由同一目录下的多个源码文件组成。
* 包名类似 namespace，与包所在目录名、编译文件名无关。
* 目录名最好不用 main、all、std 这三个保留名称。
* 可执行文件必须包含 package main，入口函数 main。

<b>说明：os.Args 返回命令行参数，os.Exit 终止进程。
<b>要获取正确的可执行文件路径，可用 filepath.Abs(exec.LookPath(os.Args[0]))。

<b>包中成员以名称首字母大小写决定访问权限。
* public: 首字母大写，可被包外访问。
* internal: 首字母小写，仅包内成员可以访问。

<b>该规则适用于全局变量、全局常量、类型、结构字段、函数、方法等。


## 8.3.1 导入包


* 使用包成员前，必须先用 import 关键字导入，但不能形成导入循环。

* import "相对目录/包主文件名"
* 相对目录是指从 <workspace>/pkg/<os_arch> 开始的子目录，以标准库为例：

```
import "fmt" -> /usr/local/go/pkg/darwin_amd64/fmt.a
import "os/exec" -> /usr/local/go/pkg/darwin_amd64/os/exec.a
```

* 在导入时，可指定包成员访问方式。比如对包重命名，以避免同名冲突。

```
import "yuhen/test" // 默认模式: test.A
import M "yuhen/test" // 包重命名: M.A
import . "yuhen/test" // 简便模式: A
import _ "yuhen/test" // 非导入模式: 仅让该包执行初始化函数。
```

* 未使用的导入包，会被编译器视为错误 ``(不包括 "import _")``。

```
./main.go:4: imported and not used: "fmt"
```

* 对于当前目录下的子包，除使用默认完整导入路径外，还可使用 local 方式。

```
workspace
|
+--- src
      |
      +--- learn
            |
            +--- main.go
            |
            +--- test
                  |
                  +--- test.go
```
> <b>main.go

```
import "learn/test"      // 正常模式
import "./test"          // 本地模式，仅对 go run main.go 有效。

```



## 8.3.2 自定义路径



* 可通过 meta 设置为代码库设置自定义路径。


> <b>server.go

```go
package main

import (
"fmt"
"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprint(w, `<meta name="go-import"
    content="test.com/finger/test git https://github.com/finger/test">`)
}

func main() {
    http.HandleFunc("/finger/test", handler)
    http.ListenAndServe(":80", nil)
}
```

* <b>该示例使用自定义域名 test.com 重定向到 github。

```
$ go get -v test.com/finger/test
Fetching https://test.com/finger/test?go-get=1
https fetch failed.
Fetching http://test.com/finger/test?go-get=1
Parsing meta tags from http://test.com/finger/test?go-get=1 (status code 200)
get "test.com/finger/test": found meta tag http://test.com/finger/test?go-get=1
test.com/finger/test (download)
test.com/finger/test
```


* 如此，该库就有两个有效导入路径，可能会导致存储两个本地副本。为此，可以给库添加专门的 "import comment"。
* 当 go get 下载完成后，会检查本地存储路径和该注释是否一致。

```go
github.com/finger/test/abc.go
package test  
            // import "test.com/finger/test"
func Hello() {
    println("Hello, Custom import path!")
}
```

* 如继续用 github 路径，会导致 go build 失败。

```
$ go get -v github.com/finger/test
github.com/finger/test (download)
package github.com/finger/test
? imports github.com/finger/test
? imports github.com/finger/test: expects import "test.com/finger/test"
```

* 这就强制包用户使用唯一路径，也便于日后将包迁移到其他位置。


## 8.3.3 初始化


* <b>初始化函数：



* 每个源文件都可以定义一个或多个初始化函数
* 编译器不保证多个初始化函数执行次序
* 初始化函数在单一线程被调用，仅执行一次
* 初始化函数在包所有全局变量初始化后执行
* 在所有初始化函数结束后才执行 main.main
* 无法调用初始化函数


* 因为无法保证初始化函数执行顺序，因此全局变量应该直接用 var 初始化。

```go
var now = time.Now()
    func init() {
    fmt.Printf("now: %v\n", now)
}

func init() {
    fmt.Printf("since: %v\n", time.Now().Sub(now))
}
```


* 可在初始化函数中使用 goroutine，可等待其结束。

```go
var now = time.Now()
    func main() {
    fmt.Println("main:", int(time.Now().Sub(now).Seconds()))
}

func init() {
    fmt.Println("init:", int(time.Now().Sub(now).Seconds()))
    w := make(chan bool)

    go func() {
        time.Sleep(time.Second * 3)
        w <- true
    }()
    <-w
}
```


输出：

```
init: 0
main: 3
```
* 不应该滥用初始化函数，仅适合完成当前文件中的相关环境设置。


## 8.4 文档



* <b>扩展工具 godoc 能自动提取注释⽣生成帮助文档。



* 仅和成员相邻 (中间没有空行) 的注释被当做帮助信息。
* 相邻行会合并成同一段落，用空行分隔段落。
* 缩进表示格式化文本，⽐比如⽰示例代码。
* 自动转换 URL 为链接。
* 自动合并多个源码文件中的 package 文档。
* 无法显式 package main 中的成员文档。


### 8.4.1 Package


* 建议用专门的 doc.go 保存 package 帮助信息。
* 包文档第一整句 (中英文句号结束) 被当做 packages 列表说明。



### 8.4.2 Example


* 只要 Example 测试函数名称符合以下规范即可。

```
                        格式                                示例
-----------+-------------------------------------------+-----------------------------------
package             Example, Example_suffix                Example_test
func                ExampleF, ExampleF_suffix              ExampleHello
type                ExampleT, ExampleT_suffix              ExampleUser, ExampleUser_copy
method              ExampleT_M, ExampleT_M_suffix          ExampleUser_ToString

```

* <font color=red><b>说明：使用 suffix 作为示例名称，其首字母必须小写。如果文件中仅有一个 Example 函数，且调用了该文件中的其他成员，那么示例会显示整个文件内容，而不仅仅是测试函数自己。</font>



### 8.4.3 Bug

* 非测试源码文件中以 BUG(author) 开始的注释，会在帮助文档 Bugs 节点中显示。
```
// BUG(finger): memory leak.
```
