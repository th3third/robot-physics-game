//
//  Spawner.h
//  chucktherobot
//
//  Created by Marshall on 07/01/2013.
//
//

#import "Object.h"
#import "Chuck.h"

@interface Spawner : Object

@property bool spawned;
@property Chuck *chuck;

+ (Spawner *) spawnerWithType: (int) newType andX: (float) x andY: (float) y;
- (id) initWithType: (int) newType andX: (float) x andY: (float) y;

@end
