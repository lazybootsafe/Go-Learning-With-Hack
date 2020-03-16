<map version="1.0.1">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1498092885756" ID="ID_1897690566" MODIFIED="1498092912051" STYLE="bubble" TEXT="afl-fuzz">
<node CREATED="1498092954339" ID="ID_662965335" MODIFIED="1498145101038" POSITION="right" TEXT="main fuzz loop">
<node CREATED="1498092968170" ID="ID_1776743583" MODIFIED="1498265753597" TEXT="cull_queue();&#x6839;&#x636e;top_rated&#x8bbe;&#x7f6e;queue&#x4e2d;&#x7684;favored&#x6807;&#x5fd7;">
<node CREATED="1498106830178" ID="ID_713506060" MODIFIED="1498106888657" TEXT="&#x53c2;&#x8003;update_bitmap_score(q);&#xff0c;&#x5728;calibration&#x7684;&#x65f6;&#x5019;&#x8c03;&#x7528;&#xff0c;&#x5728;&#x8be5;&#x51fd;&#x6570;&#x4e2d;&#xff0c;&#x8bbe;&#x7f6e;top_rated[i]"/>
<node CREATED="1498093525869" ID="ID_339997769" MODIFIED="1498106955361" TEXT="top_rated[i]-&gt;favored = 1;&#x82e5;&#x4e0d;&#x662f;favored&#x5219;&#x8df3;&#x8fc7;&#x8be5;&#x6837;&#x672c;"/>
<node CREATED="1498094122133" ID="ID_879407733" MODIFIED="1498094123889" TEXT="queued_favored++;"/>
<node CREATED="1498094132574" ID="ID_1313940729" MODIFIED="1498094134236" TEXT="if (!top_rated[i]-&gt;was_fuzzed) pending_favored++;"/>
</node>
<node CREATED="1498093480710" ID="ID_621585882" MODIFIED="1498265763097" TEXT="skipped_fuzz = fuzz_one(use_argv);">
<node CREATED="1498094692890" ID="ID_154561728" MODIFIED="1498265859773" TEXT=" if ((queue_cur-&gt;was_fuzzed || !queue_cur-&gt;favored) &amp;&amp; UR(100) &lt; SKIP_TO_NEW_PROB) return 1;//&#x5982;&#x679c;&#x5df2;&#x7ecf;fuzz&#x8fc7;&#xff0c;&#x6216;&#x8005;favored&#x4e3a;0&#xff0c;&#x5219;&#x8df3;&#x8fc7;&#x8be5;&#x6837;&#x672c;&#x7684;&#x53d8;&#x5f02;">
<icon BUILTIN="idea"/>
</node>
<node CREATED="1498094961072" ID="ID_79109529" MODIFIED="1498094962965" TEXT="fd = open(queue_cur-&gt;fname, O_RDONLY);"/>
<node CREATED="1498094975984" ID="ID_1719795449" MODIFIED="1498094977584" TEXT="orig_in = in_buf = mmap(0, len, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);"/>
<node CREATED="1498094994053" ID="ID_631019916" MODIFIED="1498094995520" TEXT="out_buf = ck_alloc_nozero(len);"/>
<node CREATED="1498095010018" ID="ID_1187509445" MODIFIED="1498095012017" TEXT="cur_depth = queue_cur-&gt;depth;"/>
<node CREATED="1498217229447" FOLDED="true" ID="ID_53720896" MODIFIED="1498265518135" TEXT="TRIMMING &#x5bf9;in_buf&#x5220;&#x9664;&#x90e8;&#x5206;&#xff0c;&#x6839;&#x636e;&#x662f;&#x5426;&#x5f71;&#x54cd;trace_bits">
<icon BUILTIN="idea"/>
<node CREATED="1498217233300" FOLDED="true" ID="ID_773767383" MODIFIED="1498264851692">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      if (!dumb_mode &amp;&amp; !queue_cur-&gt;trim_done) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;u8 res = trim_case(argv, queue_cur, in_buf);
    </p>
  </body>
</html>
</richcontent>
<icon BUILTIN="idea"/>
<node CREATED="1498217270022" FOLDED="true" ID="ID_248163630" MODIFIED="1498262690857">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Select initial chunk len, starting with large steps. */
    </p>
    <p>
      &#160;&#160;len_p2 = next_p2(q-&gt;len); &#20056;&#20197;2
    </p>
  </body>
</html>
</richcontent>
<node CREATED="1498262094438" ID="ID_912737525" MODIFIED="1498262100648">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Find first power of two greater or equal to val. */
    </p>
    <p>
      
    </p>
    <p>
      static u32 next_p2(u32 val) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;u32 ret = 1;
    </p>
    <p>
      &#160;&#160;while (val &gt; ret) ret &lt;&lt;= 1;
    </p>
    <p>
      &#160;&#160;return ret;
    </p>
    <p>
      
    </p>
    <p>
      }
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
<node CREATED="1498262199510" ID="ID_720840823" MODIFIED="1498262205238">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      #define TRIM_MIN_BYTES&#160;&#160;&#160;&#160;&#160;&#160;4
    </p>
    <p>
      #define TRIM_START_STEPS&#160;&#160;&#160;&#160;16
    </p>
    <p>
      #define TRIM_END_STEPS&#160;&#160;&#160;&#160;&#160;&#160;1024
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498262159968" ID="ID_848121610" MODIFIED="1498262745697">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      remove_len = MAX(len_p2 / TRIM_START_STEPS, TRIM_MIN_BYTES);&#21024;&#38500;&#38271;&#24230;&#36215;&#22987;&#20540;&#20026;(&#25991;&#20214;&#38271;&#24230;*2/16)
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498262271669" ID="ID_1632366515" MODIFIED="1498264841692">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      while (remove_len &gt;= MAX(len_p2 / TRIM_END_STEPS, TRIM_MIN_BYTES)) {(&#25991;&#20214;&#38271;&#24230;*2/1024) trim&#27493;&#38271;&#20174;len*2/16&#19968;&#30452;&#20943;&#23569;&#21040;len*2/1024&#65292;&#20943;&#23569;&#24133;&#24230;&#20026;&#38500;&#20197;2
    </p>
  </body>
</html>
</richcontent>
<icon BUILTIN="idea"/>
<node CREATED="1498262417363" ID="ID_550968263" MODIFIED="1498262589340" TEXT="u32 remove_pos = remove_len;&#x5220;&#x9664;&#x7684;&#x8d77;&#x59cb;&#x4f4d;&#x7f6e;"/>
<node CREATED="1498262444616" ID="ID_353123392" MODIFIED="1498264838620">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#30452;&#21040;&#21024;&#38500;&#20301;&#32622;&#36229;&#36807;&#25991;&#20214;&#38271;&#24230;
    </p>
    <p>
      stage_max = q-&gt;len / remove_len;
    </p>
    <p>
      &#160;&#160;&#160;&#160;while (remove_pos &lt; q-&gt;len) {
    </p>
  </body>
