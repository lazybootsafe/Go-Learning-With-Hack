# Go-learning
# 4.语言详解--数据

## 4.0 字符串

* 字符串是不可变字节（byte）序列，其本身是一个复合结构。

```
type stringStruct struct {
   str unsafe.pointer
   len int
}
```

* 头部指针指向字节数组，但是没有NULL结尾。默认以utf-8编码存储Unicode字符，字面量里允许使用十六进制、八进制和UTF编码格式。
```
func main() {
   s := "路人甲\61\142\u0041"

   fmt.Printf("%s\n, s")
   fmt.printf("&x, len:%d\n", s, len(s))
}
```
输出：

```
test2.go 试试就知道了。
```
* 内置函数len返回字节数组长度，cap不接受字符串类型参数。

* 字符串默认值不是nil，而是`""`.
* 使用`""`定义不做转义处理的原始字符串（raw string），支持跨行。
* 编译器不会解析原始字符串内的注释语句，且前置缩进空格也属于字符串内容。

* 支持`!= == < > + +=`操作符

如
```
s := "ab" +
     "cd"        //跨行时候假发操作符必须在上一行结尾。
```

* 允许以索引号访问字节数组（非字符），但是不能获取元素地址。

如
```
func main() {
  s := "abc"

  println(s[1])
  println(&s[1])                             //error: cannot take the address of s[1]
}
```

* 以切片语法（其实和结束索引号）返回子串时，其内部依旧只想原字节数组。

* 使用for遍历字符串时，分byte和rune两种方法。rune：返回数组索引号以及Unicode字符。

### 转换

* 要修改字符串，需要将其转换为可变类型 rune byte ，待完成后再转换回来，但是不管如何转换都需要重新分配内存，并复制数据。






























## 4.1 Array
和以往认知的数组有很大不同。
* ``数组是值类型，赋值和传参会复制整个数组，而不是指针。``
* ``数组⻓长度必须是常量，且是类型的组成部分。[2]int 和 [3]int 是不同类型。``
* ``支持 "=="、"!=" 操作符，因为内存总是被初始化过的。``
* ``指针数组 [n]*T，数组指针 *[n]T。``

* 可用复合语句初始化。

```
a := [3]int{1, 2}                        // 未初始化元素值为 0。
b := [...]int{1, 2, 3, 4}                // 通过初始化值确定数组长度。
c := [5]int{2: 100, 4:200}               // 使用索引号初始化元素。

d := [...]struct {
    name string
    age uint8
}{
    {"user1", 10},                     // 可省略元素类型。
    {"user2", 20},                     // 别忘了最后一行的逗号。
}
```


* 支持多维数组。

```
a := [2][3]int{{1, 2, 3}, {4, 5, 6}}
b := [...][2]int{{1, 1}, {2, 2}, {3, 3}}         // 第 2 纬度不能用 "..."。

```

* 值拷贝行为会造成性能问题，通常会建议使用 slice，或数组指针。

```
func test(x [2]int) {
    fmt.Printf("x: %p\n", &x)
    x[1] = 1000
}

func main() {
    a := [2]int{}
    fmt.Printf("a: %p\n", &a)
    test(a)
    fmt.Println(a)
}
```

输出：

```
a: 0x2101f9150
x: 0x2101f9170
[0 0]
```


* 内置函数 len 和 cap 都返回数组长度 (元素数量)。

```
a := [2]int{}
println(len(a), cap(a)) // 2, 2

```

## 4.2 Slice
* 需要说明，slice 并不是数组或数组指针。它通过内部指针和相关属性引用数组片段，以实现变长方案。


<b>runtime.h
```
struct Slice
{                                // must not move anything
    byte* array;                 // actual data
    uintgo len;                  // number of elements
    uintgo cap;                  // allocated number of elements
};
```

* 引用类型。但自身是结构体，值拷贝传递。
* 属性 len 表⽰示可用元素数量，读写操作不能超过该限制。
* 属性 cap 表⽰示最大扩张容量，不能超出数组限制。
* 如果 slice == nil，那么 len、cap 结果都等于 0。

```
data := [...]int{0, 1, 2, 3, 4, 5, 6}
slice := data[1:4:5]                              // [low : high : max]
```

```
          +- low    high-+    +- max                        len = high - low
          |              |    |                             cap = max - low
     +----+----+----+----+----+----+----+             +---------+---------+---------+
data | 0  | 1  | 2  | 3  | 4  | 5  | 6  |       slice | pointer | len = 3 | cap = 4 |
     +----+----+----+----+----+----+----+             +---------+---------+---------+
          |<--- len ---->|    |                              |
          |                   |                              |
          |<----- cap ------->|                              |
          |                                                  |
          +-------<<<-------- slice.array pointer ---<<<-----+
```
* 创建表达式使用的是元素索引号，而非数量。

