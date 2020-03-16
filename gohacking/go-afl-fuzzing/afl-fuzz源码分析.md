## AFL afl_fuzz.c 详细分析
### 0.前言

### 1.环境准备

#### 1.1第一个while循环
`while ((opt = getopt())`
获取各种环境的设置，选项参数等等
各种模式 参数选项


#### 1.2 usage
`usage(argv[0])`
显示使用提示


#### 1.3 setup_shm
``void setup_shm(unsigned char dumb_mode)``
设置共享内存块


#### 1.4 setup_signal_handlers
``static void setup_signal_handlers(void)``


设置信号句柄


#### 1.5 检查ASAN选项 check_asan_opts
``static void check_asan_opts(void)``
Address Sanitizer（ASan）是一个快速的内存错误检测工具


#### 1.6 一系列检查选项
检查输入输出路径是否一致``strcmp(in_dir, out_dir)；``
获取临时输入路径``tmp_dir = getenv("AFL_TMPDIR")；``
检查是否为dumb_mode模式，以及crash_mode和qemu_mode是否联动设置了


#### 1.7 变量设置
接下来一大串设置参数，获取命令行等内容。


#### 1.8 save_cmdline
``static void save_cmdline(u32 argc, char** argv)``
保存命令行参数
影响全局变量orig_cmdline指针变量指向某个函数


#### 1.9 fix_up_banner
``static void fix_up_banner(u8* name)``
修剪并且创建一个运行横幅


#### 1.10 check_if_tty()
``static void check_if_tty(void)``
检查是否在TTy终端上面运行。影响``not_on_tty``。


#### 1.11 参数设置
对于较慢的应用，使用较少的校准周期。影响参数``cal_cycles、cal_cycles_long``
检查是否为AFL_PYTHON_ONLY， 设置参数python_only，skip_deterministic用以跳过确定性步骤和不继续havoc/splice


#### 1.12 一系列CPU检查相关的函数
``static void get_core_count(void)get_core_count()`` 获取核心数量
``HAVE_AFFINITYstatic void bind_to_free_cpu(void)``构建绑定到特定核心的进程列表。如果什么也找不到，返回-1。假设一个4k cpu的上限
``check_crash_handling()``确保核心转储不会进入程序
``check_cpu_governor();``检查CPU管理者


#### 1.13 加载后处理器
``static void setup_post(void)`` 加载后处理器，如果可用的话


#### 1.14 setup_sharemem 设置共享内存块
``void setup_shm(unsigned char dumb_mode)`` 影响参数``g_shm_file_path，g_shm_fd，g_shm_base，trace_bits
trace_bits``参数就是在这里设置并初始化置零的。


#### 1.15 setup_dirs_fds 设置输出目录和文件描述符
``EXP_ST void setup_dirs_fds(void)``影响``sync_id``


#### 1.16 init_py
``init_py()``初始化python模块


#### 1.17 设置命令文件
``static void setup_cmdline_file(char** argv)``设置命令行文件。


#### 1.18 read_testcases 读取测试文件
``static void read_testcases(void)``描述：从输入目录中读取所有测试用例，然后对它们进行排队测试。在启动时被调用


函数作用：将in_dir目录下的测试用例扫描到queue中，并且区分该文件是否为经过确定性变异的input，如果是的话跳过，以节省时间
其中，调用函数1.19add_to_queue 将测试用例排成queue队列。


参数queued_at_start 初始化的input总数；queued_paths 已经排列的测试用例的总数；


#### 1.19 add_to_queue 添加到测试用例队列


``static void add_to_queue(u8* fname, u32 len, u8 passed_det)``
将新的测试用例插入队列，并初始化fname文件名称，增加cur_depth深度++ queued_paths测试用例数量++，pending_not_fuzzed没被fuzzed测试用例数量++，更新``last_path_time = get_cur_time()``

```
struct queue_entry {
u8* fname;        /* File name for the test case    文件名  */
u32 len;          /* Input length                   testcase大小 */

u8  cal_failed,   /* Calibration failed?    校准失败？          */
    trim_done,    /* Trimmed?              该testcase是否被修剪过      */
    was_fuzzed,   /* historical, but needed for MOpt  */
    passed_det,   /* Deterministic stages passed?     */
    has_new_cov,  /* Triggers new coverage?           */
    var_behavior, /* Variable behavior?               */
    favored,      /* Currently favored?          当前是否被标记位favored(更多的fuzz机会)*/
    fs_redundant; /* Marked as redundant in the fs?   */

u32 bitmap_size,  /* Number of bits set in bitmap     bitmap中bit的数量*/
    fuzz_level,   /* Number of fuzzing iterations     */
    exec_cksum;   /* Checksum of the execution trace  trace_bits的checksum*/

u64 exec_us,      /* Execution time (us)              执行时间延迟*/
    handicap,     /* Number of queue cycles behind    */
    n_fuzz,       /* Number of fuzz, does not overflow */
    depth;        /* Path depth                       路径深度*/

u8* trace_mini;   /* Trace bytes, if kept  1个bit存一个byte的trace_mini     */
u32 tc_ref;       /* Trace bytes ref count  top_rate[]中该testcase入选的次数 */

struct queue_entry *next,  /* Next element, if any             */
                   *next_100;  /* 100 elements ahead    */
};


```

