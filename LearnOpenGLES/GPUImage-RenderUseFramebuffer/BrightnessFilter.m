//
//  BrightnessFilter.m
//  GPUImage-RenderUseFramebuffer
//
//  Created by SkyRim on 2020/5/24.
//  Copyright © 2020 SkyRim. All rights reserved.
//

#import "BrightnessFilter.h"

@interface BrightnessFilter ()

@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint framebuffer;
@property (nonatomic, assign) GLuint texture;

@property (nonatomic, assign) CGSize size;

@end

@implementation BrightnessFilter

- (void)dealloc {
    glDeleteProgram(_program);
    glDeleteFramebuffers(1, &_framebuffer);
    glDeleteTextures(1, &_texture);
}

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super init]) {
        _size = size;
        [self setupFramebuffer];
        [self setupGLProgram];
    }
    
    return self;
}

- (void)setupFramebuffer {
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _size.width, _size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
    
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
    "uniform float brightness;                    \n"
    "in vec2 v_texCoord;                          \n"
    "out vec4 fragColor;                          \n"
    "void main()                                  \n"
    "{                                            \n"
    "   fragColor = texture(s_texture,v_texCoord) + vec4(brightness);\n"
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

- (void)processTexture:(GLuint)texture index:(GLenum)index completion:(nonnull void (^)(GLuint))completion {
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    glViewport(0, 0, self.size.width, self.size.height);
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.program);
    
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
    
    int brightnessUniform = glGetUniformLocation(self.program, "brightness");
    glUniform1f(brightnessUniform, self.brightness);
    
    glActiveTexture(index);
    glBindTexture(GL_TEXTURE_2D, texture);
    int textureUniform = glGetUniformLocation(self.program, "s_texture");
    glUniform1i(textureUniform, index - GL_TEXTURE0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glFinish();

    completion(_texture);
}

@end