```
data := [...]int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
expression             slice            len      cap    comment
------------+-------------------------+---------+---------+---------------------
data[:6:8]       [0 1 2 3 4 5]            6       8        省略low.
data[5:]         [5 6 7 8 9]              5       5        省略high、max。
data[:3]         [0 1 2]                  3      10        省略low、max。
data[:]          [0 1 2 3 4 5 6 7 8 9]    10     10        全部省略。

```

* 读写操作实际目标是底层数组，只需注意索引号的差别。

```
data := [...]int{0, 1, 2, 3, 4, 5}

s := data[2:4]
s[0] += 100
s[1] += 200

fmt.Println(s)
fmt.Println(data)
```

输出：

```
[102 203]
[0 1 102 203 4 5]
```

* 可直接创建 slice 对象，自动分配底层数组。

```
s1 := []int{0, 1, 2, 3, 8: 100}                // 通过初始化表达式构造，可使用索引号。
fmt.Println(s1, len(s1), cap(s1))
s2 := make([]int, 6, 8)                       // 使用 make 创建，指定 len 和 cap 值。
fmt.Println(s2, len(s2), cap(s2))
s3 := make([]int, 6)                          // 省略 cap，相当于 cap = len。
fmt.Println(s3, len(s3), cap(s3))
```
输出：

```
[0 1 2 3 0 0 0 0 100] 9 9
[0 0 0 0 0 0]         6 8
[0 0 0 0 0 0]         6 6
```

* 使用 make 动态创建 slice，避免了数组必须用常量做长度的麻烦。还可用指针直接访问底层数组，退化成普通数组操作。

```
s := []int{0, 1, 2, 3}

p := &s[2]                        // *int, 获取底层数组元素指针。
*p += 100

fmt.Println(s)
```

输出：

```
[0 1 102 3]
```


* 至于 [][]T，是指元素类型为 []T 。

```
data := [][]int{
    []int{1, 2, 3},
    []int{100, 200},
    []int{11, 22, 33, 44},
}
```

* 可直接修改 struct array/slice 成员。

```
d := [5]struct {
    x int
}{}

s := d[:]

d[1].x = 10
s[2].x = 20

fmt.Println(d)
fmt.Printf("%p, %p\n", &d, &d[0])
```

输出:

```
[{0} {10} {20} {0} {0}]
0x20819c180, 0x20819c180
```

### 4.2.1 reslice

* 所谓 reslice，是基于已有 slice 创建新 slice 对象，以便在 cap 允许范围内调整属性。

```
s := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
s1 := s[2:5] // [2 3 4]
s2 := s1[2:6:7] // [4 5 6 7]
s3 := s2[3:6] // Error
```

```
     +---+---+---+---+---+---+---+---+---+---+
data | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
     +---+---+---+---+---+---+---+---+---+---+
     0   2               5
             +---+---+---+---+---+---+---+---+
s1           | 2 | 3 | 4 |   |   |   |   |   | len = 3, cap = 8
             +---+---+---+---+---+---+---+---+
             0       2               6   7
                     +---+---+---+---+---+
s2                   | 4 | 5 | 6 | 7 |   |     len = 4, cap = 5
                     +---+---+---+---+---+
                     0           3   4   5
                                 +---+---+---+
s3                               | 7 | 8 | X | error: slice bounds out of range
                                 +---+---+---+

```
* 新对象依旧指向原底层数组。

```
s := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}

s1 := s[2:5]                        // [2 3 4]
s1[2] = 100

s2 := s1[2:6]                      // [100 5 6 7]
s2[3] = 200

fmt.Println(s)
```

输出：

```
[0 1 2 3 100 5 6 200 8 9]
```

### 4.2.2 append

* 向 slice 尾部添加数据，返回新的 slice 对象。

```
s := make([]int, 0, 5)
fmt.Printf("%p\n", &s)

s2 := append(s, 1)
fmt.Printf("%p\n", &s2)

fmt.Println(s, s2)
```

输出：

```
0x210230000
0x210230040
[] [1]
```

* 简单点说，就是在 array[slice.high] 写数据。

```
data := [...]int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}

s := data[:3]
s2 := append(s, 100, 200)                 // 添加多个值。

fmt.Println(data)
fmt.Println(s)
fmt.Println(s2)
```

输出：

```
[0 1 2 100 200 5 6 7 8 9]
[0 1 2]
[0 1 2 100 200]
```

* 一旦超出原 slice.cap 限制，就会重新分配底层数组，即便原数组并未填满。

```
data := [...]int{0, 1, 2, 3, 4, 10: 0}
s := data[:2:3]

s = append(s, 100, 200)                     // 一次 append 两个值，超出 s.cap 限制。

fmt.Println(s, data)                       // 重新分配底层数组，与原数组无关。
fmt.Println(&s[0], &data[0])               // 比对底层数组起始指针。
```