#### 1.20 load_auto自动生成附加负载
`static void load_auto(void)``该函数有点不太明白，可能是将一些自己定义的规则token添加extra_data数组中。结构体如下：


调用函数1.21maybe_add_auto将testcase添加到数组中


#### 1.21 maybe_add_auto 添加token的函数

```static void maybe_add_auto(u8* mem, u32 len)```

作用：该函数会将传入的token添加到数组中，如果数组还有空间则，添加进来。没有的话那就在数组的下半部分随机删除一个token，然后将新的添加进来。数组最大MAX_AUTO_EXTRAS 50x10=500个。影响以下队列extra[]结构体变量，a_extras_cnt 当前token总数量++（添加成功的话）。

```
struct extra_data {
  u8* data;     /* Dictionary token data    */
  u32 len;      /* Dictionary token length  */
  u32 hit_cnt;  /* Use count in the corpus  */
};
```

#### 1.22 pivot_inputs

`static void pivot_inputs(void)`在输出目录中为输入测试用例创建硬链接，选择好名称并相应地旋转。
使用函数link_or_copy重新命名并且拷贝；使用函数`mark_as_det_done`为已经经过确定性变异（deterministic）阶段的testcase文件放入deterministic_done文件夹。这样经过deterministic的testcase就不用浪费时间进行重复。


#### 1.23 load_extras 依然是加载token

`static void load_extras(u8* dir)`从extras目录中读取extras并按大小排序
作用：如果有token的目录，则将目录下的token加载到extra队列中。
其中函数load_extras_file从文件中加载extra_file并且排序，将token添加到extra数组中
影响参数和1.20load_auto差不多。


#### 1.24 find_timeout 超时函数
`static void find_timeout(void)`如果有-t的设置了自己的超时，那么会触发这个函数。


#### 1.25 setup_stdio_file 设置文件输出目录
前面同样也有一系列判断输出路径。
`EXP_ST void setup_stdio_file(void)`如果没有使用-f，则为fuzzed data设置输出目录。


#### 1.26 check_binary 检查二进制文件
`void check_binary(u8* fname)` 搜索路径，找到目标二进制文件，检查文件是否存在，是否为shell脚本，同时检查ELF头以及程序是否被插桩。

### 2 开始第一遍fuzz--dry run

#### 2.1 检查

用`start_time=get_cur_time() `获取开始时间；
检查是不是QEMU_MODE


#### 2.2 ★★`perform_dry_run`

AFL关键函数：`static void perform_dry_run(char** argv)`
作用：执行input文件夹下的预先准备的所有`testcase（perform_dry_run）`，生成初始化的queue和bitmap。这只对初始输入执行一次，所以叫：dry run。

第一个是个while循环，遍历之前生成的input_queue 也就是queue链表。该while(q) loop 的前面，准备工作：从队列中取出q->fname 读取该文件q->len 大小到use_mem 中，关闭fd
接着调用calibrate_case函数对该case进行校准。该函数内调用方式`res = calibrate_case(argv, q, use_mem, 0, 1);`
根据校准的返回值res ，查看是哪种错误并进行判断。一共有一下几种错误类型。
```
enum {
/* 00 */ FAULT_NONE,
/* 01 */ FAULT_TMOUT,
/* 02 */ FAULT_CRASH,
/* 03 */ FAULT_ERROR,
/* 04 */ FAULT_NOINST,
/* 05 */ FAULT_NOBITS  };
打印一些错误信息，退出函数
```

#### 2.3 ★★calibratecase 校准testcase

AFL关键函数:`calibrate_case(char** argv, struct queue_entry* q, u8* use_mem,u32 handicap, u8 from_queue)`校准一个新的测试用例。这是在处理输入目录时完成的，以便在早期就警告有问题的测试用例;当发现新的路径来检测变量行为等等。
这个函数是AFL的重点函数之一，在`perform_dry_run，save_if_interesting，fuzz_one，pilot_fuzzing,core_fuzzing`函数中均有调用。


步骤：

进行一系列参数设置，包括当前阶段`stage_cur`，阶段名称`stage_name`，新比特`new_bit`等初始化设置。
最后一个参数`from_queue`，判断是否是为队列中的||刚恢复fuzz 以此设置较长的时间延迟。testcase参数`q->cal_failed++` 是否校准失败参数++
判断是否已经启动forkserver ,调用函数`init_forkserver()`启动fork服务。如果是第一次接触linux
中fork()函数，不妨看一下 `https://www.cnblogs.com/dongguolei/p/8086346.html` 该函数的理解，`init_forkserver()`的详细内容见2.4
拷贝`trace_bits`到`first_trace`,并获取开始时间`start_us`；
-loop- 该loop循环多次执行这个testcase，循环的次数 8次或者3次，取决于是否快速校准。对同一个初始testcase多次运行的意义可能是，觉得有些targetApp执行同一个testcase可能也会出现不同的路径（这是我的猜测）
`static void write_to_testcase(void* mem, u32 len)` 将修改后的数据写入文件进行测试。如果use_stdin被清除了，那么取消旧文件链接并创建一个新文件。否则，prog_in_fd将被缩短。将testcase写入到文件中去。该函数较简单，不做单独解释。
run_target详细内容见2.5 主要作用是通知forkserver可以开始fork并且fuzz了。
`cksum = hash32(trace_bits, MAP_SIZE, HASH_CONST)`校验此次运行的`trace_bits`，检查是否出现新的情况。hash32函数较为简单，不多做分析。
这段代码的主要意思是先用cksum也就是本次运行的出现`trace_bits`哈希和本次`testcase q->exec_cksum`对比。如果发现不同，则调用`has_new_bits`函数(见2.6)和我们的总表virgin_bits 对比。
判断`q->exec_cksum` 是否为0，不为0那说明不是第一次执行。后面运行的时候如果，和前面第一次`trace_bits`结果不同，则需要多运行几次。这里把校准次数设为40...
-loop-end-
接着收集一些关于这个测试用例性能的统计数据。比如执行时间延迟，校准错误？，bitmap大小等等。
`update_bitmap_score(q) 2.7` 对这个测试用例的每一个byte进行排序，用一个top_rate[]来维护它的最佳入口。维护完成之后，我们这个函数在
如果这种情况没有从检测中得到new_bit，则告诉父程序。这是一个无关紧要的问题，但是需要提醒用户注意。
总结：calibratecase函数到此为止，该函数主要用途是`init_forkserver`；将testcase运行多次；用update_bitmap_score进行初始的byte排序。


