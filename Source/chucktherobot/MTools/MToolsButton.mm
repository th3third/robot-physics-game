//
//  MToolsButton.m
//  AppScaffold
//
//  Created by Marshall on 12/09/2012.
//
//

#import "MToolsButton.h"
#import "MToolsMedia.h"

@implementation MToolsButton

@synthesize value;

- (id) initWithUpState:(SPTexture *)upState
{
    if (self = [super initWithUpState: upState])
    {
        self.pivotX = self.width / 2;
        self.pivotY = self.height / 2;
        self.x = self.pivotX;
        self.y = self.pivotY;
        animationDelay = 0;
    }
    
    return self;
}

//Set up the image you want as the shadow.
- (void) setShadow: (SPTexture *) texture
{
    shadow = [SPImage imageWithTexture: texture];
    shadow.width = self.width;
    shadow.height = self.height;
    shadow.x += shadow.width * 0.1f;
    shadow.y += shadow.height * 0.1f;
    
    [self addChild: shadow];
    
    //Swap it to the back.
    [self swapChild: [self childAtIndex: 0] withChild: shadow];
}

- (void) startAnimation
{
    self.alpha = 0.8f;
    [self eventBounceStart: nil];
}

- (void) setAnimationType: (int) type
{
    animationType = type;
}

- (void) setAnimationDelay: (float) delay
{
    animationDelay = delay;
}

- (void) eventBounceStart: (SPEvent *) event
{
    switch (animationType)
    {
        case 0:
        default:
        {
            SPTween *tween = [SPTween tweenWithTarget: self time: 1.0f transition: SP_TRANSITION_EASE_IN_OUT];
            [tween animateProperty: @"scaleX" targetValue: 1.25f];
            [tween animateProperty: @"scaleY" targetValue: 1.25f];
            [tween animateProperty: @"rotation" targetValue: self.rotation + SP_D2R(10)];
            [tween animateProperty: @"alpha" targetValue: 1.0f];
            [tween addEventListener: @selector(eventBounceEnd:) atObject: self forType: SP_EVENT_TYPE_TWEEN_COMPLETED];
            [[SPStage mainStage].juggler addObject: tween];
            
            if (shadow)
            {
                SPTween *tween = [SPTween tweenWithTarget: shadow time: 1.0f transition: SP_TRANSITION_EASE_IN_OUT];
                [tween animateProperty: @"scaleX" targetValue: shadow.scaleX + .10f];
                [tween animateProperty: @"scaleY" targetValue: shadow.scaleY + .10f];
                [tween animateProperty: @"x" targetValue: shadow.x += 20];
                [tween animateProperty: @"y" targetValue: shadow.y += 20];
                [tween animateProperty: @"alpha" targetValue: 0.5f];
                [[SPStage mainStage].juggler addObject: tween];
            }
        }
        break;
            
        case 1:
        {
            self.scaleX = 0;
            self.scaleY = 0;
            self.rotation = SP_D2R(20);
            
            SPTween *tween = [SPTween tweenWithTarget: self time: 0.5f transition: SP_TRANSITION_EASE_OUT];
            [tween animateProperty: @"scaleX" targetValue: 1.00f];
            [tween animateProperty: @"scaleY" targetValue: 1.00f];
            [tween animateProperty: @"rotation" targetValue: SP_D2R(0)];
            tween.delay = 1.5f + animationDelay;
            [[SPStage mainStage].juggler addObject: tween];
        }
        break;
    }
}

- (void) eventBounceEnd: (SPEvent *) event
{
    SPTween *tween = [SPTween tweenWithTarget: self time: 1.0f transition: SP_TRANSITION_EASE_IN_OUT];
    [tween animateProperty: @"scaleX" targetValue: 1.0f];
    [tween animateProperty: @"scaleY" targetValue: 1.0f];
    [tween animateProperty: @"rotation" targetValue: self.rotation - SP_D2R(10)];
    [tween animateProperty: @"alpha" targetValue: 0.8f];
    [tween addEventListener: @selector(eventBounceStart:) atObject: self forType: SP_EVENT_TYPE_TWEEN_COMPLETED];
    [[SPStage mainStage].juggler addObject: tween];
    
    if (shadow)
    {
        SPTween *tween = [SPTween tweenWithTarget: shadow time: 1.0f transition: SP_TRANSITION_EASE_IN_OUT];
        [tween animateProperty: @"scaleX" targetValue: shadow.scaleX - .10f];
        [tween animateProperty: @"scaleY" targetValue: shadow.scaleY - .10f];
        [tween animateProperty: @"x" targetValue: shadow.x -= 20];
        [tween animateProperty: @"y" targetValue: shadow.y -= 20];
        [tween animateProperty: @"alpha" targetValue: 1.0f];
        [[SPStage mainStage].juggler addObject: tween];
    }
}

@end
