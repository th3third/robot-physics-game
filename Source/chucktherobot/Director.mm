//
//  Director.m
//  chucktherobot
//
//  Created by Marshall on 07/01/2013.
//
//

#import "Director.h"
#import "Object.h"
#import "MToolsFileManager.h"
#import "MToolsAppSettings.h"
#import "MToolsPurchaseManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Director

static CGSize designSize = {480, 320};

@synthesize scaleFactor, presetScores, _contactListener;

static Director *shared = nil;

+ (Director *) shared
{
    if (shared == nil)
    {
        shared = [[super allocWithZone: NULL] init];
    }
    
    return shared;
}

- (id) init
{
	if (self = [super init])
	{		
		//Set up the preset scores.
		presetScores = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithFloat: 5.0f], @"Level 01.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 02.ctr",
						[NSNumber numberWithFloat: 9.0f], @"Level 03.ctr",
						[NSNumber numberWithFloat: 6.0f], @"Level 04.ctr",
						[NSNumber numberWithFloat: 6.0f], @"Level 05.ctr",
						[NSNumber numberWithFloat: 3.0f], @"Level 06.ctr",
						[NSNumber numberWithFloat: 9.0f], @"Level 07.ctr",
						[NSNumber numberWithFloat: 8.0f], @"Level 08.ctr",
						[NSNumber numberWithFloat: 7.0f], @"Level 09.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 10.ctr",
						[NSNumber numberWithFloat: 4.0f], @"Level 11.ctr",
						[NSNumber numberWithFloat: 6.0f], @"Level 12.ctr",
						[NSNumber numberWithFloat: 12.0f], @"Level 13.ctr",
						[NSNumber numberWithFloat: 4.0f], @"Level 14.ctr",
						[NSNumber numberWithFloat: 3.0f], @"Level 15.ctr",
						[NSNumber numberWithFloat: 9.0f], @"Level 16.ctr",
						[NSNumber numberWithFloat: 6.0f], @"Level 17.ctr",
						[NSNumber numberWithFloat: 7.0f], @"Level 18.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 19.ctr",
						[NSNumber numberWithFloat: 6.0f], @"Level 20.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 21.ctr",
						[NSNumber numberWithFloat: 3.0f], @"Level 22.ctr",
						[NSNumber numberWithFloat: 8.0f], @"Level 23.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 24.ctr",
						[NSNumber numberWithFloat: 7.0f], @"Level 25.ctr",
						[NSNumber numberWithFloat: 4.0f], @"Level 26.ctr",
						[NSNumber numberWithFloat: 14.0f], @"Level 27.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 28.ctr",
						[NSNumber numberWithFloat: 4.0f], @"Level 29.ctr",
						[NSNumber numberWithFloat: 12.0f], @"Level 30.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 31.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 32.ctr",
						[NSNumber numberWithFloat: 4.0f], @"Level 33.ctr",
						[NSNumber numberWithFloat: 3.0f], @"Level 34.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 35.ctr",
						[NSNumber numberWithFloat: 7.0f], @"Level 36.ctr",
						[NSNumber numberWithFloat: 6.0f], @"Level 37.ctr",
						[NSNumber numberWithFloat: 11.0f], @"Level 38.ctr",
						[NSNumber numberWithFloat: 2.0f], @"Level 39.ctr",
						[NSNumber numberWithFloat: 13.0f], @"Level 40.ctr",
						[NSNumber numberWithFloat: 8.0f], @"Level 41.ctr",
						[NSNumber numberWithFloat: 3.0f], @"Level 42.ctr",
						[NSNumber numberWithFloat: 14.0f], @"Level 43.ctr",
						[NSNumber numberWithFloat: 4.0f], @"Level 44.ctr",
						[NSNumber numberWithFloat: 4.0f], @"Level 45.ctr",
						[NSNumber numberWithFloat: 9.0f], @"Level 46.ctr",
						[NSNumber numberWithFloat: 9.0f], @"Level 47.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 48.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 49.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 50.ctr",
						[NSNumber numberWithFloat: 8.0f], @"Level 51.ctr",
						[NSNumber numberWithFloat: 8.0f], @"Level 52.ctr",
						[NSNumber numberWithFloat: 7.0f], @"Level 53.ctr",
						[NSNumber numberWithFloat: 3.0f], @"Level 54.ctr",
						[NSNumber numberWithFloat: 15.0f], @"Level 55.ctr",
						[NSNumber numberWithFloat: 10.0f], @"Level 56.ctr",
						[NSNumber numberWithFloat: 5.0f], @"Level 57.ctr",
						[NSNumber numberWithFloat: 8.0f], @"Level 58.ctr",
						[NSNumber numberWithFloat: 10.0f], @"Level 59.ctr",
						[NSNumber numberWithFloat: 16.0f], @"Level 60.ctr",
						nil];
		
		self.levelsServerURL = [NSURL URLWithString: @"http://gearsprout.com/content/com.gearsprout.chuckthebot/levels"];
		self.loginScriptURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@/scripts/auth_user.php", [self.levelsServerURL absoluteString]]];
		self.createUserScriptURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@/scripts/new_user.php", [self.levelsServerURL absoluteString]]];
		self.saveLevelScriptURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@/scripts/save_level.php", [self.levelsServerURL absoluteString]]];
		self.loadLevelScriptURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@/scripts/load_level.php", [self.levelsServerURL absoluteString]]];
		self.listingsScriptURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@/scripts/listing.php", [self.levelsServerURL absoluteString]]];
		self.flagLevelScriptURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@/scripts/flag.php", [self.levelsServerURL absoluteString]]];
		self.rateLevelScriptURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@/scripts/rate.php", [self.levelsServerURL absoluteString]]];
		self.objID = 0;
		self.globalFont = @"Segoe Print";
		self.drawDebugData = NO;
		self.levelSelectPageNum = 0;
		
		//Default timeout for all network operations.
		timeoutInterval = 15.0f;
		
		if ([MToolsAppSettings getValueWithName: @"soundEnabled"])
		{
			self.soundEnabled = [[MToolsAppSettings getValueWithName: @"soundEnabled"] boolValue];
		}
		else
		{
			self.soundEnabled = YES;
		}
		
		[[SimpleAudioEngine sharedEngine] setMute: !self.soundEnabled];
		
		[self calcNumOfBackgrounds];
		
		//This is going to be the music player delegate.
		[[CDAudioManager sharedManager] setBackgroundMusicCompletionListener: self selector: @selector(musicFinished)];
		
		//The default bot type.
		//Set the first skin to on since it will always be available.
		[MToolsAppSettings setValue: @"purchased" withName: @"botskin1Receipt"];
		self.botType = @"1";
		
		//Set up the scaling factor.
		CGSize winSize = [CCDirector sharedDirector].winSize;
		scaleFactor = CGSizeMake((PTM_RATIO / 32), (PTM_RATIO / 32));
		//scaleFactor = CGSizeMake((winSize.width / designSize.width), (winSize.height / designSize.height));
		//scaleFactor = CGSizeMake(1, 1);
		NSLog(@"SCALING FACTOR: %f x %f", scaleFactor.width, scaleFactor.height);
		
		if ([MToolsAppSettings getValueWithName: @"username"])
		{
			self.username = [MToolsAppSettings getValueWithName: @"username"];
			
			if ([MToolsAppSettings getValueWithName: @"password"])
			{
				self.hashedPassword = [MToolsAppSettings getValueWithName: @"password"];
				
				[self logInWithUsername: self.username andPassword: self.hashedPassword];
			}
		}
	}
	
	return self;
}