#### 2.4 ★★ init_forkserver()

`static void init_forkserver(char **argv)`启动APP和它的forkserver；

```c
//检查输入输出管道是否存在。
if (pipe(st_pipe) || pipe(ctl_pipe)) PFATAL("pipe() failed");
//pid=0的话就是fork出来的子进程；！=0的话就是父进程 ,＜0就是fork失败了
forksrv_pid = fork();
//fork失败就打印关键词弹出失败并退出  （这里是在干什么？）
if (forksrv_pid < 0) PFATAL("fork() failed");
//如果是子进程的话，就执行下面的：
if (!forksrv_pid) {
  struct rlimit r;
  //dup2函数：复制一个文件的描述符。它们经常用来重定向进程的stdin、stdout和stderr
  if (dup2(use_stdin ? prog_in_fd : dev_null_fd, 0) < 0 ||
      dup2(dev_null_fd, 1) < 0 ||
      dup2(dev_null_fd, 2) < 0) {
    *(u32*)trace_bits = EXEC_FAIL_SIG;
    PFATAL("dup2() failed");
  }
  close(dev_null_fd);
  close(prog_in_fd);
 //该函数用于创建一个守护进程。在这个程序里面意思就是让该进程成为这个进程组的组长。
  setsid();
  ....
//如果成功，执行execv用以开始执行程序，这个函数除非出错不然不会返回。
 execv(target_path, argv);
//此处使用一个EXEC_FAIL_SIG 来告诉父进程执行失败。
*(u32*)trace_bits = EXEC_FAIL_SIG;
    exit(0);
}
....
//fuzzer从server中读取了四个字节的hello ，那么forkserver程序就设置成功了，如果没有，接下来的代码就是检查错误。
if (rlen == 4) {//判断读取是否成功
    OKF("All right - fork server is up.");
    return;}

```

fuzzer程序则等待forkprocess程序`waitpid(forksrv_pid, &status, 0) <= 0`函数返回。


疑问：fuzzer程序fork了一个进程，然后这个进程execv targetBinary ，targetBinary中也启动的了fork（），相当于fuzzer程序是实际被fork程序的祖祖父进程。`Fuzzer->Fuzzer forkpoc()->execv targetApp->targetApp forkpoc`。然后两个之间使用pipe进行通讯？
解答：我本来是学Windows的，以为execv()函数类似于windows中的createprocess，但实际上完全不一样。execv()函数执行之后永远不会返回(除非出错)，且运行程序会替换当前进程，pid不变。这样fuzzer先fork出来，然后再调用execv()函数，也就是说子进程成为了targetApp。这样下面的一系列代码就能说的通了。
实际流程：fuzzer(调用init_forkserver)->fork fueezer--targetApp(forkserver) call fork ->targetAppfork(实际fuzz的程序)。fuzzer还是实际fuzzer程序的祖父进程。这样接下来的代码就很容易理解了。
forkserver设计


下图可以很好的总结forkserver和被fuzzed程序之间的状态。
forkserver设计

首先alf-fuzz会创建两个管道`(init_forkserver())`，然后会去执行afl-gcc编译出来的目标程序。结合之前的分析，目标程序的main函数位置已经被插桩，程序的控制流会交到_afl_maybe_log手中。如fuzz是第一次运行，则此时的程序便成为了fuzz server，之后运行的目标程序都是由该server fork出来的子进程。fuzz进行的时候，fuzz server会一直fork子进程，并且将子进程的结束状态通过pipe传递给afl-fuzz。
这里有几点需要注意：afl在这里利用了fork()的特性(creates a new process by duplicating the calling process)来实现目标程序反复执行。实际的`fuzz server(_afl_maybe_log)`由afl事先插桩在目标程序中，在进入main函数之前，fuzz server便会fork()新的进程，进行fuzz。


### 总结：对于AFL插桩代码的分析有很多，结合着看应该很容易理解。推荐：`http://rk700.github.io/2017/12/28/afl-internals/ -AFL内部实现细节小记`。它里面对AFL插桩模块分析的很细，结合上图，理解起来就不难了。


#### 2.5 ★★ run_target() 运行程序
`static u8 run_target(char** argv, u32 timeout)`执行目标应用程序，监控超时。返回状态信息。被调用的程序将更新trace_bits[]。该函数将在每次运行targetBinary的时候调用，次数非常多。

一个需要特别提的操作是 forkserver 上线，由 init_forkserver 函数来完成，也就是运行 afl-as.h 文件 main_payload 中维护 forkserver 的分支，这样一来 run_target 函数只需关注和 forkserver 的交互即可，而不必每次都重新创建一个目标进程。

`memset(trace_bits, 0, MAP_SIZE);`在这个memset之后，trace_bits[]实际上是易失性的，因此我们必须防止任何早期操作进入该领域；此操作，在每次target执行之前，fuzzer首先将该共享内容清零。也就是说
判断是否为dumb或者forkserver是否无法开启`dumb_mode == 1 || no_forkserver`
如果在“哑”模式下运行，就不能依赖于编译到目标程序中的fork服务器逻辑，因此我们将继续调用execve()。代码类似于函数init_forkserver，不过没有pipe相关的读写操作。
如果不是dumb模式，forkserver已经开启了，因此只需要打开pid，fsrv_ctl_fd 管道用于写，fsrv_st_fd 管道用来读。
接着，无论是否dumb模式，根据用户要求配置timeout，然后等待子进程终止。SIGALRM处理程序简单地杀死child_pid并设置child_timed_out。
最后分别执行32和64位下面的函数`classify_counts()`设置tracebit所在的mem；
runtarget最后会返回fault参数

