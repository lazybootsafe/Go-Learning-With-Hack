# AFL源码分析改进3——afl-as.h源码分析

这篇文章只分析64位的情况，32位大同小异，这里就不多阐述

## trampoline_fmt_64
首先看到的是`trampoline_fmt_64`  

这段汇编是在汇编器编译汇编到二进制时插入到汇编代码中的。

```
static const u8* trampoline_fmt_64 =

  "\n"
  "/* --- AFL TRAMPOLINE (64-BIT) --- */\n"
  "\n"
  ".align 4\n"
  "\n"
  "leaq -(128+24)(%%rsp), %%rsp\n"
  "movq %%rdx,  0(%%rsp)\n"
  "movq %%rcx,  8(%%rsp)\n"
  "movq %%rax, 16(%%rsp)\n"
  "movq $0x%08x, %%rcx\n"
  "call __afl_maybe_log\n"
  "movq 16(%%rsp), %%rax\n"
  "movq  8(%%rsp), %%rcx\n"
  "movq  0(%%rsp), %%rdx\n"
  "leaq (128+24)(%%rsp), %%rsp\n"
  "\n"
  "/* --- END --- */\n"
  "\n";
```

首先先在栈上开辟一段空间，然后将`rdx,rcx,rax`这三个寄存器的值保存到栈上面，将rcx的值赋值会一个随机数，这个随机数是在插入这段汇编的时候动态传进来的。

然后调用`__afl_maybe_log`，调用完之后，把栈上保存的值恢复回去，再把栈恢复

## main_payload_64
接下来看的是`main_payload_64`，这里我就先删去一些对特定系统进行的patch，因为我们只是分析功能，实现的细节不用过于关注

## `__afl_maybe_log`
首先看到的是`__afl_maybe_log`，也就是插入代码调用的部分

一开始看到两条指令是

`lahf
seto %al`
这两条指令大概就是将标志寄存器`FLAGS`，溢出进位 保存到AH上面

```
"  movq  __afl_area_ptr(%rip), %rdx\n"
"  testq %rdx, %rdx\n"
"  je    __afl_setup\n"

```
这里检查共享内存是否已经加载，如果加载了的话，`__afl_area_ptr`保存了共享内存的指针，否则就是NULL

这里默认共享内存已经加载，先看后面的部分，`__afl_setup`的部分后面再分析

## `__afl_store`
```
  "__afl_store:\n"
  "  /* Calculate and store hit for the code location specified in rcx. */\n"
  "\n"
#ifndef COVERAGE_ONLY
  "  xorq __afl_prev_loc(%rip), %rcx\n"
  "  xorq %rcx, __afl_prev_loc(%rip)\n"
  "  shrq $1, __afl_prev_loc(%rip)\n"
#endif /* ^!COVERAGE_ONLY */
  "\n"
#ifdef SKIP_COUNTS
  "  orb  $1, (%rdx, %rcx, 1)\n"
#else
  "  incb (%rdx, %rcx, 1)\n"
#endif /* ^SKIP_COUNTS */
```
这部分是计算并储存代码命中位置，当前代码的位置在寄存器`rcx`中

假如没有定义`COVERAGE_ONLY`，那么前两条`xor`，是将`__afl_prev_loc`的值与`rcx`的值进行交换

然后将`__afl_prev_loc`的值右移一下，

下面是，假如定义了`SKIP_COUNTS`，那么就会执行

`or byte ptr[rdx+rcx], 1`
如果没有定义的话，那么就会变成

`inc byte ptr[rdx+rcx]`
这里`rdx`的值存的是共享内存的地址

## `__afl_return`
```
"__afl_return:\n"
"\n"
"  addb $127, %al\n"
"  sahf\n"
"  ret\n"
```
这里首先是将` al+0x7f`，然后再把标志寄存器`FLAGS`的值从`AH`中恢复回去，这里`al+0x7f`并不太了解是什么意思，但估计也是恢复标志寄存器，溢出进位的步骤吧

注意，这里调用`afl_maybe_log`，其实是执行到`afl_return`才返回的

## `__afl_setup`

```
"  /* Do not retry setup if we had previous failures. */\n"
  "\n"
  "  cmpb $0, __afl_setup_failure(%rip)\n"
  "  jne __afl_return\n"
```
首先判断之前有没有错误，有的话，直接就返回
```
"  /* Check out if we have a global pointer on file. */\n"
  "\n"
  "  movq  __afl_global_area_ptr(%rip), %rdx\n"
  "  testq %rdx, %rdx\n"
  "  je    __afl_setup_first\n"
  "\n"
  "  movq %rdx, __afl_area_ptr(%rip)\n"
  "  jmp  __afl_store\n"
```  
第一个首先是判断我们是否有一个文件全局指针

