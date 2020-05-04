# 1.绘制三角形 OpenGLES3.0
由于3.0必须加载有效的顶点着色器和片段着色器，否则不会开始绘制。
所以最简单的绘制三角形的步骤：
1. 设置屏幕渲染表面
1.1 如果为iOS，只需要创建一个 `GLKViewController` 或者创建一个 `GLKView`
1.2 然后创建一个 `EAGLContext`，将 context 绑定到 view 上即可
```objectivec
self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
GLKView *view = (GLKView *)self.view;
view.context = self.context;
```

2. 初始化并加载顶点着色器、片段着色器
2.1 创建顶点着色器
2.2 加载着色器代码
2.3 编译着色器代码
2.4 查询编译状态，如果为失败则取错误信息
```
char[] shaderStr = ...;
GLUint shader = glCreateShader(GLenum:GL_VERTEX_SHADER/GL_FRAGMENT_SHADER);
glShaderSource(shaderNum:shader, count:1, shaderStrs**:&shaderStr, length:NULL);
glCompileShader(shaderNum:shader);

GLint compiled;
glGetShaderiv(shaderNum:shader, GLenum:GL_COMPILE_STATUS, &compiled);

GLint infoLen;
glGetShaderiv(shaderNum:shader, GLenum:GL_INFO_LOG_LENGTH, &infoLen);

char *infoLog = malloc ( sizeof ( char ) * infoLen );
glGetShaderInfoLog (shader, infoLen, NULL, infoLog);
```

3. 初始化并加载、链接程序
3.1 初始化程序
3.2 添加顶点着色器、片段着色器
3.3 链接程序
3.4 查询链接状态，如果为失败则去错误信息
3.5 如果失败则移除程序避免内存泄漏
```
GLuint program = glCreateProgram();
glAttachShader (GLuint:program, GLuint:vShader);
glAttachShader (GLuint:program, GLuint:fShader);
glLinkProgram (GLuint:program);

GLint linkResult;
glGetProgramiv (GLuint:program, GLenum:GL_LINK_STATUS, GLint*:&linkResult);

GLint infoLen;
glGetProgramiv (GLuint:program, GLenum:GL_INFO_LOG_LENGTH, GLint*:&infoLen);

char *infoLog = malloc ( sizeof ( char ) * infoLen );
glGetProgramInfoLog(programObject, infoLen, NULL, infoLog );
glGetProgramInfoLog (GLuint:program, GLsizei:bufsize, GLsizei*:NULL, GLchar*:infolog);
```

4. 设置视口 viewport
```
glViewport (GLint:x, GLint:y, GLsizei:width, GLsizei:height);
```

5. 清空颜色缓冲区
5.1 先设置清空缓冲区要填充的颜色
5.2 执行清空操作
```
glClearColor (GLfloat r:1.0f, GLfloat g:1.0f, GLfloat b:1.0f, GLfloat a:0.0f );
glClear(GLbitfield:GL_COLOR_BUFFER_BIT);
```

6. 渲染图元
6.1 提供顶点数据
6.2 加载顶点数据
6.3 启用指定索引的顶点数组
6.4 开始绘制
```
glUseProgram (GLuint:program);

GLfloat vVertices[] = ...;
glVertexAttribPointer (GLuint indx:0, GLint size:3, GLenum type:GL_FLOAT, GLboolean normalized:GL_FALSE, GLsizei stride:0, const GLvoid* ptr:vVertices);

glEnableVertexAttribArray(GLuint index:0);

glDrawArrays(GLenum mode:GL_TRIANGLES, GLint first:0, GLsizei count:3);
```

7. 切换前后台缓冲区
```
glSwapBuffers(foreground, background);//iOS不需要
```

使用完毕后：需要释放链接的程序
```
glDeleteProgram (program);
```




>最简单的shader
>vertex:
>```
>char vShaderStr[] =
      "#version 300 es                          \n"
      "layout(location = 0) in vec4 vPosition;  \n"
      "void main()                              \n"
      "{                                        \n"
      "   gl_Position = vPosition;              \n"
      "}                                        \n";
>```
>
>fragment:
>```
>char fShaderStr[] =
      "#version 300 es                              \n"
      "precision mediump float;                     \n"
      "out vec4 fragColor;                          \n"
      "void main()                                  \n"
      "{                                            \n"
      "   fragColor = vec4 ( 1.0, 0.0, 0.0, 1.0 );  \n"
      "}                                            \n";
>```

>简单的三角形顶点数组
>triangle:
>GLfloat vertexs[] = {
        -0.5, -0.5, 0,
        0.5, -0.5, 0,
        0, 0.5, 0,
    };
