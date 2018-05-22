package main

func test(p *int) {
	go func() {
		println(p) //延长p的生命周期
	}()
}

func main() {
	x := 100
	p := &x
	test(p)
}