即`__afl_global_area_ptr`是否为`NULL`

如果存在的话，就把`afl_area_ptr`的值放到`rdx`，调用`afl_store`，这里`__afl_store`就是我们上面分析过的

不存在的话，就继续到`__afl_setup_first`

## `__afl_setup_first`

```
"  /* Save everything that is not yet saved and that may be touched by\n"
"     getenv() and several other libcalls we'll be relying on. */\n"
"\n"
"  leaq -352(%rsp), %rsp\n"
"\n"
"  movq %rax,   0(%rsp)\n"
"  movq %rcx,   8(%rsp)\n"
"  movq %rdi,  16(%rsp)\n"
"  movq %rsi,  32(%rsp)\n"
"  movq %r8,   40(%rsp)\n"
"  movq %r9,   48(%rsp)\n"
"  movq %r10,  56(%rsp)\n"
"  movq %r11,  64(%rsp)\n"
"\n"
"  movq %xmm0,  96(%rsp)\n"
"  movq %xmm1,  112(%rsp)\n"
"  movq %xmm2,  128(%rsp)\n"
"  movq %xmm3,  144(%rsp)\n"
"  movq %xmm4,  160(%rsp)\n"
"  movq %xmm5,  176(%rsp)\n"
"  movq %xmm6,  192(%rsp)\n"
"  movq %xmm7,  208(%rsp)\n"
"  movq %xmm8,  224(%rsp)\n"
"  movq %xmm9,  240(%rsp)\n"
"  movq %xmm10, 256(%rsp)\n"
"  movq %xmm11, 272(%rsp)\n"
"  movq %xmm12, 288(%rsp)\n"
"  movq %xmm13, 304(%rsp)\n"
"  movq %xmm14, 320(%rsp)\n"
"  movq %xmm15, 336(%rsp)\n"
```
这段代码的意思就是将剩下所有会被`libc`库函数影响的寄存器保存到栈上面

```
"  /* Map SHM, jumping to __afl_setup_abort if something goes wrong. */\n"
"\n"
"  /* The 64-bit ABI requires 16-byte stack alignment. We'll keep the\n"
"     original stack ptr in the callee-saved r12. */\n"
"\n"
"  pushq %r12\n"
"  movq  %rsp, %r12\n"
"  subq  $16, %rsp\n"
"  andq  $0xfffffffffffffff0, %rsp\n"
```
这里是先保存`r12`，然后将栈指针保存到`r12`那里，再开一段栈空间，进行对齐
```
"  leaq .AFL_SHM_ENV(%rip), %rdi\n"
CALL_L64("getenv")
  "  testq %rax, %rax\n"
"  je    __afl_setup_abort\n"
```
这里就是调用`getenv`去拿存在环境变量中的共享内存标志符，拿不到的话，就会跳到`__afl_setup_abort`
```
"  movq  %rax, %rdi\n"
CALL_L64("atoi")
"\n"
"  xorq %rdx, %rdx   /* shmat flags    */\n"
"  xorq %rsi, %rsi   /* requested addr */\n"
"  movq %rax, %rdi   /* SHM ID         */\n"
CALL_L64("shmat")
"\n"
"  cmpq $-1, %rax\n"
"  je   __afl_setup_abort\n"
```
这里调用`atoi`将字符串转为数字，然后调用`shmat`拿到共享内存，然后判断一下`shamat`的结果，假如拿不到，也会跳到`__afl_setup_abort`
```
"  /* Store the address of the SHM region. */\n"
"\n"
"  movq %rax, %rdx\n"
"  movq %rax, __afl_area_ptr(%rip)\n"
"\n"
"  movq __afl_global_area_ptr@GOTPCREL(%rip), %rdx\n"
"  movq %rax, (%rdx)\n"
"  movq %rax, %rdx\n"
```
这里是把共享内存的地址存到`afl_area_ptr`和`afl_global_area_ptr`指向的内存

