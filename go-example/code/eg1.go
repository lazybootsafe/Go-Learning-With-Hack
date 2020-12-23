package main

import "fmt"

const (
	// 定义每分钟的秒数
	SecondsPerMinute = 60

	// 定义每小时的秒数
	SecondsPerHour = SecondsPerMinute * 60

	// 定义每天的秒数
	SecondsPerDay = SecondsPerHour * 24
)

// 将传入的“秒”解析为三种时间单位
func resolveTime(seconds int) (day int, hour int, minute int) {

	day = seconds / SecondsPerDay
	hour = seconds / SecondsPerHour
	minute = seconds / SecondsPerMinute

	return
}

func main() {

	// 将返回值作为打印参数
	fmt.Println(resolveTime(1000))

	// 只获取消息和分钟
	_, hour, minute := resolveTime(18000)
	fmt.Println(hour, minute)

	// 只获取天
	day, _, _ := resolveTime(90000)
	fmt.Println(day)
}
