# 帧缓冲区对象
## 帧缓冲区对象和渲染缓冲区对象
渲染缓冲区对象是一个由应用程序分配的2D图像缓冲区。
渲染缓冲区可以用于分配和存储颜色、深度和模板值，可以用作帧缓冲区对象的颜色、深度或模板附着。
渲染缓冲区类似于屏幕外的窗口系统提供的可绘制表面，但是不能直接用作GL纹理。

帧缓冲区对象十一组颜色、深度、模板纹理或者渲染的目标。
各种2D图像可以连接到帧缓冲区对象中的颜色附着点、深度附着点、模板附着点

## 创建帧缓冲区
创建帧缓冲区
glGenFrameBuffers(n, \*frameBuffers)
销毁帧缓冲区
glDeleteFrameBuffers(n, \*fbos);
绑定帧缓冲区
glBindFrameBuffer(GL_FRAMEBUFFER, fbo)

检查帧缓冲区格式是否正确配置
glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE

程序默认帧缓冲ID为0，在操作完其他帧缓冲的时候，需要将帧缓冲ID绑定回0，否则可能影响屏幕渲染

## 帧缓冲区附件
如何判断使用纹理附件还是渲染缓冲附件：
如果你不需要从一个缓冲中采样数据，那么对这个缓冲使用渲染缓冲对象会是明智的选择。
如果你需要从缓冲中采样颜色或深度值等数据，那么你应该选择纹理附件。性能方面它不会产生非常大的影响的。

### 纹理附件
与使用普通纹理差不多，但是需要在传入data处传 NULL，表示我们仅仅分配内存而不填充它，填充纹理将会在我们渲染到帧缓冲之后来进行。
unsigned int texture;
glGenTextures(1, &texture);
glBindTexture(GL_TEXTURE_2D, texture);

glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 800, 600, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);

glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

最后一步，绑定纹理到帧缓冲上
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);

#### 深度模板纹理附件
可以将深度模板值作为纹理。
glTexImage2D(
  GL_TEXTURE_2D, 0, GL_DEPTH24_STENCIL8, 800, 600, 0, 
  GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, NULL
);

glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, texture, 0);

### 渲染缓冲对象附件
渲染缓冲对象性能较优，是有为离屏渲染优化过的。

创建渲染缓冲对象
glGenRenderbuffer(GL_RENDERBUFFER, rbo)

绑定渲染缓冲对象
glBindRenderbuffer(GL_RENDERBUFFER, rbo);

删除渲染缓冲对象
glDeleteRenderbuffers(n, \*renderbuffers)

创建深度模板渲染缓冲对象
glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, w, h)

附加到FBO中
glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, rbo);

## 帧缓冲区位块传送
可以搞想的将一个矩形区域像素值从一个帧缓冲区复制到另一个帧缓冲区。

关键应用之一是将一个多重采样渲染缓冲区解析为一个纹理。

先将缓冲数据拷贝
glReadBuffer(buffer_name_enum)

位块传送
glBlitFramebuffer(srcX, srcY, srcW, srcH, dstX, dstY, dstW, dstH， mask, filter)

mask表示那些缓冲区应该被复制的位枚举
- GL_COLOR_BUFFER_BIT
- GL_DEPTH_BUFFER_BIT
- GL_STENCIL_BUFFER_BIT
- GL_DEPTH_STENCIL_ATTACHMENT

## 帧缓冲区失效
可以删除不需要的帧缓冲区内容，减少内容数量，降低GPU和系统内存之间的带宽，提升性能，降低耗电量。

可以使整个帧缓冲区或者帧缓冲区的像素子区域失效。
glInvalidateFramebuffer(target, numAttachments, \*attachments)
glInvalidateSubFramebuffer(target, numAttachments, \*attachments, x, y, w, h)

