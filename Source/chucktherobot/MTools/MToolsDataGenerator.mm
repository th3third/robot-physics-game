//
//  MToolsDataGenerator.m
//  MusicTouch
//
//  Created by Marshall on 27/09/2012.
//
//

#import "MToolsDataGenerator.h"

@implementation MToolsDataGenerator

#define WORD_LENGTH 5

static NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

+ (NSArray *) wordsFromLetters {
    NSMutableArray *content = [NSMutableArray new];
    
    for (int i = 0; i < [letters length]; i++ ) {
        NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
        char currentWord[WORD_LENGTH + 1];
        NSMutableArray *words = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < WORD_LENGTH; j++ ) {
            if (j == 0) {
                currentWord[j] = toupper([letters characterAtIndex:i]);
            }
            else {
                currentWord[j] = [letters characterAtIndex:i];
            }
            currentWord[j+1] = '\0';
            [words addObject:[NSString stringWithCString:currentWord encoding:NSASCIIStringEncoding]];
        }
        char currentLetter[2] = { toupper([letters characterAtIndex:i]), '\0'};
        [row setValue:[NSString stringWithCString:currentLetter encoding:NSASCIIStringEncoding]
               forKey:@"headerTitle"];
        [row setValue:words forKey:@"rowValues"];
        [content addObject:row];
    }
    
    return content;
}

+ (NSArray *) lettersFromWords: (NSArray *) content
{
    NSMutableArray *words = [[NSMutableArray alloc] init];
    NSMutableDictionary *row;
    NSMutableArray *values;
    char currentLetter;
    bool add = false;
    
    for (int i = 0; i < [content count]; i++)
    {
        NSString *object = [content objectAtIndex: i];

        if (currentLetter != [object characterAtIndex: 0])
        {
            row = [[NSMutableDictionary alloc] init];
            values = [[NSMutableArray alloc] init];
            add = true;
        }
        else
        {
            add = false;
        }
        
        currentLetter = [object characterAtIndex: 0];
        [values addObject: [content objectAtIndex: i]];
        
        [row setValue: [NSString stringWithFormat: @"%c", currentLetter]
               forKey:@"headerTitle"];
        [row setValue: values forKey:@"rowValues"];
        
        if (add)
            [words addObject:row];
    }
    
    return words;
}

@end
