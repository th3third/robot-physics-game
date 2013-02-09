//
//  MToolsButton.h
//  AppScaffold
//
//  Created by Marshall on 12/09/2012.
//
//

#import "SPButton.h"

@interface MToolsButton : SPButton
{
    SPImage *shadow;
    int animationType;
    float animationDelay;
}

@property (unsafe_unretained) NSNumber *value;

- (void) setShadow: (SPTexture *) texture;

- (void) startAnimation;
- (void) setAnimationType: (int) type;
- (void) setAnimationDelay: (float) delay;

@end
