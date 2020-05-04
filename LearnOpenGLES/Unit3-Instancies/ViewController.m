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

@interface ViewController () <GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *glView;
@property (nonatomic, assign) GLint program;

@property (nonatomic, assign) GLuint vboID;
@property (nonatomic, assign) GLuint offsetVboID;
@property (nonatomic, assign) GLuint vaoID;

@end

@implementation ViewController

- (void)dealloc {
    [self freeResources];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _vboID = -1;
    _offsetVboID = -1;
    _vaoID = -1;
    
    [self setupGLView];
    [self setupGLProgram];
    [self setupDraw];
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
    //
    GLchar vShaderStr[] =
    "#version 300 es                          \n"
    "layout(location = 0) in vec2 vPosition;  \n"
    "layout(location = 1) in vec3 vColor;     \n"
    "layout(location = 2) in vec2 vOffset;    \n"
    "out vec3 v_color;                        \n"
    "void main()                              \n"
    "{                                        \n"
    "   gl_Position = vec4(vPosition+vOffset, 0, 1.0);\n"
    "   v_color = vColor;                     \n"
    "}                                        \n";
    
    //初始化加载顶点着色器
    GLuint vShader = [self compileShader:GL_VERTEX_SHADER shaderStr:vShaderStr];
    
    GLchar fShaderStr[] =
    "#version 300 es                              \n"
    "precision mediump float;                     \n"
    "in vec3 v_color;                             \n"
    "out vec4 fragColor;                          \n"
    "void main()                                  \n"
    "{                                            \n"
    "   fragColor = vec4(v_color, 1.0);           \n"
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

- (void)setupDraw {
    if (_vboID == -1) {
        glGenBuffers(1, &_vboID);
        glBindBuffer(GL_ARRAY_BUFFER, _vboID);
        
        //顶点&Color数组
        GLfloat quadVertices[] = {
            // 位置          // 颜色
            -0.05f,  0.05f,  1.0f, 0.0f, 0.0f,
            0.05f, -0.05f,  0.0f, 1.0f, 0.0f,
            -0.05f, -0.05f,  0.0f, 0.0f, 1.0f,
            
            -0.05f,  0.05f,  1.0f, 0.0f, 0.0f,
            0.05f, -0.05f,  0.0f, 1.0f, 0.0f,
            0.05f,  0.05f,  0.0f, 1.0f, 1.0f
        };
        
        glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices, GL_STATIC_DRAW);
        
        //偏移量计算+绑定
        glGenBuffers(1, &_offsetVboID);
        glBindBuffer(GL_ARRAY_BUFFER, _offsetVboID);
        
        GLfloat translations[100*2];
        int index = 0;
        float offset = 0.1f;
        for (int y = -10; y < 10; y += 2)
        {
            for (int x = -10; x < 10; x += 2)
            {
                translations[index++] = (float)x / 10.0f + offset;
                translations[index++] = (float)y / 10.0f + offset;
            }
        }
        
        glBufferData(GL_ARRAY_BUFFER, sizeof(translations), translations, GL_STATIC_DRAW);
    }
    
    if (_vaoID == -1) {
        glGenVertexArrays(1, &_vaoID);
        glBindVertexArray(_vaoID);
    }
        
    glBindBuffer(GL_ARRAY_BUFFER, _vboID);
    
    //positionIndex=0,vec2
    glVertexAttribPointer(0, 2, GL_FLOAT, NO, sizeof(GLfloat)*5, (void*)0);
    glEnableVertexAttribArray(0);
    
    //colorIndex=1,vec3
    glVertexAttribPointer(1, 3, GL_FLOAT, NO, sizeof(GLfloat)*5, (void*)0+(sizeof(GLfloat)*2));
    glEnableVertexAttribArray(1);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, _offsetVboID);
    
    //offset=2,vec2
    glVertexAttribPointer(2, 2, GL_FLOAT, NO, 0, (void*)0);
    glEnableVertexAttribArray(2);
    
    glVertexAttribDivisor(2, 1);//一个实例读取一个offset
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
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

    glBindVertexArray(_vaoID);
    glDrawArraysInstanced(GL_TRIANGLES, 0, 6, 100);//绘制100个实例
    glBindVertexArray(0);
}


//释放资源
- (void)freeResources {
    if (_vboID != -1) {
        glDeleteBuffers(1, &_vboID);
    }
    
    if (_offsetVboID != -1) {
        glDeleteBuffers(1, &_offsetVboID);
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
