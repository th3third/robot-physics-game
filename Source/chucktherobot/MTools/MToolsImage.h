//
//  MToolsImage.h
//  Laser Wars
//
//  Created by Marshall on 08/11/2012.
//
//

#import "SPImage.h"

@interface MToolsImage : SPImage

@property (nonatomic) bool glow;
@property int glowAmount;
@property (unsafe_unretained) SPTexture *originalTexture;

@end
