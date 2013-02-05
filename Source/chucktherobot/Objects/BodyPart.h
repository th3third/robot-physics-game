//
//  BodyPart.h
//  chucktherobot
//
//  Created by Marshall on 14/01/2013.
//
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "cocos2d.h"

@interface BodyPart : NSObject

@property (nonatomic, assign) b2Body *body;
@property float width;
@property float height;
@property CGPoint startPos;
@property CCSprite *sprite;
@property CCSprite *spriteHurt;
@property float dx;
@property float dy;

+ (BodyPart *) bodyPartWithBody: (b2Body *) bodyIn;

@end
