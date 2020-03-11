# Go-learning-With-Hack
# 6.语言详解--接口

## 6.1 接口定义
* 接口是一个或多个方法签名的集合，任何类型的方法集中只要拥有与之对应的全部方法，就表示它 "实现" 了该接口，无须在该类型上显式添加接口声明。
* 所谓对应方法，是指有相同名称、参数列表 (不包括参数名) 以及返回值。当然，该类型还可以有其他方法。

* 接口命名习惯以 er 结尾，结构体。
* 接口只有方法签名，没有实现。
* 接口没有数据字段。
* 可在接口中嵌⼊入其他接口。
* 类型可实现多个接口。

```go
type Stringer interface {
    String() string
}

type Printer interface {
    Stringer // 接口嵌入。
    Print()
}

type User struct {
    id   int
    name string
}

func (self *User) String() string {
    return fmt.Sprintf("user %d, %s", self.id, self.name)
}

func (self *User) Print() {
    fmt.Println(self.String())
}

func main() {
    var t Printer = &User{1, "Tom"} // *User 方法集包含 String、Print。
    t.Print()
}

```
输出：

```
user 1, Tom
```
* 空接口 interface{} 没有任何方法签名，也就意味着任何类型都实现了空接口。其作用类似面向对象语言中的根对象object。

```go
func Print(v interface{}) {
    fmt.Printf("%T: %v\n", v, v)
}

func main() {
    Print(1)
    Print("Hello, World!")
}
```

输出：

```
int: 1
string: Hello, World!
```

* 匿名接口可用作变量类型，或结构成员。

```go
type Tester struct {
    s interface {
      String() string
    }
}

type User struct {
    id   int
    name string
}

func (self *User) String() string {
    return fmt.Sprintf("user %d, %s", self.id, self.name)
}

func main() {
    t := Tester{&User{1, "Tom"}}
    fmt.Println(t.s.String())
}

```
输出：
```
user 1, Tom
```

## 6.2 执行机制

* 接口对象由接口表 (interface table) 指针和数据指针组成。

> runtime.h

```c
struct Iface
{
Itab* tab;
void* data;
};
struct Itab
{
InterfaceType* inter;
Type* type;
void (*fun[])(void);
};
```

* 接口表存储元数据信息，包括接口类型、动态类型，以及实现接口的方法指针。无论是反射还是通过接口调用方法，都会用到这些信息。
* 数据指针持有的是目标对象的只读复制品，复制完整对象或指针。

```go
type User struct {
    id   int
    name string
}

func main() {
    u := User{1, "Tom"}
    var i interface{} = u
    u.id = 2
    u.name = "Jack"

    fmt.Printf("%v\n", u)
    fmt.Printf("%v\n", i.(User))
}
```
输出：
```
{2 Jack}
{1 Tom}
```

* 接口转型返回临时对象，只有使⽤用指针才能修改其状态。

```go
type User struct {
    id   int
    name string
}

func main() {
    u := User{1, "Tom"}
    var vi, pi interface{} = u, &u
    // vi.(User).name = "Jack" // Error: cannot assign to vi.(User).name
    pi.(*User).name = "Jack"

    fmt.Printf("%v\n", vi.(User))
    fmt.Printf("%v\n", pi.(*User))
}
```

输出：
```
{1 Tom}
&{1 Jack}
```

* 只有 tab 和 data 都为 nil 时，接口才等于 nil。

```go
var a interface{} = nil // tab = nil, data = nil
var b interface{} = (*int)(nil) // tab 包含 *int 类型信息, data = nil

type iface struct {
    itab, data uintptr
}

ia := *(*iface)(unsafe.Pointer(&a))
ib := *(*iface)(unsafe.Pointer(&b))
fmt.Println(a == nil, ia)
fmt.Println(b == nil, ib, reflect.ValueOf(b).IsNil())
```

输出:
```
true {0 0}
false {505728 0} true
```

## 6.3 接口转换


* 利用类型推断，可判断接口对象是否某个具体的接口或类型。

```go
type User struct {
    id   int
    name string
}

func (self *User) String() string {
    return fmt.Sprintf("%d, %s", self.id, self.name)
}

func main() {
    var o interface{} = &User{1, "Tom"}
    if i, ok := o.(fmt.Stringer); ok { // ok-idiom
      fmt.Println(i)
    }
u := o.(*User)
// u := o.(User) // panic: interface is *main.User, not main.User
fmt.Println(u)
}
```

* 还可用 switch 做批量类型判断，不支持 fallthrough。

```go
func main() {
var o interface{} = &User{1, "Tom"}
switch v := o.(type) {
    case nil: // o == nil
  fmt.Println("nil")
    case fmt.Stringer: // interface
  fmt.Println(v)
    case func() string: // func
  fmt.Println(v())
    case *User: // *struct
  fmt.Printf("%d, %s\n", v.id, v.name)

  default:
  fmt.Println("unknown")
  }
}
```

* 超集接口对象可转换为子集接口，反之出错。

```go
type Stringer interface {
    String() string
}

type Printer interface {
    String() string
    Print()
}

type User struct {
    id   int
    name string
}

func (self *User) String() string {
    return fmt.Sprintf("%d, %v", self.id, self.name)
}

func (self *User) Print() {
    fmt.Println(self.String())
}

func main() {
    var o Printer = &User{1, "Tom"}
    var s Stringer = o
    fmt.Println(s.String())
}
```

## 6.4 接口技巧

让编译器检查，以确保某个类型实现接口。

```go
var _ fmt.Stringer = (*Data)(nil)
```

* 某些时候，让函数直接 "实现" 接口能省不少事。

```go
type Tester interface {
Do()
}
type FuncDo func()
func (self FuncDo) Do() { self() }
func main() {
var t Tester = FuncDo(func() { println("Hello, World!") })
t.Do()
}
```
