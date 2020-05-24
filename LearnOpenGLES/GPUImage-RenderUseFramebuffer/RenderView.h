//
//  RenderView.h
//  GPUImage-RenderUseFramebuffer
//
//  Created by SkyRim on 2020/5/23.
//  Copyright © 2020 SkyRim. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RenderView : UIView

- (void)setupLayer;

- (void)renderTexture:(GLuint)texture index:(GLenum)index;

@end

NS_ASSUME_NONNULL_END