#### 2.6 ★★ has_new_bits()


`static inline u8 has_new_bits(u8* virgin_map)`

检查当前执行路径是否为表带来了新内容。更新原始位以反映发现。如果唯一更改的是特定元组的命中计数，则返回1;如果有新的元组出现，则返回2。更新映射，因此后续调用将始终返回0。
这个函数是在相当大的缓冲区上的每个exec()之后调用的，因此它需要非常快。我们以32位和64位的方式做这件事。因此它需要非常快。我们以32位和64位的方式做这件事。


#### 2.7 ★★ update_bitmap_score


`static void update_bitmap_score(struct queue_entry* q)`

当碰到一条新路径时，我们将看这条路径是否比别的存在路径更加有利。“favorables”的目的是拥有一组最小的路径集（testcase）来触发到目前为止在位图中看到的所有位，并专注于fuzz这些testcase，而牺牲了其余的。这个过程的第一步是bitmap中的每个字节维护一个top_rating[]条目列表。

（一）没有能触发这条新路径的testcase 2.竞争者有更有利的速度x大小因子，就会赢得这个位置。

（二）`update_bitmap_socre()`函数在每次run_target()之后调用，根据上述规则更新top_rate[].如果一个queue入选top_rate[]，被替换掉queue的tc_ref–, 新queue的tc_ref++，并生成简化的trace_mini。如果有发生新的queue入选top_rate[],score_changed置一，在cull_queue()时，会先判断score_changed是否为1，如果不为1，就不用进行cull_queue()了。
trace_mini的组织方式：trace_mini的大小为MAP_SIZE / 8，即每个bit对应了bit_map中的一个byte；如果这个queue访问了bit_map中的一个byte(即访问了一个edge)，trace_mini中对应的bit位就置一。

（三）首先，针对每个变迁-byte，AFL会寻找产生这个变迁的一个最佳种子，或者称为队列入口top_rate[]。所谓最佳，是指该入口的执行时间x种子长度最短。对于MAX_SIZE=64KB的共享内存，AFL使top_rated[MAX_SIZE]来记录每一个变迁的最佳种子。每当一个种子可以产生新路径，AFL就会更新top_rated，做法如下：
在给入口可以覆盖的变迁内，不妨设ID为i，比较现在种子的执行时间x种子长度是否小于原来top_rated[i]，如果小，则更新之。

### 3 主循环

#### 3.1 进入主循环之前★★cull_queue()  

`static void cull_queue(void) `精简队列，上面第二个被讨论的机制是：检查toprated[]类目，以此前未见过的byte依次争夺优胜者，然后把他们标记为favored在下次开始跑之前。根据top_rated设置queue中的favored标志。在fuzz的过程中favored 条目将会给与更多的时间。

为了优化模糊工作，AFL使用快速算法定期重新评估队列，该算法选择一个较小的测试用例子集，该子集仍覆盖到目前为止所看到的每个元组，并且其特征使它们对Fuzzing特别有利。该算法通过为每个队列条目分配与其执行延迟和文件大小成正比的分数来工作;然后为每个tuples选择最低得分候选者。
cull_queue()遍历top_rated[]中的queue，然后提取出发现新的edge的entry，并标记为favored，使得在下次遍历queue时，这些entry能获得更多执行fuzz的机会。
这里本质上采用了贪婪算法，如果top_rated[i]存在，且对应temp_v[]中对应bit位还没抹去，即这一轮选出的queue还没覆盖bit_map[i]对应的边，则取出这个top_rated[i]。抹去temp_v中top_rated[i]能访问到的位。最后将这个top_rated[i]标记为favored,如果这个queue还没fuzzed，pending_favored++.


具体步骤：

如果是dumb模式或者score_changed没有改变，也就是没有出现新的“favored”竞争者，那么函数直接返回，因为没有校准的意义。
挨个遍历bitmap中的每个byte；核心代码如下：
```c
for (i = 0; i < MAP_SIZE; i++)
   //判断每个byte的top_rated是否存在 该byte对应的temp_v是否被置为1。
 if (top_rated[i] && (temp_v[i >> 3] & (1 << (i & 7))))
 {
   u32 j = MAP_SIZE >> 3;
/* 从temp_v中，移除所有属于当前current-entry的byte，也就是这个testcase触发了多少path就给tempv标记上*/
   while (j--)
     if (top_rated[i]->trace_mini[j])
       temp_v[j] &= ~top_rated[i]->trace_mini[j];
   top_rated[i]->favored = 1;
   queued_favored++;
   if (top_rated[i]->fuzz_level == 0 || !top_rated[i]->was_fuzzed) pending_favored++;
 }

```
这里需要结合`update_bitmap_score()`进行理解。update_bitmap_score在trim_case和calibrate_case中被调用，用来维护一个最小(favored)的测试用例集合(top_rated[i])。这里会比较执行时间*种子大小，如果当前用例更小，则会更新top_rated。结合以下事例更容易理解

```

tuple t0,t1,t2,t3,t4；seed s0,s1,s2 初始化temp_v=[1,1,1,1,1]
s1可覆盖t2,t3 | s2覆盖t0,t1,t4，并且top_rated[0]=s2，top_rated[2]=s1
开始后判断temp_v[0]=1，说明t0没有被访问
top_rated[0]存在(s2) -> 判断s2可以覆盖的范围 -> trace_mini=[1,1,0,0,1]
更新temp_v=[0,0,1,1,0]
标记s2为favored
继续判断temp_v[1]=0，说明t1此时已经被访问过了，跳过
继续判断temp_v[2]=1，说明t2没有被访问
top_rated[2]存在(s1) -> 判断s1可以覆盖的范围 -> trace_mini=[0,0,1,1,0]
更新temp_v=[0,0,0,0,0]
标记s1为favored
此时所有tuple都被覆盖，favored为s1,s2
将queue中冗余的testcase进行标记 ，使用函数mark_as_redundant，位置/queue/.state/redundant_edges/中。
```

