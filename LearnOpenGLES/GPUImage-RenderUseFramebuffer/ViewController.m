//
//  ViewController.m
//  GPUImage-RenderUseFramebuffer
//
//  Created by SkyRim on 2020/5/23.
//  Copyright © 2020 SkyRim. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import "RenderView.h"
#import "BrightnessFilter.h"
#import "ColorInverseFilter.h"

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) BrightnessFilter *filter1;
@property (nonatomic, strong) ColorInverseFilter *filter2;
@property (nonatomic, strong) RenderView *renderView;
@property (nonatomic, assign) GLuint tex;

@end

@implementation ViewController

- (void)dealloc {
    if (_tex != -1) {
        glDeleteTextures(1, &_tex);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tex = -1;
    
    [self setupContext];
    [self setupRenderView];
    [self setupFilter1];
    [self setupFilter2];
    [self render];
}

- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        printf("Failed to create ES context\n");
        return;
    }
    
    [EAGLContext setCurrentContext:self.context];
}

- (void)setupRenderView {
    self.renderView = [[RenderView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.renderView];
}

- (void)setupFilter1 {
    self.filter1 = [[BrightnessFilter alloc] initWithSize:self.view.bounds.size];
    self.filter1.brightness = 0.5;
}

- (void)setupFilter2 {
    self.filter2 = [[ColorInverseFilter alloc] initWithSize:self.view.bounds.size];
}

- (GLuint)getTextureFromImage:(UIImage *)image {
    CGImageRef cgImage = image.CGImage;
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef imgData = CGDataProviderCopyData(provider);
    GLbyte *byte = (GLbyte *)CFDataGetBytePtr(imgData);
    
    GLuint tex;
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, byte);
    
    return tex;
}

- (void)render {
    if (self.tex == -1) {
        NSString *imgPath = [NSBundle.mainBundle pathForResource:@"wall" ofType:@"jpg"];
        UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
        self.tex = [self getTextureFromImage:img];
    }

    [self.filter1 processTexture:self.tex index:GL_TEXTURE0 completion:^(GLuint texture) {
        [self.filter2 processTexture:texture index:GL_TEXTURE1 completion:^(GLuint texture) {
            [self.renderView renderTexture:texture index:GL_TEXTURE2];
        }];
    }];
}

@end
