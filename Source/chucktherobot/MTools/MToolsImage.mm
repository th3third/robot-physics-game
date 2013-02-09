//
//  MToolsImage.m
//  Laser Wars
//
//  Created by Marshall on 08/11/2012.
//
//

#import "MToolsImage.h"
#import "SPRenderSupport.h"
#import "SPRenderTexture.h"

@implementation MToolsImage

- (id) init
{
    if (self = [super init])
    {
        self.glow = NO;
        self.glowAmount = 20;
    }
    
    return self;
}

- (void) setGlow: (bool) glow
{
    if (glow == _glow)
        return;
    
    _glow = glow;
    
    if (!glow)
    {
        if (self.originalTexture)
            self.texture = self.originalTexture;
        
        return;
    }
    
    self.originalTexture = self.texture;
    
    SPRenderTexture *renderTexture = [[SPRenderTexture alloc] initWithWidth: self.texture.width + (self.glowAmount * 2) height:self.texture.height + (self.glowAmount * 2)];
    
    SPImage *image = [SPImage imageWithTexture: self.texture];
    float alphaSteps = self.alpha / self.glowAmount;
    
    for (int i = self.glowAmount; i >= 0; i--)
    {
        image.width = self.texture.width + (i * (self.glowAmount * 2));
        image.height = self.texture.height + (i * (self.glowAmount * 2));
        image.alpha = self.alpha - (alphaSteps * i);
        
        [renderTexture drawObject: image];
    }
    
    self.texture = renderTexture;
}

@end
