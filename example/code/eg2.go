package main

import "fmt"

// 用于测试值传递效果的结构体
type Data struct {
	complax []int // 测试切片在参数传递中的效果

	instance InnerData // 实例分配的innerData

	ptr *InnerData // 将ptr声明为InnerData的指针类型
}

// 代表各种结构体字段
type InnerData struct {
	a int
}

// 值传递测试函数
func passByValue(inFunc Data) Data {

	// 输出参数的成员情况
	fmt.Printf("inFunc value: %+v\n", inFunc)

	// 打印inFunc的指针
	fmt.Printf("inFunc ptr: %p\n", &inFunc)

	return inFunc
}

func main() {

	// 准备传入函数的结构
	in := Data{
		complax: []int{1, 2, 3},
		instance: InnerData{
			5,
		},

		ptr: &InnerData{1},
	}

	// 输入结构的成员情况
	fmt.Printf("in value: %+v\n", in)

	// 输入结构的指针地址
	fmt.Printf("in ptr: %p\n", &in)

	// 传入结构体，返回同类型的结构体
	out := passByValue(in)

	// 输出结构的成员情况
	fmt.Printf("out value: %+v\n", out)

	// 输出结构的指针地址
	fmt.Printf("out ptr: %p\n", &out)
}