</html>
</richcontent>
<icon BUILTIN="idea"/>
<node CREATED="1498262479657" ID="ID_596417901" MODIFIED="1498262566090" TEXT="u32 trim_avail = MIN(remove_len, q-&gt;len - remove_pos);&#x5220;&#x9664;&#x7684;&#x957f;&#x5ea6;"/>
<node CREATED="1498262551664" ID="ID_446562628" MODIFIED="1498263057433" TEXT="write_with_gap(in_buf, q-&gt;len, remove_pos, trim_avail);&#x6839;&#x636e;in_buf&#x5199;out_file">
<node CREATED="1498262855309" ID="ID_191434671" MODIFIED="1498262857733" TEXT="static void write_with_gap(void* mem, u32 len, u32 skip_at, u32 skip_len) {">
<node CREATED="1498262874401" ID="ID_1792974654" MODIFIED="1498262894502" TEXT="fd = open(out_file, O_WRONLY | O_CREAT | O_EXCL, 0600);"/>
<node CREATED="1498262896321" ID="ID_1572728772" MODIFIED="1498263031354" TEXT="if (skip_at) ck_write(fd, mem, skip_at, out_file);&#x4e00;&#x76f4;&#x5199;&#x5230;trim&#x8d77;&#x59cb;&#x4f4d;&#x7f6e;"/>
<node CREATED="1498263089171" ID="ID_538682331" MODIFIED="1498263119440" TEXT="if (tail_len) ck_write(fd, mem + skip_at + skip_len, tail_len, out_file);&#x8df3;&#x8fc7;skip_len&#xff0c;&#x7ee7;&#x7eed;&#x5199;tail_len&#x957f;&#x5ea6;&#x7684;&#x6570;&#x636e;"/>
</node>
</node>
<node CREATED="1498262614264" ID="ID_1288016208" MODIFIED="1498262615740" TEXT="fault = run_target(argv, exec_tmout);"/>
<node CREATED="1498263170337" ID="ID_650860191" MODIFIED="1498263172451" TEXT="cksum = hash32(trace_bits, MAP_SIZE, HASH_CONST);"/>
<node CREATED="1498264026421" ID="ID_126004727" MODIFIED="1498264829785" TEXT="if (cksum == q-&gt;exec_cksum) {&#x5982;&#x679c;trim&#x4ee5;&#x540e;&#xff0c;trace_bits&#x4e0d;&#x53d8;">
<icon BUILTIN="idea"/>
<node CREATED="1498264053811" ID="ID_890893784" MODIFIED="1498264085737" TEXT="u32 move_tail = q-&gt;len - remove_pos - trim_avail;&#x5c3e;&#x90e8;&#x7684;&#x5b57;&#x8282;&#x6570;"/>
<node CREATED="1498264120192" ID="ID_49237165" MODIFIED="1498264135707" TEXT="q-&gt;len -= trim_avail;&#x6587;&#x4ef6;&#x957f;&#x5ea6;&#xff0c;&#x51cf;&#x53bb;trim&#x6389;&#x7684;&#x5b57;&#x8282;&#x957f;&#x5ea6;"/>
<node CREATED="1498264158493" ID="ID_152152358" MODIFIED="1498264170634" TEXT="len_p2  = next_p2(q-&gt;len);&#x8ba1;&#x7b97;&#x65b0;&#x7684;"/>
<node CREATED="1498264186133" ID="ID_1142137086" MODIFIED="1498264235225" TEXT="memmove(in_buf + remove_pos, in_buf + remove_pos + trim_avail,move_tail);&#x8df3;&#x8fc7;trim&#xff0c;&#x79fb;&#x52a8;&#x5c3e;&#x90e8;"/>
<node CREATED="1498264287000" ID="ID_194399985" MODIFIED="1498264299195">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      if (!needs_write) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;needs_write = 1;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(clean_trace, trace_bits, MAP_SIZE);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
<node CREATED="1498264390187" ID="ID_407995733" MODIFIED="1498264395821" TEXT="&#x5426;&#x5219;">
<node CREATED="1498264413203" ID="ID_158051952" MODIFIED="1498264424534" TEXT="remove_pos += remove_len;trim&#x4f4d;&#x7f6e;&#x5f80;&#x524d;&#x79fb;&#x52a8;"/>
</node>
<node CREATED="1498264435008" ID="ID_1278206369" MODIFIED="1498264439723" TEXT="&#x6700;&#x540e;&#x5199;&#x5230;&#x78c1;&#x76d8;">
<node CREATED="1498264441470" ID="ID_1810683756" MODIFIED="1498264487193" TEXT="fd = open(q-&gt;fname, O_WRONLY | O_CREAT | O_EXCL, 0600);"/>
<node CREATED="1498264488020" ID="ID_390661377" MODIFIED="1498264511789" TEXT="ck_write(fd, in_buf, q-&gt;len, q-&gt;fname);"/>
<node CREATED="1498264512302" ID="ID_1913526810" MODIFIED="1498264519691" TEXT="memcpy(trace_bits, clean_trace, MAP_SIZE);"/>
<node CREATED="1498264520798" ID="ID_646196009" MODIFIED="1498264584346" TEXT="update_bitmap_score(q); &#x7ed9;top_rated&#x8d4b;&#x503c;&#x4e3a;&#x5f53;&#x524d;q"/>
</node>
</node>
<node CREATED="1498262450804" ID="ID_172644401" MODIFIED="1498262634912">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      remove_len &gt;&gt;= 1;&#21024;&#38500;&#38271;&#24230;&#38500;&#20197;2
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
</node>
<node CREATED="1498217304561" ID="ID_1574894683" MODIFIED="1498217306196" TEXT="queue_cur-&gt;trim_done = 1;"/>
<node CREATED="1498217307675" ID="ID_1636564246" MODIFIED="1498217315695" TEXT="if (len != queue_cur-&gt;len) len = queue_cur-&gt;len;"/>
</node>
<node CREATED="1498095032280" ID="ID_733952940" MODIFIED="1498095033911" TEXT="memcpy(out_buf, in_buf, len);"/>
<node CREATED="1498095053828" FOLDED="true" ID="ID_769758440" MODIFIED="1498095230991" TEXT="orig_perf = perf_score = calculate_score(queue_cur);">
<node CREATED="1498095062512" ID="ID_1512116950" MODIFIED="1498095107831" TEXT="u32 avg_exec_us = total_cal_us / total_cal_cycles;   u32 avg_bitmap_size = total_bitmap_size / total_bitmap_entries;   u32 perf_score = 100;"/>
<node CREATED="1498095114026" ID="ID_946331857" MODIFIED="1498095154330" TEXT="if (q-&gt;exec_us * 0.1 &gt; avg_exec_us) perf_score = 10; //&#x6267;&#x884c;&#x65f6;&#x95f4;&#x8d8a;&#x957f;&#xff0c;&#x5206;&#x6570;&#x8d8a;&#x4f4e;"/>
<node CREATED="1498095155395" ID="ID_391075986" MODIFIED="1498095165304" TEXT="if (q-&gt;bitmap_size * 0.3 &gt; avg_bitmap_size) perf_score *= 3;//bitmap_size&#x8d8a;&#x5927;&#x8d8a;&#x597d;"/>
<node CREATED="1498095190271" ID="ID_315485519" MODIFIED="1498095191786" TEXT="switch (q-&gt;depth) {      case 0 ... 3:   break;     case 4 ... 7:   perf_score *= 2; break;     case 8 ... 13:  perf_score *= 3; break;     case 14 ... 25: perf_score *= 4; break;//&#x8d8a;&#x6df1;&#x53d1;&#x73b0;&#x6f0f;&#x6d1e;&#x53ef;&#x80fd;&#x6027;&#x8d8a;&#x9ad8;"/>
<node CREATED="1498095213786" ID="ID_259465831" MODIFIED="1498095215229" TEXT="return perf_score;"/>
</node>
<node CREATED="1498184554231" ID="ID_73737330" MODIFIED="1498274339633" TEXT="flip">
<icon BUILTIN="idea"/>
<node CREATED="1498095234011" FOLDED="true" ID="ID_1743528803" MODIFIED="1498275161845" TEXT="flip1">
<icon BUILTIN="idea"/>
<node CREATED="1498095285675" ID="ID_144540310" MODIFIED="1498095287353" TEXT="stage_short = &quot;flip1&quot;;   stage_max   = len &lt;&lt; 3;   stage_name  = &quot;bitflip 1/1&quot;;"/>
<node CREATED="1498095327473" ID="ID_1448884707" MODIFIED="1498095329073" TEXT=" stage_val_type = STAGE_VAL_NONE;    orig_hit_cnt = queued_paths + unique_crashes;    prev_cksum = queue_cur-&gt;exec_cksum;"/>
<node CREATED="1498095443331" ID="ID_1304726346" MODIFIED="1498184616698" TEXT="for (stage_cur = 0; stage_cur &lt; stage_max; stage_cur++) {">
<icon BUILTIN="idea"/>
<node CREATED="1498095331568" FOLDED="true" ID="ID_426395154" MODIFIED="1498265977375" TEXT="FLIP_BIT(out_buf, stage_cur); &#x53d8;&#x5f02;">
<node CREATED="1498095504394" ID="ID_246525090" MODIFIED="1498095514708" TEXT="#define FLIP_BIT(_ar, _b) do { \     u8* _arf = (u8*)(_ar); \     u32 _bf = (_b); \     _arf[(_bf) &gt;&gt; 3] ^= (128 &gt;&gt; ((_bf) &amp; 7)); \   } while (0)"/>
</node>
<node CREATED="1498095367484" ID="ID_110682921" MODIFIED="1498275153884" TEXT="if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry; &#x6d4b;&#x8bd5;&#xff0c;&#x5982;&#x679c;&#x4ea7;&#x751f;&#x4e86;&#x597d;&#x7684;&#x6837;&#x672c;&#xff0c;&#x5c31;&#x52a0;&#x5165;&#x961f;&#x5217;">
<icon BUILTIN="idea"/>
<node CREATED="1498095523226" FOLDED="true" ID="ID_1384064918" MODIFIED="1498100237062" TEXT="write_to_testcase(out_buf, len);  out/.cur_input">
<node CREATED="1498095793423" ID="ID_1103504049" MODIFIED="1498095838455" TEXT="out/.cur_input"/>
<node CREATED="1498095840928" ID="ID_1878882153" MODIFIED="1498095863432" TEXT="if (out_file) {      unlink(out_file); /* Ignore errors. */      fd = open(out_file, O_WRONLY | O_CREAT | O_EXCL, 0600);"/>
<node CREATED="1498095899078" ID="ID_1387470851" MODIFIED="1498095900948" TEXT="ck_write(fd, mem, len, out_file);"/>
</node>
<node CREATED="1498095921630" FOLDED="true" ID="ID_899150090" MODIFIED="1498106594236" TEXT="fault = run_target(argv, exec_tmout);">
<icon BUILTIN="idea"/>
<node CREATED="1498095956575" ID="ID_227433903" MODIFIED="1498095985517" TEXT="memset(trace_bits, 0, MAP_SIZE);"/>
<node CREATED="1498096011636" ID="ID_1381866698" MODIFIED="1498100098249" TEXT="if ((res = write(fsrv_ctl_fd, &amp;prev_timed_out, 4)) != 4) {&#x5411;forkserver&#x53d1;&#x4fe1;&#x53f7;&#xff0c;&#x542f;&#x52a8;&#x4e00;&#x4e2a;&#x6d4b;&#x8bd5;">
<node CREATED="1498099932498" ID="ID_82659390" MODIFIED="1498099934480" TEXT="while ( 1 )         {           v67 = 198;           if ( read(198, &amp;_afl_temp, 4uLL) != 4 )//&#x7b49;&#x5f85;&#x542f;&#x52a8;&#x547d;&#x4ee4;&#xff0c;run_target"/>
</node>
<node CREATED="1498096072292" ID="ID_449118794" MODIFIED="1498100088278" TEXT="if ((res = read(fsrv_st_fd, &amp;child_pid, 4)) != 4) {&#x8bfb;&#x53d6;&#x5b59;&#x5b50;&#x8fdb;&#x7a0b;&#x7684;pid">
<node CREATED="1498099942465" ID="ID_1811107434" MODIFIED="1498099966884" TEXT="LODWORD(v68) = fork();           if ( v68 &lt; 0 )             break;           if ( !v68 )             goto __afl_fork_resume;//&#x5b59;&#x5b50;&#x8fdb;&#x7a0b;&#x7ee7;&#x7eed;&#x8dd1;&#x6d4b;&#x8bd5;&#x8f6f;&#x4ef6;           _afl_fork_pid = v68;           write(199, &amp;_afl_fork_pid, 4uLL);//forkserver&#x5c06;&#x5b59;&#x5b50;&#x8fdb;&#x7a0b;pid&#x53d1;&#x7ed9;afl-fuzz"/>
</node>
<node CREATED="1498096411943" ID="ID_808769525" MODIFIED="1498096413920" TEXT="it.it_value.tv_sec = (timeout / 1000);   it.it_value.tv_usec = (timeout % 1000) * 1000;"/>
<node CREATED="1498096424149" ID="ID_245774735" MODIFIED="1498100067072" TEXT="setitimer(ITIMER_REAL, &amp;it, NULL);&#x8bbe;&#x7f6e;&#x8d85;&#x65f6;&#xff0c;&#x7b49;&#x5f85;&#x5b59;&#x5b50;&#x8fdb;&#x7a0b;&#x7ed3;&#x675f;"/>
<node CREATED="1498096448707" ID="ID_95697986" MODIFIED="1498100057332" TEXT="if ((res = read(fsrv_st_fd, &amp;status, 4)) != 4) {&#x7b49;&#x5f85;&#x8fd4;&#x56de;&#x8fdb;&#x7a0b;&#x7ed3;&#x675f;status">
<node CREATED="1498099984482" ID="ID_1454106202" MODIFIED="1498100004650" TEXT="LODWORD(v69) = waitpid(_afl_fork_pid, &amp;_afl_temp, 0);//https://linux.die.net/man/2/waitpid afl_temp&#x4fdd;&#x5b58;exit status           if ( v69 &lt;= 0 )             break;           write(199, &amp;_afl_temp, 4uLL);//forkserver&#x5c06;&#x5b59;&#x5b50;&#x8fdb;&#x7a0b;&#x7684;&#x9000;&#x51fa;&#x72b6;&#x6001;&#x53d1;&#x7ed9;afl-fuzz"/>
</node>
<node CREATED="1498096564827" ID="ID_1219902992" MODIFIED="1498100029900" TEXT="it.it_value.tv_sec = 0;   it.it_value.tv_usec = 0;    setitimer(ITIMER_REAL, &amp;it, NULL); &#x6e05;&#x7a7a;&#x8d85;&#x65f6;&#x8ba1;&#x65f6;&#x5668;"/>
<node CREATED="1498096598950" ID="ID_1334759312" MODIFIED="1498096600252" TEXT="total_execs++;"/>
<node CREATED="1498096628506" ID="ID_131161236" MODIFIED="1498100584976" TEXT="classify_counts((u64*)trace_bits); &#x89c4;&#x8303;&#x5316;trace_bits,&#x4e5f;&#x53eb;&#x7bee;&#x5b50;bucket">
<node CREATED="1498096726694" ID="ID_406473250" MODIFIED="1498100161717" TEXT="count_class_lookup8 &#xff08;0&#xff0c;1,2,4,8&#xff0c;...128)"/>
<node CREATED="1498096759704" ID="ID_1265407047" MODIFIED="1498100592080" TEXT="count_class_lookup16(0000,0001,..0080)"/>
<node CREATED="1498096961448" ID="ID_468262176" MODIFIED="1498100218192" TEXT="mem16[0] = count_class_lookup16[mem16[0]]; &#x91cd;&#x65b0;&#x8d4b;&#x503c;&#xff0c;&#x547d;&#x4e2d;&#x6b21;&#x6570;&#xff0c;&#x89c4;&#x8303;&#x5316;"/>
</node>
<node CREATED="1498097070092" ID="ID_748685559" MODIFIED="1498097078830" TEXT="if (child_timed_out) return FAULT_TMOUT; &#x8d85;&#x65f6;"/>
<node CREATED="1498097185896" ID="ID_279835484" MODIFIED="1498097188314" TEXT=" if (WIFSIGNALED(status) &amp;&amp; !stop_soon) {     kill_signal = WTERMSIG(status);     return FAULT_CRASH;   }"/>
<node CREATED="1498097231766" ID="ID_1405956314" MODIFIED="1498097233123" TEXT=" if (uses_asan &amp;&amp; WEXITSTATUS(status) == MSAN_ERROR) {     kill_signal = 0;     return FAULT_CRASH;   }"/>
<node CREATED="1498097241228" ID="ID_1208575271" MODIFIED="1498097242572" TEXT="return FAULT_NONE;"/>
</node>
<node CREATED="1498097094082" ID="ID_1653856376" MODIFIED="1498099673044" TEXT=" if (fault == FAULT_TMOUT) {      if (subseq_tmouts++ &gt; TMOUT_LIMIT) {       cur_skipped_paths++;       return 1;     }    }"/>
<node CREATED="1498099763925" FOLDED="true" ID="ID_1156635556" MODIFIED="1498266420942" TEXT="queued_discovered += save_if_interesting(argv, out_buf, len, fault);">
<icon BUILTIN="idea"/>
<node CREATED="1498103286295" FOLDED="true" ID="ID_881748943" MODIFIED="1498266415985" TEXT="&#x6b63;&#x5e38;&#x9000;&#x51fa;&#x7684;&#x60c5;&#x51b5;if (fault == crash_mode) {">
<node CREATED="1498103327627" ID="ID_1071861935" MODIFIED="1498103706151" TEXT="if (!(hnb = has_new_bits(virgin_bits))) {       &#xa;if (crash_mode) total_crashes++;       &#xa;return 0;     }   &#xa;&#x6ca1;&#x6709;&#x65b0;&#x53d1;&#x73b0;&#xff0c;&#x76f4;&#x63a5;&#x8fd4;&#x56de;0">
<node CREATED="1498103402490" ID="ID_636800221" MODIFIED="1498265990410" TEXT="static inline u8 has_new_bits(u8* virgin_map) {">
<icon BUILTIN="idea"/>
<node CREATED="1498103445377" ID="ID_76625605" MODIFIED="1498103453037" TEXT="u64* current = (u64*)trace_bits;   "/>
<node CREATED="1498103454254" ID="ID_1279865598" MODIFIED="1498103455714" TEXT="u64* virgin  = (u64*)virgin_map;"/>
<node CREATED="1498103466817" ID="ID_517208767" MODIFIED="1498103469687" TEXT="u32  i = (MAP_SIZE &gt;&gt; 3);"/>
<node CREATED="1498103480038" ID="ID_1636324896" MODIFIED="1498103481642" TEXT="while (i--) {">
<node CREATED="1498103633103" ID="ID_269315775" MODIFIED="1498103665766" TEXT="if (unlikely(*current) &amp;&amp; unlikely(*current &amp; *virgin)) {        &#xa;if (likely(ret &lt; 2)) {          &#xa;u8* cur = (u8*)current;         &#xa;u8* vir = (u8*)virgin;"/>
<node CREATED="1498103484545" ID="ID_1807447084" MODIFIED="1498103684549" TEXT="if ((cur[0] &amp;&amp; vir[0] == 0xff) || (cur[1] &amp;&amp; vir[1] == 0xff) ||            &#xa; (cur[2] &amp;&amp; vir[2] == 0xff) || (cur[3] &amp;&amp; vir[3] == 0xff) ||             &#xa;(cur[4] &amp;&amp; vir[4] == 0xff) || (cur[5] &amp;&amp; vir[5] == 0xff) ||             &#xa;(cur[6] &amp;&amp; vir[6] == 0xff) || (cur[7] &amp;&amp; vir[7] == 0xff)) ret = 2;         &#xa;else ret = 1;"/>
<node CREATED="1498103552733" ID="ID_1855457185" MODIFIED="1498103554161" TEXT="*virgin &amp;= ~*current;"/>
<node CREATED="1498103564920" ID="ID_942656394" MODIFIED="1498103566321" TEXT="current++;     virgin++;"/>
</node>
<node CREATED="1498103594594" ID="ID_1057654508" MODIFIED="1498103596047" TEXT="return ret;"/>
</node>
</node>
<node CREATED="1498103816714" ID="ID_1834555925" MODIFIED="1498265897269" TEXT="&#x6709;&#x65b0;&#x7684;&#x53d1;&#x73b0;">
<icon BUILTIN="idea"/>
<node CREATED="1498103824038" ID="ID_675654178" MODIFIED="1498103860573" TEXT="fn = alloc_printf(&quot;%s/queue/id:%06u,%s&quot;, out_dir, queued_paths,describe_op(hnb)); &#x5206;&#x914d;queue&#x6587;&#x4ef6;&#x540d;"/>
<node CREATED="1498103878245" ID="ID_335091713" MODIFIED="1498103887328" TEXT="add_to_queue(fn, len, 0); &#x6dfb;&#x52a0;&#x5230;&#x961f;&#x5217;">
<icon BUILTIN="idea"/>
<node CREATED="1498103913069" ID="ID_148039442" MODIFIED="1498103914567" TEXT="static void add_to_queue(u8* fname, u32 len, u8 passed_det) {">
<node CREATED="1498103917476" ID="ID_1173739244" MODIFIED="1498103981772" TEXT="struct queue_entry* q = ck_alloc(sizeof(struct queue_entry));&#xa;  q-&gt;fname        = fname;&#xa;  q-&gt;len          = len;&#xa;  q-&gt;depth        = cur_depth + 1;//&#x6bd4;&#x7236;&#x4eb2;&#x6837;&#x672c;&#x6df1;&#x4e00;&#x5c42;&#xa;  q-&gt;passed_det   = passed_det;"/>
<node CREATED="1498104000371" ID="ID_34735937" MODIFIED="1498104029391">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      if (queue_top) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;queue_top-&gt;next = q;//&#38142;&#20837;&#38431;&#21015;
    </p>
    <p>
      &#160;&#160;&#160;&#160;queue_top = q;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;} else q_prev100 = queue = queue_top = q;
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498104059822" ID="ID_1793527827" MODIFIED="1498104063404" TEXT="queued_paths++;   pending_not_fuzzed++;"/>
<node CREATED="1498104080372" ID="ID_1112551513" MODIFIED="1498104081586" TEXT="last_path_time = get_cur_time();"/>
</node>
</node>
<node CREATED="1498104126802" ID="ID_1181994518" MODIFIED="1498104129676" TEXT="if (hnb == 2) {       queue_top-&gt;has_new_cov = 1;       queued_with_cov++;     }"/>
<node CREATED="1498104150171" ID="ID_1149497883" MODIFIED="1498104152029" TEXT="queue_top-&gt;exec_cksum = hash32(trace_bits, MAP_SIZE, HASH_CONST);"/>
<node CREATED="1498104258836" ID="ID_1815703132" MODIFIED="1498104263210" TEXT="res = calibrate_case(argv, queue_top, mem, queue_cycle - 1, 0);">
<icon BUILTIN="idea"/>
<node CREATED="1498104395675" FOLDED="true" ID="ID_327754084" MODIFIED="1498106797394" TEXT="static u8 calibrate_case(char** argv, struct queue_entry* q, u8* use_mem,  u32 handicap, u8 from_queue) {">
<node CREATED="1498104648007" ID="ID_1748205081" MODIFIED="1498104658169" TEXT="stage_name = &quot;calibration&quot;;   stage_max  = CAL_CYCLES;&#x662f;8"/>
<node CREATED="1498104595894" ID="ID_1768188117" MODIFIED="1498104597518" TEXT="q-&gt;cal_failed++;"/>
<node CREATED="1498104488847" FOLDED="true" ID="ID_1733885471" MODIFIED="1498106485094">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      if (dumb_mode != 1 &amp;&amp; !no_forkserver &amp;&amp; !forksrv_pid)
    </p>
    <p>
      &#160;&#160;&#160;&#160;init_forkserver(argv);
    </p>
  </body>
