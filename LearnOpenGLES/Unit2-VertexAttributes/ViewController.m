//
//  ViewController.m
//  Unit1-DrawTriangle
//
//  Created by SkyRim on 2020/4/27.
//  Copyright © 2020 SkyRim. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>

//Const Values
const int VertexElementSize = 3;
const int VertexPositionSize = 3;
const int VertexColorSize = 4;
const int VertexPositionIndex = 0;
const int VertexColorIndex = 1;

@interface ViewController () <GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *glView;
@property (nonatomic, assign) GLint program;

@property (nonatomic, assign) GLuint vboID;
@property (nonatomic, assign) GLuint vaoID;

@end

@implementation ViewController

- (void)dealloc {
    [self freeResources];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _vboID = -1;
    _vaoID = -1;
    
    [self setupGLView];
    [self setupGLProgram];
}

- (void)setupGLView {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        printf("Failed to create ES context\n");
        return;
    }
    
    [EAGLContext setCurrentContext:context];
    
    GLKView *view = [[GLKView alloc] initWithFrame:self.view.bounds context:context];
    view.delegate = self;
    
    [self.view addSubview:view];
    
    self.context = context;
    self.glView = view;
}

//初始化、加载并链接程序
- (void)setupGLProgram {
    GLchar vShaderStr[] =
    "#version 300 es                          \n"
    "layout(location = 0) in vec4 vPosition;  \n"
    "layout(location = 1) in vec4 vColor;     \n"
    "out vec4 v_color;                        \n"
    "void main()                              \n"
    "{                                        \n"
    "   gl_Position = vPosition;              \n"
    "   v_color = vColor;                     \n"
    "}                                        \n";
    
    //初始化加载顶点着色器
    GLuint vShader = [self compileShader:GL_VERTEX_SHADER shaderStr:vShaderStr];
    
    GLchar fShaderStr[] =
    "#version 300 es                              \n"
    "precision mediump float;                     \n"
    "in vec4 v_color;                             \n"
    "out vec4 fragColor;                          \n"
    "void main()                                  \n"
    "{                                            \n"
    "   fragColor = v_color;                      \n"
    "}                                            \n";
    
    //初始化加载片段着色器
    GLuint fShader = [self compileShader:GL_FRAGMENT_SHADER shaderStr:fShaderStr];
    
    //初始化程序
    GLint program = glCreateProgram();
    
    if (program == 0) {
        return;
    }
    
    //绑定着色器到程序
    glAttachShader(program, vShader);
    glAttachShader(program, fShader);
    
    //链接程序
    glLinkProgram(program);
    
    //查看链接状态
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    
    //成功则返回
    BOOL linkSuccess = linkStatus != 0;
    if (linkSuccess) {
        self.program = program;
        return;
    }
    
    //否则取日志看链接错误日志
    GLint logLen;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLen);
    if (logLen > 0) {
        char *logStr = malloc(sizeof(char) * logLen);
        printf("Link GL Program Failed, error:%s\n", logStr);
        free(logStr);
    }
    
    glDeleteProgram(program);
}

//初始化并加载着色器
- (GLuint)compileShader:(GLenum)type shaderStr:(const GLchar *)shaderStr {
    //初始化
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        return 0;
    }
    
    //加载
    glShaderSource(shader, 1, &shaderStr, NULL);
    //编译
    glCompileShader(shader);
    
    //判断编译结果
    GLint compileStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    
    //编译成功则返回
    BOOL compileSuccess = compileStatus != 0;
    if (compileSuccess) {
        return shader;
    }
    
    //否则获取错误日志
    GLint logLen;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLen);
    if (logLen > 0) {
        char *logStr = malloc(sizeof(char) * logLen);
        printf("GL Shader Compile Failed, error:%s\n", logStr);
        free(logStr);
    }
    
    return 0;
}

#pragma mark - GLKViewDelegate

- (void)glkView:(nonnull GLKView *)view drawInRect:(CGRect)rect {
    //设置视口
    glViewport(0, 0, (GLsizei)view.drawableWidth, (GLsizei)view.drawableHeight);
    
    //设置填充颜色
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //设置程序
    glUseProgram(self.program);
    
    //顶点&Color数组
    const GLsizei elementLen = (VertexPositionSize+VertexColorSize)*VertexElementSize;
    GLfloat vertexs[elementLen] = {
        -0.5, -0.5, 0,
        1.0, 0, 0, 1.0,
        0.5, -0.5, 0,
        0, 1.0, 0, 1.0,
        0, 0.5, 0,
        0, 0, 1.0, 1.0
    };

//    [self drawWithoutVBOs:vertexs];
//    [self drawWithVBOs:vertexs];
    [self drawWithVAO:vertexs];
}

