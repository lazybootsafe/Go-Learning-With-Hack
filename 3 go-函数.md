# Go-learning
# 3.语言详解--函数

## 3.1 定义
函数是结构化编程的最小模块单元。他将复杂的算法过程分解为若干个小任务，隐藏相关细节，使得程序结构更加清晰。函数被设计成相对独立，通过接受输入参数完成一段算法指令，输出货存储相关结果。关键字func 用于定义函数，go中的函数不太方便的限制，也借鉴了动态语言的某些优点。

* <font color=red>无须前置声明</font>
* <font color=red>不支持命名嵌套定义（nested）</font>
* <font color=red>不支持同名函数重载（overload）</font>
* <font color=red>不支持默认参数</font>
* <font color=red>支持不定长便参</font>
* <font color=red>支持多返回值</font>
* <font color=red>支持命名返回值</font>
* <font color=red>支持匿名函数和闭包</font>

> <font color=red><b>不支持左花括号另起一行

* 函数属于第一类对象，具备相同签名（参数及返回值列表）的视作同一类型。
code：

```
func hello() {
   println("hello,sir!")
}

func exec(f func()){
   f()
}

func main(){
   f := hello
   exec(f)   
}
```
* 第一类对象（first-class object）只可在运行期创建，可用做函数参数或者返回值，可存入变量的实体。最常见的用法就是匿名函数。

* 从代码维护的角度来说，使用命名类型更加方便

code：

```
// 定义函数类型
type formatFunc(string, ...interface{}) (string, error)

//如不使用命名类型，这个参数签名会长的爆炸。
type format(f formatFunc, s string, a...interface{}) (string, error) {
   return f(s, a...)
}
```
* 函数只能判断是否为nil 不支持其他比较操作。

code：
```
func a...
func b...
println(a == nil)
println(a == b)  // 无效操作
```
* 从函数返回局部变量指针是安全的，编译器会通过逃逸分析（escape analysis）来决定是否在堆上分配内存。

code：

```
func test() *int {
  a := 0x100
  return &a
}

func main() {
   var a *int =test()
   println(a, &a)
}

```
输出：(省略)

```

$go build -gcflags "-l -m"   //禁用函数内联，输出优化信息
....
....

$go tool objdump -s "main\.main" test    //反汇编确认
......
......

```
* 函数内联（inline）对内存分配有一定的影响。如果上列中允许内联，那么就会直接在栈上分配内存。
* 当前编译器并未实现尾递归优化（tail-call optimization）尽管go执行栈的上限是gb规模，轻易不会出现堆栈溢出（Stack Overflow）醋五，但还是需要注意拷贝栈的赋值成本。

### 建议命名规则
这个就不用多说了

每个程序猿都有自己的规则。。


## 3.2 参数

go对参数的处理偏向保守，不支持有默认值的可选参数，不支持实参，调用时，必须按签名顺序传递指定类型和数量的实参，就算以 `_` 命名的参数也不能忽略。

* 在参数列表中，相邻的同类型参数可合并

code：
```
func test(x, y int, s string, _ bool) *int {
   return nil
}

func main() {
   test(1, 2, "abc")                // error : enough arguments in call to test
}
```

* 参数可视作函数局部变量，因此不能在相同层次定义同名变量。

code：

```
func add(x, y int) int {
  x := 100                       //error : no new variables on the left side of :=
  var y int                       // error : y redeclared in this block
  return x + y
}
```
* 形参是指函数定义中的参数，实参则是函数的调用时所传递的参数。形参类似函数局部变量，而实参则是函数外部对象，可以是常量 变量，表达式 或者函数等。

* 不管是指针，引用类型，还是其他的类型参数，都是值拷贝传递（pass-by-value）。区别无非是拷贝目标对象，还是拷贝指针而已。在函数调用前，回味形参和返回值分配内存空间，并将实参拷贝到形参内存。

code：

