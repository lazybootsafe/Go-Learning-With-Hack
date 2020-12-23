# AFL源码分析改进5——afl-fuzz.c源码分析2 第二部分

## fuzz_one  

这是一个函数，从准备fuzz的队列中拿出一项，用来fuzz，这个函数返回0就代表fuzz成功，1就代表这个被跳过或不要这一项了
```
if (pending_favored) {

    /* If we have any favored, non-fuzzed new arrivals in the queue,
       possibly skip to them at the expense of already-fuzzed or non-favored
       cases. */

    if ((queue_cur->was_fuzzed || !queue_cur->favored) &&
        UR(100) < SKIP_TO_NEW_PROB) return 1;

```
假如`pending_favored`为真，那么判断下当前从队列中拿出来的这一项是否被fuzz过，或者不是`favired`的，当这两个条件满足其中一项，就会随机一个0-100的数，假如随机到100才会继续下去（非常残酷啊）  

```
else if (!dumb_mode && !queue_cur->favored && queued_paths > 10) {

    /* Otherwise, still possibly skip non-favored cases, albeit less often.
       The odds of skipping stuff are higher for already-fuzzed inputs and
       lower for never-fuzzed entries. */

    if (queue_cycle > 1 && !queue_cur->was_fuzzed) {

      if (UR(100) < SKIP_NFAV_NEW_PROB) return 1;

    } else {

      if (UR(100) < SKIP_NFAV_OLD_PROB) return 1;

    }

  }
```

然后假如满足不是`dumb`模式，当前项不是`favored`，并且等待fuzz的有10项以上，就会进入`else if`的流程中  

假如当前项没被fuzz过，就有75%的几率跳过，被fuzz过就有95%的几率跳过  

```
/* Map the test case into memory. */

fd = open(queue_cur->fname, O_RDONLY);

if (fd < 0) PFATAL("Unable to open '%s'", queue_cur->fname);

len = queue_cur->len;

orig_in = in_buf = mmap(0, len, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);

if (orig_in == MAP_FAILED) PFATAL("Unable to mmap '%s'", queue_cur->fname);

close(fd);
```
这部分是将当前的`test case`用`mmap`读进内存中  

```

if (queue_cur->cal_failed) {

  u8 res = FAULT_TMOUT;

  if (queue_cur->cal_failed < CAL_CHANCES) {

    res = calibrate_case(argv, queue_cur, in_buf, queue_cycle - 1, 0);

    if (res == FAULT_ERROR)
      FATAL("Unable to execute target application");

  }

  if (stop_soon || res != crash_mode) {
    cur_skipped_paths++;
    goto abandon_entry;
  }

}
```
假如当前项有校准错误，并且校准错误次数小于3次，那么就用`calibrate_case`进行测试

```
/************
 * TRIMMING *
 ************/
if (!dumb_mode && !queue_cur->trim_done) {

  u8 res = trim_case(argv, queue_cur, in_buf);

  if (res == FAULT_ERROR)
    FATAL("Unable to execute target application");

  if (stop_soon) {
    cur_skipped_paths++;
    goto abandon_entry;
  }

  /* Don't retry trimming, even if it failed. */

  queue_cur->trim_done = 1;

  if (len != queue_cur->len) len = queue_cur->len;

}
memcpy(out_buf, in_buf, len);
```
这一部分就是对样例进行`trimming`，`trim_case`这个函数我们之后会进行分析

```
/*********************
 * PERFORMANCE SCORE *
 *********************/

orig_perf = perf_score = calculate_score(queue_cur);

/* Skip right away if -d is given, if we have done deterministic fuzzing on
   this entry ourselves (was_fuzzed), or if it has gone through deterministic
   testing in earlier, resumed runs (passed_det). */

if (skip_deterministic || queue_cur->was_fuzzed || queue_cur->passed_det)
  goto havoc_stage;

/* Skip deterministic fuzzing if exec path checksum puts this out of scope
   for this master instance. */

if (master_max && (queue_cur->exec_cksum % master_max) != master_id - 1)
  goto havoc_stage;

doing_det = 1;
```

这里是用`calculate_score`计算评分，然后下面是根据各种条件，然后直接跳到`havoc`那个变异阶段

```
for (stage_cur = 0; stage_cur < stage_max; stage_cur++) {

  stage_cur_byte = stage_cur >> 3;

  FLIP_BIT(out_buf, stage_cur);

  if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;

  FLIP_BIT(out_buf, stage_cur);
  
```
