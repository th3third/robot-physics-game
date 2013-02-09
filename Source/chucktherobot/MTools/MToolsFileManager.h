//
//  MToolsFileManager.h
//  AppScaffold
//
//  Created by Marshall on 29/11/2012.
//
//

#import <Foundation/Foundation.h>

@interface MToolsFileManager : NSFileManager

+ (NSArray *) sortByDateDesc: (NSArray *) filesArray atPath: (NSString *) path;
+ (NSArray *) sortByDateAsc: (NSArray *) filesArray atPath: (NSString *) path;

+ (bool) addSkipBackupAttributeToItemAtString: (NSString *) string;
+ (NSString *)applicationDocumentsDirectory;

@end