## `__afl_forkserver`
到这里就是`fork server`的逻辑
```
"__afl_forkserver:\n"
"\n"
"  /* Enter the fork server mode to avoid the overhead of execve() calls. We\n"
"     push rdx (area ptr) twice to keep stack alignment neat. */\n"
"\n"
"  pushq %rdx\n"
"  pushq %rdx\n"
  "  /* Phone home and tell the parent that we're OK. (Note that signals with\n"
"     no SA_RESTART will mess it up). If this fails, assume that the fd is\n"
"     closed because we were execve()d from an instrumented binary, or because\n"
"     the parent doesn't want to use the fork server. */\n"
"\n"
"  movq $4, %rdx               /* length    */\n"
"  leaq __afl_temp(%rip), %rsi /* data      */\n"
"  movq $" STRINGIFY((FORKSRV_FD + 1)) ", %rdi       /* file desc */\n"
CALL_L64("write")
"  cmpq $4, %rax\n"
"  jne  __afl_fork_resume\n"
```
首先是`push` 两次`rdx`来使得栈整齐一点？emmmm，这里就不管了

然后是将`__afl_temp`中的4个字节写到提前开好的管道中，这里开管道的过程在`afl-fuzz`的代码中，后面再慢慢分析

再判断下`write`的返回值，假如不为4，就会跳到`__afl_fork_resume`，这个后面到了再分析

## `__afl_fork_wait_loop`

```
"__afl_fork_wait_loop:\n"
"\n"
"  /* Wait for parent by reading from the pipe. Abort if read fails. */\n"
"\n"
"  movq $4, %rdx               /* length    */\n"
"  leaq __afl_temp(%rip), %rsi /* data      */\n"
"  movq $" STRINGIFY(FORKSRV_FD) ", %rdi             /* file desc */\n"
CALL_L64("read")
"  cmpq $4, %rax\n"
"  jne  __afl_die\n"
```
这里是不断地从管道中读取内容，假如读取到的字节数不为4就会跳到`__afl_die`

如果正常读取，就会到下面的代码
```
"  /* Once woken up, create a clone of our process. This is an excellent use\n"
"     case for syscall(__NR_clone, 0, CLONE_PARENT), but glibc boneheadedly\n"
"     caches getpid() results and offers no way to update the value, breaking\n"
"     abort(), raise(), and a bunch of other things :-( */\n"
"\n"
CALL_L64("fork")
"  cmpq $0, %rax\n"
"  jl   __afl_die\n"
"  je   __afl_fork_resume\n"
"\n"
"  /* In parent process: write PID to pipe, then wait for child. */\n"
"\n"
"  movl %eax, __afl_fork_pid(%rip)\n"
"\n"
"  movq $4, %rdx                   /* length    */\n"
"  leaq __afl_fork_pid(%rip), %rsi /* data      */\n"
"  movq $" STRINGIFY((FORKSRV_FD + 1)) ", %rdi             /* file desc */\n"
CALL_L64("write")
```
这里首先`fork`了，然后判断`fork`是否成功，如果成功，就会跳到`__afl_fork_resume`

失败的话，就会跳到`__afl_die`

之后把`fork`出来的`pid`存到`__afl_fork_pid`中，再写到与`fuzzer`通信的管道中
```
"  movq $0, %rdx                   /* no flags  */\n"
"  leaq __afl_temp(%rip), %rsi     /* status    */\n"
"  movq __afl_fork_pid(%rip), %rdi /* PID       */\n"
CALL_L64("waitpid")
"  cmpq $0, %rax\n"
"  jle  __afl_die\n"
```
这里是父进程等待子进程，如果`waitpid`返回的结果小于等于0，就会跳到`afl_die，waitpid`也会把子进程的状态写到`afl_temp`中
```
"  /* Relay wait status to pipe, then loop back. */\n"
 "\n"
 "  movq $4, %rdx               /* length    */\n"
 "  leaq __afl_temp(%rip), %rsi /* data      */\n"
 "  movq $" STRINGIFY((FORKSRV_FD + 1)) ", %rdi         /* file desc */\n"
 CALL_L64("write")
 "\n"
 "  jmp  __afl_fork_wait_loop\n"
 ```
然后把子进程的状态通过管道写回到`fuzzer`中，跳回到`__afl_fork_wait_loop`，继续等待`fuzzer`的`fork`请求

## `__afl_fork_resume`

