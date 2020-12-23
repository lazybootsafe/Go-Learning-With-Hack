package main

import (
	"fmt"
	"net"
)

// 服务逻辑，传入地址和退出的通道
func server(address string, exitChan chan int) {

	// 根据给定地址进行侦听
	l, err := net.Listen("tcp", address)

	// 如果侦听发生错误，打印错误并退出
	if err != nil {
		fmt.Println(err.Error())
		exitChan <- 1
	}

	// 打印侦听地址，表示侦听成功
	fmt.Println("listen: " + address)

	// 延迟关闭侦听器
	defer l.Close()

	// 侦听循环
	for {

		// 新连接没有到来时，Accept是阻塞的
		conn, err := l.Accept()

		// 发生任何的侦听错误，打印错误并退出服务器
		if err != nil {
			fmt.Println(err.Error())
			continue
		}

		// 根据连接开启会话，这个过程需要在并行执行
		go handleSession(conn, exitChan)
	}
}