- (void)drawWithoutVBOs:(GLfloat *)vertexs {
    GLsizei stride = (VertexPositionSize+VertexColorSize)*sizeof(GLfloat);
    
    glVertexAttribPointer(VertexPositionIndex, VertexPositionSize, GL_FLOAT, GL_FALSE, stride, vertexs);
    glEnableVertexAttribArray(VertexPositionIndex);

    glVertexAttribPointer(VertexColorIndex, VertexColorSize, GL_FLOAT, GL_FALSE, stride, vertexs+VertexPositionSize);
    glEnableVertexAttribArray(VertexColorIndex);

    glDrawArrays(GL_TRIANGLES, VertexPositionIndex, VertexElementSize);
    
    glDisableVertexAttribArray(VertexPositionIndex);
    glDisableVertexAttribArray(VertexColorIndex);
}

- (void)drawWithVBOs:(GLfloat *)vertexs {
    GLsizei stride = (VertexPositionSize+VertexColorSize)*sizeof(GLfloat);
    
    //设置缓冲区对象，这样就不需要每次将数据从应用内存拷贝到显存
    if (_vboID == -1) {
        glGenBuffers(1, &_vboID);
        
        glBindBuffer(GL_ARRAY_BUFFER, _vboID);
        glBufferData(GL_ARRAY_BUFFER, stride*VertexElementSize, vertexs, GL_STATIC_DRAW);
    }
    
    //绑定缓冲区
    glBindBuffer(GL_ARRAY_BUFFER, _vboID);
    
    //绑定缓冲区之后，顶点数组的pointer的起始值为0
    glVertexAttribPointer(VertexPositionIndex, VertexPositionSize, GL_FLOAT, GL_FALSE, stride, (void*)0);
    glEnableVertexAttribArray(VertexPositionIndex);
    
    glVertexAttribPointer(VertexColorIndex, VertexColorSize, GL_FLOAT, GL_FALSE, stride, (void*)0+VertexPositionSize*sizeof(GLfloat));
    glEnableVertexAttribArray(VertexColorIndex);
    
    glDrawArrays(GL_TRIANGLES, VertexPositionIndex, VertexElementSize);
    
    glDisableVertexAttribArray(VertexPositionIndex);
    glDisableVertexAttribArray(VertexColorIndex);
    
    //取消绑定状态
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)drawWithVAO:(GLfloat *)vertexs {
    GLsizei stride = (VertexPositionSize+VertexColorSize)*sizeof(GLfloat);
    
    //首次初始化VBO
    if (_vboID == -1) {
        glGenBuffers(1, &_vboID);
        
        glBindBuffer(GL_ARRAY_BUFFER, _vboID);
        glBufferData(GL_ARRAY_BUFFER, stride*VertexElementSize, vertexs, GL_STATIC_DRAW);
    }
    
    //首次初始化VAO
    if (_vaoID == -1) {
        glGenVertexArrays(1, &_vaoID);
        glBindVertexArray(_vaoID);
        
        //绑定缓冲区
        glBindBuffer(GL_ARRAY_BUFFER, _vboID);
        
        //绑定缓冲区之后，顶点数组的pointer的起始值为0
        glVertexAttribPointer(VertexPositionIndex, VertexPositionSize, GL_FLOAT, GL_FALSE, stride, (void*)0);
        glEnableVertexAttribArray(VertexPositionIndex);
        
        glVertexAttribPointer(VertexColorIndex, VertexColorSize, GL_FLOAT, GL_FALSE, stride, (void*)0+VertexPositionSize*sizeof(GLfloat));
        glEnableVertexAttribArray(VertexColorIndex);
    }
    
    //每次就可以通过bindVAO方便的同步上下文了
    glBindVertexArray(_vaoID);
    glDrawArrays(GL_TRIANGLES, VertexPositionIndex, VertexElementSize);
    glBindVertexArray(0);
}

//释放资源
- (void)freeResources {
    if (_vboID != -1) {
        glDeleteBuffers(1, &_vboID);
    }
    
    if (_vaoID != -1) {
        glDeleteVertexArrays(1, &_vaoID);
    }
    
    [EAGLContext setCurrentContext:self.context];
    
    if (self.program) {
        glDeleteProgram(self.program);
    }
    
    [EAGLContext setCurrentContext:nil];
}

@end
