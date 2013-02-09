//
//  MToolsFileManager.m
//  AppScaffold
//
//  Created by Marshall on 29/11/2012.
//
//

#import "MToolsFileManager.h"

@implementation MToolsFileManager

+ (NSArray *) sortByDateDesc: (NSArray *) filesArray atPath: (NSString *) path
{
    NSError *error;
    
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
    for(NSString* file in filesArray) {
        NSString* filePath = [path stringByAppendingPathComponent:file];
        NSDictionary* properties = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath: filePath
                                    error:&error];
        NSDate* modDate = [properties objectForKey:NSFileModificationDate];
        
        if(error == nil)
        {
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           file, @"path",
                                           modDate, @"lastModDate",
                                           nil]];
        }
    }
    
    // sort using a block
    // order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {
                                // compare
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                           [path2 objectForKey:@"lastModDate"]];
                                // invert ordering
                                if (comp == NSOrderedDescending) {
                                    comp = NSOrderedAscending;
                                }
                                else if(comp == NSOrderedAscending){
                                    comp = NSOrderedDescending;
                                }
                                return comp;
                            }];

    return sortedFiles;
}

+ (NSArray *) sortByDateAsc: (NSArray *) filesArray atPath: (NSString *) path
{
    NSError *error;
    
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
    for(NSString* file in filesArray) {
        NSString* filePath = [path stringByAppendingPathComponent:file];
        NSDictionary* properties = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath: filePath
                                    error:&error];
        NSDate* modDate = [properties objectForKey:NSFileModificationDate];
        
        if(error == nil)
        {
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           file, @"path",
                                           modDate, @"lastModDate",
                                           nil]];
        }
    }
    
    // sort using a block
    // order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {
                                // compare
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                           [path2 objectForKey:@"lastModDate"]];
                                return comp;
                            }];
    
    return sortedFiles;
}

+ (bool) addSkipBackupAttributeToItemAtString: (NSString *) string
{
    NSURL *url = [NSURL fileURLWithPath: string];
    if (![[NSFileManager defaultManager] fileExistsAtPath: [url path]])
        return NO;
    
    NSError *error;
    bool success = [url setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if (!success)
    {
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    
    return success;
}

+ (NSString *)applicationDocumentsDirectory
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
