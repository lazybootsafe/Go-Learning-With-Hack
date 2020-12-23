package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

func main() {
	client := &http.Client{}

	// 创建一个http请求
	req, err := http.NewRequest("POST", "http://evilxyz.xyz/", strings.NewReader("key=value"))

	// 发现错误就打印并退出
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
		return
	}

	// 为标头添加信息
	req.Header.Add("User-Agent", "myClient")

	// 开始请求
	resp, err := client.Do(req)

	// 处理请求的错误
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
		return
	}

	data, err := ioutil.ReadAll(resp.Body)
	fmt.Println(string(data))

	defer resp.Body.Close()

}
