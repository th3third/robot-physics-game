//
//  MToolsDebug.h
//  skeefree
//
//  Created by Marshall on 02/10/2012.
//
//

#import <Foundation/Foundation.h>

@interface MToolsDebug : NSObject
{
    
}

@property bool enableLog;

+ (MToolsDebug *) sharedManager;

+ (void) log: (NSString *) message;

@end

@interface  debug : MToolsDebug

+ (void) log: (NSString *) message;

@end
