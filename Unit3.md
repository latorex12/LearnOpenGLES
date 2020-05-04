# 图元装配与光栅化
## 图元
OpenGL ES可以绘制三种图元：
- 三角形
    - GL_TRIANGLES:绘制单独的三角形
    - GL_TRIANGLE_STRIP:绘制一系列相互连接的三角形
    - GL_TRIANGLE_FAN:绘制一系列相互连接的三角形(扇形连接)
- 直线
    - GL_LINES:绘制不相连的线段
    - GL_LINE_STRIP:绘制相连的线段
    - GL_LINE_LOOP:绘制相连的闭环线段
    - 可以通过 `glLineWidth` 指定线段宽度
- 点
    - GL_POINTS:绘制点
    - 可以通过 `gl_PointSize` 设置点

### 绘制图元
有五种绘制图元API:
- glDrawArrays:最简单的图元绘制方式
- glDrawElements:绘制一组相连图元，但是传索引而非顶点，可以减少数据量
- glDrawRangeElements:同上，可以传入start/end的范围
- glDrawArraysInstanced
- glDrawElementsInstanced

### 图元重启
可以通过传入一个索引类型的最大值，用来告诉OpenGL系统想要在一次调用中渲染多个不相连的图元。这样可以降低绘图API调用开销。
如：三角形条带元素索引(0,1,2,3)和(7,8,9,10)

当索引类型为 GL_UNBSIGNED_BYTE，最大值为 255
如果想要通过图元重启在一次调用中绘制两个条带，则传入：(0,1,2,3,*255*,7,8,9,10)

可以通过下面代码启用、禁用图元重启：
glEnable(GL_ROIMITIVE_RESTART_FIXED_INDEX)
glDisable(GL_ROIMITIVE_RESTART_FIXED_INDEX)

### 驱动顶点
如果使用平面着色的形式，则不会发生颜色差值。
所以该图元依那一个顶点的颜色为准，则有公式计算。一般为最后一个顶点的颜色。
如point则一一对应。
line则为终止点的颜色。
triangle则为最后一个顶点的颜色。

### 几何形状实例化
几何形状实例化可以用一次API调用多次渲染具有不同属性的对象。可以降低多次调用API导致CPU的处理开销。

接口如下：
glDrawArraysInstanced
glDrawElementsInstanced

//告诉OpenGLES 每几个图元分配一个该数据
glVertexAttribDivisor

## 图元装配
图元装配分为如下阶段：
1. 顶点着色器输出->物体坐标
2. 裁剪->裁剪坐标
3. 透视分割->规范化设备坐标
4. 视口变换->窗口坐标
5. 光栅化

### 裁剪
就是将最终展示部分之外的图元放弃，部分展示的图元进行裁剪，形成新的图元。
但是裁剪性能消耗较高，一般实现方式为渲染到一个大一些的视口，这样可以避免裁剪，而变成剪裁。这个更大的视口区域称之为保护带区域。

### 透视分割
通过处理世界坐标的点，将其转化为规范坐标[-1.0,1.0]

### 视口变换
调整观察空间的大小及深度。

通过如下接口配置：
调整视口
glViewPort
调整深度范围
glDepthRangef

## 光栅化
光栅化就是将矢量的图元描述（可以当成是矢量空间图），转化为屏幕空间上的位图（未着色）。

### 剔除
由性能考虑，我们可以判断一个面是面向观察者的，还是背向观察者的。我们可以只渲染面向的面，剔除背向观察者的面。
这样就可以节省至少50%的性能消耗。

通过如下接口指定正面三角形的方向：
glFrontFace
指定剔除三角形的面：
glCullFace

可以通过以下接口启用或禁用剔除：
glEnable
glDisable

### 多边形偏移（深度冲突）
如果绘制两个重叠的多边形，你会注意到伪像情况。
在于深度相同或者深度精度不够，所以绘制的时候系统会不知道哪个面应该绘制在前方。

这时，可以通过给深度加一个偏移值来解决。
glPolygonOffset

设置深度测试函数：
glDepthFunc

## 遮挡查询
可以通过遮挡查询函数查询当前片段中是否有通过深度测试的片段。（是否被遮挡）
创建查询
glGenQueries
删除查询
glDeleteQueries

开始查询
glBeginQuery
结束查询
glEndQuery

获取查询结果
glGetQueryObjectuiv
