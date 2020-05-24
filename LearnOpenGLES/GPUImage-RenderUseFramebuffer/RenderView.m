//
//  RenderView.m
//  GPUImage-RenderUseFramebuffer
//
//  Created by SkyRim on 2020/5/23.
//  Copyright © 2020 SkyRim. All rights reserved.
//

#import "RenderView.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import "YFDefineHeader.h"

@interface RenderView ()

@property (nonatomic, assign) GLint program;
@property (nonatomic, assign) GLuint framebuffer;
@property (nonatomic, assign) GLuint renderbuffer;
@property (nonatomic, assign) GLuint tex;

@end

@implementation RenderView

+(Class)layerClass {
    return CAEAGLLayer.class;
}

- (void)dealloc {
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
    }
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
    }
    
    if (_program) {
        glDeleteProgram(_program);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
        [self setupFramebuffer];
        [self setupGLProgram];
    }
    
    return self;
}

- (void)setupLayer {
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.backgroundColor = UIColor.whiteColor.CGColor;
    layer.opaque = YES;
}

- (void)setupFramebuffer {
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    glGenRenderbuffers(1, &_renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    [EAGLContext.currentContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSAssert(NO, @"glCheckFramebufferStatus failed.");
    }
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

- (void)renderTexture:(GLuint)texture index:(GLenum)index {
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.program);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    static GLfloat verticals[] = {
        -1, -1,
        1, -1,
        -1, 1,
        1, 1,
    };
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, verticals);
    
    static GLfloat coords[] = {
        0, 0,
        1, 0,
        0, 1,
        1, 1,
    };
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, coords);
    
    glActiveTexture(index);
    glBindTexture(GL_TEXTURE_2D, texture);
    int textureUniform = glGetUniformLocation(self.program, "s_texture");
    glUniform1i(textureUniform, index - GL_TEXTURE0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [EAGLContext.currentContext presentRenderbuffer:_renderbuffer];
    
    GL_ERRORS(__LINE__);
}

@end
