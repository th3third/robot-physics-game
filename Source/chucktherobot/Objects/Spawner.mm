//
//  Spawner.m
//  chucktherobot
//
//  Created by Marshall on 07/01/2013.
//
//

#import "Spawner.h"

@implementation Spawner

+ (Spawner *) spawnerWithType: (int) newType andX: (float) x andY: (float) y
{
    return [[Spawner alloc] initWithType: newType andX: x andY: y];
}

- (id) init
{
    return [self initWithType: (int) 0 andX: (float) 20 andY: (float) 20];
}

- (id) initWithType: (int) newType andX: (float) x andY: (float) y
{
    if (self = [super init])
    {
        self.type = newType;
        self.startPos = ccp(x, y);
        
        [self createBox2DBody];
    }
    
    return self;
}

- (void) tick:(ccTime)dt
{
    if (self.spawned)
        return;
    
    //Spawn "Chuck" here.
    Chuck *chuck = [Chuck chuckWithPos: self.startPos];
    self.chuck = chuck;
    self.spawned = YES;
}

- (void) reset
{
    self.spawned = NO;
    [self.chuck remove];
}

- (NSString *) serialize
{
    NSMutableString *code = [NSMutableString string];
    [code appendString: [super serialize]];
    
    return code;
}

- (void) moveByX:(float)x andY:(float)y
{
    [self moveToPoint: ccp(self.bodyVisible.position.x + x, self.bodyVisible.position.y + y)];
}

- (void) moveToPoint:(CGPoint)point
{
    if (!self.bodyVisible)
        return;
    
    self.bodyVisible.position = point;
    self.startPos = point;
}

- (void) remove
{
    [debug log: @"You cannot remove the spawner, that would break the stage!"];
}

- (void) createBox2DBody
{
    [self createVisibleBody];
}

- (void) createVisibleBody
{
    if (self.bodyVisible)
    {
        return;
    }
    self.bodyVisible = [CCSprite spriteWithFile: @"Media/Objects/spawn.png"];
    [self addChild: self.bodyVisible];
}

@end