```
func test(x *int) {
   fmt.printf("pointer: %p, target: %v\n", &x, x)         //输出形参x的地址
}

func main() {
   a := 0x100
   p := &a
   fmt.printf("pointer: %p, target: %v\n", &p, p)          //输出实参p的地址

   test(p)
}
```
从输出结果可以看出，尽管实参和形参都指向同一目标，但传递指针时依然被复制。

* 下面是一个指针参数导致实参变量被分配到堆上的简单实例，可对比传值参数的汇编代码，可看出具体的差别。

code：
```
func test(p *int) {
   go func(){
     println(p)                //延长p的生命周期
   }()
}

func main() {
   x := 100
   p := &x
   test(p)
}
```
输出：
```
$ go build -gcflags "-m"           //输出编译器优化策略

moved to heap :x
&x excapes to heap                  //逃逸


$ go tool objdump -s "main\.main" test

.........
CALL runtime.newobject(SB)                //在堆上为x分配内存
```

* 要实现传出参数（out），通常建议使用返回值，也可以继续用二级指针。

code：
```
func test(p **int) {
   x := 100
   *p = &x

}

func main() {
   var p *int
   test(&p)
   println(*p)
}
```
输出：
100

* 如果函数参数过多，建议将其重构成一个复合结构类型，也算是变相实现可选参数和命名实参的功能。

code：
```
type serverOption struct {
   address string
   port    int
   path    string
   timeout time.Duration
   log     *log.Logger
}

func newOption() *serverOption {
   return &serverOption{
     address:"0.0.0.0"
     port:  8080,
     path:  "/var/test",
     timeout: time.Second * 5,
     log:    nil,
   }
}

func server(option *serverOption) {}

func main() {
  opt := newOption()
  opt.port = 8085,                    //命名参数设置

  server(opt)
}
```

* 将过多的参数独立成option struct，既便于拓展参数集，也方便通过newOption 函数设置默认配置。这也是代码复用的一种当时，避免处处调用时繁琐的参数配置。

### 变参

变参本质上就是切片slice。
只能有一个，且必须是最后一个，即列表尾部。
```
func test(s string, n ...int) string {
    var x int
    for _, i := range n {
    x += i
  }
 return fmt.Sprintf(s, x)
}

func main() {
  println(test("sum: %d", 1, 2, 3))
}
```


使用切片 slice 对象做变参时，必须展开。

```
func main() {
  s := []int{1, 2, 3}
  println(test("sum: %d", s...))
}
```
## 3.3 返回值

* 有返回值的函数，必须有明确的return终止语句。

```
func test(x int) int {
  if x > 0 {
     return 1
    }else if x < 0 {
      return -1
    }
}         // error: missing return at the end of function
```

* 除非有painc，或者无break的死循环，则无需return终止语句。

```
func test(x int) int {
   for {
     break
   }
}             //error : missing return at the end of function
```

* 借鉴自动态语言的多分返回值模式，函数得以返回更多状态，尤其是error模式。

```
import "error"

func div(x, y int) (int, error) {
   if y == 0 {
     return 0, error.New("division by xx")
   }
   return x / y, nil
}
```

* 稍有不便的是没有元祖（tuple）类型，也不能用数组，切片接受，但可用`_`忽略不想要的返回值。多返回值可用作其他函数调用实参，或当做结果直接返回。

* 多返回值可直接作为其他函数调用实参。<br>

```
func test() (int, int) {
  return 1, 2
}

func add(x, y int) int {
  return x + y
}

func sum(n ...int) int {
  var x int
  for _, i := range n {
  x += i
}
  return x
}

func main() {

  println(add(test()))
  println(sum(test()))
}
```

* 命名返回参数可看做与形参类似的局部变量，最后由 return 隐式返回。<br>

```
func add(x, y int) (z int) {
  z = x + y
  return
}

func main() {
  println(add(1, 2))
}
```

* 命名返回参数可被同名局部变量遮蔽，此时需要显式返回。<br>

```
func add(x, y int) (z int) {
    {                           // 不能在一个级别，引发 "z redeclared in this block" 错误。
    var z = x + y
    // return                  // Error: z is shadowed during return
    return z                  // 必须显式返回。
    }
}
```