- (void) initPhysics
{
	if (self.world)
	{		
		delete self.world;
		self.world = NULL;
	}
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	
    //Give the world to the Director.
    self.world = new b2World(gravity);
    
	// Do we want to let bodies sleep?
	self.world->SetAllowSleeping(false);
	
	self.world->SetContinuousPhysics(true);
	
	//Set up the contact listener.
	_contactListener = new MyContactListener();
	self.world->SetContactListener(_contactListener);
	
	m_debugDraw = new GLESDebugDraw(PTM_RATIO);
	m_debugDraw->SetFlags(b2Draw::e_jointBit); 
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	flags += b2Draw::e_jointBit;
	flags += b2Draw::e_aabbBit;
	flags += b2Draw::e_pairBit;
	flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
	self.world->SetDebugDraw(m_debugDraw);
}

- (void) calcNumOfBackgrounds
{
	self.numOfBackgrounds = [[[NSBundle mainBundle] pathsForResourcesOfType: @".jpg" inDirectory: @"Media/Backgrounds/wallpaper"] count];
}

- (void) awakeAll
{
    for (Object *object in [[Director shared].stage objects])
    {
        [object wakeUp];
    }
}

+ (NSString *) levelsPath
{
    return [NSString stringWithFormat: @"%@/levels", [MToolsFileManager applicationDocumentsDirectory]];
}

