//
//  MToolsNetworkAlert.h
//  AppScaffold
//
//  Created by Marshall on 27/11/2012.
//
//  This class is designed to pull an alert from a server and display it if the current app has not shown it yet.
//

#import <Foundation/Foundation.h>

@interface MToolsNetworkAlert : NSObject <NSXMLParserDelegate, UIAlertViewDelegate>
{
    @private
    NSMutableArray *queue;          //stack the messages we receive in here so we can process them one by one.
    NSMutableArray *alerts;
    NSXMLParser *parser;    //used to parse the master alert file.
    UIActivityIndicatorView *activityIndicator; //Hopefully this won't be on the screen long...
    
    //Here be all the fields that we're gonna use. Arrrr...
    //The XML file needs to have the following fields: name of alert, date of alert, apps that are alerted (put in a "all" value), message of alert, buttons for alert (okay or okay & cancel), testing switch, and the URL to go to if they hit okay with a two-button alert.
    NSMutableDictionary *currentAlert;
    NSString *currentElement;
    NSMutableString *name;
    NSMutableString *date;
    NSMutableString *app;
    NSMutableArray *apps;
    NSMutableString *title;
    NSMutableString *message;
    NSMutableString *button;
    NSMutableArray *buttons;
    NSNumber *testing;
    NSNumber *delay;
    NSMutableString *action;
    NSMutableArray *actions;
}

@property NSURL *masterURL; //url to the master alert file.
@property bool isTesting; //if this is on, we will only get testing messages.
@property id selectorDelegate;

+ (MToolsNetworkAlert *) sharedManager;

- (void) checkForNewAlerts;
- (void) displayNewAlerts;

@end