#### 3.2 进入主循环前，准备工作

`static void show_init_stats(void)`在处理输入目录的末尾显示快速统计信息，并添加一系列警告。
一些校准的东西也在这里结束了，还有一些硬编码的常量。也许最终会清理干净。

`static u32 find_start_position(void)`在恢复时，尝试找到要开始的队列位置。只有在恢复时，以及在可以找到原始fuzzer_stats时，这才有意义。

`static void write_stats_file(double bitmap_cvg, double stability, double eps)`更新一些状态稳健。

`static void save_auto(void)`自动更新token，目录`/queue/.state/autoextras/auto。`

not_on_tty？

循环开始前，调用cull_queue() 对queue进行筛选，详细见3.1

#### 3.3 主循环 while(1)

判断queue_cur是否为空，如果是，则表示已经完成对队列的遍历，初始化相关参数，重新开始遍历队列
找到queue入口的testcase，`seek_to = find_start_position()`；直接跳到该testcase
如果一整个队列循环都没新发现，尝试重组策略。
调用关键函数`fuzz_one()`对该`testcase进行fuzz。fuzz_one()`函数参见3.4。
上面的变异完成后，AFL会对文件队列的下一个进行变异处理。当队列中的全部文件都变异测试后，就完成了一个”cycle”，这个就是AFL状态栏右上角的”cycles done”。而正如cycle的意思所说，整个队列又会从第一个文件开始，再次进行变异，不过与第一次变异不同的是，这一次就不需要再进行deterministic fuzzing了。如果用户不停止AFL，那么seed文件将会一遍遍的变异下去。

#### 3.4 ★★ fuzz_one()

`static u8 fuzz_one_original(char** argv)`从队列中取出当前testcase并模糊。这个函数太长了…如果fuzzed成功，返回0;如果跳过或退出，返回1。
步骤：

根据是否有`pending_favored`和`queue_cur`的情况按照概率进行跳过；有`pending_favored`, 对于fuzz过的或者non-favored的以概率99%跳过；无`pending_favored`，95%跳过`fuzzed&non-favored`，75%跳过`not fuzzed&non-favored`，不跳过favored。
假如当前项有校准错误，并且校准错误次数小于3次，那么就用`calibrate_case`进行测试。
如果测试用例没有修剪过，那么调用函数`trim_case`对测试用例进行修剪。详见3.5
修剪完毕之后，使用`calculate_score`对每个测试用例进行打分。函数详见3.6
如果该queue已经完成deterministic阶段，则直接跳到havoc阶段
deterministic阶段变异4个stage，变异过程中会多次调用函数`common_fuzz_stuff`函数见3.8，保存interesting 的种子：
bitflip，按位翻转，1变为0，0变为1
arithmetic，整数加/减算术运算
interest，把一些特殊内容替换到原文件中
dictionary，把自动生成或用户提供的token替换/插入到原文件中

havoc，中文意思是“大破坏”，此阶段会对原文件进行大量变异。
splice，中文意思是“绞接”，此阶段会将两个文件拼接起来得到一个新的文件。详细变异策略见3.7。
该 testcase完成。

#### 3.5 ★★ trim_case()


`static u8 trim_case(char** argv, struct queue_entry* q, u8* in_buf)`在进行确定性检查时，修剪所有新的测试用例以节省周期。修剪器使用文件大小的1/16到1/1024之间的2次方增量，速度和效率的折中。


step：

首先取testcase长度2的指数倍
第一个while循环，从文件大小1/16的步长开始，慢慢到文件大小的1/1024倍步长。
第二个while循环，嵌套在第一个内，从文件头开始按步长cut testcase，然后target_run();如果删除之后对文件执行路径没有影响那么就将这个删除保存至实际文件中。再删除之前会将trace_bits保存到起来。删除完成之后重新拷贝。如果不清楚看下面代码。

```c
static u8 trim_case(char** argv, struct queue_entry* q, u8* in_buf) {
....
static u8 clean_trace[MAP_SIZE];
u8  needs_write = 0
/* 从文件长度1/16开始最到最小1/1024步长，设置移除文件的大小 */
while (remove_len >= MAX(len_p2 / TRIM_END_STEPS, TRIM_MIN_BYTES)) {
      /*按选定的步长，移除，然后循环该文件*/
    while (remove_pos < q->len) {
      //删除
         write_with_gap(in_buf, q->len, remove_pos, trim_avail);
        //执行
         fault = run_target(argv, exec_tmout);
     /* 检查trace_bit是否不一样 */
         cksum = hash32(trace_bits, MAP_SIZE, HASH_CONST);
     /* 如果删除对跟踪没有影响，则使其永久。作者表明可能可变路径会对此产生一些影响，不过没有大碍*/
         if (cksum == q->exec_cksum) {
          memmove(in_buf + remove_pos, in_buf + remove_pos + trim_avail, move_tail);
       /* 保存之前的trace_bits，因为执行如果改变了trace_bits*/
           if (!needs_write) {
         memcpy(clean_trace, trace_bits, MAP_SIZE);}
     } else remove_pos += remove_len;
   }
   remove_len >>= 1;   //增加步长
}
}
```

