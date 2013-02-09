//
//  MToolsMatchmaker.m
//  LaserWars
//
//  Created by Tommy Tornroos on 6/21/12.
//  Copyright (c) 2012 TuneTransfers.com, LLC. All rights reserved.
//

#import "MToolsMatchmaker.h"
#import "MToolsAlertViewManager.h"

@implementation MToolsMatchmaker

@synthesize 
    delegate;

@synthesize userAuthenticated;
@synthesize isServer;
@synthesize ready;
@synthesize maxPlayers;
@synthesize myMatch;

//Singleton implementation.
static MToolsMatchmaker *sharedHelper = nil;
+ (MToolsMatchmaker *) sharedInstance 
{
    if (!sharedHelper) 
    {
        sharedHelper = [[MToolsMatchmaker alloc] init];
    }
    return sharedHelper;
}

//Standard init.
- (id)init 
{
    if ((self = [super init])) 
    {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) 
        {
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
        }
        maxPlayers = 4;
    }
    return self;
}

//Check and see if the authetication status changed.
- (void)authenticationChanged 
{    
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) 
    {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;           
    } 
    else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) 
    {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

//Check and see if Game Center is currently available to this instance.
- (BOOL)isGameCenterAvailable 
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer 
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

//Auths the local player with Game Center.
- (void)authenticateLocalUser 
{
    if (!gameCenterAvailable) 
    {
        return;
    }
    
    NSLog(@"Authenticating local user...");
    
    if ([GKLocalPlayer localPlayer].authenticated == NO) 
    {     
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];        
    } 
    else 
    {
        NSLog(@"Already authenticated!");
    }
}

//A player disconnected.
- (void) match:(GKMatch *)match player:(NSString *)discID didChangeState:(GKPlayerConnectionState)state
{
    if (state == GKPlayerStateDisconnected)
    {
        [self.gameMaster performSelector: @selector(playerDisconnected:) withObject: discID];
    }
    else if (state == GKPlayerStateConnected)
    {
        NSLog(@"Player has connected.");
    }
}

//Lost connection to the match.
- (void) match:(GKMatch *)match didFailWithError:(NSError *)error
{
    [[MToolsAlertViewManager sharedManager] alertWithMessage: @"Lost connection to the server."];
    [self.gameMaster performSelector: @selector(eventFinishedMatch) withObject: nil];
}

//Used to drop a player directly in to a match.
- (void)findInstantMatch
{
    NSLog(@"Finding an instant match.");
    //[tempVC.view addSubview:leaderboardController.view];
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = maxPlayers;
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) 
    {
        if (error)
        {
            // Process the error.
			NSLog(@"An error occured trying to find a match.");
        }
        else if (match != nil)
        {
            NSLog(@"Found a match.");
            myMatch = match; // Use a retaining property to retain the match.
            match.delegate = self;
            
            //Not ready yet.
            ready = NO;
            
            if (self.gameMaster)
                [self.gameMaster performSelector: @selector(joinMatch)];
        }
    }];
}

- (void)createMatch
{
    NSLog(@"Created new match, waiting for players.");
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = maxPlayers;
    isServer = true;
    
    //Check and see if this is a solo match (maybe multiple AIs).
    if (maxPlayers <= 1)
    {
        [self.gameMaster performSelector: @selector(createMatch:) withObject: [NSArray arrayWithObject: [GKLocalPlayer localPlayer].playerID]];
        return;
    }
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error)
     {
        if (error)
        {
            NSLog(@"An error occured during creating the match: %@", error);
        }
        else
        {
            myMatch = match;
            match.delegate = self;
            
            //Not ready yet.
            ready = NO;
            
            NSLog(@"Players have been found for the match: %@", myMatch.playerIDs);
            if (self.gameMaster)
                [self.gameMaster performSelector: @selector(createMatch)];
        }
    }];
}

- (bool) checkIfReady
{
    //If we're not ready, then everyone isn't. Don't bother sending the message if this is the case.
    if (!ready)
        return NO;
    
    return YES;
}

//Finds all the activity that is occuring in the game.
- (void)findAllActivity
{
    [[GKMatchmaker sharedMatchmaker] queryActivityWithCompletionHandler:^(NSInteger activity, NSError *error) 
    {
        if (error)
        {
            // Process the error.
        }
        else
        {
            NSLog(@"There are %@ players online", activity);
        }
    }];
}

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController 
{
    CGRect frame = viewController.view.frame;
	//[tempVC dismissModalViewControllerAnimated:YES];
	[UIView beginAnimations:@"curldoup" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	//[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.stage.nativeView cache:YES];
	frame.origin.y = 480;
	viewController.view.frame = frame;
	[UIView commitAnimations];
	//[viewController.view removeFromSuperview];
}

//Received data from another player.
- (void) match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)recvID
{
    NSLog(@"Received data from player %@", recvID);
    [self.gameMaster performSelector: @selector(receivedData:fromParticipantID:) withObject: data withObject: recvID];
    
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error 
{
    [lobbyViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);    
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch 
{
    [lobbyViewController dismissModalViewControllerAnimated:YES];
    myMatch = theMatch;
    myMatch.delegate = self;
    if (!matchStarted && myMatch.expectedPlayerCount == 0) 
    {
        NSLog(@"Ready to start match!");
    }
}

//Leaderboard functions.
- (bool) reportScore:(int64_t)score forCategory:(NSString *)category
{
    NSLog(@"Attempting to send score.");
    
    //Submit scores to the leaderboard.
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error)
    {
        if (error != nil)
        {
            NSLog(@"There was an error reporting the score: %@", error);
        }
        else
        {
            NSLog(@"Successfully sent score.");
        }
    }];
    
    
    return true;
}

@end
