//
//  MainMenuLayer.h
//  chucktherobot
//
//  Created by Marshall on 03/01/2013.
//
//

#import <GameKit/GameKit.h>
#import "Layer.h"
#import <MessageUI/MessageUI.h>
#import "DialogLayer.h"

@interface MainMenuLayer : Layer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, MFMailComposeViewControllerDelegate>
{
    CCTexture2D *spriteTexture_;
	DialogLayer *purchaseDialog;
	DialogLayer *creditsDialog;
	DialogLayer *loadingDialog;
}

@end