* 命名返回参数允许 defer 延迟调用通过闭包读取和修改。

```
func add(x, y int) (z int) {
    defer func() {
    z += 100
    }()
    z = x + y
    return
}

func main() {
    println(add(1, 2)) // 输出: 103
}
```

* 显式 return 返回前，会先修改命名返回参数。

```
func add(x, y int) (z int) {
    defer func() {
    println(z) // 输出: 203
    }()
    z = x + y
    return z + 200 // 执⾏行顺序: (z = z + 200) -> (call defer) -> (ret)
}

func main() {
    println(add(1, 2)) // 输出: 203
```

### 命名返回值

对返回值命名和简短变量定义一样。

```
func paging(sql string, index nil) (count int, pages int, err error) {

}
```


## 3.4 匿名函数

* 匿名函数是指没有定义名字符号的函数。除了没有名字外，匿名函数和普通函数完全相同。
* 最大的区别是我们可在函数内部定义匿名函数，形成类似嵌套效果。匿名函数可直接调用，保存到变量，作为参数或返回值。

* 匿名函数可赋值给变量，做为结构字段，或者在 channel 里传送。

```
// --- function variable ---

fn := func() { println("Hello, World!") }
fn()

// --- function collection ---

fns := [](func(x int) int){
    func(x int) int { return x + 1 },
    func(x int) int { return x + 2 },
}
  println(fns[0](100))

// --- function as field ---

d := struct {
  fn func() string
  }{
fn: func() string { return "Hello, World!" },
}
  println(d.fn())

// --- channel of function ---

fc := make(chan func() string, 2)
fc <- func() string { return "Hello, World!" }
println((<-fc)())
```
* 除了闭包因素外，匿名函数也是一种常见的重构手段，可将大函数分解成多个相对独立的匿名函数块，然后用相对简洁的调用完成逻辑流程，以实现框架和细节分离。
* 相比语句块，匿名函数的作用域被隔离（不使用闭包），不会引发外部污染，更加灵活。没有定义顺序先知，必要时刻抽离，便于实现干净清晰的代码层次。
* 闭包复制的是原对象指针，这就很容易解释延迟引用现象。
* 闭包（closure）是在其词法上下文中引用了自由变量的函数，或者说是函数和其引用的环境的组合体。

```
func test() func() {
    x := 100
    fmt.Printf("x (%p) = %d\n", &x, x)
    return func() {
    fmt.Printf("x (%p) = %d\n", &x, x)
    }
}

func main() {
    f := test()
    f()
}
```
输出：
```
x (0x2101ef018) = 100
x (0x2101ef018) = 100
```
* 在汇编层面，test 实际返回的是 FuncVal 对象，其中包含了匿名函数地址、闭包对象指
针。当调用匿名函数时，只需以某个寄存器传递该对象即可。
* 通过输出指针，我们注意到闭包直接引用了原环境变量。分析汇编代码，返回值不仅是匿名函数还包括了引用的环境变量指针。
* 汇编代码和我们主题无关，这里就不贴上去了。。。

```
FuncVal { func_address, closure_var_pointer ... }
```
* 闭包通过指针引用缓解经变量，会导致生命周期延长，甚至会被分配到堆内存，所谓“延迟求值”的特征。

```
func test() []func() {
  var s []func()

  for i :=;i < 2; i++ {
    s = append(s, func() {
      println(&i, i)
    )}
  }
   return s
}

func main() {
  for _, f :=range test() {
    f()
  }
}
```
* 解决办法就是每次用不同的环境变量或传参复制，让各自闭包环境各不相同。

* 多个匿名函数引用统一环境变量，也会让事情变得更加复杂。任何的修改行为都会影响其他函数取值，在并发模式下可能需要做同步处理。

## 3.5 延迟调用

* 关键字 defer 用于注册延迟调用。这些调用直到 return 前才被执行，通常用于释放资源或错误处理。

```
func test() error {
  f, err := os.Create("test.txt")
  if err != nil { return err }
  defer f.Close()                          // 注册调用，而不是注册函数。必须提供参数，哪怕为空。
  f.WriteString("Hello, World!")
  return nil
}
```

