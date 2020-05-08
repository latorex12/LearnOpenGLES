# 纹理
## 纹理基础
纹理可以为图元附加细节。提供了真实性。

纹理分为以下几类：
- 2D纹理
- 立方图纹理
- 3D纹理
- 2D纹理数组

### 纹理对象及加载
创建纹理对象
glGenTextures
删除纹理对象
glDeleteTextures
绑定纹理到指定类型
glBindTexture

加载2D纹理
glTexImage2D

设置打包解包对齐，影响像素存储、读取的行为
glPixelStorei

### mipMap和纹理过滤
当使用纹理时，当过滤器（缩小放大）设置为就近采样，对应坐标的颜色值是从对应纹理坐标读取的，有时会产生严重的锯齿伪像。这种情况和人类直觉常识不符。

所以我们需要使用Mip贴图链，提前采样好各分辨率维度下的图像效果，在对应大小的图元上使用对应的贴图，这样就可以避免就近采样带来的问题。
贴图链依然使用 `glTexImage2D` 加载

过滤模式通过如下接口设置（还有其他设置选项
glTexParameter-i/iv/f/fv

目前过滤模式有以下设置项及设置值
- GL_TEXTURE_MAG_FILTER:放大过滤器
    - GL_NEAREST:就近采样
    - GL_LINEAR:线性插值采样
- GL_TEXTURE_MIN_FILTER:缩小过滤器
    - GL_NEAREST:就近
    - GL_LINEAR:线性插值
    - GL_NEAREST_MIPMAP_NEAREST:从最近的mip级别中取得单点样本
    - GL_NEAREST_MIPMAP_LINEAR:从两个最近的mip级别中获得样本并且在样本间插值
    - GL_LINEAR_MIPMAP_NEAREST:从最近的mip级别中取得双线性样本
    - GL_LINEAR_MIPMAP_LINEAR:从两个最近的mip级别中获得双线性样本（三线性过滤，效果最好，一般最消耗性能
    
#### 无缝立方图过滤
3.0之后，当过滤核心落在立方图的边缘时，会自动从其覆盖的立方图中每个面获得样本，可以再立方图的每个面的边缘形成更平滑的过滤，自动开启。

### 纹理包装
当纹理坐标超出[0,1]的范围时，应该如何绘制。
目前有三种纹理包装模式：
    - GL_REPEAT:重复纹理
    - GL_CLAMP_TO_EDGE:限定读取纹理边缘
    - GL_MIRRORED_REPEAT:重复纹理和镜像

同时纹理包装方向有三种：
    - GL_TEXTURE_WRAP_S(x)
    - GL_TEXTURE_WRAP_T(y)
    - GL_TEXTURE_WRAP_R(z)

包装模式通过如下接口设置（还有其他设置选项
glTexParameter-i/iv/f/fv

### 纹理调配
用于控制输入的R/RG/RGB/RGBA纹理中的颜色分量如何在读取时映射到具体分量。
如R映射为(0,0,R,1)而不是默认的(R,0,0,1)

调配模式通过如下接口设置（还有其他设置选项
glTexParameter-i/iv/f/fv

分量有四种：
    - GL_TEXTURE_SWIZZLE_R
    - GL_TEXTURE_SWIZZLE_G
    - GL_TEXTURE_SWIZZLE_B
    - GL_TEXTURE_SWIZZLE_A
    
来源有四种：
    - GL_RED
    - GL_GREEN
    - GL_BLUE
    - GL_ALPHA
    
可指定的常量有两种：
    - GL_ZERO
    - GL_ONE
    
### 纹理细节级别
可以设置用于纹理的最大mip贴图级别，如可以先加载小mip，待大mip下载完毕再更换成高清的mip。

细节级别通过如下接口设置（还有其他设置选项
glTexParameter-i/iv/f/fv

设置纹理最大贴图级别：
GL_TEXTURE_BASE_LEVEL
设置纹理最小贴图级别：
GL_TEXTURE_MAX_LEVEL(默认值1000)

### 深度纹理对比
实现平滑的阴影边缘效果。（本次略

### 纹理格式
目前分为几个大类：
    - 规范化纹理格式
    - 浮点纹理
    - 整数纹理
    - 共享指数纹理（HDR）
    - sRGB纹理
    - 深度纹理
   
### 使用纹理
使用前需要先激活纹理，将纹理与纹理单元绑定
glActiveTexture

着色器中，可以使用内建函数 `texture` 从纹理贴图中读取

加载3D纹理和2D纹理数组
glTexImage3D

## 压缩纹理
纹理压缩可以减少纹理在设备上内存占用，节约读取纹理消耗的内存带宽，同时减少资源文件在安装包中的大小。
glCompressedTexImage2D
glCompressedTexImage3D

## 纹理子图像
支持可以只更新纹理图像的一部分。
glTexSubImage2D
glTexSubImage3D
glCompressedTexSubImage2D
glCompressedTexSubImage3D

## 从颜色缓冲区复制纹理数据
可以从颜色缓冲区复制图像数据到纹理中。（目前缓冲区提供更快、性能更好的方法
1.设置读取的缓冲区，本操作设为GL_BACK
glReadBuffer
2.复制数据到纹理
glCopyTexImage2D
glCopyTexSubImage2D
glCopyTexSubImage3D

需要注意的是，复制数据支持颜色分量多->少，如RGBA支持复制到RGB，但不能RGB复制到RGBA，因为缺少A分量。

## 采样器对象
有点类似VertexArray，可以缓存采样器状态配置，方便使用及减少API频繁调用带来的性能损耗。
创建销毁绑定
glGenSamplers
glDeleteSamplers
glBindSampler

设置
glSamplerParameter-i/iv/f/fv

## 不可变纹理
避免每次渲染纹理前的一系列检查造成的性能消耗，支持指定纹理为不可变纹理，这样加载时只要数据正确就可以避免后面多次校验。
glTexStorage2D
glTexStorage3D

一旦设置不可变纹理，使用纹理压缩、缓冲区复制纹理数据等方式将报错，只能使用
glTexSubImage2D/3D
glGenerateMipMap或者渲染到纹理图像来填充数据。

## 像素解包缓冲区对象
3.0引入像素解包缓冲区对象，对象与GL_PIXEL_UNPACK_BUFFER目标绑定指定。用以提高纹理上传操作的性能。
像素解包、解压缩等可以直接来自缓冲区对象。和VBO相似，数据指针是缓冲中的一个偏移量，而不是指向客户端内存的指针。