</html></richcontent>
<icon BUILTIN="idea"/>
<node CREATED="1498104692605" ID="ID_398167800" MODIFIED="1498104699974" TEXT="if (pipe(st_pipe) || pipe(ctl_pipe)) PFATAL(&quot;pipe() failed&quot;);&#x5efa;&#x7acb;&#x7ba1;&#x9053;"/>
<node CREATED="1498104703205" ID="ID_1281905454" MODIFIED="1498104715495" TEXT="forksrv_pid = fork();&#x5b50;&#x8fdb;&#x7a0b;">
<node CREATED="1498104740165" ID="ID_1888730870" MODIFIED="1498104784092" TEXT="dup2(dev_null_fd, 1);     dup2(dev_null_fd, 2);&#x5173;&#x95ed;&#x8f93;&#x51fa;"/>
<node CREATED="1498104787433" ID="ID_545477304" MODIFIED="1498104823626" TEXT="if (out_file) {        dup2(dev_null_fd, 0);      } &#x5173;&#x95ed;&#x8f93;&#x5165;"/>
<node CREATED="1498104850445" ID="ID_1828042920" MODIFIED="1498104878773">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#37325;&#23450;&#21521;&#31649;&#36947;&#21040;198 199
    </p>
    <p>
      if (dup2(ctl_pipe[0], FORKSRV_FD) &lt; 0) PFATAL(&quot;dup2() failed&quot;);
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (dup2(st_pipe[1], FORKSRV_FD + 1) &lt; 0) PFATAL(&quot;dup2() failed&quot;);
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498104900023" ID="ID_82465954" MODIFIED="1498104932090" TEXT="execv(target_path, argv);&#x6267;&#x884c;&#x63d2;&#x6869;&#x540e;&#x7684;&#x7a0b;&#x5e8f;&#xff0c;forkserver"/>
</node>
<node CREATED="1498104733601" ID="ID_1525003459" MODIFIED="1498104736392" TEXT="&#x7236;&#x8fdb;&#x7a0b;">
<node CREATED="1498104976916" ID="ID_1422612410" MODIFIED="1498105185478">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#35774;&#32622;&#36229;&#26102;
    </p>
    <p>
      it.it_value.tv_sec = ((exec_tmout * FORK_WAIT_MULT) / 1000);
    </p>
    <p>
      &#160;&#160;it.it_value.tv_usec = ((exec_tmout * FORK_WAIT_MULT) % 1000) * 1000;
    </p>
    <p>
      &#160;&#160;setitimer(ITIMER_REAL, &amp;it, NULL);
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498104995982" ID="ID_1359574229" MODIFIED="1498105024913" TEXT="rlen = read(fsrv_st_fd, &amp;status, 4); &#x8bfb;&#x53d6;&#x72b6;&#x6001;&#xff0c;forkserver&#x542f;&#x52a8;">
<node CREATED="1498105029892" ID="ID_285670528" MODIFIED="1498105053707" TEXT="if ( write(199, &amp;_afl_temp, 4uLL) == 4 ) //&#x901a;&#x77e5;afl-fuzz&#x7236;&#x8fdb;&#x7a0b;init_forkserver&#x51fd;&#x6570;&#xff0c;&#x5df2;&#x7ecf;&#x542f;&#x52a8;forkserver"/>
</node>
<node CREATED="1498105157013" ID="ID_1098852878" MODIFIED="1498105181211">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#28165;&#31354;&#35745;&#26102;&#22120;
    </p>
    <p>
      it.it_value.tv_sec = 0;
    </p>
    <p>
      &#160;&#160;it.it_value.tv_usec = 0;
    </p>
    <p>
      &#160;&#160;setitimer(ITIMER_REAL, &amp;it, NULL);
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498105209468" ID="ID_1346207936" MODIFIED="1498105218725">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      if (rlen == 4) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;OKF(&quot;All right - fork server is up.&quot;);
    </p>
    <p>
      &#160;&#160;&#160;&#160;return;
    </p>
    <p>
      &#160;&#160;}
    </p>
  </body>
