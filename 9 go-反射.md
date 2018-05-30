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

* 对于匿名字段，可用多级索引（按定义顺序）直接访问。

```go
type user struct {
    name string
    age  int
}

type manager struct {
    user
    title string
}

func main()  {
    var m manager

    t := reflect.TypeOf(m)

    name, _ :=t.FieldByName("name")             //按照名称查找
    fmt.Println(name.Name, name.Type)

    age := t.FieldByIndex([]int{0, 1})           //按照多级索引查找
    fmt.Println(age.Name, age.Type)
}
```

输出：

```
name string
age  int
```

* FieldByName 不支持多级名称，如有同名遮蔽，需通过匿名字段二次获取。

* 同样的，输出方法集时，一样区分基类型和指针类型。

* 有一点和想想的不用，反射能弹指当前包或外包的非导出结构成员。

* 相对reflect来说，当前包和外包都是“外包”。

* 可用反射提取struct tag ，还能自动分解，。常用于ORM映射，或数据格式验证。

* 辅助判断方法 Implements ConvertibleTo AssignableTo,都是运行期进行动态调用和赋值所必须的。

### 9.2 值

和type获取类型信息不同value专注于对象实例数据读写。

接口变量会复制对象，且是unaddressable的，所以想修改目标对象，就必须使用指针。

```go
func main()  {
    a := 100
    va, vp :=reflect.ValueOf(a), reflect.ValueOf(&a).Elem

    fmt.Println(va.CanAddr(), va.CanSet())
    fmt.Println(vp.CanAddr(), vp.CanSet())
}

```
输出：

```
false false
true  true
```
* 就算传入指针，一样需要通过elem获取目标对象。因为被接口存储的指针本身是不能寻址和进行设置操作的。

* 不能对非导出字段直接进行设置操纵，无论是当前包还是外包。

* 可通过Interface 方法进行类型推断和转换。

* 复合类型对象设置示例；

* 接口有两种nil状态，这一直是个潜在麻烦。解决方法是用IsNil判断值是否为nil

* 也可用unsafe转换后直接判断iface.data是否为零值。

* value里的某些方法并未实现ok-idom或返回error，所以得自行判断返回的是否为Zero Value


### 9.3 方法

动态调用方法，谈不上有多麻烦。只需按In列表准备好所需参数即可。

```go
type X struct {}

func (X) Test(x, y int) (int, error) {
    return x + y, fmt.Errorf("err:%d",x+y)
}

func main()  {
    var a X

    v := reflect.ValueOf(&a)
    m := v.MethodByName("TEST")

    in := []reflect.Value{
        reflect.ValueOf(1),
        reflect.ValueOf(2),
    }

    out := m.Call(in)
    for_, v := range out {
        fmt.Println(v)
    }
}
```

输出：
```
3
err： 3
```

* 对于变参来说，用CallSlice要更方便一些。


### 9.4 构建

反射库提供了内置函数make和new的对应操作，其中最有意思的就是makefunc。可用它实现通过模板，适应不同数据类型。

```go
//通用算法函数
func add(args []reflect.Value) (results []reflect.Value) {
    if len(args) == 0 {
        return nil
    }
    var ret reflect.Value

    switch args[0].Kind() {
    case reflect.Int:
        n := 0
        for_, a := range args {
            n += int(a, Int())
        }

      ret = reflect.ValueOf(n)
    case reflect.String:
      ss := make([]string, 0, len(args))
      for_, s := range args {
          ss = append(ss, s.String())
      }

      ret = reflect.ValueOf(strings.Join(ss, ""))
    }

    results = append(results, ret)
    return
}

//将函数指针参数指向通用算法函数
func makeAdd(fptr interface())  {
    fn := reflect.ValueOf(fptr).Elem()
    v := reflect.MakeFunc(fn, Type(), add())   //zheshi guanjian
    fn.Set(v)                                  //指向通用算法函数
}

func main()  {
    var int&Add func (x, y int) int
    var strAdd func(a, b string) string

    makeAdd(&intAdd)
    makeAdd(&strAdd)

    println(intAdd(100, 200))
    println(strAdd("hello,"," world!"))
}
```

输出：

```
300
hello， world！
```
