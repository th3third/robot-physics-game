//
//  MToolsAppSettings.h
//  AppScaffold
//
//  Created by Marshall on 27/11/2012.
//
//  Used to help save and load application settings.
//

#import <Foundation/Foundation.h>

@interface MToolsAppSettings : NSObject

//Singleton implementation.
+ (MToolsAppSettings *) sharedManager;

@property (unsafe_unretained) NSDictionary *appDefaults;    //used to store all the app default settings.

- (void) standardKeys;
- (void) registerDefaults;
+ (void) setValue: (id) newDefault withName: (NSString *) name;
+ (id) getValueWithName: (NSString *) name;
+ (void) removeValueWithName: (NSString *) name;

+ (void) scheduleDeletionForKey: (NSString *) name startsFromNow: (NSNumber *) starts;
- (void) processScheduledDeletions;

@end
