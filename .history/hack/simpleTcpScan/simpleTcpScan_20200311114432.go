package main

import (
	"fmt"
	"net"
	"os"
	"strconv"
	"time"
)

func main() {
	// 使用
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "Using: %s ip-addr\n", os.Args[0])
		os.Exit(1)
	}

	target := os.Args[1]

	activeThreads := 0
	doneChannel := make(chan bool)

	for port := 0; port <= 65534; port++ {
		go testTCPConnection(target, port, doneChannel)
		activeThreads++
	}
	// 等待所有线程结束
	for activeThreads > 0 {
		<-doneChannel
		activeThreads--
	}
}

func testTCPConnection(ip string, port int, doneChannel chan bool) {
	_, err := net.DialTimeout("tcp", ip+":"+strconv.Itoa(port),
		time.Second*10)
	if err == nil {
		fmt.Printf("Port %d: Open\n", port)
	}
	doneChannel <- true
}