输出：

```
[0 1 100 200] [0 1 2 3 4 0 0 0 0 0 0]
0x20819c180 0x20817c0c0
```

* 从输出结果可以看出，append 后的 s 重新分配了底层数组，并复制数据。如果只追加一个值，则不会超过 s.cap 限制，也就不会重新分配。
* 通常以 2 倍容量重新分配底层数组。在大批量添加数据时，建议一次性分配足够大的空间，以减少内存分配和数据复制开销。或初始化足够长的 len 属性，改用索引号进行操作。及时释放不再使用的 slice 对象，避免持有过期数组，造成 GC 无法回收。

```
s := make([]int, 0, 1)
c := cap(s)

for i := 0; i < 50; i++ {
    s = append(s, i)
    if n := cap(s); n > c {
    fmt.Printf("cap: %d -> %d\n", c, n)
    c = n
    }
}
```

输出:

```
cap: 1 -> 2
cap: 2 -> 4
cap: 4 -> 8
cap: 8 -> 16
cap: 16 -> 32
cap: 32 -> 64
```
### 4.2.3 copy
* 函数 copy 在两个 slice 间复制数据，复制长度以 len 小的为准。两个 slice 可指向同一底层数组，允许元素区间重叠。

```
data := [...]int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}

s := data[8:]
s2 := data[:5]

copy(s2, s)                               // dst:s2, src:s

fmt.Println(s2)
fmt.Println(data)
```

输出：

```
[8 9 2 3 4]
[8 9 2 3 4 5 6 7 8 9]
```

* 应及时将所需数据 copy 到较小的 slice，以便释放超大号底层数组内存。

## 4.3 Map

* 引用类型，哈希表。键必须是⽀支持相等运算符 (==、!=) 类型，比如 number、string、pointer、array、struct，以及对应的 interface。值可以是任意类型，没有限制。

```
m := map[int]struct {
    name string
    age int
}{
    1: {"user1", 10},                    // 可省略元素类型。
    2: {"user2", 20},
}

println(m[1].name)
```

* 预先给 make 函数一个合理元素数量参数，有助于提升性能。因为事先申请一大块内存，可避免后续操作时频繁扩张。

```
m := make(map[string]int, 1000)
```

常见操作：

```
m := map[string]int{
    "a": 1,
}

if v, ok := m["a"]; ok {                                // 判断 key 是否存在。
    println(v)
}
    println(m["c"])                                    // 对于不存在的 key，直接返回 \0，不会出错。

    m["b"] = 2                                        // 新增或修改。

    delete(m, "c")                                    // 删除。如果 key 不存在，不会出错。

    println(len(m))                                  // 获取键值对数量。cap 无效。

    for k, v := range m {                            // 迭代，可仅返回 key。随机顺序返回，每次都不相同。

    println(k, v)
}
```

* 不能保证迭代返回次序，通常是随机结果，具体和版本实现有关。从 map 中取回的是一个 value 临时复制品，对其成员的修改是没有任何意义的。

```
type user struct{ name string }
    m := map[int]user{                 // 当 map 因扩张而重新哈希时，各键值项存储位置都会发生改变。 因此，map
    1: {"user1"},                     // 被设计成 not addressable。 类似 m[1].name 这种期望透过原 value
}                                    // 指针修改成员的行为自然会被禁止。

m[1].name = "Tom"                  // Error: cannot assign to m[1].name
```


正确做法是完整替换 value 或使用指针。

```
u := m[1]
u.name = "Tom"
m[1] = u // 替换 value。

m2 := map[int]*user{
    1: &user{"user1"},
}
m2[1].name = "Jack" // 返回的是指针复制品。透过指针修改原对象是允许的。可以在迭代时安全删除键值。但如果期间有新增操作，那么就不知道会有什么意外了。

for i := 0; i < 5; i++ {
m := map[int]string{
    0: "a", 1: "a", 2: "a", 3: "a", 4: "a",
    5: "a", 6: "a", 7: "a", 8: "a", 9: "a",
}

for k := range m {
    m[k+k] = "x"
    delete(m, k)
}

fmt.Println(m)
}

```

输出：

```
map[12:x 16:x 2:x 6:x 10:x 14:x 18:x]
map[12:x 16:x 20:x 28:x 36:x]
map[12:x 16:x 2:x 6:x 10:x 14:x 18:x]
map[12:x 16:x 2:x 6:x 10:x 14:x 18:x]
map[12:x 16:x 20:x 28:x 36:x]
```

## 4.4 Struct
* 值类型，赋值和传参会复制全部内容。可用 `_` 定义补位字段，支持指向自身类型的指针成员。

