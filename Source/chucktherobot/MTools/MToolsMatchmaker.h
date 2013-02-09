//
//  MToolsMatchmaker.h
//  LaserWars
//
//  Created by Tommy Tornroos on 6/21/12.
//  Copyright (c) 2012 TuneTransfers.com, LLC. All rights reserved.
//

#import <GameKit/GameKit.h>

//Delegate protocol.
@protocol MToolsMatchmakerDelegate 
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data 
   fromPlayer:(NSString *)playerID;
@end

//MToolsMatchmaker interface stuff.
@interface MToolsMatchmaker : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate>
{
    //View controller stuff.
    UIViewController *lobbyViewController;
    
    //Match attributes n' stuff.
    bool matchStarted;
    bool gameCenterAvailable;
    
    @public
        NSString *playerID;
        NSString *serverID;
}

@property (readonly) bool userAuthenticated;
@property bool isServer;
@property bool ready;
@property int maxPlayers;
@property (unsafe_unretained) id gameMaster;
@property (unsafe_unretained) GKMatch *myMatch;

+ (MToolsMatchmaker *)sharedInstance;

//General functions.
- (void) createMatch;
- (void) findInstantMatch;
- (void) findAllActivity;
- (void) authenticateLocalUser;

//Leaderboard functions.
- (bool) reportScore: (int64_t) score forCategory: (NSString *) category;

//Delegate stuff.
@property (unsafe_unretained) id <MToolsMatchmakerDelegate> delegate;

@end
