# Go-learning
go-learning --将之前学习go语言过程 开发/改造扫描器的过程记录下来

这里主要是我学习GO的过程，学习的书籍是雨痕老师写的

python作为主要编程语言的扫描器叫证道玉，
是内部使用的扫描器，用其在代码审计和黑盒测试中，让我收获了大量的xx。

go扫描器其实和证道玉是同一个原理，就是主要编程语言变成了Go，辅以python代码；
之前研究过一下go+python，两种方法：一是讲go语言打包成so动态链接库，利用python的ctypes模块可以调用
二是go写成接口，提供python调用。觉得第一种好一点，尽管使用python去调用go会有一些性能上的损耗，但总体上还可以。

<del>go版本扫描器目前正在coding</del>

证道玉扫描器在16年就基本完成，最近也只是在完善功能而已，大体的框架都没有改。
功能结构：
```
zhengdaoyu 证道玉扫描器

├─ActiveScan 主动扫描系统
│  │
│  ├─Infornation 信息收集模块
│  │  ├─PortScan 端口扫描功能
│  │  ├─subDomain 子域名枚举功能
│  │  ├─URLHack 搜索引擎hack功能
│  │  ├─whois whois信息收集功能
│  │  ├─whatCMS cms中间件识别功能
│  │  ├─whatWAF 探测WAF功能
│  │  └─WeakFile 敏感文件扫描功能
│  ├─Spider 爬虫模块
│  │  ├─SuperSpdier 启发式web爬虫功能
│  │  └─GamFinder 社交平台（twitter，facebook等）爬虫功能
│  ├─VulnCheck 漏洞检测模块
│  │  ├─Inject 注入检测功能
│  │  │  ├─Sqlmap-Api sqlmapapi接口调用子功能
│  │  │  ├─FingerInject 自定义根据各种情景变化注入子功能
│  │  │  └─X-waf 自动化爆破waf功能
│  │  ├─PocScan 批量poc测试功能
│  │  ├─xss xss漏洞检测功能，包含dom检测方式
│  │  ├─RCE 命令执行/代码执行检测功能
│  │  ├─Download 下载敏感文件功能
│  │  └─Other0day 如文件操作、ssrf、0day poc等其他检测功能
│  ├─Report 报告模块
│  │  ├─HTML 导出HTML报告功能
│  │  ├─PDF 导出PDF报告功能
│  │  └─Log 扫描日志功能
│  └─WebUI （未完成）web界面模块
│
├─PassiveScan 被动扫描系统
│  │
│  ├─DataSorting 流量镜像数据源数据处理模块
│  ├─LogSorting 日志数据源数据处理模块
│  ├─SecCheck 漏洞验证模块
│  ├─Proxy 代理以及任务分发模块
│  ├─Report 被动扫描日志模块
│  └─WebUI web界面模块
│
├─AuditScan 代码审计系统
│  │
│  ├─CodeAudit 白盒代码审计模块
│  │  ├─StaticAudit 静态代码扫描审计功能（AST）
│  │  └─DynamicAudit 动态代码跟踪审计功能（仅php）
│  ├─GlassAudit 灰盒代码审计模块
│  │  ├─skywolfapi 调用360 skywolf api 进行代码追踪审计功能
│  │  └─GlassAudit 插桩式代码审计功能
│  └─Report 报告模块
│
├─F-DeepLearning 深度学习调度分发与训练系统（基于HDFS java实现）
│  │
│  ├─F-Learning 深度学习调度模块（已完成TensorFlow caffe pytorch Keras XGBoost等常用框架集成）
│  │  ├─F-DL-Master 负责输入数据分片、启动及管理Container、执行日志保存等功能
│  │  ├─F-DL-Client 负责启动作业及获取作业执行状态功能
│  │  ├─F-DL-Container 作业的实际执行者，负责启动Worker或PS进程，监控并向汇报进程状态等功能
│  │  └─WebUI web界面功能
│  ├─Rules 训练数据集及规则库模块
│  ├─PyTorch-self 定制化pytorch模块（未完成）
│  └─TensorFlow-Self 定制TF模块（定制版TensorFlow与扫描器功能接入，由TensorFlow训练出切实可行
│                              的payload规则，将规则赋予scanner测试性能。）
│
├─ControlRobot 机器人总控制系统（基于chatbot 功能未完善）
│  │
│  ├─qqapi qq接口robot
│  └─wxapi 微信接口robot

ps：其中x-waf来自于大佬 https://github.com/3xp10it/bypass_waf 的项目;
尽管我重构了相当多代码，但是依然使用大佬项目名字以示尊重。

```

以上python项目应该不会开源。go扫描器正在开源路上，逐一完成。如对本人算法项目，机器学习，深度学习项目感兴趣的话，请移步本人另一个github。

go扫描器将在macarena项目上更新。
