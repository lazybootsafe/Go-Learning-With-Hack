# fuzz改进与创新

## 一些想法与实践

## 神经网络结合

一种程序平滑化的方法，用afl生成的seeds作为训练数据，训练神经网络，输出对应的bitmap信息，然后利用梯度等信息来生成新的测试样例，提高边覆盖率。

## 提升fuzz效率

多种技术来提升fuzz的效率

- Context-sensitive branch count afl使用的context-free的技术，而Context-sensitive 的话能提供更多信息给fuzzer，使得其能做出更好的决策
- Byte-level taint tracking 文章自己实现了一种tracking的方法，能判断输入数据哪一部分是被用于conditional statement中，然后专门去变异这部分
- Search algorithm based on gradient descent 通过taint tracking找到哪一部分是在conditional statement中之后，就用gradient descent来找到能到达未探索边的输入数据
- Input length exploration 简单来说就是在taint tracking中，找到那些read-like函数调用，假如这些函数的返回值被用于conditional statement中，并且conditional statement不通过，则尝试增加输入的数据  

## GAN 和LSTM

利用GAN和LSTM来提高seeds的质量，使得afl能探索到更多的路径，首先是先fuzz一段时间，然后用生成的seeds除重，喂给GAN，然后GAN生成新的测试样例，然后用这里样例作为初始化数据，进行fuzz，LSTM也是差不多，然后GAN的效果好一点

## 多核优化
- Snapshot System Call paper里面介绍，fork在fuzzer中是一个性能损耗严重的部分，因此他们提出了一个snapshot的syscall，
- Dual File System Service 使用memory disk，减少读写小文件的overhead，当memory disk空间不多的时候，还会把文件移动回真正的disk，建立一个链接
- Shared In-memory Test-Case Log 这个其实是对AFL原本多client协作的改进吧

## 插桩

简化插桩的数量来提高fuzz的效率，利用了llvm，感觉有点像编译原理的东西

## 静态动态分析结合fuzz