</html></richcontent>
</node>
</node>
</node>
<node CREATED="1498105360343" ID="ID_1744977069" MODIFIED="1498105368301" TEXT="if (q-&gt;exec_cksum) memcpy(first_trace, trace_bits, MAP_SIZE);"/>
<node CREATED="1498105379055" ID="ID_1532137966" MODIFIED="1498105380992" TEXT="start_us = get_cur_time_us();"/>
<node CREATED="1498105382348" ID="ID_650175085" MODIFIED="1498106492522" TEXT="for (stage_cur = 0; stage_cur &lt; stage_max; stage_cur++) {">
<node CREATED="1498105428270" ID="ID_445553565" MODIFIED="1498105430707" TEXT="write_to_testcase(use_mem, q-&gt;len);"/>
<node CREATED="1498105438109" ID="ID_408805697" MODIFIED="1498105440258" TEXT="fault = run_target(argv, use_tmout);"/>
<node CREATED="1498105468076" ID="ID_414857257" MODIFIED="1498105539097" TEXT="if (stop_soon || fault != crash_mode) goto abort_calibration; &#x68c0;&#x9a8c;&#x5931;&#x8d25;&#xff0c;&#x5e94;&#x8be5;&#x6b63;&#x5e38;&#x9000;&#x51fa;&#xff0c;&#x53ef;&#x662f;&#x5931;&#x8d25;"/>
<node CREATED="1498105542049" ID="ID_963389788" MODIFIED="1498105594541" TEXT="&#x6ca1;&#x6709;&#x65b0;&#x7684;&#x53d1;&#x73b0;&#xff0c;&#x4e5f;&#x8868;&#x793a;&#x6821;&#x9a8c;&#x5931;&#x8d25;&#xa;if (!dumb_mode &amp;&amp; !stage_cur &amp;&amp; !count_bytes(trace_bits)) {      &#xa; fault = FAULT_NOINST;       &#xa;goto abort_calibration;     }">
<node CREATED="1498105599615" ID="ID_1704429223" MODIFIED="1498105616666" TEXT="static u32 count_bytes(u8* mem) {">
<node CREATED="1498105620110" ID="ID_1373652237" MODIFIED="1498105643651">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      static u32 count_bytes(u8* mem) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;u32* ptr = (u32*)mem;
    </p>
    <p>
      &#160;&#160;u32&#160;&#160;i&#160;&#160;&#160;= (MAP_SIZE &gt;&gt; 2);
    </p>
    <p>
      &#160;&#160;u32&#160;&#160;ret = 0;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;while (i--) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;u32 v = *(ptr++);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (!v) continue;
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (v &amp; FF(0)) ret++;
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (v &amp; FF(1)) ret++;
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (v &amp; FF(2)) ret++;
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (v &amp; FF(3)) ret++;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;return ret;
    </p>
    <p>
      
    </p>
    <p>
      }
    </p>
  </body>
