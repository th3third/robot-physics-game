//
//  StageFile.h
//  chucktherobot
//
//  Created by Marshall on 07/01/2013.
//
//

#import <Foundation/Foundation.h>
#import "DialogLayer.h"

@class Object;

@interface Stage : NSObject <NSXMLParserDelegate>
{
	NSXMLParser *parser;
	DialogLayer *diaLayer;
	
	//Caches for the parsing operations.
	bool parsingObjects;
	NSString *currentElement;
	NSMutableString *parsedName;
	NSMutableString *parsedCreator;
	NSMutableString *parsedLastModified;
	NSMutableString *parsedBackground;
	NSMutableString *parsedObjectValue;
	NSMutableDictionary *parsedObject;
	NSMutableArray *parsedObjects;
	NSMutableArray *parsedTags;
	NSMutableString *parsedRating;
}

@property NSString *name;
@property NSString *creator;
@property int background;
@property NSDate *lastModified;
@property int rating;
@property NSMutableArray *tags;
@property (nonatomic) NSString *serialized;

@property NSMutableArray *objects;

+ (Stage *) stage;
+ (Stage *) stageWithData: (NSData *) data;
- (id) initWithData: (NSData *) data;

- (void) createDefaults;
- (void) addObject: (Object *) object;
- (void) removeObject: (Object *) object;
- (void) removeAllObjects;

- (bool) saveToFile;

@end
