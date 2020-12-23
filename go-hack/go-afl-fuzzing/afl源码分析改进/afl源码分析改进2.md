# AFL源码分析改进2——afl-as.c源码分析

首先来看下`main`函数  

`u8* inst_ratio_str = getenv("AFL_INST_RATIO");`
先是从环境变量中拿了`AFL_INST_RATIO`，应该是插入指令的密度  

之后一大堆东西略过一下  
```
gettimeofday(&tv, &tz);

rand_seed = tv.tv_sec ^ tv.tv_usec ^ getpid();

srandom(rand_seed);
```

这里是根据时间和`pid`来随机化`seed`  

再下面是把 `inst_ratio_str`转为数字  
```
if (inst_ratio_str) {

  if (sscanf(inst_ratio_str, "%u", &inst_ratio) != 1 || inst_ratio > 100)
    FATAL("Bad value of AFL_INST_RATIO (must be between 0 and 100)");

}
```
之后比较有趣的一部分代码  

```
if (getenv("AFL_USE_ASAN") || getenv("AFL_USE_MSAN")) {
  sanitizer = 1;
  inst_ratio /= 3;
}
```
如果使用 `ASAN`或者`MSAN`的话，就会把插入指令的密度降低为 1/3，以加快速度  

之后就是关键的`add_instrumentation`函数  
```
if (input_file) {

  inf = fopen(input_file, "r");
  if (!inf) PFATAL("Unable to read '%s'", input_file);

} else inf = stdin;
```
首先是打开汇编代码文件  

```
outfd = open(modified_file, O_WRONLY | O_EXCL | O_CREAT, 0600);

if (outfd < 0) PFATAL("Unable to write to '%s'", modified_file);

outf = fdopen(outfd, "w");

if (!outf) PFATAL("fdopen() failed");
```
然后打开一个新的文件  

然后就是循环读每一行，进行判断  
```
if (!pass_thru && !skip_intel && !skip_app && !skip_csect && instr_ok &&
        instrument_next && line[0] == '\t' && isalpha(line[1])) {

      fprintf(outf, use_64bit ? trampoline_fmt_64 : trampoline_fmt_32,
              R(MAP_SIZE));

      instrument_next = 0;
      ins_lines++;

    }

```
一开始就是判断一堆条件，假如满足这些条件的话，就插入指令

`fputs(line, outf);`
之后再输出原来那行
```
if (line[0] == '\t' && line[1] == '.') {

  /* OpenBSD puts jump tables directly inline with the code, which is
     a bit annoying. They use a specific format of p2align directives
     around them, so we use that as a signal. */

  if (!clang_mode && instr_ok && !strncmp(line + 2, "p2align ", 8) &&
      isdigit(line[10]) && line[11] == '\n') skip_next_label = 1;

  if (!strncmp(line + 2, "text\n", 5) ||
      !strncmp(line + 2, "section\t.text", 13) ||
      !strncmp(line + 2, "section\t__TEXT,__text", 21) ||
      !strncmp(line + 2, "section __TEXT,__text", 21)) {
    instr_ok = 1;
    continue;
  }

  if (!strncmp(line + 2, "section\t", 8) ||
      !strncmp(line + 2, "section ", 8) ||
      !strncmp(line + 2, "bss\n", 4) ||
      !strncmp(line + 2, "data\n", 5)) {
    instr_ok = 0;
    continue;
  }

}
```

这里是找 `.text`在的那一行，也就是代码段
```
if (strstr(line, ".code")) {

      if (strstr(line, ".code32")) skip_csect = use_64bit;
      if (strstr(line, ".code64")) skip_csect = !use_64bit;

    }

```
这里是判断是32位还是64位的

```
/* If we're in the right mood for instrumenting, check for function
      names or conditional labels. This is a bit messy, but in essence,
      we want to catch:

        ^main:      - function entry point (always instrumented)
        ^.L0:       - GCC branch label
        ^.LBB0_0:   - clang branch label (but only in clang mode)
        ^\tjnz foo  - conditional branches

      ...but not:

        ^# BB#0:    - clang comments
        ^ # BB#0:   - ditto
        ^.Ltmp0:    - clang non-branch labels
        ^.LC0       - GCC non-branch labels
        ^.LBB0_0:   - ditto (when in GCC mode)
        ^\tjmp foo  - non-conditional jumps

      Additionally, clang and GCC on MacOS X follow a different convention
      with no leading dots on labels, hence the weird maze of #ifdefs
      later on.

    */
```

这段注释大概就是说，在 `main`函数，`GCC branch label，clang branch label，conditional branches`处插入指令  

```
if (line[0] == '\t') {

      if (line[1] == 'j' && line[2] != 'm' && R(100) < inst_ratio) {

        fprintf(outf, use_64bit ? trampoline_fmt_64 : trampoline_fmt_32,
                R(MAP_SIZE));

        ins_lines++;

      }

      continue;

    }

```

这里就是找到 j开头，但是第二个字母不是m的指令，如`jne`, `jbe`指令的  

后面还有 `R(100) < inst_ratio` 这个就是根据概率来选择插入或者不插入  

```
if (ins_lines)
  fputs(use_64bit ? main_payload_64 : main_payload_32, outf);
这里还会插入 main_payload
```

插入的两个汇编有点长，这里就不仔细分析了  

```
if (!(pid = fork())) {

  execvp(as_params[0], (char**)as_params);
  FATAL("Oops, failed to execute '%s' - check your PATH", as_params[0]);

}
```
插入完指令后，会fork子进程，用来执行as，将汇编变成二进制  