- (int) getNewObjectID
{
	return self.objID++;
}

#pragma mark USER STUFFZ

//Upon creation these are stored in the app settings for future use.
//The password is immediately hashed although the username needs to remain intact in plain text until transmission.
- (bool) createUsername: (NSString *) username andPassword: (NSString *) password andEmail: (NSString *) email
{	
	if (!username || !password)
		return NO;

	self.dataState = DATA_STATE_CREATING_USERNAME;
	
	NSString *encryptedPassword = [Director sha: password];
	self.username = username;
	self.hashedPassword = encryptedPassword;
	
	NSString *requestString = [NSString stringWithFormat: @"value1=%@&value2=%@&value3=%@", encryptedPassword, username, email];
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: self.createUserScriptURL cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: timeoutInterval];
	[request setHTTPMethod: @"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody: requestData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURLResponse *response = [[NSURLResponse alloc] init];
	NSString *responseString;
	NSError *error;
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	responseString = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];
	
	[self cleanupConnection];
	
	if ([responseString isEqualToString: @"failed"])
	{
		self.username = nil;
		self.hashedPassword = nil;
		
		return NO;
	}
	else if ([responseString isEqualToString: @"exists"])
	{
		[debug log: @"A user by that name already exists."];
		self.username = nil;
		self.hashedPassword = nil;
		
		return NO;
	}
	else
	{
		[MToolsAppSettings setValue: self.username withName: @"username"];
		[MToolsAppSettings setValue: self.hashedPassword withName: @"password"];
		
		return YES;
	}
	
	return NO;
}

//Password MUST already be hashed to work.
- (bool) logInWithUsername: (NSString *) username andPassword: (NSString *) encryptedPassword
{
	if (self.processingNetworkRequest)
		return NO;
	
	self.processingNetworkRequest = YES;
	
	if (!username || !encryptedPassword)
		return NO;
	
	self.dataState = DATA_STATE_LOGGING_IN;

	self.username = username;
	self.hashedPassword = encryptedPassword;
	
	NSString *requestString = [NSString stringWithFormat: @"value1=%@&value2=%@", encryptedPassword, username];
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: self.loginScriptURL cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: timeoutInterval];
	[request setHTTPMethod: @"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody: requestData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURLResponse *response = [[NSURLResponse alloc] init];
	NSString *responseString;
	NSError *error;
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	responseString = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];
	
	NSString *successfulResponse = [Director sha: [NSString stringWithFormat: @"%@bears%@", self.username, self.hashedPassword]];
	
	[self cleanupConnection];
	
	if (![responseString isEqualToString: successfulResponse])
	{
		[debug log: @"Logging in failed."];
		self.username = nil;
		self.hashedPassword = nil;
	}
	else
	{
		[debug log: @"Successful log in!"];
		[MToolsAppSettings setValue: self.username withName: @"username"];
		[MToolsAppSettings setValue: self.hashedPassword withName: @"password"];
		
		return YES;
	}
	
	return NO;
}

- (void) logout
{
	self.username = NULL;
	self.hashedPassword = NULL;
	
	[MToolsAppSettings setValue: @"" withName: @"username"];
	[MToolsAppSettings setValue: @"" withName: @"password"];
}

//TODO: Strip out the | character in the level name. You can't do that!
- (bool) saveLevelToServer
{
	self.dataState = DATA_STATE_SAVING_LEVEL;
	self.processingNetworkRequest = YES;
	
	NSString *compiledTags = [[[Director shared].stage.tags valueForKey: @"description"] componentsJoinedByString: @","];
	NSString *requestString = [NSString stringWithFormat: @"value1=%@&value2=%@&value3=%@&value4=%@&value5=%@", self.hashedPassword, self.username, [Director shared].stage.serialized, [Director shared].stage.name, compiledTags];
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: self.saveLevelScriptURL cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: timeoutInterval];
	[request setHTTPMethod: @"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody: requestData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURLResponse *response = [[NSURLResponse alloc] init];
	NSString *responseString;
	NSError *error;
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	responseString = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];

	[self cleanupConnection];
	
	if ([responseString isEqualToString: @"success"])
	{
		return YES;
	}
	else
	{
		return NO;
	}

	return NO;
}

