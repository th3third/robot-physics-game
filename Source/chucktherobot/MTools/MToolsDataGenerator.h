//
//  DataGenerator.h
//  MusicTouch
//
//  Created by Marshall on 27/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface MToolsDataGenerator : NSObject
{
    
}

+ (NSArray *) wordsFromLetters;
+ (NSArray *) lettersFromWords: (NSArray *) content;

@end
