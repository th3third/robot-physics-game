//
//  MToolsAppSettings.m
//  AppScaffold
//
//  Created by Marshall on 27/11/2012.
//
//

#import "MToolsAppSettings.h"
#import "MToolsDebug.h"

@implementation MToolsAppSettings

@synthesize appDefaults;

//Singleton implementation.
static MToolsAppSettings *sharedManager = nil;

+ (MToolsAppSettings *) sharedManager
{
    if (!sharedManager)
    {
        sharedManager = [[MToolsAppSettings alloc] init];
    }
    
    return sharedManager;
}

- (id) init
{
    if (self = [super init])
    {
        appDefaults = [NSDictionary dictionary];
        
        [self processScheduledDeletions];
    }
    
    return self;
}

- (void) standardKeys
{
    NSNumber *timesRun = [MToolsAppSettings getValueWithName: @"timesRun"];
    if (!timesRun)
        timesRun = [NSNumber numberWithInt: 0];
    timesRun = [NSNumber numberWithInt: [timesRun intValue] + 1];
    
    [MToolsAppSettings setValue: timesRun withName: @"timesRun"];
    [debug log: [NSString stringWithFormat: @"Number of times run: %@", [MToolsAppSettings getValueWithName: @"timesRun"]]];
}

- (void) loadDefaults
{
    
}

//Overrides the current defaults with the app defaults dictionary. Shouldn't need to use this unless something weird is going on.
- (void) registerDefaults
{
    [[NSUserDefaults standardUserDefaults] registerDefaults: appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//Set a default value for the app. This goes directly in to the standard user defaults.
//This MUST be an object.
+ (void) setValue: (id) newDefault withName: (NSString *) name
{
	if (!newDefault || [name isEqualToString: @""])
		return;
	
    [[NSUserDefaults standardUserDefaults] setObject: newDefault forKey: name];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//Removes a value from the standard user defaults.
+ (void) removeValueWithName: (NSString *) name
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: name];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//Retrives the value of a user default. This comes directly from the standard user defaults.
//This MUST be an object.
+ (id) getValueWithName: (NSString *) name
{
    //[[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] objectForKey: name];
}

//Creates a reminder that will delete a certain named key after x amount of app starts.
//This is useful to clear entries for the network alert system so the alerts will pop back up again.
+ (void) scheduleDeletionForKey: (NSString *) name startsFromNow: (NSNumber *) starts
{
    NSMutableArray *reminders = [NSMutableArray array];
    
    //Get the existing reminders if it's already there.
    if ([MToolsAppSettings getValueWithName: @"reminders"])
        reminders = [MToolsAppSettings getValueWithName: @"reminders"];
    
    NSMutableDictionary *reminder = [NSDictionary dictionaryWithObjectsAndKeys:
                              starts, @"startsLeft",
                              name, @"name",
                              nil];
    [reminders addObject: reminder];
    [MToolsAppSettings setValue: reminders withName: @"reminders"];
    [debug log: [NSString stringWithFormat: @"Scheduling reminder for %@ in %@ starts", name, starts]];
}

//Processes all of the reminders and does the deletions if they've reached zero.
//NOTICE: This should only be called ONCE per start.
- (void) processScheduledDeletions
{
    //Just return if there aren't any scheduled deletions.
    if (![MToolsAppSettings getValueWithName: @"reminders"])
    {
        return;
    }
    
    NSMutableArray *reminders = [MToolsAppSettings getValueWithName: @"reminders"];
    NSMutableArray *remove = [NSMutableArray array];
    [debug log: [NSString stringWithFormat: @"Reminders: %d", [reminders count]]];
    
    for (NSMutableDictionary *reminder in reminders)
    {
        NSNumber *startsLeft = [reminder objectForKey: @"startsLeft"];
        startsLeft = [NSNumber numberWithInt: [startsLeft intValue] - 1];
        
        //If it's at zero, we need to remove the keys.
        if ([startsLeft intValue] <= 0)
        {
            [debug log: [NSString stringWithFormat: @"Removing reminder for %@", [reminder objectForKey: @"name"]]];
            [MToolsAppSettings removeValueWithName: [reminder objectForKey: @"name"]];
            [remove addObject: reminder];
        }
        //Otherwise, reinsert.
        else
        {
            [reminder setObject: startsLeft forKey: @"startsLeft"];
        }   
    }
    
    //Clean up the leftover reminders.
    for (NSMutableArray *reminder in remove)
    {
        [reminders removeObject: reminder];
    }
}

@end