- (void) loadBlankStage
{
	[self initPhysics];
	
	[Director shared].stage = [[Stage alloc] init];
}

- (void) loadStageFromData: (NSData *) stageData
{
	[self initPhysics];
	
	[Director shared].stage = [[Stage alloc] init];
	[[Director shared].stage initWithData: stageData];
}

- (bool) getLevelFromServer
{
	if (!self.loggedIn)
		return NO;
	
	self.dataState = DATA_STATE_LOADING_LEVEL;
	self.processingNetworkRequest = YES;
	
	NSDate *localDateModified;
	//Get the current list of local levels to see if we've already got this one. If so, see what the modified date is.
	for (NSString *name in [Director shared].localLevelsList)
	{
		if ([name isEqualToString: [Director shared].stageName])
		{
			[self loadCurrentStage];
			localDateModified = [Director shared].stage.lastModified;
		}
	}
	
	//TODO: modify the script to return "current" if the date modified the app sends is greater than the last modified value in the database.
	NSString *requestString = [NSString stringWithFormat: @"value1=%@&value2=%@", [Director shared].stageName, [[Director shared].stage.lastModified description]];
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: self.loadLevelScriptURL cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: timeoutInterval];
	[request setHTTPMethod: @"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody: requestData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURLResponse *response = [[NSURLResponse alloc] init];
	NSString *responseString;
	NSError *error;
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	responseString = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];

	[self cleanupConnection];
	
	//Go to the local level if it hasn't been modified since the download.
	if ([responseString isEqualToString: @"current"])
	{
		return true;
	}
	else if (![responseString isEqualToString: @""])
	{
		//Go ahead and load the stage from the local file.
		[self loadStageFromData: returnData];
		[[Director shared].stage saveToFile];
		
		return true;
	}
	else
	{
		//TODO: Default to local level if we can't contact the server.
		return false;
	}
	
	return false;
}

- (int) getScoreForLevel: (NSString *) name
{
	int time = [[presetScores objectForKey: name] intValue];
	
	if (time <= 0)
		time = 10;
		
	return time;
}

- (void) loadCurrentStage
{
	if (![Director shared].stageName)
	{
		NSLog(@"There is no stage name set and the Director is trying to load it! Aborting the load of current stage.");
		return;
	}
	
	//Here we'll need to see if we have the stage file on the device. If not, then we need to go to the server to retrieve it. Failing that, tell them it was unable to be loaded at this time.
	//The stage files are stored in the Documents/Stages folder of the app.
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *stagePath = [NSString stringWithFormat: @"%@/levels/%@.ctr", [MToolsFileManager applicationDocumentsDirectory], [Director shared].stageName];
	[debug log: [NSString stringWithFormat: @"Loading file %@", stagePath]];
	if ([fm fileExistsAtPath: stagePath])
	{
		[debug log: @"Found the stage in the local documents."];
	}
	else
	{
		[self getLevelFromServer];
		 [debug log: @"Did not find the stage in the local documents. Downloading from server."];
	}
	 
	 //Go ahead and load the stage from the local file.
	 NSData *stageData = [NSData dataWithContentsOfFile: stagePath];
	[self loadStageFromData: stageData];
}

- (void) nextLocalLevel
{
	self.localLevelIndex++;
	
	if (self.localLevelIndex >= [self.defaultLevelsList count])
	{
		self.localLevelIndex = 0;
	}
	
	[[Director shared] setStageName: [NSString stringWithFormat: @"defaults/%@", [[self.defaultLevelsList objectAtIndex: self.localLevelIndex] stringByDeletingPathExtension]]];
}

- (void) removeLocalLevel: (NSString *) name
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *stagePath = [NSString stringWithFormat: @"%@/levels/%@.ctr", [MToolsFileManager applicationDocumentsDirectory], [Director shared].stageName];
	[debug log: [NSString stringWithFormat: @"Deleting file %@", stagePath]];
	if ([fm fileExistsAtPath: stagePath])
	{
		[debug log: @"Found the stage in the local documents."];
		[fm removeItemAtPath: stagePath error: nil];
	}
	else
	{
		[debug log: @"Did not find the stage in the local documents."];
	}
}

