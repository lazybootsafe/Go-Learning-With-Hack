### 二次开发，不想fork，github作为go仓库使用。

Linux 平台

```shell
# 创建目录
$ cd install
# 执行安装程序，默认端口为 8090，指定其他端口加参数 --port=8087
$ ./install
# 浏览器访问 http://ip:8090 进入安装界面，完成安装配置
# Ctrl + C 停止 install 程序, 启动 MM-Wiki 系统
$ cd ..
$ ./mm-wiki --conf conf/mm-wiki.conf
# 浏览器访问你监听的 ip 和端口
# 开始 MM-Wiki 的使用之旅吧！
```
Windows 平台

```bash

# 进入 install 目录
# 双击点开 install.exe 文件
# 浏览器访问 http://ip:8090 进入安装界面，完成安装配置
# 关闭刚刚点开的 install 窗口
# 使用 windows 命令行工具（cmd.exe）进入程序根目录
$ 执行 mm-wiki.exe --conf conf/mm-wiki.conf
# 浏览器访问你监听的 ip 和端口
# 开始 MM-Wiki 的使用之旅吧！
```