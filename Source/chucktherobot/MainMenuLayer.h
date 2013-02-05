//
//  MainMenuLayer.h
//  chucktherobot
//
//  Created by Marshall on 03/01/2013.
//
//

#import <GameKit/GameKit.h>
#import "Layer.h"

@interface MainMenuLayer : Layer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CCTexture2D *spriteTexture_;
}

@end
