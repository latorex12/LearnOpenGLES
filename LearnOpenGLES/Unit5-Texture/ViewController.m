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
@property (nonatomic, assign) GLuint vboTexID;
@property (nonatomic, assign) GLuint vaoID;
@property (nonatomic, assign) GLuint textureID;
@property (nonatomic, assign) GLuint uniformTexID;

@property (nonatomic, assign) CGImageRef img;

@end

@implementation ViewController

- (void)dealloc {
    [self freeResources];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _vboID = -1;
    _vboTexID = -1;
    _textureID = -1;
    _uniformTexID = -1;
    _vaoID = -1;
    
    [self setupGLView];
    [self setupGLProgram];
    [self setupDraw];
    [self setupTexture];
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
    "layout(location = 1) in vec2 vTexCoord;  \n"
    "out vec2 v_texCoord;                     \n"
    "void main()                              \n"
    "{                                        \n"
    "   gl_Position = vPosition;              \n"
    "   v_texCoord = vTexCoord;               \n" //纹理坐标
    "}                                        \n";
    
    //初始化加载顶点着色器
    GLuint vShader = [self compileShader:GL_VERTEX_SHADER shaderStr:vShaderStr];
    
    GLchar fShaderStr[] =
    "#version 300 es                              \n"
    "precision mediump float;                     \n"
    "uniform sampler2D s_texture;                 \n"
    "in vec2 v_texCoord;                          \n"
    "out vec4 fragColor;                          \n"
    "void main()                                  \n"
    "{                                            \n"
    "   fragColor = texture(s_texture,v_texCoord);\n"
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
        
        //顶点数组
        GLfloat vertexs[] = {
            -0.5, -0.5,
            0.5, -0.5,
            0, 0.5,
        };
        
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_STATIC_DRAW);
        
        //绑定纹理坐标
        glGenBuffers(1, &_vboTexID);
        glBindBuffer(GL_ARRAY_BUFFER, _vboTexID);
        
        GLfloat texCoord[] = {
            0, 0,
            1, 0,
            0.5, 1,
        };
        
        glBufferData(GL_ARRAY_BUFFER, sizeof(texCoord), texCoord, GL_STATIC_DRAW);
    }
    
    if (_vaoID == -1) {
        glGenVertexArrays(1, &_vaoID);
        glBindVertexArray(_vaoID);
    }
            
    //positionIndex=0,vec2
    glBindBuffer(GL_ARRAY_BUFFER, _vboID);
    glVertexAttribPointer(0, 2, GL_FLOAT, NO, 0, (void*)0);
    glEnableVertexAttribArray(0);
    
    //texture coordinate
    glBindBuffer(GL_ARRAY_BUFFER, _vboTexID);
    glVertexAttribPointer(1, 2, GL_FLOAT, NO, 0, (void*)0);
    glEnableVertexAttribArray(1);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

- (void)setupTexture {
    if (_textureID == -1) {
        glGenTextures(1, &_textureID);
        glBindTexture(GL_TEXTURE_2D, _textureID);

        //设置过滤方式为就近采样
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        //设置环绕方式为重复
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

        NSString *imgPath = [NSBundle.mainBundle pathForResource:@"wall" ofType:@"jpg"];
        UIImage *uiImg = [UIImage imageWithContentsOfFile:imgPath];
        CGImageRef cgImg = uiImg.CGImage;
        GLsizei width =  (GLsizei)CGImageGetWidth(cgImg);
        GLsizei height = (GLsizei)CGImageGetHeight(cgImg);

        CFDataRef dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(cgImg));
        GLubyte *imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);//通过系统解码图片拿到图片原始数据RGBA32

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);

        _uniformTexID = glGetUniformLocation(self.program, "s_texture");
    }
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

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textureID);
    glUniform1i(_uniformTexID, 0);//很奇怪的一点，为什么需要填数字0而不是GL_TEXTURE0，也不是_textureID，迷惑设计
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glBindVertexArray(0);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view display];
    });
}


//释放资源
- (void)freeResources {
    if (_vboID != -1) {
        glDeleteBuffers(1, &_vboID);
    }
    
    if (_vboTexID != -1) {
        glDeleteBuffers(1, &_vboTexID);
    }
    
    if (_textureID != -1) {
        glDeleteTextures(1, &_textureID);
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
