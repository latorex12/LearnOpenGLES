//
//  BrightnessFilter.h
//  GPUImage-RenderUseFramebuffer
//
//  Created by SkyRim on 2020/5/24.
//  Copyright © 2020 SkyRim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface BrightnessFilter : NSObject

@property (nonatomic, assign) float brightness;

- (instancetype)initWithSize:(CGSize)size;
- (void)processTexture:(GLuint)texture index:(GLenum)index completion:(void(^)(GLuint texture))completion;

@end

NS_ASSUME_NONNULL_END
