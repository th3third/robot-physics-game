//
//  MToolsDebug.m
//  skeefree
//
//  Created by Marshall on 02/10/2012.
//
//

#import "MToolsDebug.h"

@implementation MToolsDebug

@synthesize enableLog;

//Singleton implementation.
static MToolsDebug *sharedManager = nil;

+ (MToolsDebug *) sharedManager
{
    if (!sharedManager)
    {
        sharedManager = [[MToolsDebug alloc] init];
        sharedManager.enableLog = true;
    }
    
    return sharedManager;
}

+ (void) log: (NSString *) message
{
    if (sharedManager.enableLog)
    {
        NSLog(@"Debug: %@", message);
    }
}

@end

@implementation debug

+ (void) log: (NSString *) message
{
    if (sharedManager.enableLog)
    {
        NSLog(@"Debug: %@", message);
    }
}

@end
