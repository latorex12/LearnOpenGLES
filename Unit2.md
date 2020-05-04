# 顶点属性、数组和缓冲区对象
## 顶点属性
常量顶点属性，通过以下函数指定
glVertexAttrib..

顶点数组
glVertexAttribPointer

获取程序活动顶点属性列表
glGetActiveAttrib

## 通用顶点属性绑定索引
可以分为三种方式：
1. 最简单，直接声明时指定(location = N)
2. OpenGL ES 3.0将属性变量名称绑定到一个通用的顶点属性索引：通过链接后查询绑定索引即可 `glGetAttribLocation`
3. 应用程序将顶点属性绑定到属性名称：通过 `glBindAttribLocation`

## 顶点缓冲区对象
将顶点数据缓存在图形内存中，可以减少客户内存的占用及拷贝带来的内存消耗。

创建缓冲区对象
glGenBuffers

绑定缓冲区对象
glBindBuffer

设置缓冲区对象数据
glBufferData

设置缓冲区对象数据片段
glBufferSubData

删除缓冲区对象
glDeleteBuffers

### 同顶点属性组合使用
当组合顶点数组使用的时候，顶点数组就可以将 pointer 设置为0，默认绑定的对应 buffer 的0位置。

## 顶点数组对象
每次配置顶点属性、缓冲区比较麻烦，可以使用顶点数组将顶点相关配置记录进顶点数组对象，当使用时直接设置好。

创建顶点数组对象
glGenVertexArrays

绑定顶点数组对象
glBindVertexArray

删除顶点数组对象
glDeleteVertexArrays

## 映射缓冲区对象
映射缓冲区是将对象数据存储映射到应用程序的地址空间，可以减少应用的内存占用，性能上比顶点缓冲区好一些。

开始映射
glMapBufferRange

停止映射
glUnmapBuffer

刷新映射缓冲
glFlushMappedBufferRange

复制缓冲区对象
glCopyBufferSubData

