# AFL源码分析改进1——afl-gcc.c源码分析

想写一个fuzz框架，所以先来读一下著名的fuzz框架AFL的源码  

首先看下main函数，关键的部分是下面这三行  
```
find_as(argv[0]);

edit_params(argc, argv);

execvp(cc_params[0], (char**)cc_params);
```
首先是`find as`  
as是什么东西呢？  

如果了解编译过程，那么就知道把源代码编译成二进制，主要是经过”源代码”->”汇编代码”->”二进制”这样的过程。而将汇编代码编译成为二进制的工具，即为汇编器`assembler`。Linux系统下的常用汇编器是as。  

`find_as`里面详细的过程这里就不分析了  

之后就是`edit_params`  
`cc_params = ck_alloc((argc + 128) * sizeof(u8*));`
首先是分配一块内存空间  

然后就是根据argv配置各种东西，包括环境变量的设置  

其中看到一些有趣的东西  

```
if (!strcmp(cur, "-fsanitize=address") ||
       !strcmp(cur, "-fsanitize=memory")) asan_set = 1;

   if (strstr(cur, "FORTIFY_SOURCE")) fortify_set = 1;

   cc_params[cc_par_cnt++] = cur;
```

上网查了下资料，大概就是AFL可以使用`sanitizer`去更有效的查找`memory access bugs`  

但是同时也会带来性能的下降  

最后是 `execvp`
这里可以打印一下参数  
```
gcc note.c -o www -B /home/test/afl-2.52b -g -O3 -funroll-loops -D__AFL_COMPILER=1 -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION=1

```

关键的一点就是 -B  

`-B <directory>           Add <directory> to the compiler's search paths`
大概就是汇编器的目录  

上面的`find_as`就是用来找这个的  

所以 `afl-gcc`就是gcc 的一个wraper,用来设置一下gcc的编译选项，还有就是把汇编器换成afl自己实现的一个汇编器