</html></richcontent>
</node>
</node>
</node>
<node CREATED="1498105698261" ID="ID_759319540" MODIFIED="1498105700335" TEXT="cksum = hash32(trace_bits, MAP_SIZE, HASH_CONST);"/>
</node>
<node CREATED="1498105754256" ID="ID_732106976" MODIFIED="1498105757059" TEXT="stop_us = get_cur_time_us();    total_cal_us     += stop_us - start_us;   total_cal_cycles += stage_max;"/>
<node CREATED="1498105423786" ID="ID_324951327" MODIFIED="1498105783159">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#160;q-&gt;exec_us&#160;&#160;&#160;&#160;&#160;= (stop_us - start_us) / stage_max;
    </p>
    <p>
      &#160;&#160;q-&gt;bitmap_size = count_bytes(trace_bits);
    </p>
    <p>
      &#160;&#160;q-&gt;handicap&#160;&#160;&#160;&#160;= handicap;
    </p>
    <p>
      &#160;&#160;q-&gt;cal_failed&#160;&#160;= 0;
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498105818028" ID="ID_167325340" MODIFIED="1498105819737" TEXT="total_bitmap_size += q-&gt;bitmap_size;   total_bitmap_entries++;"/>
<node CREATED="1498105823703" ID="ID_1854907742" MODIFIED="1498105838797" TEXT="update_bitmap_score(q);">
<icon BUILTIN="idea"/>
<node CREATED="1498105834850" ID="ID_1933321346" MODIFIED="1498106324475" TEXT="static void update_bitmap_score(struct queue_entry* q) {">
<node CREATED="1498105890269" ID="ID_1530901800" MODIFIED="1498105898048" TEXT="u64 fav_factor = q-&gt;exec_us * q-&gt;len; &#x6267;&#x884c;&#x65f6;&#x95f4;&#x548c;&#x957f;&#x5ea6;"/>
<node CREATED="1498105914195" ID="ID_76710074" MODIFIED="1498105915815" TEXT="for (i = 0; i &lt; MAP_SIZE; i++)">
<node CREATED="1498106148104" ID="ID_1545414370" MODIFIED="1498106159228" TEXT="if (trace_bits[i]) {//&#x65b0;&#x53d1;&#x73b0;">
<node CREATED="1498106111906" ID="ID_1865980200" MODIFIED="1498106137061" TEXT="&#x539f;&#x6765;&#x8be5;tuple&#x6709;&#x6700;&#x4f18;&#x7684;q&#x5bf9;&#x5e94;&#x7684;&#x60c5;&#x51b5;">
<node CREATED="1498105918427" ID="ID_747051522" MODIFIED="1498106185627">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      if (top_rated[i]) {//&#35813;tuple&#21407;&#26469;&#23601;&#26377;q&#23545;&#24212;
    </p>
  </body>
</html></richcontent>
<node CREATED="1498106013172" ID="ID_1255492922" MODIFIED="1498106032391" TEXT="if (fav_factor &gt; top_rated[i]-&gt;exec_us * top_rated[i]-&gt;len) continue; &#x5982;&#x679c;&#x4e0d;&#x5982;&#x539f;&#x6765;&#x7684;&#xff0c;&#x67e5;&#x8be2;&#x4e0b;&#x4e00;&#x4e2a;tuple"/>
<node CREATED="1498106046789" ID="ID_177084552" MODIFIED="1498106083900">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#21542;&#21017;&#26367;&#25442;&#21407;&#26469;&#30340;&#65292;&#21407;&#26469;&#30340;&#24341;&#29992;&#35745;&#25968;&#20943;&#19968;
    </p>
    <p>
      if (!--top_rated[i]-&gt;tc_ref) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;ck_free(top_rated[i]-&gt;trace_mini);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;top_rated[i]-&gt;trace_mini = 0;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
  </body>
</html></richcontent>
</node>
</node>
</node>
<node CREATED="1498106193306" ID="ID_1409898810" MODIFIED="1498106217870" TEXT="&#x539f;&#x6765;&#x8be5;tuple&#x6ca1;&#x6709;&#x6700;&#x4f18;&#x7684;q&#x5bf9;&#x5e94;&#x7684;&#x60c5;&#x51b5;&#xff0c;&#x76f4;&#x63a5;&#x8d4b;&#x503c;">
<node CREATED="1498106225960" ID="ID_1828631609" MODIFIED="1498106227451" TEXT="top_rated[i] = q;        q-&gt;tc_ref++;"/>
</node>
</node>
</node>
</node>
</node>
<node CREATED="1498106415227" ID="ID_776877126" MODIFIED="1498106417076" TEXT="return fault;"/>
</node>
</node>
<node CREATED="1498104361984" ID="ID_1457131619" MODIFIED="1498104385507">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      fd = open(fn, O_WRONLY | O_CREAT | O_EXCL, 0600);
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (fd &lt; 0) PFATAL(&quot;Unable to create '%s'&quot;, fn);
    </p>
    <p>
      &#160;&#160;&#160;&#160;ck_write(fd, mem, len, fn);
    </p>
    <p>
      &#160;&#160;&#160;&#160;close(fd);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;keeping = 1; //&#36820;&#22238;keeping&#20026;1
    </p>
  </body>
</html></richcontent>
</node>
</node>
</node>
<node CREATED="1498100384846" ID="ID_1633326133" MODIFIED="1498103282929" TEXT="case FAULT_TMOUT:">
<node CREATED="1498100503964" ID="ID_1498410217" MODIFIED="1498100505887" TEXT="simplify_trace((u64*)trace_bits);">
<node CREATED="1498100556406" ID="ID_1248012621" MODIFIED="1498100557948" TEXT="mem8[0] = simplify_lookup[mem8[0]];"/>
<node CREATED="1498100628683" ID="ID_824680045" MODIFIED="1498100631255" TEXT="static const u8 simplify_lookup[256] = {     [0]         = 1,   [1 ... 255] = 128  };"/>
<node CREATED="1498100670866" ID="ID_1267284820" MODIFIED="1498100672475" TEXT="Destructively simplify trace by eliminating hit count information    and replacing it with 0x80 or 0x01 depending on whether the tuple    is hit or not. Called on every new crash or timeout, should be    reasonably fast."/>
</node>
<node CREATED="1498100821633" ID="ID_476579866" MODIFIED="1498100836131" TEXT="fn = alloc_printf(&quot;%s/hangs/id:%06llu,%s&quot;, out_dir,unique_hangs, describe_op(0)); &#x6587;&#x4ef6;&#x540d;"/>
<node CREATED="1498102994759" ID="ID_533851145" MODIFIED="1498102996359" TEXT="unique_hangs++;        last_hang_time = get_cur_time();        break;"/>
</node>
<node CREATED="1498103021330" ID="ID_1494349656" MODIFIED="1498103107695" TEXT="case FAULT_CRASH:">
<node CREATED="1498103110460" ID="ID_1562984314" MODIFIED="1498103127156" TEXT="total_crashes++;"/>
<node CREATED="1498103141153" ID="ID_1443578111" MODIFIED="1498103142727" TEXT="simplify_trace((u64*)trace_bits);"/>
<node CREATED="1498103167080" ID="ID_1428169640" MODIFIED="1498103168517" TEXT="if (!has_new_bits(virgin_crash)) return keeping;"/>
<node CREATED="1498103191471" ID="ID_1293173599" MODIFIED="1498103206125" TEXT="fn = alloc_printf(&quot;%s/crashes/id:%06llu,sig:%02u,%s&quot;, out_dir,  unique_crashes, kill_signal, describe_op(0));"/>
<node CREATED="1498103226157" ID="ID_1598918882" MODIFIED="1498103227973" TEXT="unique_crashes++;        last_crash_time = get_cur_time();       last_crash_execs = total_execs;        break;"/>
</node>
<node CREATED="1498103022669" ID="ID_441125438" MODIFIED="1498103305042" TEXT="&#x4e0a;&#x9762;&#x4e24;&#x4e2a;&#x90fd;&#x662f;&#x5f02;&#x5e38;&#xff0c;&#x8fd4;&#x56de;&#x7684;keeping&#x4e3a;0"/>
<node CREATED="1498103024554" ID="ID_927663725" MODIFIED="1498103731142" TEXT="fd = open(fn, O_WRONLY | O_CREAT | O_EXCL, 0600);   &#xa;if (fd &lt; 0) PFATAL(&quot;Unable to create &apos;%s&apos;&quot;, fn);   &#xa;ck_write(fd, mem, len, fn);   &#xa;close(fd);    &#xa;ck_free(fn);    &#xa;return keeping;"/>
</node>
</node>
<node CREATED="1498095372415" ID="ID_929653660" MODIFIED="1498095384728" TEXT="FLIP_BIT(out_buf, stage_cur); &#x8fd8;&#x539f;"/>
</node>
<node CREATED="1498095409413" ID="ID_43438884" MODIFIED="1498095411445" TEXT="new_hit_cnt = queued_paths + unique_crashes;    stage_finds[STAGE_FLIP1]  += new_hit_cnt - orig_hit_cnt;   stage_cycles[STAGE_FLIP1] += stage_max;"/>
</node>
<node CREATED="1498118651557" FOLDED="true" ID="ID_1984599561" MODIFIED="1498184567386" TEXT="bitflip 2/1">
<node CREATED="1498118681906" ID="ID_319886480" MODIFIED="1498118719365">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      FLIP_BIT(out_buf, stage_cur);
    </p>
    <p>
      &#160;&#160;&#160;&#160;FLIP_BIT(out_buf, stage_cur + 1);
    </p>
    <p>
      if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498118778969" FOLDED="true" ID="ID_1594967675" MODIFIED="1498184573723" TEXT="bitflip 4/1">
<node CREATED="1498118878310" ID="ID_1896288385" MODIFIED="1498118883215">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      FLIP_BIT(out_buf, stage_cur);
    </p>
    <p>
      &#160;&#160;&#160;&#160;FLIP_BIT(out_buf, stage_cur + 1);
    </p>
    <p>
      &#160;&#160;&#160;&#160;FLIP_BIT(out_buf, stage_cur + 2);
    </p>
    <p>
      &#160;&#160;&#160;&#160;FLIP_BIT(out_buf, stage_cur + 3);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498135620712" FOLDED="true" ID="ID_1141244560" MODIFIED="1498184578533" TEXT="bitflip 8/8">
<node CREATED="1498135643151" ID="ID_1415395917" MODIFIED="1498135648764">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      out_buf[stage_cur] ^= 0xFF;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498146382269" ID="ID_402087825" MODIFIED="1498146452412">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#22914;&#26524;&#21457;&#29616;&#25913;&#21464;&#23383;&#33410;&#21518;&#65292;trace&#19981;&#19968;&#26679;&#23601;&#35774;&#32622;
    </p>
    <p>
      eff_map[EFF_APOS(stage_cur)] = 1
    </p>
    <p>
      if (cksum != queue_cur-&gt;exec_cksum) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;eff_map[EFF_APOS(stage_cur)] = 1;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;eff_cnt++;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
  </body>
</html></richcontent>
<node CREATED="1498176266276" ID="ID_1007145724" MODIFIED="1498176300739" TEXT="&#x4e00;&#x4e2a;&#x5b57;&#x8282;&#xff0c;&#x516b;&#x4f4d;&#xff0c;&#x8868;&#x793a;&#x6837;&#x672c;&#x4e2d;8&#x4e2a;&#x5b57;&#x8282;&#x662f;&#x5426;&#x5f71;&#x54cd;trace"/>
<node CREATED="1498176337143" ID="ID_1201102628" MODIFIED="1498176346039" TEXT="&#x4ee3;&#x66ff;&#x4e86;&#x7ecf;&#x5178;&#x7684;&#x6c61;&#x70b9;&#x5206;&#x6790;"/>
</node>
</node>
<node CREATED="1498181611793" FOLDED="true" ID="ID_849883579" MODIFIED="1498184585609" TEXT="bitflip 16/8">
<node CREATED="1498184320378" ID="ID_679216384" MODIFIED="1498184362943">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#22914;&#26524;&#26159;&#19981;&#24433;&#21709;trace&#30340;&#26679;&#26412;&#20013;&#30340;&#23383;&#33410;&#65292;&#25105;&#20204;&#23601;&#36339;&#36807;
    </p>
    <p>
      if (!eff_map[EFF_APOS(i)] &amp;&amp; !eff_map[EFF_APOS(i + 1)]) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;stage_max--;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;continue;
    </p>
    <p>
      &#160;&#160;&#160;&#160;}
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498184402774" ID="ID_1504189828" MODIFIED="1498184404303" TEXT="*(u16*)(out_buf + i) ^= 0xFFFF;"/>
</node>
<node CREATED="1498184406634" FOLDED="true" ID="ID_1236101035" MODIFIED="1498184587875" TEXT="bitflip 32/8">
<node CREATED="1498184436290" ID="ID_1307404694" MODIFIED="1498184441936">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Let's consult the effector map... */
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (!eff_map[EFF_APOS(i)] &amp;&amp; !eff_map[EFF_APOS(i + 1)] &amp;&amp;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;!eff_map[EFF_APOS(i + 2)] &amp;&amp; !eff_map[EFF_APOS(i + 3)]) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;stage_max--;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;continue;
    </p>
    <p>
      &#160;&#160;&#160;&#160;}
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498184443602" ID="ID_1647299041" MODIFIED="1498184453185" TEXT="*(u32*)(out_buf + i) ^= 0xFFFFFFFF;"/>
</node>
</node>
<node CREATED="1498184621446" FOLDED="true" ID="ID_1759479208" MODIFIED="1498191242534" TEXT="arith">
<node CREATED="1498184637723" FOLDED="true" ID="ID_429454753" MODIFIED="1498190252282" TEXT="arith 8/8">
<node CREATED="1498184815386" ID="ID_834210839" MODIFIED="1498184820367">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Let's consult the effector map... */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (!eff_map[EFF_APOS(i)]) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;stage_max -= 2 * ARITH_MAX;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;continue;
    </p>
    <p>
      &#160;&#160;&#160;&#160;}
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498190168529" ID="ID_1569355680" MODIFIED="1498190170783" TEXT="u8 orig = out_buf[i];"/>
<node CREATED="1498190171977" ID="ID_917821519" MODIFIED="1498190232837">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      for (j = 1; j &lt;= ARITH_MAX; j++) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;u8 r = orig ^ (orig + j);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;/* Do arithmetic operations only if the result couldn't be a product
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;of a bitflip. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;if (!could_be_bitflip(r)) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;stage_cur_val = j;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;out_buf[i] = orig + j;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;stage_cur++;
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
<node CREATED="1498190255144" FOLDED="true" ID="ID_1758205555" MODIFIED="1498190923337" TEXT="arith 16/8">
<node CREATED="1498190282088" ID="ID_1992389770" MODIFIED="1498190286682">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Let's consult the effector map... */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (!eff_map[EFF_APOS(i)] &amp;&amp; !eff_map[EFF_APOS(i + 1)]) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;stage_max -= 4 * ARITH_MAX;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;continue;
    </p>
    <p>
      &#160;&#160;&#160;&#160;}
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498190377507" ID="ID_1060388768" MODIFIED="1498190381928">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      stage_cur_val = j;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u16*)(out_buf + i) = orig + j;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;stage_cur++;
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
<node CREATED="1498190919900" FOLDED="true" ID="ID_1949856254" MODIFIED="1498191215973" TEXT="arith 32/8">
<node CREATED="1498190925546" ID="ID_1035592039" MODIFIED="1498191194681">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Let's consult the effector map... */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (!eff_map[EFF_APOS(i)] &amp;&amp; !eff_map[EFF_APOS(i + 1)] &amp;&amp;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;!eff_map[EFF_APOS(i + 2)] &amp;&amp; !eff_map[EFF_APOS(i + 3)]) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;stage_max -= 4 * ARITH_MAX;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;continue;
    </p>
    <p>
      &#160;&#160;&#160;&#160;}
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498191196645" ID="ID_1479335631" MODIFIED="1498191213791">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      *(u32*)(out_buf + i) = orig + j;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
</node>
<node CREATED="1498191243964" FOLDED="true" ID="ID_1753914654" MODIFIED="1498191936782" TEXT="interest">
<node CREATED="1498191248613" FOLDED="true" ID="ID_692781294" MODIFIED="1498191758961" TEXT="interest 8/8">
<node CREATED="1498191356125" ID="ID_1820013523" MODIFIED="1498191360991">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      if (!eff_map[EFF_APOS(i)]) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;stage_max -= sizeof(interesting_8);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;continue;
    </p>
    <p>
      &#160;&#160;&#160;&#160;}
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498191415480" ID="ID_317641077" MODIFIED="1498191420256">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      #define INTERESTING_8 \
    </p>
    <p>
      &#160;&#160;-128,&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Overflow signed 8-bit when decremented&#160;&#160;*/ \
    </p>
    <p>
      &#160;&#160;-1,&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/*&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*/ \
    </p>
    <p>
      &#160;&#160;&#160;0,&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/*&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*/ \
    </p>
    <p>
      &#160;&#160;&#160;1,&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/*&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*/ \
    </p>
    <p>
      &#160;&#160;&#160;16,&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* One-off with common buffer size&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*/ \
    </p>
    <p>
      &#160;&#160;&#160;32,&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* One-off with common buffer size&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*/ \
    </p>
    <p>
      &#160;&#160;&#160;64,&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* One-off with common buffer size&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*/ \
    </p>
    <p>
      &#160;&#160;&#160;100,&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* One-off with common buffer size&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*/ \
    </p>
    <p>
      &#160;&#160;&#160;127&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Overflow signed 8-bit when incremented&#160;&#160;*/
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498191716687" ID="ID_1760582754" MODIFIED="1498191722439">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      for (j = 0; j &lt; sizeof(interesting_8); j++) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;/* Skip if the value could be a product of bitflips or arithmetics. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;if (could_be_bitflip(orig ^ (u8)interesting_8[j]) ||
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;could_be_arith(orig, (u8)interesting_8[j], 1)) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;stage_max--;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;continue;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498191739861" ID="ID_1956907413" MODIFIED="1498191748451">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      stage_cur_val = interesting_8[j];
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;out_buf[i] = interesting_8[j];
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
<node CREATED="1498191779082" FOLDED="true" ID="ID_486106963" MODIFIED="1498191870785" TEXT="interest 16/8">
<node CREATED="1498191783653" ID="ID_9629934" MODIFIED="1498191806253">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Let's consult the effector map... */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (!eff_map[EFF_APOS(i)] &amp;&amp; !eff_map[EFF_APOS(i + 1)]) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;stage_max -= sizeof(interesting_16);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;continue;
    </p>
    <p>
      &#160;&#160;&#160;&#160;}
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498191848082" ID="ID_1527914226" MODIFIED="1498191854231">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      if (!could_be_bitflip(orig ^ (u16)interesting_16[j]) &amp;&amp;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;!could_be_arith(orig, (u16)interesting_16[j], 2) &amp;&amp;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;!could_be_interest(orig, (u16)interesting_16[j], 2, 0)) {
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498191856015" ID="ID_772156572" MODIFIED="1498191867014" TEXT="*(u16*)(out_buf + i) = interesting_16[j];          if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;"/>
</node>
<node CREATED="1498191872038" FOLDED="true" ID="ID_545700158" MODIFIED="1498191920079" TEXT="interest 32/8">
<node CREATED="1498191912312" ID="ID_791246616" MODIFIED="1498191917138">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      *(u32*)(out_buf + i) = interesting_32[j];
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
</node>
<node CREATED="1498191938071" FOLDED="true" ID="ID_1731411285" MODIFIED="1498274323094" TEXT="DICTIONARY">
<node CREATED="1498191941958" ID="ID_1319604856" MODIFIED="1498193907112" TEXT="user extras (over)">
<node CREATED="1498193827601" ID="ID_1962440507" MODIFIED="1498193832067">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      last_len = extras[j].len;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;memcpy(out_buf + i, extras[j].data, last_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
<node CREATED="1498193929817" ID="ID_1779390823" MODIFIED="1498193931928" TEXT="user extras (insert)">
<node CREATED="1498193934021" ID="ID_1835516658" MODIFIED="1498193965607">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Insert token */
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;memcpy(ex_tmp + i, extras[j].data, extras[j].len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;/* Copy tail */
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;memcpy(ex_tmp + i + extras[j].len, out_buf + i, len - i);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;if (common_fuzz_stuff(argv, ex_tmp, len + extras[j].len)) {
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
<node CREATED="1498193989043" ID="ID_881276583" MODIFIED="1498193990859" TEXT="auto extras (over)">
<node CREATED="1498194017420" ID="ID_923149036" MODIFIED="1498194021804">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      last_len = a_extras[j].len;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;memcpy(out_buf + i, a_extras[j].data, last_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;if (common_fuzz_stuff(argv, out_buf, len)) goto abandon_entry;
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
</node>
<node CREATED="1498194067318" FOLDED="true" ID="ID_714762161" MODIFIED="1498274324655" TEXT="havoc">
<node CREATED="1498204832107" ID="ID_817825302" MODIFIED="1498204968766" TEXT="stage_max   = (doing_det ? HAVOC_CYCLES_INIT : HAVOC_CYCLES) * perf_score / havoc_div / 100; &#x8fd9;&#x91cc;&#x7684;&#x6b21;&#x6570;&#x4e0e;&#x5206;&#x6570;&#x6709;&#x5173;"/>
<node CREATED="1498205034663" ID="ID_637103241" MODIFIED="1498205111232">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#26159;&#19968;&#20010;&#32452;&#21512;
    </p>
    <p>
      for (stage_cur = 0; stage_cur &lt; stage_max; stage_cur++) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;u32 use_stacking = 1 &lt;&lt; (1 + UR(HAVOC_STACK_POW2));
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;stage_cur_val = use_stacking;
    </p>
    <p>
      &#160;
    </p>
    <p>
      &#160;&#160;&#160;&#160;for (i = 0; i &lt; use_stacking; i++) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;switch (UR(15 + ((extras_cnt + a_extras_cnt) ? 2 : 0))) {
    </p>
  </body>
</html></richcontent>
<node CREATED="1498205826849" FOLDED="true" ID="ID_1032326856" MODIFIED="1498205834456" TEXT="flip">
<node CREATED="1498205115451" ID="ID_598494614" MODIFIED="1498205164742">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 0:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Flip a single bit somewhere. Spooky! */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;FLIP_BIT(out_buf, UR(temp_len &lt;&lt; 3));
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498205682402" FOLDED="true" ID="ID_1533527174" MODIFIED="1498205797568" TEXT="interesting">
<node CREATED="1498205147830" ID="ID_299400724" MODIFIED="1498205182784">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 1:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Set byte to interesting value. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;out_buf[UR(temp_len)] = interesting_8[UR(sizeof(interesting_8))];
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498205184124" ID="ID_1589745625" MODIFIED="1498205214120">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#160;case 2:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Set word to interesting value, randomly choosing endian. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len &lt; 2) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (UR(2)) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u16*)(out_buf + UR(temp_len - 1)) =
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;interesting_16[UR(sizeof(interesting_16) &gt;&gt; 1)];
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} else {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u16*)(out_buf + UR(temp_len - 1)) = SWAP16(
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;interesting_16[UR(sizeof(interesting_16) &gt;&gt; 1)]);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498205217331" ID="ID_20026886" MODIFIED="1498205233208">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 3:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Set dword to interesting value, randomly choosing endian. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len &lt; 4) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (UR(2)) {
    </p>
    <p>
      &#160;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u32*)(out_buf + UR(temp_len - 3)) =
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;interesting_32[UR(sizeof(interesting_32) &gt;&gt; 2)];
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} else {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u32*)(out_buf + UR(temp_len - 3)) = SWAP32(
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;interesting_32[UR(sizeof(interesting_32) &gt;&gt; 2)]);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498205586613" FOLDED="true" ID="ID_413106184" MODIFIED="1498205663153" TEXT="+-">
<node CREATED="1498205239567" ID="ID_406061194" MODIFIED="1498205285679">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 4:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Randomly subtract from byte. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;out_buf[UR(temp_len)] -= 1 + UR(ARITH_MAX);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498205288317" ID="ID_1242864006" MODIFIED="1498205372848">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 5:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Randomly add to byte. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;out_buf[UR(temp_len)] += 1 + UR(ARITH_MAX);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498205374624" ID="ID_1697952454" MODIFIED="1498205391774">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 6:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Randomly subtract from word, random endian. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len &lt; 2) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (UR(2)) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 pos = UR(temp_len - 1);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u16*)(out_buf + pos) -= 1 + UR(ARITH_MAX);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} else {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 pos = UR(temp_len - 1);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u16 num = 1 + UR(ARITH_MAX);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u16*)(out_buf + pos) =
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;SWAP16(SWAP16(*(u16*)(out_buf + pos)) - num);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498205399710" ID="ID_1435857333" MODIFIED="1498205438359">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 7:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Randomly add to word, random endian. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len &lt; 2) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (UR(2)) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 pos = UR(temp_len - 1);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u16*)(out_buf + pos) += 1 + UR(ARITH_MAX);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} else {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 pos = UR(temp_len - 1);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u16 num = 1 + UR(ARITH_MAX);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u16*)(out_buf + pos) =
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;SWAP16(SWAP16(*(u16*)(out_buf + pos)) + num);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498205440086" ID="ID_827573377" MODIFIED="1498205457397">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 8:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Randomly subtract from dword, random endian. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len &lt; 4) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (UR(2)) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 pos = UR(temp_len - 3);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u32*)(out_buf + pos) -= 1 + UR(ARITH_MAX);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} else {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 pos = UR(temp_len - 3);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 num = 1 + UR(ARITH_MAX);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u32*)(out_buf + pos) =
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;SWAP32(SWAP32(*(u32*)(out_buf + pos)) - num);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1498205460038" ID="ID_599776178" MODIFIED="1498205474557">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 9:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Randomly add to dword, random endian. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len &lt; 4) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (UR(2)) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 pos = UR(temp_len - 3);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u32*)(out_buf + pos) += 1 + UR(ARITH_MAX);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} else {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 pos = UR(temp_len - 3);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 num = 1 + UR(ARITH_MAX);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;*(u32*)(out_buf + pos) =
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;SWAP32(SWAP32(*(u32*)(out_buf + pos)) + num);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498205812657" FOLDED="true" ID="ID_883048983" MODIFIED="1498205820432" TEXT="random">
<node CREATED="1498205478409" ID="ID_1432308968" MODIFIED="1498205500392">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 10:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Just set a random byte to a random value. Because,
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;why not. We use XOR with 1-255 to eliminate the
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;possibility of a no-op. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;out_buf[UR(temp_len)] ^= 1 + UR(255);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498205865992" FOLDED="true" ID="ID_34176432" MODIFIED="1498205877798" TEXT="delete">
<node CREATED="1498205555945" ID="ID_635081013" MODIFIED="1498205561678">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 11 ... 12: {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Delete bytes. We're making this a bit more likely
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;than insertion (the next option) in hopes of keeping
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;files reasonably small. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 del_from, del_len;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len &lt; 2) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Don't delete too much. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;del_len = choose_block_len(temp_len - 1);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;del_from = UR(temp_len - del_len + 1);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memmove(out_buf + del_from, out_buf + del_from + del_len,
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;temp_len - del_from - del_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;temp_len -= del_len;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498205929588" FOLDED="true" ID="ID_2771810" MODIFIED="1498206842608" TEXT="clone insert">
<node CREATED="1498205934185" ID="ID_986749648" MODIFIED="1498205939591">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 13:
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len + HAVOC_BLK_XL &lt; MAX_FILE) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Clone bytes (75%) or insert a block of constant bytes (25%). */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u8&#160;&#160;actually_clone = UR(4);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 clone_from, clone_to, clone_len;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u8* new_buf;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (actually_clone) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;clone_len&#160;&#160;= choose_block_len(temp_len);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;clone_from = UR(temp_len - clone_len + 1);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} else {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;clone_len = choose_block_len(HAVOC_BLK_XL);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;clone_from = 0;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;clone_to&#160;&#160;&#160;= UR(temp_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;new_buf = ck_alloc_nozero(temp_len + clone_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Head */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(new_buf, out_buf, clone_to);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Inserted part */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (actually_clone)
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(new_buf + clone_to, out_buf + clone_from, clone_len);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;else
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memset(new_buf + clone_to,
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;UR(2) ? UR(256) : out_buf[UR(temp_len)], clone_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Tail */
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(new_buf + clone_to + clone_len, out_buf + clone_to,
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;temp_len - clone_to);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;ck_free(out_buf);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;out_buf = new_buf;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;temp_len += clone_len;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498206845604" FOLDED="true" ID="ID_1721783745" MODIFIED="1498206881990" TEXT="overwrite block">
<node CREATED="1498206871886" ID="ID_686995130" MODIFIED="1498206877912">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 14: {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Overwrite bytes with a randomly selected chunk (75%) or fixed
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;bytes (25%). */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 copy_from, copy_to, copy_len;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len &lt; 2) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;copy_len&#160;&#160;= choose_block_len(temp_len - 1);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;copy_from = UR(temp_len - copy_len + 1);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;copy_to&#160;&#160;&#160;= UR(temp_len - copy_len + 1);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (UR(4)) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (copy_from != copy_to)
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memmove(out_buf + copy_to, out_buf + copy_from, copy_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} else memset(out_buf + copy_to,
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;UR(2) ? UR(256) : out_buf[UR(temp_len)], copy_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498206964223" FOLDED="true" ID="ID_240709750" MODIFIED="1498206983013" TEXT="overwrite extra">
<node CREATED="1498206974631" ID="ID_1016056434" MODIFIED="1498206980209">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 15: {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Overwrite bytes with an extra. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (!extras_cnt || (a_extras_cnt &amp;&amp; UR(2))) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* No user-specified extras or odds in our favor. Let's use an
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;auto-detected one. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 use_extra = UR(a_extras_cnt);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 extra_len = a_extras[use_extra].len;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 insert_at;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (extra_len &gt; temp_len) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;insert_at = UR(temp_len - extra_len + 1);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(out_buf + insert_at, a_extras[use_extra].data, extra_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} else {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* No auto extras or odds in our favor. Use the dictionary. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 use_extra = UR(extras_cnt);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 extra_len = extras[use_extra].len;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 insert_at;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (extra_len &gt; temp_len) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;insert_at = UR(temp_len - extra_len + 1);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(out_buf + insert_at, extras[use_extra].data, extra_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498207005686" FOLDED="true" ID="ID_1205663284" MODIFIED="1498207018154" TEXT="insert extra">
<node CREATED="1498207011885" ID="ID_832789234" MODIFIED="1498207016754">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      case 16: {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u32 use_extra, extra_len, insert_at = UR(temp_len + 1);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;u8* new_buf;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Insert an extra. Do the same dice-rolling stuff as for the
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;previous case. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (!extras_cnt || (a_extras_cnt &amp;&amp; UR(2))) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;use_extra = UR(a_extras_cnt);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;extra_len = a_extras[use_extra].len;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len + extra_len &gt;= MAX_FILE) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;new_buf = ck_alloc_nozero(temp_len + extra_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Head */
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(new_buf, out_buf, insert_at);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Inserted part */
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(new_buf + insert_at, a_extras[use_extra].data, extra_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;} else {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;use_extra = UR(extras_cnt);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;extra_len = extras[use_extra].len;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (temp_len + extra_len &gt;= MAX_FILE) break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;new_buf = ck_alloc_nozero(temp_len + extra_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Head */
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(new_buf, out_buf, insert_at);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Inserted part */
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(new_buf + insert_at, extras[use_extra].data, extra_len);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/* Tail */
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;memcpy(new_buf + insert_at + extra_len, out_buf + insert_at,
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;temp_len - insert_at);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;ck_free(out_buf);
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;out_buf&#160;&#160;&#160;= new_buf;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;temp_len += extra_len;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;break;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;}
    </p>
  </body>
</html></richcontent>
</node>
</node>
</node>
</node>
<node CREATED="1498272445127" FOLDED="true" ID="ID_1965587396" MODIFIED="1498274327901" TEXT="splicing">
<node CREATED="1498272448806" ID="ID_1598149443" MODIFIED="1498272473995">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Pick a random queue entry and seek to it. Don't splice with yourself. */
    </p>
    <p>
      &#160;&#160;&#160;&#160;do { tid = UR(queued_paths); } while (tid == current_entry);
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498272476383" ID="ID_1621741578" MODIFIED="1498272491303">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      splicing_with = tid;
    </p>
    <p>
      &#160;&#160;&#160;&#160;target = queue;
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498272548027" ID="ID_1042935571" MODIFIED="1498272568190">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#36941;&#21382;&#21040;target
    </p>
    <p>
      while (tid &gt;= 100) { target = target-&gt;next_100; tid -= 100; }
    </p>
    <p>
      &#160;&#160;&#160;&#160;while (tid--) target = target-&gt;next;
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498272621310" ID="ID_1162501004" MODIFIED="1498272634902">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Read the testcase into a new buffer. */
    </p>
    <p>
      &#160;&#160;&#160;&#160;fd = open(target-&gt;fname, O_RDONLY);
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (fd &lt; 0) PFATAL(&quot;Unable to open '%s'&quot;, target-&gt;fname);
    </p>
    <p>
      &#160;&#160;&#160;&#160;new_buf = ck_alloc_nozero(target-&gt;len);
    </p>
    <p>
      &#160;&#160;&#160;&#160;ck_read(fd, new_buf, target-&gt;len, target-&gt;fname);
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498272638352" ID="ID_341474324" MODIFIED="1498272677528">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Find a suitable splicing location, somewhere between the first and
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;the last differing byte. Bail out if the difference is just a single
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;byte or so. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;locate_diffs(in_buf, new_buf, MIN(len, target-&gt;len), &amp;f_diff, &amp;l_diff);
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498272718374" ID="ID_1623726451" MODIFIED="1498272724000">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* Split somewhere between the first and last differing byte. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;split_at = f_diff + UR(l_diff - f_diff);
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498272820842" ID="ID_193544441" MODIFIED="1498272834005">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#32452;&#21512;&#160;
    </p>
    <p>
      len = target-&gt;len;
    </p>
    <p>
      &#160;&#160;&#160;&#160;memcpy(new_buf, in_buf, split_at);
    </p>
    <p>
      &#160;&#160;&#160;&#160;in_buf = new_buf;
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498272836134" ID="ID_1998766030" MODIFIED="1498272857957">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#32452;&#21512;&#20889;&#21040;out_buf&#160;
    </p>
    <p>
      ck_free(out_buf);
    </p>
    <p>
      &#160;&#160;&#160;&#160;out_buf = ck_alloc_nozero(len);
    </p>
    <p>
      &#160;&#160;&#160;&#160;memcpy(out_buf, in_buf, len);
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498272859759" ID="ID_23305813" MODIFIED="1498272884238" TEXT="goto havoc_stage; &#x56de;&#x53bb;&#x7ee7;&#x7eed;havoc"/>
</node>
</node>
<node CREATED="1498093513173" ID="ID_1954515654" MODIFIED="1498266472458" TEXT="queue_cur = queue_cur-&gt;next;     current_entry++;&#x904d;&#x5386;queue&#x94fe;&#x8868;&#xff0c;&#x901a;&#x8fc7;save_if_interesting&#x51fd;&#x6570;&#x4e0d;&#x65ad;&#x6709;&#x65b0;&#x7684;&#x6837;&#x672c;&#x94fe;&#x5165;&#x961f;&#x5217;"/>
<node CREATED="1498269710565" ID="ID_1670917215" MODIFIED="1498269721157" TEXT="&#x4e0d;&#x4f1a;&#x7ec8;&#x6b62;">
<node CREATED="1498269722889" ID="ID_180959819" MODIFIED="1498269729454">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#160;&#160;while (1) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;u8 skipped_fuzz;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;cull_queue();
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;if (!queue_cur) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;queue_cycle++;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;current_entry&#160;&#160;&#160;&#160;&#160;= 0;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;cur_skipped_paths = 0;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;queue_cur&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;= queue;
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498269742056" ID="ID_583861225" MODIFIED="1498269768673" TEXT="&#x5982;&#x679c;queue_cur&#x4e3a;&#x7a7a;&#x7684;&#x8bdd;&#xff0c;&#x4f1a;&#x88ab;&#x91cd;&#x65b0;&#x8d4b;&#x503c;&#xff0c;&#x518d;&#x8dd1;&#x4e00;&#x904d;"/>
</node>
<node CREATED="1498273043265" ID="ID_1015259239" MODIFIED="1498273166346">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#22914;&#26524;&#19968;&#36718;&#32467;&#26463;&#20102;&#36824;&#27809;&#26377;&#26032;&#30340;&#21457;&#29616;&#65288;&#26032;&#30340;&#36335;&#24452;&#21152;&#20837;queue&#65289;&#30340;&#35805;&#65292;&#20351;&#29992;splice&#30340;&#26041;&#27861;
    </p>
  </body>
</html>
</richcontent>
<node CREATED="1498273065570" ID="ID_1273461730" MODIFIED="1498273070995">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      /* If we had a full queue cycle with no new finds, try
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;recombination strategies next. */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;if (queued_paths == prev_queued) {
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;if (use_splicing) cycles_wo_finds++; else use_splicing = 1;
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;} else cycles_wo_finds = 0;
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
</node>
<node CREATED="1498137223006" FOLDED="true" ID="ID_1628928053" MODIFIED="1498265609943" POSITION="right" TEXT="static void show_stats(void) {">
<node CREATED="1498137327607" ID="ID_569992267" MODIFIED="1498137414733">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      t_bytes = count_non_255_bytes(virgin_bits);
    </p>
    <p>
      &#160;&#160;t_byte_ratio = ((double)t_bytes * 100) / MAP_SIZE;
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498137491374" ID="ID_818551639" MODIFIED="1498137492840" TEXT="stab_ratio = 100 - ((double)var_byte_count) * 100 / t_bytes;"/>
<node CREATED="1498137548251" ID="ID_1326497693" MODIFIED="1498137549827" TEXT="if (cur_ms - last_stats_ms &gt; STATS_UPDATE_SEC * 1000) {">
<node CREATED="1498137551474" FOLDED="true" ID="ID_800345782" MODIFIED="1498138462527" TEXT="write_stats_file(t_byte_ratio, stab_ratio, avg_exec);">
<node CREATED="1498137647594" ID="ID_154590281" MODIFIED="1498137649212" TEXT="u8* fn = alloc_printf(&quot;%s/fuzzer_stats&quot;, out_dir);"/>
<node CREATED="1498137664002" ID="ID_485411797" MODIFIED="1498137665395" TEXT="fd = open(fn, O_WRONLY | O_CREAT | O_TRUNC, 0600);"/>
<node CREATED="1498137680408" ID="ID_405168554" MODIFIED="1498137681774" TEXT="f = fdopen(fd, &quot;w&quot;);"/>
<node CREATED="1498137734429" ID="ID_1501524167" MODIFIED="1498137752138">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      fprintf(f, &quot;start_time&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;: %llu\n&quot;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498137877033" ID="ID_1236134207" MODIFIED="1498137899714" TEXT="cycles_done,     queue_cycle"/>
</node>
<node CREATED="1498137577275" FOLDED="true" ID="ID_1904276159" MODIFIED="1498138455479" TEXT="save_auto();">
<node CREATED="1498138136107" ID="ID_868014940" MODIFIED="1498138137753" TEXT="if (!auto_changed) return;"/>
<node CREATED="1498138290843" ID="ID_961834741" MODIFIED="1498138292590" TEXT="static void maybe_add_auto(u8* mem, u32 len) {">
<node CREATED="1498138264731" ID="ID_209770631" MODIFIED="1498138270013">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      a_extras = ck_realloc_block(a_extras, (a_extras_cnt + 1) *
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;sizeof(struct extra_data));
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;&#160;&#160;a_extras[a_extras_cnt].data = ck_memdup(mem, len);
    </p>
    <p>
      &#160;&#160;&#160;&#160;a_extras[a_extras_cnt].len&#160;&#160;= len;
    </p>
    <p>
      &#160;&#160;&#160;&#160;a_extras_cnt++;
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1498138328125" ID="ID_1882325734" MODIFIED="1498138343307">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      for (i = 0; i &lt; MIN(USE_AUTO_EXTRAS, a_extras_cnt); i++) {
    </p>
    <p>
      &#160;&#160;&#160;&#160;u8* fn = alloc_printf(&quot;%s/queue/.state/auto_extras/auto_%06u&quot;, out_dir, i);
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498138337759" ID="ID_431397878" MODIFIED="1498138354358" TEXT="fd = open(fn, O_WRONLY | O_CREAT | O_TRUNC, 0600);"/>
<node CREATED="1498138355459" ID="ID_38614011" MODIFIED="1498138366663" TEXT="ck_write(fd, a_extras[i].data, a_extras[i].len, fn);"/>
</node>
<node CREATED="1498137580673" FOLDED="true" ID="ID_67586785" MODIFIED="1498138696334" TEXT="write_bitmap();">
<node CREATED="1498138592167" ID="ID_300942036" MODIFIED="1498138600290" TEXT="case &apos;B&apos; main&#x9009;&#x9879;">
<node CREATED="1498138622096" ID="ID_1123020518" MODIFIED="1498138628505">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      in_bitmap = optarg;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;read_bitmap(in_bitmap);
    </p>
  </body>
</html>
</richcontent>
<node CREATED="1498138634900" ID="ID_551938702" MODIFIED="1498138678788" TEXT="s32 fd = open(fname, O_RDONLY);"/>
<node CREATED="1498138679721" ID="ID_1100888396" MODIFIED="1498138687500" TEXT="ck_read(fd, virgin_bits, MAP_SIZE, fname);"/>
</node>
</node>
<node CREATED="1498138449918" ID="ID_1368459277" MODIFIED="1498138451552" TEXT="if (!bitmap_changed) return;"/>
<node CREATED="1498138490068" ID="ID_516101661" MODIFIED="1498138495538">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      fname = alloc_printf(&quot;%s/fuzz_bitmap&quot;, out_dir);
    </p>
    <p>
      &#160;&#160;fd = open(fname, O_WRONLY | O_CREAT | O_TRUNC, 0600);
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498138524548" ID="ID_1859236185" MODIFIED="1498138526088" TEXT="ck_write(fd, virgin_bits, MAP_SIZE, fname);"/>
</node>
</node>
<node CREATED="1498138735616" FOLDED="true" ID="ID_1142507769" MODIFIED="1498138972491" TEXT="maybe_update_plot_file(t_byte_ratio, avg_exec);">
<node CREATED="1498138831018" ID="ID_1901678568" MODIFIED="1498138836472">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      fprintf(plot_file,
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&quot;%llu, %llu, %u, %u, %u, %u, %0.02f%%, %llu, %llu, %u, %0.02f\n&quot;,
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;get_cur_time() / 1000, queue_cycle - 1, current_entry, queued_paths,
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;pending_not_fuzzed, pending_favored, bitmap_cvg, unique_crashes,
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;unique_hangs, max_depth, eps); /* ignore errors */
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;fflush(plot_file);
    </p>
  </body>
</html>
</richcontent>
</node>
<node CREATED="1498138885049" ID="ID_1493477470" MODIFIED="1498138921979">
<richcontent TYPE="NODE"><html>
  <head>
    
  </head>
  <body>
    <p>
      &#22312;setup_dirs_fds&#20989;&#25968;&#20013;
    </p>
    <p>
      tmp = alloc_printf(&quot;%s/plot_data&quot;, out_dir);
    </p>
    <p>
      &#160;&#160;fd = open(tmp, O_WRONLY | O_CREAT | O_EXCL, 0600);
    </p>
    <p>
      &#160;&#160;if (fd &lt; 0) PFATAL(&quot;Unable to create '%s'&quot;, tmp);
    </p>
    <p>
      &#160;&#160;ck_free(tmp);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;plot_file = fdopen(fd, &quot;w&quot;);
    </p>
    <p>
      &#160;&#160;if (!plot_file) PFATAL(&quot;fdopen() failed&quot;);
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;fprintf(plot_file, &quot;# unix_time, cycles_done, cur_path, paths_total, &quot;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&quot;pending_total, pending_favs, map_size, unique_crashes, &quot;
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&quot;unique_hangs, max_depth, execs_per_sec\n&quot;);
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
<node CREATED="1498140441093" ID="ID_10946753" MODIFIED="1498140550001" TEXT="define SAYF(x...)    printf(x) &#x5728;debug.h&#x4e2d;"/>
<node CREATED="1498144910865" ID="ID_845456812" MODIFIED="1498144912413" TEXT=" map density : 0.01% / 0.01%">
<node CREATED="1498144914103" ID="ID_847396984" MODIFIED="1498145048326" TEXT="((double)queue_cur-&gt;bitmap_size) * 100 / MAP_SIZE &#x5f53;&#x524d;&#x7684;&#x6837;&#x672c;&#x8986;&#x76d6;&#x7387;"/>
<node CREATED="1498144963451" ID="ID_743984872" MODIFIED="1498144973691" TEXT="t_byte_ratio">
<node CREATED="1498145020132" ID="ID_890297898" MODIFIED="1498145066462" TEXT="t_bytes = count_non_255_bytes(virgin_bits);   t_byte_ratio = ((double)t_bytes * 100) / MAP_SIZE; &#x76ee;&#x524d;&#x6240;&#x6709;&#x6837;&#x672c;&#x7684;&#x8986;&#x76d6;&#x7387;"/>
</node>
</node>
</node>
</node>
</map>
