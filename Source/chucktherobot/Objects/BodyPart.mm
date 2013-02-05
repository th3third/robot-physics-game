//
//  BodyPart.m
//  chucktherobot
//
//  Created by Marshall on 14/01/2013.
//
//

#import "BodyPart.h"

@implementation BodyPart

+ (BodyPart *) bodyPartWithBody: (b2Body *) bodyIn
{
    BodyPart *part = [[BodyPart alloc] init];
    part.body = bodyIn;
    
    return part;
}

@end
