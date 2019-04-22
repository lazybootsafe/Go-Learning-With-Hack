package main

import "fmt"

// 字典结构
type Dictionary struct {
	data map[interface{}]interface{} // 键值都为interface{}类型
}

// 根据键获取值
func (d *Dictionary) Get(key interface{}) interface{} {
	return d.data[key]
}

// 设置键值
func (d *Dictionary) Set(key interface{}, value interface{}) {

	d.data[key] = value
}

// 遍历所有的键值，如果回调返回值为false，停止遍历
func (d *Dictionary) Visit(callback func(k, v interface{}) bool) {

	if callback == nil {
		return
	}

	for k, v := range d.data {
		if !callback(k, v) {
			return
		}
	}
}

// 清空所有的数据
func (d *Dictionary) Clear() {
	d.data = make(map[interface{}]interface{})
}

// 创建一个字典
func NewDictionary() *Dictionary {
	d := &Dictionary{}

	// 初始化map
	d.Clear()
	return d
}

func main() {

	// 创建字典实例
	dict := NewDictionary()

	// 添加游戏数据
	dict.Set("My Factory", 60)
	dict.Set("Terra Craft", 36)
	dict.Set("Don't Hungry", 24)

	// 获取值及打印值
	favorite := dict.Get("Terra Craft")
	fmt.Println("favorite:", favorite)

	// 遍历所有的字典元素
	dict.Visit(func(key, value interface{}) bool {

		// 将值转为int类型，并判断是否大于40
		if value.(int) > 40 {

			// 输出很贵
			fmt.Println(key, "is expensive")
			return true
		}

		// 默认都是输出很便宜
		fmt.Println(key, "is cheap")

		return true
	})
}
