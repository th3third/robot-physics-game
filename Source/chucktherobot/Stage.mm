//
//  StageFile.m
//  chucktherobot
//
//  Created by Marshall on 07/01/2013.
//
//

#import "Stage.h"
#import "Spawner.h"
#import "Director.h"
#import "DialogLayer.h"
#import "MToolsFileManager.h"
#import "Objects.h"

@implementation Stage

@synthesize name, creator, lastModified, background;

+ (Stage *) stage
{    
    return [self stageWithData: nil];
}

+ (Stage *) stageWithData: (NSData *) data
{
    return [[Stage alloc] initWithData: data];
}

- (id) init
{
    if (self = [self initWithData: nil])
    {
		if (!self.objects)
			self.objects = [NSMutableArray array];
    }
    
    return self;
}

- (id) initWithData: (NSData *) data
{
	if (self = [super init])
	{		
		if (!data)
		{
			[self createDefaults];
		}
		else
		{			
			parser = [[NSXMLParser alloc] initWithData: data];
			[parser setDelegate: self];
			[parser setShouldProcessNamespaces: NO];
			[parser setShouldReportNamespacePrefixes: NO];
			[parser setShouldResolveExternalEntities: NO];
			[parser parse];
			
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			self.name = parsedName;
			self.creator = parsedCreator;
			self.lastModified = [dateFormatter dateFromString: parsedLastModified];
			self.background = [parsedBackground intValue];
			
			[self unserializeObjects: parsedObjects];
		}
	}
	
	return self;
}

- (NSString *) serialize
{
	NSMutableString *code = [NSMutableString string];
	
    //Update the last modified value.
    lastModified = [NSDate date];
    
    //Update the creator to the currently logged in user.
    //If they're not logged in, this defaults to Anonymous.
    //TODO: Put in the checking for this when the log in system is implemented.
    creator = @"Anonymous";
    
	//Stage opening tag.
	[code appendString: @"<stage>"];
	
    //Stage name
    [code appendString: @"<name>"];
    [code appendString: name];
    [code appendString: @"</name>\n"];
    
    //Stage creator
    [code appendString: @"<creator>"];
    [code appendString: creator];
    [code appendString: @"</creator>\n"];
	
    //Last modified
    [code appendString: @"<lastModified>"];
    [code appendString: [lastModified description]];
    [code appendString: @"</lastModified>\n"];
	
	//Background
    [code appendString: @"<background>"];
    [code appendString: [NSString stringWithFormat: @"%d", background]];
    [code appendString: @"</background>\n"];
    
    //Stage objects
    [code appendString: @"<objects>\n"];
    for (Object *object in self.objects)
    {
		[code appendString: @"<object>\n"];
        [code appendString: [NSString stringWithFormat: @"<type>%@</type>\n", object.class]];
        [code appendString: [object serialize]];
		[code appendString: @"</object>\n"];
    }
    [code appendString: @"</objects>"];
    
	//Stage opening tag.
	[code appendString: @"</stage>"];
	
	return code;
}

- (void) unserializeObjects: (NSArray *) objects
{
	NSMutableArray *jointsToAdd = [NSMutableArray array];
	
	for (NSDictionary *dict in objects)
	{
		NSString *type = [dict objectForKey: @"type"];
		if ([type isEqualToString: @"Chuck"])
		{
			Chuck *chuck = [[Chuck alloc] unserializeWithDict: dict];
			[self addObject: chuck];
		}
		else if ([type isEqualToString: @"Rectangle"])
		{
			Rectangle *rectangle = [[Rectangle alloc] unserializeWithDict: dict];
			[self addObject: rectangle];
		}
		else if ([type isEqualToString: @"Circle"])
		{
			Circle *circle = [[Circle alloc] unserializeWithDict: dict];
			[self addObject: circle];
		}
		else if ([type isEqualToString: @"Balloon"])
		{
			Balloon *balloon = [[Balloon alloc] unserializeWithDict: dict];
			[self addObject: balloon];
		}
		else if ([type isEqualToString: @"Pivot"])
		{
			[jointsToAdd addObject: dict];
		}
		else if ([type isEqualToString: @"Weld"])
		{
			[jointsToAdd addObject: dict];
		}
		else if ([type isEqualToString: @"Rope"])
		{
			[jointsToAdd addObject: dict];
		}
		else if ([type isEqualToString: @"Motor"])
		{
			[jointsToAdd addObject: dict];
		}
	}
	
	[self addUnserializedJoints: jointsToAdd];
}

- (void) addUnserializedJoints: (NSMutableArray *) joints
{	
	for (int addType = 0; addType < 4; addType++)
	{		
		for (NSDictionary *dict in joints)
		{		
			NSString *type = [dict objectForKey: @"type"];
			if ([type isEqualToString: @"Pivot"] && addType == 0)
			{
				Pivot *pivot = [[Pivot alloc] unserializeWithDict: dict];
				[self addObject: pivot];
			}
			else if ([type isEqualToString: @"Motor"]  && addType == 1)
			{
				Motor *motor = [[Motor alloc] unserializeWithDict: dict];
				[self addObject: motor];
			}
			else if ([type isEqualToString: @"Weld"]  && addType == 2)
			{
				Weld *weld = [[Weld alloc] unserializeWithDict: dict];
				[self addObject: weld];
			}
			else if ([type isEqualToString: @"Rope"]  && addType == 3)
			{
				Rope *rope = [[Rope alloc] unserializeWithDict: dict];
				[self addObject: rope];
			}
		}
	}
}

