# 片段着色器
## 概述
片段着色器为片段操作提供了通用功能的可编程方法。
片段着色器的输入由如下部分组成。
- 输入：顶点着色器生成的差值数据
- 统一变量
- 采样器
- 代码

片段着色器的输出是一个或者多个片段颜色。传递到管线的逐片段操作部分。

### 内建特殊变量
- gl_FragCoord:只读，保存片段的窗口相对坐标vec4(x,y,z,1/w)
- gl_FrontFacing:只读。片段是正面图元时为true，否则为false.
- gl_PointCoord:只写，可以覆盖片段的深度值。需要禁用显卡的'early-z'功能。

### 内建常量
- gl_MaxFragmentImputVectors:片段着色器输入的最大数量，最小为15
- gl_MaxTextureImageUnits:可用纹理单元最大数量，最小值为16
- gl_MaxFragmentUniformVectors:片段着色器内可以使用的vec4统一变量项目的最大数量。最小值224
- gl_MaxDrawBuffers:多重渲染目标的最大支持数量，最小值为4
- gl_MinProgramTexelOffset/glMaxProgramTexelOffset:内建essl函数texture\*Offset()偏移参数支持的最大和最小偏移量。

可通过 glGetIntegerv 来查询上述参数再具体实现中的值

## 使用技巧
### 多重纹理
纹理不仅可以存储图像信息，也可以存储深度、亮度、法线信息，可以比逐顶点更高精细度。

### 雾化
通过计算公式计算距离然后调整雾化颜色分量，形成雾化效果。

### alpha测试
判断alpha低于一定值，就将其discard

### 用户裁剪平面
通过平面计算公式，计算点到平面的距离，然后判断是否需要丢弃。
