# Go-learning
# 2.语言详解--表达式
## 2.1 保留字
go语言仅有25个保留字（keyword），保留关键词不能用用作常量 变量 函数名以及结构字段等标识符。

```
break default func interface select
case defer go map struct
chan else goto package switch
const fallthrough if range type
continue for import return var
```
每行五个，比较好记。

## 2.2 运算符

> 硬件的方向是物理，软件的方向是数学。----窃·格拉瓦

全部运算符以及分隔符列表：

```
+ & += &= && == != ( )
- | -= |= || < <= [ ]
* ^ *= ^= <- > >= { }
/ << /= <<= ++ = := , ;
% >> %= >>= -- ! ... . :
&^ &^=
```

### 优先级

一元运算符优先级最高，二元则分成五个级别，从高到低分别是：
```
优先级        运算符                                        说明
------------+---------------------------------------------+----------------------------
high         * / & << >> & &^
             + - |? ^
             == != < <= < >=
             <-                                            channel
             &&
low          ||
```
相同优先级的二元运算符，从左往右。

### 二元运算符

* 除唯一操作外，操作数类型必须相同。如果其中一个是无显式类型声明的常量，那么该常量操作数会自动转型。
* 位移右操作数必须是无符号证书，或可以转换的无显式类型常量
* 如果是非常量位移表达式，优先将无显式类型的常量左操作数转型

### 位运算符

二进制位运算符比较特别的就是 bit clear，在其他于语言里很少见到。
```
-----------+----------------+-------+-----------------------------
AND         按位于：都为1        a&b      0101&0011 = 0001
OR          按位或 至少一个1     a|b      0101|0011 = 0111
XOR         按位异或 只有一个1   a^b      0101^0011 = 0110
NOT         按位取反 一元        ^a      ^0111 = 1000
AND NOT     按位清除 bit clear  a&^b     0110&^ 1011 = 0100
LEFT SHIFT  位左移              a<<2     0001<<3=1000
RIGHT SHIFT 位右移              a>>2     1010>>2 = 0010
```

### 自增

自增自减不再是运算符只能作为独立语句，不能用于表达式。

### 指针

内存地址是内存中每个字节单元的唯一编号，而指针则是一个实体。指针会分配内存空间，相当于一个专门用来保存内存地址的整型变量。

* 取址运算符 `&` 用于获取对象的地址
* 指针运算符 `*` 用于间接引用目标对象
* 二级指针 `**T` 如包含报名则写成 ``*package.T``

* 并非所有对象都能进行取地址操作，但变量总是能正确返回（addressable）指针运算符为左值的时候，可更新目标对象状态；
而为右值时则是为了获取目标状态。

* 指针类型支持相等运算符，但不能做加减法运行和类型转换

```
x := 1234
p := &x
p++ // Error: invalid operation: p += 1 (mismatched types *int and int)
```

* 指针没有专门指向成员的 `_>`运算符，统一使用 `.` 选择表达式

零长度（zero-size）对象的地址是否相等和具体的实现版本有关。

## 2.3 初始化

对复合对象类型（数组 切片 字典 结构体 ）变量初始化时，有一些语法限制：
* 初始化表达式必须含类型标签
* 左花括号必须在类型尾部，不能另起一行
* 多个成员初始值以逗号分隔
* 允许多行，但每行必须以逗号或者右花括号结束

```
// var a struct { x int } = { 100 } // syntax error
// var b []int = { 1, 2, 3 } // syntax error
// c := struct {x int; y string} // syntax error: unexpected semicolon or newline
// {
// }
var a = struct{ x int }{100}
var b = []int{1, 2, 3}
```

```
a := []int{
1,
2 // Error: need trailing comma before newline in composite literal
}
a := []int{
1,
2, // ok
}
b := []int{
1,
2 } // ok
```

## 2.4 流控制

### if ...else

* 可省略条件表达式括号
* 支持初始化语句，可定义代码块局部变量
* 代码块左大括号必须在条件表达式尾部
* 条件表达式必须是布尔类型

```
x := 0
// if x > 10 // Error: missing condition in if statement
// {
// }
  if n := "abc"; x > 0 { // 初始化语句未必就是定义变量，⽐比如 println("init") 也是可以的。
     println(n[2])
  } else if x < 0 { // 注意 else if 和 else 左⼤大括号位置。
     println(n[1])
  } else {
     println(n[0])
}
```
### switch

```
x := []int{1, 2, 3}
i := 2

switch i {
case x[1]:
     println("a")
  case 1, 3:
     println("b")
  default:
     println("c")
}
```
输出：
`a`

如需要继续下一分支，可使用 fallthrough，但不再判断条件。
```
x := 10
  switch x {
    case 10:
       println("a")
    fallthrough
    case 0:
       println("b")
  }
```
输出：
```
a
b
```
省略条件表达式，可当 if...else if...else 使用。
```
switch {
  case x[1] > 0:
    println("a")
  case x[1] < 0:
    println("b")
  default:
    println("c")
  }
switch i := x[2]; { // 带初始化语句
  case i > 0:
    println("a")
  case i < 0:
    println("b")
  default:
    println("c")
}
```
### for
仅有for一种循环语句，但是常用方式都能支持。
```
s := "abc"
for i, n := 0, len(s); i < n; i++ { // 常见的 for 循环，支持初始化语句。
println(s[i])
}
n := len(s)
for n > 0 { // 替代 while (n > 0) {}
println(s[n]) // 替代 for (; n > 0;) {}
n--
}
for { // 替代 while (true) {}
println(s) // 替代 for (;;) {}
}
```
