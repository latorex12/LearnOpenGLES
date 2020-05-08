# 顶点着色器
## 顶点着色器概述
顶点着色器提供顶点操作的通用可编程方法。
顶点着色器的输入：
- 属性
- 统一变量和统一变量缓冲区
- 采样器
- 着色器程序

输出：
- 输出变量
- 内建变量

### 内建变量
#### 内建特殊变量
gl_VertexID:顶点索引
gl_InstanceID:实例编号
gl_Position:输出顶点位置的裁剪坐标
gl_PositionSize:点尺寸，用于渲染点
gl_FrontFacing:特殊变量

#### 内建统一状态
gl_DepthRangeParameters:深度范围

#### 内建常量
gl_MaxVertexAttribs:顶点属性最大数量，>16
gl_MaxVertexUniformVectors:可以使用的vec4统一变量项目的最大数量，>256
gl_MaxVertexOutputVectors:输出向量的最大数量，>16
gl_MaxVertexTextureImageUnits:可用的纹理单元的最大数量，>16
gl_MaxCombinedTextureImageUnits:顶点、片段着色器可用纹理单元数量和，>32

#### 精度限定符
highp
lowp
mediump

#### 统一变量限制数量
代码中的字面量的每次使用可能都会被当做统一变量存储。所以这种情况，需要使用常数变量来避免字面量被多次计数。


下略...
## 顶点着色器应用
### 矩阵变换
### 光照计算
## 生成纹理坐标
## 顶点蒙皮
## 变换反馈
## 顶点纹理
