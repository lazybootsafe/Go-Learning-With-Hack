# AFL源码分析改进4——afl-fuzz.c源码分析1

因为`afl-fuzz.c`源码太多了，所以我只挑我比较感兴趣的部分来分析吧

## `detect_file_args`
这个函数是将命令参数中的@@替换为真正的文件路径

```
EXP_ST void detect_file_args(char** argv) {

  u32 i = 0;
  u8* cwd = getcwd(NULL, 0);

  if (!cwd) PFATAL("getcwd() failed");

  while (argv[i]) {

    u8* aa_loc = strstr(argv[i], "@@");

    if (aa_loc) {

      u8 *aa_subst, *n_arg;

      /* If we don't have a file name chosen yet, use a safe default. */

      if (!out_file)
        out_file = alloc_printf("%s/.cur_input", out_dir);

      /* Be sure that we're always using fully-qualified paths. */

      if (out_file[0] == '/') aa_subst = out_file;
      else aa_subst = alloc_printf("%s/%s", cwd, out_file);

      /* Construct a replacement argv value. */

      *aa_loc = 0;
      n_arg = alloc_printf("%s%s%s", argv[i], aa_subst, aa_loc + 2);
      argv[i] = n_arg;
      *aa_loc = '@';

      if (out_file[0] != '/') ck_free(aa_subst);

    }

    i++;

  }

  free(cwd); /* not tracked */

}
```

首先用`getcwd`拿到当前路径  

然后遍历`argv`，判断各个参数是否含有`@@`  

有的话，首先判断有没有定义一个文件名，如果没有的话，就使用`.cur_input`  

之后使用`alloc_printf`来生成一个新的字符串，替换原来的  

## `setup_stdio_file`

假如在`detect_file_args`没有找到`@@`，就会跳到这里，设置好`stdio_file`
```
EXP_ST void setup_stdio_file(void) {

  u8* fn = alloc_printf("%s/.cur_input", out_dir);

  unlink(fn); /* Ignore errors */

  out_fd = open(fn, O_RDWR | O_CREAT | O_EXCL, 0600);

  if (out_fd < 0) PFATAL("Unable to create '%s'", fn);

  ck_free(fn);

}
```
使用的还是 `.cur_input`

## `perform_dry_run`
这个函数是测试输入的样例

```
while (q) {

  u8* use_mem;
  u8  res;
  s32 fd;

  u8* fn = strrchr(q->fname, '/') + 1;

  ACTF("Attempting dry run with '%s'...", fn);

  fd = open(q->fname, O_RDONLY);
  if (fd < 0) PFATAL("Unable to open '%s'", q->fname);

  use_mem = ck_alloc_nozero(q->len);

  if (read(fd, use_mem, q->len) != q->len)
    FATAL("Short read from '%s'", q->fname);

  close(fd);

  res = calibrate_case(argv, q, use_mem, 0, 1);
  ck_free(use_mem);

```
首先是一个循环，遍历整个输入样例的队列  

然后先是打开文件，分配一块内存，将文件内容读入内存  

然后调用`calibrate_case`进行测试  

之后对测试的结果进行判断，有`FAULT_NONE，FAULT_TMOUT，FAULT_CRASH`等，这里就不详细说了  

## `calibrate_case`
首先是一大堆设置参数什么的，这里就不详细说了  
```
if (dumb_mode != 1 && !no_forkserver && !forksrv_pid)
  init_forkserver(argv);
```
这里是判断`forkserver`是否启动了，没启动就将其启动

再跳过一部分不是很重要的代码

`write_to_testcase(use_mem, q->len);`

这里是将`testcase`写到文件中去，感觉这里对磁盘的性能要求挺大的吧…….读小文件，写小文件….这里可以作为一个优化点，使用内存磁盘什么的，分一块不是很大的就够用了  

`fault = run_target(argv, use_tmout);
`
这里就是真正的运行程序，里面的逻辑其实在分析`afl-as.h`的时候已经讲到了  

其中有一个小细节就是，假如没有`@@`，就会将`.cur_input`的`fd` `dup2`到0上  

`cksum = hash32(trace_bits, MAP_SIZE, HASH_CONST);`  
之后就是计算`trace_bits`的`checksum`，这里trace_bits就是共享内存  

下面就是一些对测试样例性能的分析，把这个作为基准，详细的就不多说了

## `cull_queue`
这是一个用来设置`favored entry`的函数  
```
struct queue_entry* q;
static u8 temp_v[MAP_SIZE >> 3];
u32 i;

if (dumb_mode || !score_changed) return;

score_changed = 0;

memset(temp_v, 255, MAP_SIZE >> 3);
```
首先是初始化`temp_v（previously-unseen bytes）`  

```
while (q) {
  q->favored = 0;
  q = q->next;
}
```
之后将`queue_entry`中的所有`favored`设为0

```
for (i = 0; i < MAP_SIZE; i++)
  if (top_rated[i] && (temp_v[i >> 3] & (1 << (i & 7)))) {

    u32 j = MAP_SIZE >> 3;

    /* Remove all bits belonging to the current entry from temp_v. */

    while (j--)
      if (top_rated[i]->trace_mini[j])
        temp_v[j] &= ~top_rated[i]->trace_mini[j];

    top_rated[i]->favored = 1;
    queued_favored++;

    if (!top_rated[i]->was_fuzzed) pending_favored++;

  }

q = queue;

while (q) {
  mark_as_redundant(q, !q->favored);
  q = q->next;
}
```
这里就是判断有没有没被`temp_v`所命中的`bitmap`，如果有，并且在`top_rated`中，就将其设为`favored`  
