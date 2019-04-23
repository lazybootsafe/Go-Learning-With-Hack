package main

import (
	"errors"
	"fmt"
	"time"
)

// 模拟RPC客户端的请求和接收消息封装
func RPCClient(ch chan string, req string) (string, error) {

	// 向服务器发送请求
	ch <- req

	// 等待服务器返回
	select {
	case ack := <-ch: // 接收到服务器返回数据
		return ack, nil
	case <-time.After(time.Second): // 超时
		return "", errors.New("Time out")
	}
}

// 模拟RPC服务器端接收客户端请求和回应
func RPCServer(ch chan string) {
	for {
		// 接收客户端请求
		data := <-ch

		// 打印接收到的数据
		fmt.Println("server received:", data)

		// 反馈给客户端收到
		ch <- "roger"
	}
}

func main() {

	// 创建一个无缓冲字符串通道
	ch := make(chan string)

	// 并发执行服务器逻辑
	go RPCServer(ch)

	// 客户端请求数据和接收数据
	recv, err := RPCClient(ch, "hi")
	if err != nil {
		// 发生错误打印
		fmt.Println(err)
	} else {
		// 正常接收到数据
		fmt.Println("client received", recv)
	}

}
