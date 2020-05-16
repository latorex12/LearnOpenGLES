# 片段操作
## 简介
主要介绍在片段着色器之后，我们可以应用到整个帧缓冲区或者单独片段的操作，如：
- 剪裁区域测试
- 模板缓冲区测试
- 深度缓冲区测试
- 多重采样
- 混合
- 抖动

## 缓冲区
系统有三种缓冲区：
- 颜色缓冲区（包含前台、后台颜色双缓冲
- 深度缓冲区
- 模板缓冲区

### 清除缓冲区
清除指定缓冲区
glClear(GLbitfield mask)

enum GLbitfield {
    GL_COLOR_BUFFER_BIT,
    GL_DEPTH_BUFFER_BIT,
    GL_STENCIL_BUFFER_BIT,
}

清除缓冲区颜色默认值
glClearColor(red,green,blue,alpha)

清除缓冲区深度默认值
glClearDepth(depth)

清除缓冲区模板值
glClearStencil(s)

### 掩码控制帧缓冲区写入
控制颜色分量写入
glColorMask(red, green, blue, aplha)

控制深度写入
glDepthMask(depth)

控制模板写入
glStencilMask(mask)
mask是像素可以修改的位掩码

模板写入掩码，判断顶点顺序
glStencilMaskSeparate(face, mask)
可以为正面和反面制定不同的掩码。

## 片段测试和操作
### 剪裁测试
可以制定一个矩形区域，限制帧缓冲区中可以写入的像素。
glScissor(x, y, w, h)

需要调用启动剪裁测试
glEnable(GL_SCISSOR_TEST)

### 模板缓冲区测试
模板缓冲中有模板值，可以用来判断，然后丢弃符合丢弃规则的片段。

开启模板测试
glEnable(GL_STENCIL_TEST)

指定模板测试函数
glStencilFunc(func, ref, mask)

分正反面指定模板测试函数
glStencilFuncSeparate(face ,func, ref, mask)

func有以下定义：
GL_NEVER、GL_LESS、GL_LEQUAL、GL_GREATER、GL_GEQUAL、GL_EQUAL、GL_NOTEQUAL和GL_ALWAYS。

函数如下
参考值ref(100) 运算符func(equal)  模板值mask(100)

结果会有三种
1. 无法通过模板测试 sfail
2. 通过模板测试，未通过深度测试 dpfail
3. 两者都通过 dppass

通过设置指定不同结果使用不同操作：
GL_KEEP    保持当前储存的模板值
GL_ZERO    将模板值设置为0
GL_REPLACE    将模板值设置为glStencilFunc函数设置的ref值
GL_INCR    如果模板值小于最大值则将模板值加1
GL_INCR_WRAP    与GL_INCR一样，但如果模板值超过了最大值则归零
GL_DECR    如果模板值大于最小值则将模板值减1
GL_DECR_WRAP    与GL_DECR一样，但如果模板值小于0则将其设置为最大值
GL_INVERT    按位翻转当前的模板缓冲值

### 深度测试
深度缓冲中有渲染表面上每个像素与视点最近片段的距离值，每个新输入的片段都会和深度值比较，所以如果输入的片段深度值小于保存的值，表示片段在前面，所以可以将输入片段的深度值更新，并且将其颜色值代替缓冲区中的颜色值。

启用深度测试
glEnable(GL_DEPTH_TEST)

深度比较函数
glDepthFunc(func)

func操作定义：
GL_ALWAYS    永远通过深度测试
GL_NEVER    永远不通过深度测试
GL_LESS    在片段深度值小于缓冲的深度值时通过测试
GL_EQUAL    在片段深度值等于缓冲区的深度值时通过测试
GL_LEQUAL    在片段深度值小于等于缓冲区的深度值时通过测试
GL_GREATER    在片段深度值大于缓冲区的深度值时通过测试
GL_NOTEQUAL    在片段深度值不等于缓冲区的深度值时通过测试
GL_GEQUAL    在片段深度值大于等于缓冲区的深度值时通过测试

## 混合
如果片段通过了片段测试，则会将颜色与片段像素位置的颜色混合（因为有透明的情况），两个颜色它们会使用指定的计算方式混合。

ColorFinal = fs * ColorSource op fd * ColorDest

其中，a、b分别为系数因子，op为指定的数学运算符。

比例因子通过
设置两个颜色的比例因子
glBlendFunc(sfactor, dfactor)
设置正反面颜色的比例因子
glBlendFuncSeparate(srcRGB, dstRGB, srcAlpla, dstAlpha)

混合系数取值详见书中，有不同的计算方式
同时，用于计算的常量颜色通过下面函数指定
glBlendColor(r, g, b, a)

## 抖动
帧缓冲区中每个分量的位数导致的缓冲区中可用颜色数量有限的系统上，可以适用抖动模拟更大的色深。

## 多重采样抗锯齿
可以避免产生锯齿现象，生成比较平滑的效果。

## 帧缓冲区读取写入像素
读取
glReadPixels(x, y, w, h, format, type, \*pixels)

## 多重渲染目标
可以渲染到多个颜色缓冲区。

通过命令指定渲染颜色附着
glDrawBuffers(n, \*bufs)