```
type Node struct {
    _ int
    id int
    data *byte
    next *Node
}

func main() {
    n1 := Node{
    id: 1,
    data: nil,
  }

n2 := Node{
    id: 2,
    data: nil,
    next: &n1,
  }
}
```


* 顺序初始化必须包含全部字段，否则会出错。

```
type User struct {
    name string
    age int
}

u1 := User{"Tom", 20}
u2 := User{"Tom"} // Error: too few values in struct initializer
```


* 支持匿名结构，可用作结构成员或定义变量。

```
type File struct {
    name string
    size int
attr struct {
    perm int
    owner int
  }
}

f := File{
name: "test.txt",
size: 1025,
               // attr: {0755, 1}, // Error: missing type in composite literal
}
f.attr.owner = 1
f.attr.perm = 0755

var attr = struct {
    perm int
    owner int
}{2, 0755}

f.attr = attr

```


* 支持 "=="、"!=" 相等操作符，可用作 map 键类型。

```
type User struct {
    id int
    name string
}

m := map[User]int{
    User{1, "Tom"}: 100,
}
```


* 可定义字段标签，用反射读取。标签是类型的组成部分。

```
var u1 struct { name string "username" }
var u2 struct { name string }
u2 = u1                    // Error: cannot use u1 (type struct { name string "username" }) as
                          // type struct { name string } in assignment
```

* 空结构 "节省" 内存，比如用来实现 set 数据结构，或者实现没有 "状态" 只有方法的 "静态类"。

```
var null struct{}
set := make(map[string]struct{})
set["a"] = null
```

### 4.4.1 匿名字段


* 匿名字段不过是一种语法糖，从根本上说，就是一个与成员类型同名 (不含包名) 的字段。被匿名嵌入的可以是任何类型，当然也包括指针。

```
type User struct {
    name string
}

type Manager struct {
    User
    title string
}

m := Manager{
    User: User{"Tom"},               // 匿名字段的显式字段名，和类型名相同。
    title: "Administrator",
}
```

* 可以像普通字段那样访问匿名字段成员，编译器从外向内逐级查找所有层次的匿名字段，直到发现目标或出错。

```
type Resource struct {
  id int
}

type User struct {
    Resource
    name string
}

type Manager struct {
    User
    title string
}

var m Manager
m.id = 1
m.name = "Jack"
m.title = "Administrator"

```


* 外层同名字段会遮蔽嵌入字段成员，相同层次的同名字段也会让编译器无所适从。解决方法是使用显式字段名。

```
type Resource struct {
    id int
    name string
}

type Classify struct {
    id int
}

type User struct {
    Resource                // Resource.id 与 Classify.id 处于同一层次。
    Classify
    name string             // 遮蔽 Resource.name。
}

u := User{
    Resource{1, "people"},
    Classify{100},
    "Jack",
}

println(u.name)                // User.name: Jack
println(u.Resource.name)       // people
                              // println(u.id) // Error: ambiguous selector u.id
println(u.Classify.id)        // 100

```
* 不能同时嵌入某一类型和其指针类型，因为它们名字相同。

```
type Resource struct {
    id int
}

type User struct {
    *Resource
     // Resource // Error: duplicate field Resource
    name string
}

u := User{
    &Resource{1},
    "Administrator",
}

println(u.id)
println(u.Resource.id)
```
### 4.4.2 面向对象

* 面向对象三大特征里，Go 仅支持封装，尽管匿名字段的内存布局和行为类似继承。没有class 关键字，没有继承、多态等等。

```
type User struct {
    id   int
    name string
}

type Manager struct {
    User
    title string
}

m := Manager{User{1, "Tom"}, "Administrator"}
// var u User = m // Error: cannot use m (type Manager) as type User in assignment
// 没有继承，自然也不会有多态。
var u User = m.User // 同类型拷贝。
```
* 内存布局和 C struct 相同，没有任何附加的 object 信息。

```
  |<-------- User:24 ------->|<-- title:16 -->|
  +--------------+-----------+----------------+             +---------------+
m | 1            | string    |     string     |             | Administrator | [n]byte
  +--------------+-----------+----------------+             +---------------+
                         |            |                                    |
                         |            | +--->>>------------------->>>------+
                         |
                         +--->>>-------------------------------->>>----+
                       |                                               |
                 +--------->>>------------------------------>>>-+ |    |
                 |                                                |    |
  +-----------+-------------+                                    +---------+
u |    1      | string      |                                    | Tom     | [n]byte
  +-----------+-------------+                                    +---------+
  |<- id:8 -->|<- name:16 ->|

```
* 可用 unsafe 包相关函数输出内存地址信息。

```
m : 0x2102271b0, size: 40, align: 8
m.id : 0x2102271b0, offset: 0
m.name : 0x2102271b8, offset: 8
m.title: 0x2102271c8, offset: 24
```