- (void) flagLevel:(NSString *)name
{
	if (!name)
		return;
	NSLog(@"Sending flag for %@", name);
	self.dataState = DATA_STATE_SAVING_LEVEL;
	self.processingNetworkRequest = YES;
	
	NSString *requestString = [NSString stringWithFormat: @"value1=%@&value2=%@&value3=%@", self.hashedPassword, self.username, name];
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: self.flagLevelScriptURL cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: timeoutInterval];
	[request setHTTPMethod: @"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody: requestData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURLResponse *response = [[NSURLResponse alloc] init];
	NSString *responseString;
	NSError *error;
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	responseString = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];
	[self cleanupConnection];
	
	[self removeLocalLevel: name];
}

- (void) rateLevel: (NSString *) name withRating: (int) rating
{
	if (!name || rating < 0 || rating > 1)
		return;
	
	self.processingNetworkRequest = YES;
	
	NSString *requestString = [NSString stringWithFormat: @"value1=%@&value2=%@&value3=%@&value4=%d", self.hashedPassword, self.username, name, rating];
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: self.rateLevelScriptURL cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: timeoutInterval];
	[request setHTTPMethod: @"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody: requestData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	[NSURLConnection sendAsynchronousRequest: request queue: queue completionHandler:^(NSURLResponse *responseString, NSData *returnData, NSError *error) {
		if (error)
		{
			[debug log: [NSString stringWithFormat: @"There was an error sending the rating: %@", error]];
		}
		
		self.processingNetworkRequest = NO;
	}];
}

#pragma mark MUSIC

- (void) playMusic: (NSString *) bgm
{
	if ([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
	{
		[self stopMusic];
	}
	
	//Preload background music.
	if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
	{
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic: bgm];
	}
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 1.0f];
	
	//Play background music.
	if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
	{
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic: bgm loop: NO];
	}
}

- (void) stopMusic
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

- (void) toggleSound
{
	if (![[SimpleAudioEngine sharedEngine] mute])
	{
		[[SimpleAudioEngine sharedEngine] setMute: YES];
	}
	else
	{
		[[SimpleAudioEngine sharedEngine] setMute: NO];
	}
	
	self.soundEnabled = ![[SimpleAudioEngine sharedEngine] mute];	
	[MToolsAppSettings setValue: [NSNumber numberWithBool: [[SimpleAudioEngine sharedEngine] mute]] withName: @"soundEnabled"];
}

- (void) musicFinished
{
	if ([Director shared].editing)
	{
		[[Director shared] playMusic: [NSString stringWithFormat: @"Media/Audio/general/music/creator%d.mp3", arc4random() % 3]];
	}
	else
	{
		[[Director shared] playMusic: @"Media/Audio/general/music/main_menu.mp3"];
	}
}

#pragma mark CONNECTION DELEGATE

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"Received response");
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Received error: %@", error);
	
	[self cleanupConnection];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Finished loading.");
	
	[self cleanupConnection];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSString *response = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	NSLog(@"Received response: %@", response);
	
	switch (self.dataState)
	{
		case DATA_STATE_CREATING_USERNAME:
		{
			if ([response isEqualToString: @"failed"])
			{
				[debug log: @"Creation failed."];
				self.username = nil;
				self.hashedPassword = nil;
			}
			else if ([response isEqualToString: @"created"])
			{
				[debug log: @"User successfully created."];
				[MToolsAppSettings setValue: self.username withName: @"username"];
				[MToolsAppSettings setValue: self.hashedPassword withName: @"password"];
			}
			else if ([response isEqualToString: @"exists"])
			{
				[debug log: @"Username already exists."];
				self.username = nil;
				self.hashedPassword = nil;
			}
			
			break;
		}
			
		case DATA_STATE_LOGGING_IN:
		{
			
		}
	}
	
	[self cleanupConnection];
}

- (void) cleanupConnection
{
	self.processingNetworkRequest = NO;
	self.dataState = nil;
}

#pragma  mark GETTERS/SETTERS

- (NSString *) playerName
{
	if (!_playerName)
		return @"You";
	
	return _playerName;
}

