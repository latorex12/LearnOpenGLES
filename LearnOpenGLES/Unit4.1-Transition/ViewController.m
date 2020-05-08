//
//  ViewController.m
//  Unit1-DrawTriangle
//
//  Created by SkyRim on 2020/4/27.
//  Copyright © 2020 SkyRim. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

@interface ViewController () <GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *glView;
@property (nonatomic, assign) GLint program;

@end

@implementation ViewController

- (void)dealloc {
    [EAGLContext setCurrentContext:self.context];
    
    if (self.program) {
        glDeleteProgram(self.program);
    }
    
    [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    "uniform mat4 m_mvp;                      \n" //添加transform统一变量
    "void main()                              \n"
    "{                                        \n"
    "   gl_Position = m_mvp*vPosition;        \n" //顶点变换
    "}                                        \n";
    
    //初始化加载顶点着色器
    GLuint vShader = [self compileShader:GL_VERTEX_SHADER shaderStr:vShaderStr];
    
    GLchar fShaderStr[] =
    "#version 300 es                              \n"
    "precision mediump float;                     \n"
    "out vec4 fragColor;                          \n"
    "void main()                                  \n"
    "{                                            \n"
    "   fragColor = vec4 ( 1.0, 0.0, 0.0, 1.0 );  \n"
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
    
    //顶点数组
    GLfloat vertexs[] = {
        -0.5, -0.5, 0,
        0.5, -0.5, 0,
        0, 0.5, 0,
    };
    
    //加载顶点数组
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, vertexs);
    //启用指定索引的顶点数组
    glEnableVertexAttribArray(0);
    
    //创建转换矩阵
    static int rotateTime = 0;
    GLKMatrix4 transMat = GLKMatrix4Rotate(GLKMatrix4Identity, M_PI*rotateTime++/60, 0, 0, 1);//z轴旋转，每帧3°
    
    GLint matLocation = glGetUniformLocation(self.program, "m_mvp");
    glUniformMatrix4fv(matLocation, 1, GL_FALSE, (GLfloat *)&transMat);
    
    //开始绘制
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view setNeedsDisplay];
    });
}

@end