#pragma mark PARSING OPERATIONS

- (void) parserDidStartDocument:(NSXMLParser *)parser
{
	//TODO: Put in a loading notification for this.
	[debug log: @"Parser started."];
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
	//TODO: Clear the loading notification.
    [debug log: @"Finished parsing"];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [debug log: [NSString stringWithFormat: @"An error occured during parsing: %@", parseError]];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //[debug log: [NSString stringWithFormat: @"Started element: %@", elementName]];
    currentElement = [elementName copy];
    
	//NON-OBJECT SECTION
	if (!parsingObjects)
	{
		if ([currentElement isEqualToString: @"stage"])
		{
			//Clear all the caches.
			parsedName = [NSMutableString string];
			parsedCreator = [NSMutableString string];
			parsedLastModified = [NSMutableString string];
			parsedBackground = [NSMutableString string];
		}
		else if ([currentElement isEqualToString: @"objects"])
		{
			parsedObjects = [NSMutableArray array];
			parsingObjects = YES;
		}
	}
	
	//OBJECT SECTION
	else
	{
		if ([currentElement isEqualToString: @"object"])
		{
			parsedObject = [NSMutableDictionary dictionary];
		}
		else if (currentElement)
		{
			parsedObjectValue = [NSMutableString string];
		}
	}
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //[debug log: [NSString stringWithFormat: @"Ended element: %@", elementName]];
    currentElement = [elementName copy];
	
	//NON-OBJECT SECTION
    if (!parsingObjects)
	{
		if ([elementName isEqualToString: @"stage"])
		{
			//This signals that we're done with parsing this stage.
			parsedName = [parsedName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			parsedLastModified = [parsedLastModified stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			parsedCreator = [parsedCreator stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		}
	}
	
	//OBJECT SECTION
	else
	{
		if ([currentElement isEqualToString: @"object"])
		{
			[parsedObjects addObject: parsedObject];
		}
		else if ([currentElement isEqualToString: @"objects"])
		{
			parsingObjects = NO;
		}
		else
		{
			NSString *finalValue = [parsedObjectValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
			[parsedObject setObject: finalValue forKey: currentElement];
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	//NON-OBJECT SECTION
	if (!parsingObjects)
	{
		if ([currentElement isEqualToString: @"name"])
		{
			[parsedName appendString: string];
		}
		else if ([currentElement isEqualToString: @"creator"])
		{
			[parsedCreator appendString: string];
		}
		else if ([currentElement isEqualToString: @"lastModified"])
		{
			[parsedLastModified appendString: string];
		}
		else if ([currentElement isEqualToString: @"background"])
		{
			[parsedBackground appendString: string];
		}
	}
	
	//OBJECT SECTION
	else
	{
		if (currentElement)
		{
			[parsedObjectValue appendString: string];
		}
	}
}

#pragma mark OBJECT DEFAULTS/ADDITION/REMOVAL

- (void) createDefaults
{
	name = @"Untitled";
	creator = @"John Doe";
	lastModified = [NSDate date];
	background = 1;
	
    //We need to start with a spawning point, so this is always added in.
	CGSize s = [CCDirector sharedDirector].winSize;
    CGPoint startPoint = ccp(s.width / 2, s.height / 2);
    Chuck *chuck = [Chuck chuckWithPos: startPoint];
    [self addObject: chuck];
}

- (void) addObject: (Object *) object
{
	if (!object)
	{
		[debug log: @"Tried to add a null object to stage."];
		return;
	}
	
    [self.objects addObject: object];
}

- (void) removeObject: (Object *) object
{
    [self.objects removeObject: object];
    [object remove];
}

- (void) removeAllObjects
{
    for (Object *object in self.objects)
    {
        [self removeObject: object];
    }
}

#pragma mark FILE OPERATIONS

- (bool) saveToFile
{
    //Done putting everything in the file.
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSData *fileData = [self.serialized dataUsingEncoding: NSUTF8StringEncoding];
    NSString *filePath = [NSString stringWithFormat: @"%@/levels/%@.ctr", [MToolsFileManager applicationDocumentsDirectory], name];
    [debug log: [NSString stringWithFormat: @"Level is being saved as %@", filePath]];
    
    //TODO: Put in file overwrite confirmation.
    if ([fm fileExistsAtPath: filePath])
    {
        [debug log: @"File exists at path. Attempting to overwrite."];
    }
    
    [fm createFileAtPath: filePath contents: fileData attributes: nil];
    [MToolsFileManager addSkipBackupAttributeToItemAtString: filePath];
    
    return YES;
}

#pragma  mark GETTERS/SETTERS

- (NSString *) serialized
{	
	return [self serialize];
}

@end
