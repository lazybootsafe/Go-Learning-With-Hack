### kunpeng代码赏析

此项目作者为``@ywolf `` 项目地址为 ``https://github.com/opensec-cn/kunpeng``  
是我非常喜欢的一个项目和大佬.  

[项目readme](https://github.com/opensec-cn/kunpeng/blob/master/README.md)  
先看这个原项目README是对作者们辛勤劳动的认可.

根据官方文档的介绍，这个项目是以动态链接库的形式提供给Go以及其他语言进行调用的，因此会存在调用方和被调用方两个角色，请大家仔细区分。
```
目录  
代码赏析  
其他语言调用  
```

### 代码赏析
#### 获取对象
调用方调用plugin包加载so文件，并获取其中的Greeter对象：  
```go
plug, _ := plugin.Open("./kunpeng_go.so")
g, _ := plug.Lookup("Greeter")
```
由于Plugin.Lookup()获得的是一个interface{}类型对象，需要将其进行一次类型断言才能访问到Greeter对象内的公有属性。好在Go具有非侵入式接口的语言特性，使调用方在本地定义一个属于Greeter对象公有方法子集的接口就能断言成功：
```go
type Greeter interface {
	Check(string) ([]map[string]string)
	GetPlugins() []map[string]string
        ...
}

// omit
kunpeng, ok := g.(Greeter)
// kunpeng.GetPlugins()
```
#### 执行检测  
调用方定义一个Task结构体，实例化后转成JSON字符串传给Greeter.Check()，即可等待检测结果：  
```go
type Meta struct {
	System   string   `json:"system"`
	PathList []string `json:"pathlist"`
	FileList []string `json:"filelist"`
	PassList []string `json:"passlist"`
}

type Task struct {
	Type   string `json:"type"`
	Netloc string `json:"netloc"`
	Target string `json:"target"`
	Meta   Meta   `json:"meta"`
}

// omit
task, _ := json.Marshal(Task{"service", "0.0.0.0:0000", "mysql", Meta{}})
result := kunpeng.Check(string(task))
```
被调用方的Check()在解析JSON字符串拿到plugin.Task对象 （结构体与调用方定义的Task一致） 后，直接交给plugin.Scan()去执行实际检测逻辑，拿到的结果又转成JSON字符串返回：
```go
func Check(task *C.char) *C.char {
	var m plugin.Task
        if err := json.Unmarshal([]byte(C.GoString(task)), &m); err != nil {
	        return C.CString("[]")
	}
	result := plugin.Scan(m)
	if len(result) == 0{
		return C.CString("[]")
	}
	b, err := json.Marshal(result)
	if err != nil {
	        return C.CString("[]")
	}
	return C.CString(string(b))
}
```
从上面的代码中可以看到，为了支持跨语言调用，KunPeng使用更底层兼容性更高的CGo来处理几个入口函数中的原始数据类型。

plugin.Scan()分别遍历GoPlugins和JSONPlugins （两种类型插件的具体区别见下面插件开发和插件加载章节） ，根据Task的Target字段选择PoC子集进行检测并返回结果集合：
```go
func Scan(task Task) (result []map[string]interface{}) {
	for n, pluginList := range GoPlugins {
		if strings.Contains(strings.ToLower(task.Target), strings.ToLower(n)) || task.Target == "all" {
			for _, plugin := range pluginList {
				plugin.Init()
				if len(task.Meta.PassList) == 0 {
					task.Meta.PassList = Config.PassList
				}
				if !plugin.Check(task.Netloc, task.Meta) {
					continue
				}
				for _, res := range plugin.GetResult() {
					result = append(result, util.Struct2Map(res))
				}
			}
		}
	}
	if task.Type == "service" {
		return result
	}
	for target, pluginList := range JSONPlugins {
		if strings.Contains(strings.ToLower(task.Target), strings.ToLower(target)) || task.Target == "all" {
			for _, plugin := range pluginList {
				if yes, res := jsonCheck(task.Netloc, plugin); yes {
					result = append(result, util.Struct2Map(res))
				}
			}
		}
	}
	return result
}
```
#### 插件开发
##### Go类型插件

KunPeng定义了一个用于描述插件信息的公有结构体Plugin：
```go
type References struct {
	URL string `json:"url"`
	CVE string `json:"cve"`
}

type Plugin struct {
	Name       string     `json:"name"`
	Remarks    string     `json:"remarks"`
	Level      int        `json:"level"`
	Type       string     `json:"type"`
	Author     string     `json:"author"`
	References References `json:"references"`
	Request    string
	Response   string
}
以及公有接口GoPlugin：

type GoPlugin interface {
	Init() Plugin
	Check(string, TaskMeta) bool
	GetResult() []Plugin
}
```
由于KunPeng未定义插件的相关基类及缺省字段和方法，所以我们需要在plugin/go/目录下创建一个新的.go文件，在其中自定义一个包含info和result字段的结构体来表示新的插件：
```go
type pluginXXX struct {
	info   plugin.Plugin
	result []plugin.Plugin
}
```
随后，为该结构体实现GoPlugin接口中所有的方法：
```go
func (p *pluginXXX) Init() plugin.Plugin {
    p.info = plugin.Plugin{}
}

func (p *pluginXXX) Check(netloc string, meta TaskMeta) bool {
    // 自定义检测过程逻辑，成功返回true，失败返回false
    return false
}

func (p *pluginXXX) GetResult() []plugin.Plugin {
    return p.result
}
```
并在文件的init()方法中调用plugin.Regist()注册该插件即可：
```go
func init() {
	plugin.Regist("xxx", new(plugin))
}
```
##### JSON类型插件

KunPeng同样为我们准备好了用于描述JSON插件信息的公有结构体JSONPlugin，并对它实现了统一的检测方法jsonCheck()：
```go
type JSONPlugin struct {
	Target  string `json:"target"`
	Meta    Plugin `json:"meta"`
	Request struct {
		Path     string `json:"path"`
		PostData string `json:"postdata"`
	} `json:"request"`
	Verify struct {
		Type  string `json:"type"`
		Match string `json:"match"`
	} `json:"verify"`
}

func jsonCheck(URL string, p JSONPlugin) (bool, Plugin) {
    // 常规的HTTP发包和结果比较，略
    return false, result
}
```
我们可以在plugin/json/目录下创建一个新的.json文件，写入我们需要的信息 （具体内容参考官方文档） 即可：
```json
{
    "target": "xxx",
    "meta": {
        "name": "xxx",
        "remarks": "xxx",
        "level": 0,
        "type": "RCE",
        "author": "gyyyy",
        "references": {
              "url": "https://github.com/gyyyy/",
              "cve": ""
        }
    },
    "request":{
        "path": "/index.html",
        "postData": ""
    },
    "verify":{
        "type": "string",
        "match": "gyyyy"
    }
}
```
#### 插件加载
##### Go类型插件

前面说了，Go类型插件需要在init()时进行注册，Regist()会将插件对象以target为键放入GoPlugins集合，并初始化插件信息：
```go
func Regist(target string, plugin GoPlugin) {
	GoPlugins[target] = append(GoPlugins[target], plugin)
	var pluginInfo = plugin.Init()
}
```
由于入口文件中匿名导入了plugin/go包，所以在程序启动时，所有编写好的Go类型插件就都会init()到GoPlugins中完成加载。

##### JSON类型插件

相比之下，JSON类型插件的加载过程就要繁琐一些。

入口文件匿名导入plugin/json包后，会调用plugin/json/init.go文件中的init()方法进行加载：
```go
func init() {
	loadJSONPlugin(false, "/plugin/json/")
	go loadExtraJSONPlugin()
}
```
loadJSONPlugin()遍历目录中的所有.json文件，交给readPlugin()进行处理。readPlugin()读取文件后将JSON字符串解析为JSONPlugin对象返回，所有非重复插件对象将以target为键全部放入JSONPlugins集合中。

而新开的Goroutine调用loadExtraJSONPlugin()，每隔20秒对配置的extra_plugin_path目录执行loadJSONPlugin()操作进行加载。
为了节省篇幅这里就不细述了。
### 其他语言调用(go-python)
这里有个很典型的例子就是go语言做动态链接库so dll或者其他形式被调用,比如我是一个python开发者,不会使用go语言进行开发编程,那就直接下载对应的so或者dll ,python调用即可.  
[官方原版call-so.py](call-so.py)  
```python
# coding:utf-8

import sys
import time
import json
from ctypes import *


def _args_encode(args_string):
    '''Encode by utf-8 in PY3.'''
    if sys.version_info >= (3, 0):
        args_string = args_string.encode('utf-8')
    return args_string


# 加载动态连接库
kunpeng = cdll.LoadLibrary('./kunpeng_c.so')

# 定义出入参变量类型
kunpeng.GetPlugins.restype = c_char_p
kunpeng.Check.argtypes = [c_char_p]
kunpeng.Check.restype = c_char_p
kunpeng.SetConfig.argtypes = [c_char_p]
kunpeng.GetVersion.restype = c_char_p

print(kunpeng.GetVersion())

# 获取插件信息
out = kunpeng.GetPlugins()

# 修改配置
config = {
    'timeout': 10,
    # 'aider': 'http://xxxx:8080',
    # 'http_proxy': 'http://xxxxx:1080',
    # 'pass_list':['xtest']
    # 'extra_plugin_path': '/home/test/plugin/',
}

conf_args = json.dumps(config)
kunpeng.SetConfig(_args_encode(conf_args))

# 开启日志打印
kunpeng.ShowLog()

# 扫描目标
task = {
    'type': 'web',
    'netloc': 'http://www.google.cn',
    'target': 'web',
    'meta':{
        'system': '',
        'pathlist':[],
        'filelist':[],
        'passlist':[]
    }
}
task2 = {
    'type': 'service',
    'netloc': '192.168.0.105:3306',
    'target': 'mysql',
    'meta':{
        'system': '',
        'pathlist':[],
        'filelist':[],
        'passlist':[]
    }
}

task = _args_encode(json.dumps(task))
task2 = _args_encode(json.dumps(task2))

out = kunpeng.Check(task)
print(json.loads(out))
out = kunpeng.Check(task2)
print(json.loads(out))
```
可以看到在扫描目标添加task这里,有点麻烦,所以我改进一下,变成多线程和url.txt的模式.  
[改版后调用文件](call-so-txt.py)

```python
# coding:utf-8
# 3.7 test pass by finger

import sys
import time
import json
from ctypes import *
import threading


def _args_encode(args_string):
    '''Encode by utf-8 in PY3.'''
    if sys.version_info >= (3, 0):
        args_string = args_string.encode('utf-8')
    return args_string


# 加载动态连接库
kunpeng = cdll.LoadLibrary('./kunpeng_c.so')

# 定义出入参变量类型
kunpeng.GetPlugins.restype = c_char_p
kunpeng.Check.argtypes = [c_char_p]
kunpeng.Check.restype = c_char_p
kunpeng.SetConfig.argtypes = [c_char_p]
kunpeng.GetVersion.restype = c_char_p

print(kunpeng.GetVersion())

# 获取插件信息
out = kunpeng.GetPlugins()
# print(out)

# 修改配置
config = {
    'timeout': 10,
    # 'aider': 'http://xxxx:8080', # 漏洞辅助验证接口，部分漏洞无法通过回显判断是否存在漏洞，可通过辅助验证接口进行判断。python -c'import socket,base64;exec(base64.b64decode("aGlzdG9yeSA9IFtdCndlYiA9IHNvY2tldC5zb2NrZXQoc29ja2V0LkFGX0lORVQsc29ja2V0LlNPQ0tfU1RSRUFNKQp3ZWIuYmluZCgoJzAuMC4wLjAnLDgwODgpKQp3ZWIubGlzdGVuKDEwKQp3aGlsZSBUcnVlOgogICAgdHJ5OgogICAgICAgIGNvbm4sYWRkciA9IHdlYi5hY2NlcHQoKQogICAgICAgIGRhdGEgPSBjb25uLnJlY3YoNDA5NikKICAgICAgICByZXFfbGluZSA9IGRhdGEuc3BsaXQoIlxyXG4iKVswXQogICAgICAgIGFjdGlvbiA9IHJlcV9saW5lLnNwbGl0KClbMV0uc3BsaXQoJy8nKVsxXQogICAgICAgIHJhbmtfc3RyID0gcmVxX2xpbmUuc3BsaXQoKVsxXS5zcGxpdCgnLycpWzJdCiAgICAgICAgaHRtbCA9ICJORVcwMCIKICAgICAgICBpZiBhY3Rpb24gPT0gImFkZCI6CiAgICAgICAgICAgIGhpc3RvcnkuYXBwZW5kKHJhbmtfc3RyKQogICAgICAgICAgICBwcmludCAiYWRkIityYW5rX3N0cgogICAgICAgIGVsaWYgYWN0aW9uID09ICJjaGVjayI6CiAgICAgICAgICAgIHByaW50ICJjaGVjayIrcmFua19zdHIKICAgICAgICAgICAgaWYgcmFua19zdHIgaW4gaGlzdG9yeToKICAgICAgICAgICAgICAgIGh0bWw9IlZVTDAwIgogICAgICAgICAgICAgICAgaGlzdG9yeS5yZW1vdmUocmFua19zdHIpCiAgICAgICAgcmF3ID0gIkhUVFAvMS4wIDIwMCBPS1xyXG5Db250ZW50LVR5cGU6IGFwcGxpY2F0aW9uL2pzb247IGNoYXJzZXQ9dXRmLThcclxuQ29udGVudC1MZW5ndGg6ICVkXHJcbkNvbm5lY3Rpb246IGNsb3NlXHJcblxyXG4lcyIgJShsZW4oaHRtbCksaHRtbCkKICAgICAgICBjb25uLnNlbmQocmF3KQogICAgICAgIGNvbm4uY2xvc2UoKQogICAgZXhjZXB0OnBhc3M="))' 在辅助验证机器上运行以上代码，填入http://IP:8088，不开启则留空。
    # 'http_proxy': 'http://xxxxx:1080',
    # 'pass_list':['xtest'] // 默认密码字典，不定义则使用硬编码在代码里的小字典
    # 'extra_plugin_path': '/home/test/plugin/', //除已编译好的插件（Go、JSON）外，可指定额外插件目录（仅支持JSON插件），指定后程序会周期读取加载插件
}

conf_args = json.dumps(config)
kunpeng.SetConfig(_args_encode(conf_args))

# 开启日志打印
# kunpeng.ShowLog()

def callback():
    a = task
    # print(a)
    out = kunpeng.Check(task)
    print(a, json.loads(out))
    # print(a)

# 扫描目标
# with open("ips.txt") as fp:
with open("url.txt") as fp:
    for item in fp.readlines():
        # print(item)
        task = {
            'type': 'web',  # 目标类型web或者service
            # 'type': 'service',
            'netloc': item.strip(),
            'target': 'all'
        #     "meta":{
        #     "system": "windows",  //操作系统，部分漏洞检测方法不同系统存在差异，提供给插件进行判断
        #     "pathlist":[], //目录路径URL列表，部分插件需要此类信息，例如列目录漏洞插件
        #     "filelist":[], //文件路径URL列表，部分插件需要此类信息，例如struts2漏洞相关插件
        #     "passlist":[] //自定义密码字典
        # } // 非必填
        }

        # print(task)
        task = _args_encode(json.dumps(task))
        t1 = threading.Thread(target=callback)

        t1.start()
```
明显看出`import threading`和后面的`with open`.
(未完待续)