文件大小对模糊性能有很大影响，这是因为大文件使目标二进制文件变得更慢，并且因为它们减少了突变将触及重要的格式控制结构而不是冗余数据块的可能性。这在`perf_tips.txt`中有更详细的讨论。
用户可能会提供低质量的起始语料库，某些类型的突变可能会产生迭代地增加生成文件的大小的效果，因此应对这一趋势是很重要的。
幸运的是，插装反馈提供了一种简单的方法来自动删除输入文件，同时确保对文件的更改不会对执行路径产生影响。
在afl-fuzz中内置的修边器试图按可变长度和stepover顺序删除数据块;任何不影响跟踪映射校验和的删除都被提交到磁盘。修剪器的设计并不是特别彻底;相反，它试图在精度和在进程上花费的execve（）调用的数量之间取得平衡，选择块大小和stepover来匹配。每个文件的平均增益大约在5%到20%之间。
独立的afl-tmin工具使用了更详尽的迭代算法，并尝试在修剪过的文件上执行字母标准化。afl-tmin的操作如下。
首先，工具自动选择操作模式。如果初始输入崩溃了目标二进制文件，afl-tmin将以非插装模式运行，只需保留任何能产生更简单文件但仍然会使目标崩溃的调整。如果目标是非崩溃的，那么这个工具使用一个插装的模式，并且只保留那些产生完全相同的执行路径的微调。


#### 3.6 calculate_score()


`static u32 calculate_score(struct queue_entry* q)`根据case的执行速度/bitmap的大小/case产生时间/路径深度等因素给case进行打分,返回值为一个分数，用来调整在havoc阶段的用时。使得执行时间短，代码覆盖高，新发现的，路径深度深的case拥有更多havoc变异的机会。此段代码没有较强逻辑，在这里就简单介绍。


#### 3.7 mutation变异策略

因为变异阶段没有什么太多逻辑性的东西，我觉得不需要再进行太多补充解释。此处内容大多来源于：`https://blog.csdn.net/Chen_zju/article/details/80791268` 也可以前往观看。
-3.7.1 bitflip 阶段

基本原理：bitflip，按位翻转，1变为0，0变为1。

拿到一个原始文件，打头阵的就是bitflip，而且还会根据翻转量/步长进行多种不同的翻转，按照顺序依次为：
bitflip 1/1，每次翻转1个bit，按照每1个bit的步长从头开始
bitflip 2/1，每次翻转相邻的2个bit，按照每1个bit的步长从头开始
bitflip 4/1，每次翻转相邻的4个bit，按照每1个bit的步长从头开始
bitflip 8/8，每次翻转相邻的8个bit，按照每8个bit的步长从头开始，即依次对每个byte做翻转
bitflip 16/8，每次翻转相邻的16个bit，按照每8个bit的步长从头开始，即依次对每个word做翻转
bitflip 32/8，每次翻转相邻的32个bit，按照每8个bit的步长从头开始，即依次对每个dword做翻转
作为精妙构思的fuzzer，AFL不会放过每一个获取文件信息的机会。这一点在bitflip过程中就体现的淋漓尽致。具体地，在上述过程中，AFL巧妙地嵌入了一些对文件格式的启发式判断。包括自动检测token和生成effector map。

自动检测token

在进行bitflip 1/1变异时，对于每个byte的最低位(least significant bit)翻转还进行了额外的处理：如果连续多个bytes的最低位被翻转后，程序的执行路径都未变化，而且与原始执行路径不一致(检测程序执行路径的方式可见上篇文章中“分支信息的分析”一节)，那么就把这一段连续的bytes判断是一条token。
例如，PNG文件中用IHDR作为起始块的标识，那么就会存在类似于以下的内容
`.......IHDR........`
当翻转到字符I的最高位时，因为IHDR被破坏，此时程序的执行路径肯定与处理正常文件的路径是不同的；随后，在翻转接下来3个字符的最高位时，IHDR标识同样被破坏，程序应该会采取同样的执行路径。由此，AFL就判断得到一个可能的token：IHDR，并将其记录下来为后面的变异提供备选。
AFL采取的这种方式是非常巧妙的：就本质而言，这实际上是对每个byte进行修改并检查执行路径；但集成到bitflip后，就不需要再浪费额外的执行资源了。此外，为了控制这样自动生成的token的大小和数量，AFL还在config.h中通过宏定义了限制.
对于一些文件来说，我们已知其格式中出现的token长度不会超过4，那么我们就可以修改MAX_AUTO_EXTRA为4并重新编译AFL，以排除一些明显不会是token的情况。遗憾的是，这些设置是通过宏定义来实现，所以不能做到运行时指定，每次修改后必须重新编译AFL

生成effector map

在进行bitflip 8/8变异时，AFL还生成了一个非常重要的信息：effector map。这个effector map几乎贯穿了整个`deterministic fuzzing`的始终。

```
/* Effector map setup. These macros calculate:                        设置效应地图：
   EFF_APOS      - position of a particular file offset in the map.   文件偏移
   EFF_ALEN      - length of a map with a particular number of bytes. 特殊字符的长度
   EFF_SPAN_ALEN - map span for a sequence of bytes.                  一个字节序列的映射
   */
#define EFF_APOS(_p)          ((_p) >> EFF_MAP_SCALE2)
#define EFF_REM(_x)           ((_x) & ((1 << EFF_MAP_SCALE2) - 1))
#define EFF_ALEN(_l)          (EFF_APOS(_l) + !!EFF_REM(_l))
#define EFF_SPAN_ALEN(_p, _l) (EFF_APOS((_p) + (_l) - 1) - EFF_APOS(_p) + 1)

```

