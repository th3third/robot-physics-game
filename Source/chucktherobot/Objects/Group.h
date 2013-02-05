//
//  Group.h
//  chucktherobot
//
//  Created by Marshall on 16/01/2013.
//
//

#import <Foundation/Foundation.h>
#import "Object.h"

@interface Group : NSObject

@property NSMutableArray *objects;

- (void) addObject: (id) object;
- (void) removeObject: (Object *) object;

@end