- (bool) loggedIn
{
	return ((self.username && self.hashedPassword) && (![self.username isEqualToString: @""] && ![self.hashedPassword isEqualToString: @""]));
}

- (NSArray *) localLevelsList
{
	NSMutableArray *levelsList = [NSMutableArray array];
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSError *error;
	[levelsList addObjectsFromArray: [fm contentsOfDirectoryAtPath: [Director levelsPath] error: &error]];
	
	if (error)
	{
		NSLog(@"WARNING: Could not find anything in the local levels directory: %@", error);
	}
	
	//Removes all "levels" found that don't have the .ctr extension.
	//Sometimes random files crop up in this folder that shouldn't be included with the levels.
	NSMutableArray *levelsToRemove = [NSMutableArray arrayWithCapacity: 1];
	for (NSString *levelName in levelsList)
	{
		if (![[levelName pathExtension] isEqualToString: @"ctr"])
		{
			[levelsToRemove addObject: levelName];
		}
	}
	[levelsList removeObjectsInArray: levelsToRemove];
	
	return levelsList;
}

- (NSArray *) defaultLevelsList
{
	NSMutableArray *levelsList = [NSMutableArray array];
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSError *error;
	[levelsList addObjectsFromArray: [fm contentsOfDirectoryAtPath: [[Director levelsPath] stringByAppendingPathComponent: @"\defaults"] error: &error]];
	
	if (error)
	{
		NSLog(@"WARNING: Could not find anything in the local levels directory: %@", error);
	}
	
	//Removes all "levels" found that don't have the .ctr extension.
	//Sometimes random files crop up in this folder that shouldn't be included with the levels.
	NSMutableArray *levelsToRemove = [NSMutableArray arrayWithCapacity: 1];
	for (NSString *levelName in levelsList)
	{
		if (![[levelName pathExtension] isEqualToString: @"ctr"])
		{
			[levelsToRemove addObject: levelName];
		}
	}
	[levelsList removeObjectsInArray: levelsToRemove];
	
	return levelsList;
}

- (NSArray *) onlineLevelsList: (int) number withSorting: (int) sorting
{
	NSArray *levelsList;
	
	self.dataState = DATA_STATE_LOADING_LISTINGS;
	self.processingNetworkRequest = YES;
	
	NSString *requestString = [NSString stringWithFormat: @"value1=%d&value2=%d", number, sorting];
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: self.listingsScriptURL cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 60.0];
	[request setHTTPMethod: @"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody: requestData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURLResponse *response = [[NSURLResponse alloc] init];
	NSString *responseString;
	NSError *error;
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	responseString = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];

	[self cleanupConnection];
	
	//TODO: Parse out the listing returned.
	NSMutableArray *finalLevelsList = [NSMutableArray array];
	if (![responseString isEqualToString: @""])
	{
		levelsList = [responseString componentsSeparatedByString: @"|"];
		
		for (NSString *level in levelsList)
		{
			NSArray *separatedLevel = [level componentsSeparatedByString: @"~"];
			[finalLevelsList addObject: separatedLevel];
		}
	}
	
	return finalLevelsList;
}

- (bool) fullVersion
{
	if (PREPAID_VERSION)
	{
		return true;
	}
	else
	{
		return [[MToolsPurchaseManager sharedManager] productPurchased: @"fullversion"];
	}
}

- (void) setPaused:(bool)paused
{
    _paused = paused;
    
	if (self.editing)
	{
		if (paused)
		{
			[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 1.00];
		}
		else
		{
			[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 0.25];
		}
	}
}

#pragma  mark ENCRYPTION

+ (NSString *) sha: (NSString *) string
{
	if (!string)
		return nil;
	
	NSString *hashkey = string;
	// PHP uses ASCII encoding, not UTF
	const char *s = [hashkey cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
	
	// This is the destination
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	// This one function does an unkeyed SHA1 hash of your hash data
	CC_SHA1(keyData.bytes, keyData.length, digest);
	
	// Now convert to NSData structure to make it usable again
	NSData *out = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
	// description converts to hex but puts <> around it and spaces every 4 bytes
	NSString *hash = [out description];
	hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
	hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
	hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
	
	return hash;
}

#pragma mark SCALING

- (CGPoint) scalePoint:(CGPoint)point
{
    return CGPointMake(point.x * scaleFactor.width, point.y * scaleFactor.height);
}

@end
