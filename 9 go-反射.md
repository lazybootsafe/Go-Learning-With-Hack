# Go-learning
# 9.语言详解--反射

## 9.1 类型

* 反射（reflect）让我们能在运行期弹指对象的类型信息和内存结构，弥补了静态语言上的不足。
* 反射还是实现元编程的重要手段。

* 和C数据结构一样的，GO对象头部并没有类型指针，通过其自身是无法在运行期获知任何类型相关的信息的。反射操作所需要的全部信息都源自接口变量。
* 接口变量除存储自身类型外， 还会保存实际对象的类型数据。

```go
func TypeOf(i interface{}) Type
func ValueOf(i interface{}) Value
```

* 这两个反射入口函数，会将任何传入的对象转换为接口类型。

* 在面对类型时，需要区分type和kind。前者辨识真是类型（静态类型），后者表示其基础结构（底层类型）区别。

```go
type x int

func main() {
   var a X = 100
   t := reflect.TypeOf(a)

   fmt.Println(t.Name(), t.kind())
}
```

* 输出：

```go
x int
```

* 所以在类型判断上，需选择正确的方式。

```go
type X int
type Y int

func main()  {
    var a, b x = 100, 200
    var c    y = 300

    ta, tb, tc := reflect.TypeOf(a), reflect.TypeOf(b), reflect.TypeOf(c)

    fmt.Println(ta == tb, ta == tc)
    fmt.Println(ta.kind() == tc.kind())
}


```
* 输出：

```go
true false
true
```

* 除通过实际对象获取类型外，也可直接构造一些基础符合类型。

```go
func main()  {
    a := reflect.ArrayOf(10, reflect.TypeOf(byte(0)))
    m := reflect.MapOf(reflect.TypeOf(""), reflect.TypeOf(0))

    fmt.Println(a, m)
}
```

输出：

```
[10]uint8 map[string]int
```

* 传入对象应区分基类型和指针类型，因为他们并不属于同一类型。

```go
func main()  {
    x := 10

    tx, tp := reflect.TypeOf(x), reflect.TypeOf(&x)

    fmt.println(tx, tp, tx ==tp)
    fmt.Println(tx.kind(), tp.kind())
    fmt.Println(tx == tp.Elem())
}
```


输出：

```go

int *int false
int ptr
true
```

* 方法Elem返回指针，数据，切片，字典或通道的基类型。

```go
func main()  {
    fmt.Println(reflect.TypeOf(map[string]int()).Elem())
    fmt.Println(reflect.TypeOf([]int32{}).Elem())
}
```

输出：

```
int
int32
```

* 只有在获取结构体指针的基类型后，才能遍历它的字段。

```go
type user struct {
    name string
    age  int
}

type manger struct {
    user
    title string
}

func main()  {
    var m manager
    t := reflect.TypeOf(&m)

    if t.kind() ==reflect.Ptr {
        t =t.Elem
    }

    for i := 0; i < t.NumField();i++ {
      f := t.Fiedle(i)
      fmt.Println(f.Name, f.Type, f.Offset)

      if f.Annoymous {
          for x := 0;x < f.Type.NumField();x++ {
              af := f.Type.Field(x)
              fmt.Println(" ", af.Name, af.Type)
          }
      }
    }
}
```

输出：

```
user main.user 0
   name string
   age  int
title string 24
```