具体地，在对每个byte进行翻转时，如果其造成执行路径与原始路径不一致，就将该byte在effector map中标记为1，即“有效”的，否则标记为0，即“无效”的。
这样做的逻辑是：如果一个byte完全翻转，都无法带来执行路径的变化，那么这个byte很有可能是属于”data”，而非”metadata”（例如size, flag等），对整个fuzzing的意义不大。所以，在随后的一些变异中，会参考effector map，跳过那些“无效”的byte，从而节省了执行资源。
由此，通过极小的开销（没有增加额外的执行次数），AFL又一次对文件格式进行了启发式的判断。看到这里，不得不叹服于AFL实现上的精妙。
不过，在某些情况下并不会检测有效字符。第一种情况就是dumb mode或者从fuzzer，此时文件所有的字符都有可能被变异。第二、第三种情况与文件本身有关：即默认情况下，如果文件小于128 bytes，那么所有字符都是“有效”的；同样地，如果AFL发现一个文件有超过90%的bytes都是“有效”的，那么也不差那10%了，大笔一挥，干脆把所有字符都划归为“有效”。


#### -3.7.2 arithmetic 阶段

在bitflip变异全部进行完成后，便进入下一个阶段：arithmetic。与bitflip类似的是，arithmetic根据目标大小的不同，也分为了多个子阶段：
arith 8/8，每次对8个bit进行加减运算，按照每8个bit的步长从头开始，即对文件的每个byte进行整数加减变异
arith 16/8，每次对16个bit进行加减运算，按照每8个bit的步长从头开始，即对文件的每个word进行整数加减变异
arith 32/8，每次对32个bit进行加减运算，按照每8个bit的步长从头开始，即对文件的每个dword进行整数加减变异
加减变异的上限，在config.h中的宏ARITH_MAX定义，默认为35。所以，对目标整数会进行`+1, +2, …, +35, -1, -2, …, -35`的变异。特别地，由于整数存在大端序和小端序两种表示方式，AFL会贴心地对这两种整数表示方式都进行变异。
此外，AFL还会智能地跳过某些arithmetic变异。第一种情况就是前面提到的effector map：如果一个整数的所有bytes都被判断为“无效”，那么就跳过对整数的变异。第二种情况是之前bitflip已经生成过的变异：如果加/减某个数后，其效果与之前的某种bitflip相同，那么这次变异肯定在上一个阶段已经执行过了，此次便不会再执行。


#### -3.7.3 interest 阶段

interest 8/8，每次对8个bit进替换，按照每8个bit的步长从头开始，即对文件的每个byte进行替换
interest 16/8，每次对16个bit进替换，按照每8个bit的步长从头开始，即对文件的每个word进行替换
interest 32/8，每次对32个bit进替换，按照每8个bit的步长从头开始，即对文件的每个dword进行替换
而用于替换的”interesting values”，是AFL预设的一些比较特殊的数。这些数的定义在config.h文件中，可以看到，用于替换的基本都是可能会造成溢出的数。
与之前类似，effector map仍然会用于判断是否需要变异；此外，如果某个interesting value，是可以通过bitflip或者arithmetic变异达到，那么这样的重复性变异也是会跳过的。


#### -3.7.3 dictionary 阶段

进入到这个阶段，就接近deterministic fuzzing的尾声了。具体有以下子阶段：
`user extras (over)`，从头开始，将用户提供的tokens依次替换到原文件中
`user extras (insert)`，从头开始，将用户提供的tokens依次插入到原文件中
`auto extras (over)`，从头开始，将自动检测的tokens依次替换到原文件中
其中，用户提供的tokens，是在词典文件中设置并通过-x选项指定的，如果没有则跳过相应的子阶段

`user extras (over)`

对于用户提供的tokens，AFL先按照长度从小到大进行排序。这样做的好处是，只要按照顺序使用排序后的tokens，那么后面的token不会比之前的短，从而每次覆盖替换后不需要再恢复到原状。
随后，AFL会检查tokens的数量，如果数量大于预设的MAX_DET_EXTRAS（默认值为200），那么对每个token会根据概率来决定是否进行替换：

```
for (j = 0; j < extras_cnt; j++) {
   if ((extras_cnt > MAX_DET_EXTRAS && UR(extras_cnt) >= MAX_DET_EXTRAS) ||
       extras[j].len > len - i ||
       !memcmp(extras[j].data, out_buf + i, extras[j].len) ||
       !memchr(eff_map + EFF_APOS(i), 1, EFF_SPAN_ALEN(i, extras[j].len))) {
     stage_max--;
     continue;
   }

```
这里的UR(extras_cnt)是运行时生成的一个0到extras_cnt之间的随机数。所以，如果用户词典中一共有400个tokens，那么每个token就有`200/400=50%`的概率执行替换变异。我们可以修改`MAX_DET_EXTRAS`的大小来调整这一概率。
由上述代码也可以看到，effector map在这里同样被使用了：如果要替换的目标bytes全部是“无效”的，那么就跳过这一段，对下一段目标执行替换。

`user extras (insert)`

这一子阶段是对用户提供的tokens执行插入变异。不过与上一个子阶段不同的是，此时并没有对tokens数量的限制，所以全部tokens都会从原文件的第1个byte开始，依次向后插入；此外，由于原文件并未发生替换，所以effector map不会被使用。
这一子阶段最特别的地方，就是变异不能简单地恢复。之前每次变异完，在变异位置处简单取逆即可，例如bitflip后，再进行一次同样的bitflip就恢复为原文件。正因为如此，之前的变异总体运算量并不大。
但是，对于插入这种变异方式，恢复起来则复杂的多，所以AFL采取的方式是：将原文件分割为插入前和插入后的部分，再加上插入的内容，将这3部分依次复制到目标缓冲区中（当然这里还有一些小的优化，具体可阅读代码）。而对每个token的每处插入，都需要进行上述过程。所以，如果用户提供了大量tokens，或者原文件很大，那么这一阶段的运算量就会非常的多。直观表现上，就是AFL的执行状态栏中，`”user extras (insert)”`的总执行量很大，执行时间很长。如果出现了这种情况，那么就可以考虑适当删减一些tokens

