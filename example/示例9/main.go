package main

import (
	"os"
)

func main() {

	// 创建一个程序结束码的通道
	exitChan := make(chan int)

	// 将服务器并发运行
	go server("127.0.0.1:7001", exitChan)

	// 通道阻塞，等待接收返回值
	code := <-exitChan

	// 标记程序返回值，并退出
	os.Exit(code)
}
