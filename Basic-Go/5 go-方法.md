# Go-learning
# 5.语言详解--方法

## 5.1 方法定义

方法总是绑定对象实例，并隐式将实例作为第一实参 (receiver)。

* 只能为当前包内命名类型定义方法。
* 参数 receiver 可任意命名。如方法中未曾使⽤用，可省略参数名。
* 参数 receiver 类型可以是 T 或 ``*T``。基类型 T 不能是接口或指针。
* 不支持方法重载，receiver 只是参数签名的组成部分。
* 可用实例 value 或 pointer 调用全部方法，编译器自动转换。
* 没有构造和析构方法，通常用简单工厂模式返回对象实例。

```go
type Queue struct {
    elements []interface{}
}

func NewQueue() *Queue {                      // 创建对象实例。
    return &Queue{make([]interface{}, 10)}
}

func (*Queue) Push(e interface{}) error {   // 省略 receiver 参数名。
    panic("not implemented")
}

// func (Queue) Push(e int) error {       // Error: method redeclared: Queue.Push
// panic("not implemented")
// }

func (self *Queue) length() int {        // receiver 参数名可以是 self、this 或其他。
    return len(self.elements)
}
```


* 方法不过是一种特殊的函数，只需将其还原，就知道 receiver T 和 ``*T`` 的差别。

```go
type Data struct{
    x int
}

func (self Data) ValueTest() { // func ValueTest(self Data);
    fmt.Printf("Value: %p\n", &self)
}

func (self *Data) PointerTest() { // func PointerTest(self *Data);
    fmt.Printf("Pointer: %p\n", self)
}
func main() {
    d := Data{}
    p := &d
    fmt.Printf("Data: %p\n", p)
    d.ValueTest() // ValueTest(d)
    d.PointerTest() // PointerTest(&d)
    p.ValueTest() // ValueTest(*p)
    p.PointerTest() // PointerTest(p)
}
```

输出：

```
Data : 0x2101ef018
Value : 0x2101ef028
Pointer: 0x2101ef018
Value : 0x2101ef030
Pointer: 0x2101ef018
```

* 从 1.4 开始，不再支持多级指针查找方法成员。

```go
type X struct{}

func (*X) test() {
    println("X.test")
}
func main() {
    p := &X{}
    p.test()
// Error: calling method with receiver &p (type **X) requires explicit dereference
// (&p).test()
}
```

## 5.2 匿名字段

* 可以像字段成员那样访问匿名字段方法，编译器负责查找。

```go
type User struct {
    id   int
    name string
}

type Manager struct {
    User
}

func (self *User) ToString() string { // receiver = &(Manager.User)
    return fmt.Sprintf("User: %p, %v", self, self)
}

func main() {
    m := Manager{User{1, "Tom"}}
    fmt.Printf("Manager: %p\n", &m)
    fmt.Println(m.ToString())
}
```

输出：

```
Manager: 0x2102281b0
User : 0x2102281b0, &{1 Tom}
```

* 通过匿名字段，可获得和继承类似的复用能⼒力。依据编译器查找次序，只需在外层定义同名方法，就可以实现 "override"。

```go
type User struct {
    id   int
    name string
}

type Manager struct {
    User
    title string
}

func (self *User) ToString() string {
    return fmt.Sprintf("User: %p, %v", self, self)
}

func (self *Manager) ToString() string {
    return fmt.Sprintf("Manager: %p, %v", self, self)
}

func main() {
    m := Manager{User{1, "Tom"}, "Administrator"}
    fmt.Println(m.ToString())
    fmt.Println(m.User.ToString())
}
```


输出：

```
Manager: 0x2102271b0, &{{1 Tom} Administrator}
User : 0x2102271b0, &{1 Tom}
```

## 5.3 方法集
每个类型都有与之关联的方法集，这会影响到接口实现规则。
* 类型 T 方法集包含全部 receiver T 方法。
* 类型 ``*T 方法集包含全部 receiver T + *T 方法。``
* 如类型 S 包含匿名字段 T，则 S 方法集包含 T 方法。
* 如类型 S 包含匿名字段 ``*T，则 S 方法集包含 T + *T 方法。``
* 不管嵌入 T 或 ``*T，*S 方法集总是包含 T + *T 方法。``
* 用实例 value 和 pointer 调用方法 (含匿名字段) 不受方法集约束，编译器总是查找全部方法，并自动转换 receiver 实参。


## 5.4 表达式

* 根据调用者不同，方法分为两种表现形式：

```go
instance.method(args...) ---> <type>.func(instance, args...)
```

* 前者称为 method value，后者 method expression。

* 两者都可像普通函数那样赋值和传参，区别在于 method value 绑定实例，而 method expression 则须显式传参。

```go
type User struct {
    id   int
    name string
}

func (self *User) Test() {
    fmt.Printf("%p, %v\n", self, self)
}

func main() {
    u := User{1, "Tom"}
    u.Test()
    mValue := u.Test
    mValue() // 隐式传递 receiver
    mExpression := (*User).Test
    mExpression(&u) // 显式传递 receiver
}
```

输出：

```
0x210230000, &{1 Tom}
0x210230000, &{1 Tom}
0x210230000, &{1 Tom}
```

* 需要注意，method value 会复制 receiver。

```go
type User struct {
    id   int
    name string
}

func (self User) Test() {
    fmt.Println(self)
}

func main() {
    u := User{1, "Tom"}
    mValue := u.Test // 立即复制 receiver，因为不是指针类型，不受后续修改影响。
    u.id, u.name = 2, "Jack"
    u.Test()
    mValue()
}
```

输出：

```
{2 Jack}
{1 Tom}
```

* 在汇编层面，method value 和闭包的实现方式相同，实际返回 FuncVal 类型对象。

```
FuncVal { method_address, receiver_copy }
```
* 可依据方法集转换 method expression，注意 receiver 类型的差异。

```go
type User struct {
    id   int
    name string
}

func (self *User) TestPointer() {
    fmt.Printf("TestPointer: %p, %v\n", self, self)
}

func (self User) TestValue() {
    fmt.Printf("TestValue: %p, %v\n", &self, self)
}

func main() {
    u := User{1, "Tom"}
    fmt.Printf("User: %p, %v\n", &u, u)
    mv := User.TestValue
    mv(u)
    mp := (*User).TestPointer
    mp(&u)
    mp2 := (*User).TestValue // *User 方法集包含 TestValue。
    mp2(&u) // 签名变为 func TestValue(self *User)。
} // 实际依然是 receiver value copy。
```

输出：

```
User : 0x210231000, {1 Tom}
TestValue : 0x210231060, {1 Tom}
TestPointer: 0x210231000, &{1 Tom}
TestValue : 0x2102310c0, {1 Tom}
```

* 将方法 "还原" 成函数，就容易理解下面的代码了。

```go
type Data struct{}

func (Data) TestValue() {}
func (*Data) TestPointer() {}

func main() {
    var p *Data = nil
    p.TestPointer()
    (*Data)(nil).TestPointer() // method value
    (*Data).TestPointer(nil) // method expression
    // p.TestValue() // invalid memory address or nil pointer dereference
    // (Data)(nil).TestValue() // cannot convert nil to type Data
    // Data.TestValue(nil) // cannot use nil as type Data in function argument
}
```