`auto extras (over)`

这一项与”`user extras (over)`”很类似，区别在于，这里的tokens是最开始bitflip阶段自动生成的。另外，自动生成的tokens总量会由USE_AUTO_EXTRAS限制（默认为10）。

#### -3.7.4 havoc 大破坏

对于非dumb mode的主fuzzer来说，完成了上述deterministic fuzzing后，便进入了充满随机性的这一阶段；对于dumb mode或者从fuzzer来说，则是直接从这一阶段开始。
havoc，顾名思义，是充满了各种随机生成的变异，是对原文件的“大破坏”。具体来说，havoc包含了对原文件的多轮变异，每一轮都是将多种方式组合（stacked）而成：
随机选取某个bit进行翻转
随机选取某个byte，将其设置为随机的interesting value
随机选取某个word，并随机选取大、小端序，将其设置为随机的interesting value
随机选取某个dword，并随机选取大、小端序，将其设置为随机的interesting value
随机选取某个byte，对其减去一个随机数
随机选取某个byte，对其加上一个随机数
随机选取某个word，并随机选取大、小端序，对其减去一个随机数
随机选取某个word，并随机选取大、小端序，对其加上一个随机数
随机选取某个dword，并随机选取大、小端序，对其减去一个随机数
随机选取某个dword，并随机选取大、小端序，对其加上一个随机数
随机选取某个byte，将其设置为随机数
随机删除一段bytes
随机选取一个位置，插入一段随机长度的内容，其中75%的概率是插入原文中随机位置的内容，25%的概率是插入一段随机选取的数
随机选取一个位置，替换为一段随机长度的内容，其中75%的概率是替换成原文中随机位置的内容，25%的概率是替换成一段随机选取的数
随机选取一个位置，用随机选取的token（用户提供的或自动生成的）替换
随机选取一个位置，用随机选取的token（用户提供的或自动生成的）插入
怎么样，看完上面这么多的“随机”，有没有觉得晕？还没完，AFL会生成一个随机数，作为变异组合的数量，并根据这个数量，每次从上面那些方式中随机选取一个（可以参考高中数学的有放回摸球），依次作用到文件上。如此这般丧心病狂的变异，原文件就大概率面目全非了，而这么多的随机性，也就成了fuzzing过程中的不可控因素，即所谓的“看天吃饭”了。


#### -3.7.5 splice

历经了如此多的考验，文件的变异也进入到了最后的阶段：splice。如其意思所说，splice是将两个seed文件拼接得到新的文件，并对这个新文件继续执行havoc变异。
具体地，AFL在seed文件队列中随机选取一个，与当前的seed文件做对比。如果两者差别不大，就再重新随机选一个；如果两者相差比较明显，那么就随机选取一个位置，将两者都分割为头部和尾部。最后，将当前文件的头部与随机文件的尾部拼接起来，就得到了新的文件。在这里，AFL还会过滤掉拼接文件未发生变化的情况。


#### 3.8 common_fuzz_stuff

`common_fuzz_stuff(char** argv, u8* out_buf, u32 len) `编写修改后的测试用例，运行程序，处理结果。处理错误条件，如果需要退出，返回1。这是`fuzz_one()`的一个辅助函数。该函数贯穿了整个变异过程的始终。
步骤：

`write_to_testcase() `将变异写到文件中，该函数前面解释过。
`run_target() `前面解释过；
`save_if_interesting() `判断一个文件是否为interesting种子，如果是那么就保存输入文件(queue)

#### 3.9 save_if_interesting

`static u8 save_if_interesting(char** argv, void* mem, u32 len, u8 fault)`判断是否为感兴趣的输入,判断一个文件是否是感兴趣的输入(has_new_bits)，即是否访问了新的tuple或者tuple访问次数发生变化，如果是则保存输入文件（放到队列queue中）。
步骤：

`has_new_bits(virgin_bits)`校验哈希
`add_to_queue()`添加到队列
`calibrate_case()`校准种子，同时calibrate_case函数里的`update_bitmap_score()`重新排列toprate[]种子。

### 4 总结

再把fuzz.c的整体流程总结一下：

afl_fuzz的main函数会解析用户输入命令，检查环境变量的设置、输入输出路径、目标文件。程序定义了结构体queue_entry链表维护fuzz中使用的文件。
函数`perform_dry_run() `会使用初始的测试用例进行测试，确保目标程序能够正常执行,生成初始化的queue和bitmap。
函数` cull_queue() `会对初始队列进行筛选（更新favored entry）。遍历`top_rated[]`中的queue，然后提取出发现新edge的entry，并标记为favored，使得在下次遍历queue时，这些entry能获得更多执行fuzz的机会。
进入while(1)开始fuzz循环

- 进入循环后第一部还是 `cull_queue() `对queue进行筛选
- 判断queue_cur是否为空，如果是，则表示已经完成对队列的遍历，初始化相关参数，重新开始遍历队列
- `fuzz_one()` 函数会对`queue_cur`所对应文件进行fuzz，包括(跳过`-calibrate_case-`修剪测试用例-对用例评分-确定性变异或直接`havoc&ssplice`)
- 判断是否结束，更新`queue_cur`和`current_entry`
- 当队列中的所有文件都经过变异测试了，则完成一次”cycle done”。整个队列又会从第一个文件开始，再次继续进行变异

## 自我总结

个人感觉的AFL难点在于forkserver和fuzzer交互运行之间的关系那一块，另外就是bitmap相关的，`trace_bits,trace_mini,virgin_bits,top_rate[]`,这几个变量都是干什么的？在那个阶段改变的？哪个函数改变的？又是谁对它们进行的操作？如果这几点理解了，那么整个AFL就比较容易理解了。  