* 多个 defer 注册，按 FILO 次序执⾏行。哪怕函数或某个延迟调用发生错误，这些调用依旧会被执行。

```
func test(x int) {
  defer println("a")
  defer println("b")
  defer func() {
  println(100 / x)                 // div0 异常未被捕获，逐步往外传递，最终终止进程。
  }()
  defer println("c")
}

func main() {
  test(0)
}
```

输出：

```
c
b
a
panic: runtime error: integer divide by zero
```

* 延迟调用参数在注册时求值或复制，可用指针或闭包 "延迟" 读取。

```
func test() {
  x, y := 10, 20
  defer func(i int) {
  println("defer:", i, y)                       // y 闭包引用
}(x)                                            // x 被复制
  x += 10
  y += 100
  println("x =", x, "y =", y)
}
```
输出：
```
x = 20 y = 120
defer: 10 120
```
* 滥用 defer 可能会导致性能问题，尤其是在一个 "大循环" 里。

```
var lock sync.Mutex
  func test() {
  lock.Lock()
  lock.Unlock()
}

func testdefer() {
  lock.Lock()
  defer lock.Unlock()
}

func BenchmarkTest(b *testing.B) {
    for i := 0; i < b.N; i++ {
    test()
  }
}

func BenchmarkTestDefer(b *testing.B) {
    for i := 0; i < b.N; i++ {
    testdefer()
  }
}
```
输出:
```
BenchmarkTest? 50000000 43 ns/op
BenchmarkTestDefer 20000000 128 ns/op
```

## 3.6 错误处理

* 没有结构化异常，使用 panic 抛出错误，recover 捕获错误。

```
func test() {
    defer func() {
    if err := recover(); err != nil {
    println(err.(string))                      // 将 interface{} 转型为具体类型。
  }
}()
  panic("panic error!")
}
```
* 由于 panic、recover 参数类型为 interface{}，因此可抛出任何类型对象。

```
func panic(v interface{})
func recover() interface{}
```
* 延迟调用中引发的错误，可被后续延迟调用捕获，但仅最后一个错误可被捕获。

```
func test() {
    defer func() {
    fmt.Println(recover())
}()
defer func() {
    panic("defer panic")
}()
    panic("test panic")
}

func main() {
    test()
}
```
输出：
```
defer panic
```

* 捕获函数 recover 只有在延迟调用内直接调用才会终止错误，否则总是返回 nil。任何未捕获的错误都会沿调用堆栈向外传递。

```
func test() {
    defer recover()                            // 无效！
    defer fmt.Println(recover())               // 无效！
    defer func() {
      func() {
      println("defer inner")
      recover()                                // 无效！
  }()
}()
  panic("test panic")
}

func main() {
  test()
}
```
输出：
```
defer inner
<nil>
panic: test panic
```

* 使用延迟匿名函数或下面这样都是有效的。

```
func except() {
  recover()
}

func test() {
  defer except()
  panic("test panic")
}
```

* 如果需要保护代码片段，可将代码块重构成匿名函数，如此可确保后续代码被执行。

```
func test(x, y int) {
    var z int
    func() {
      defer func() {
        if recover() != nil { z = 0 }
        }()
  z = x / y
  return
}()
  println("x / y =", z)
}
```

* 除用 panic 引发中断性错误外，还可返回 error 类型错误对象来表示函数调用状态。

```
type error interface {
Error() string
}
```

* 标准库 errors.New 和 fmt.Errorf 函数用于创建实现 error 接口的错误对象。通过判断错误对象实例来确定具体错误类型。

```
var ErrDivByZero = errors.New("division by zero")
func div(x, y int) (int, error) {
  if y == 0 { return 0, ErrDivByZero }
  return x / y, nil
}

func main() {
  switch z, err := div(10, 0); err {
    case nil:
  println(z)
    case ErrDivByZero:
  panic(err)
  }
}
```

* 如何区别使用 panic 和 error 两种方式？惯例是：导致关键流程出现不可修复性错误的使用 panic，其他使用 error。