```
"__afl_fork_resume:\n"
  "\n"
  "  /* In child process: close fds, resume execution. */\n"
  "\n"
  "  movq $" STRINGIFY(FORKSRV_FD) ", %rdi\n"
  CALL_L64("close")
  "\n"
  "  movq $" STRINGIFY((FORKSRV_FD + 1)) ", %rdi\n"
  CALL_L64("close")
  "\n"
```
这里是把两个管道给关掉
```
"  popq %rdx\n"
"  popq %rdx\n"
"\n"
"  movq %r12, %rsp\n"
"  popq %r12\n"
"\n"
"  movq  0(%rsp), %rax\n"
"  movq  8(%rsp), %rcx\n"
"  movq 16(%rsp), %rdi\n"
"  movq 32(%rsp), %rsi\n"
"  movq 40(%rsp), %r8\n"
"  movq 48(%rsp), %r9\n"
"  movq 56(%rsp), %r10\n"
"  movq 64(%rsp), %r11\n"
"\n"
"  movq  96(%rsp), %xmm0\n"
"  movq 112(%rsp), %xmm1\n"
"  movq 128(%rsp), %xmm2\n"
"  movq 144(%rsp), %xmm3\n"
"  movq 160(%rsp), %xmm4\n"
"  movq 176(%rsp), %xmm5\n"
"  movq 192(%rsp), %xmm6\n"
"  movq 208(%rsp), %xmm7\n"
"  movq 224(%rsp), %xmm8\n"
"  movq 240(%rsp), %xmm9\n"
"  movq 256(%rsp), %xmm10\n"
"  movq 272(%rsp), %xmm11\n"
"  movq 288(%rsp), %xmm12\n"
"  movq 304(%rsp), %xmm13\n"
"  movq 320(%rsp), %xmm14\n"
"  movq 336(%rsp), %xmm15\n"
"\n"
"  leaq 352(%rsp), %rsp\n"
"\n"
"  jmp  __afl_store\n"
```
然后把各种寄存器恢复，跳到`__afl_store`

## `__afl_die`

```
"__afl_die:\n"
"\n"
"  xorq %rax, %rax\n"
CALL_L64("_exit")
```
这里就是简单的`exit`

## `__afl_setup_abort`  

```
__afl_setup_abort:\n"
  "\n"
  "  /* Record setup failure so that we don't keep calling\n"
  "     shmget() / shmat() over and over again. */\n"
  "\n"
  "  incb __afl_setup_failure(%rip)\n"
  "\n"
  "  movq %r12, %rsp\n"
  "  popq %r12\n"
  "\n"
  "  movq  0(%rsp), %rax\n"
  "  movq  8(%rsp), %rcx\n"
  "  movq 16(%rsp), %rdi\n"
  "  movq 32(%rsp), %rsi\n"
  "  movq 40(%rsp), %r8\n"
  "  movq 48(%rsp), %r9\n"
  "  movq 56(%rsp), %r10\n"
  "  movq 64(%rsp), %r11\n"
  "\n"
  "  movq  96(%rsp), %xmm0\n"
  "  movq 112(%rsp), %xmm1\n"
  "  movq 128(%rsp), %xmm2\n"
  "  movq 144(%rsp), %xmm3\n"
  "  movq 160(%rsp), %xmm4\n"
  "  movq 176(%rsp), %xmm5\n"
  "  movq 192(%rsp), %xmm6\n"
  "  movq 208(%rsp), %xmm7\n"
  "  movq 224(%rsp), %xmm8\n"
  "  movq 240(%rsp), %xmm9\n"
  "  movq 256(%rsp), %xmm10\n"
  "  movq 272(%rsp), %xmm11\n"
  "  movq 288(%rsp), %xmm12\n"
  "  movq 304(%rsp), %xmm13\n"
  "  movq 320(%rsp), %xmm14\n"
  "  movq 336(%rsp), %xmm15\n"
  "\n"
  "  leaq 352(%rsp), %rsp\n"
  "\n"
  "  jmp __afl_return\n"

```
这里就是设置`__afl_setup_failure`为1，然后恢复下寄存器，直接返回

## 总结

这里大概说下被fuzz的程序运行的过程和`fork_server`的过程  

首先`afl-fuzz`这个程序会创建两个管道，然后利用`afl-gcc`或者`afl-clang`编译的程序，就会被执行  

之前在`afl-as.c`中也分析到了，main函数肯定会被插桩的，也就是肯定会调用`__afl_maybe_log`  

而对于第一次运行的进程，就会作为`fork-server`，后面的由`fork-server` fork出来的才是真正被fuzz的程序  

然后`fork-server` 不断地等待fuzzer的指令去fork子进程，用`waitpid`去拿到子进程的结束状态，写回给fuzzer  

不过这里也有个疑问，那些`read(0,xxx,xxx)`是怎么hook掉的？ 感觉应该是fuzzer改掉了，使得0是某个特定的文件吧（这里只是猜测，详细的后面再去分析下`afl-fuzz`）  
