//
//  MToolsNetworkAlert.m
//  AppScaffold
//
//  Created by Marshall on 27/11/2012.
//
//

#import "MToolsNetworkAlert.h"
#import "MToolsAppSettings.h"
#import "MToolsDebug.h"

@implementation MToolsNetworkAlert

@synthesize masterURL, isTesting, selectorDelegate;

//Singleton implementation.
static MToolsNetworkAlert *sharedManager = nil;

+ (MToolsNetworkAlert *) sharedManager
{
    if (!sharedManager)
    {
        sharedManager = [[MToolsNetworkAlert alloc] init];
    }
    
    return sharedManager;
}

- (id) init
{
    if (self = [super init])
    {
        parser = [NSXMLParser alloc];
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0, 0, 25.0f, 25.0f)];
        [activityIndicator sizeToFit];
        activityIndicator.autoresizingMask =
            (UIViewAutoresizingFlexibleLeftMargin |
             UIViewAutoresizingFlexibleRightMargin |
             UIViewAutoresizingFlexibleTopMargin |
             UIViewAutoresizingFlexibleBottomMargin);
        
        #ifdef SPARROW_PROJECT
            [[SPStage mainStage].nativeView addSubview: activityIndicator];
        #else
            [[[UIApplication sharedApplication] keyWindow] addSubview: activityIndicator];
        #endif
        
        //Initializers and all that.
        alerts = [NSMutableArray array];
        queue = [NSMutableArray array];
        
        //The master URL is by default set to http://gearsprout.com/NetworkAlerts/master.xml
        //This could change if for some reason the URL changes in the future. Setting masterURL after init will make sure that a different URL is used whenever checking for new alerts.
        masterURL = [NSURL URLWithString: @"http://gearsprout.com/NetworkAlerts/master.xml"];
    }
    
    return self;
}

//Check for new alerts and pop them in the queue if we find any.
//This will query a master alert file to see if there are any new alerts we don't find in the settings.
- (void) checkForNewAlerts
{
	if (isTesting)
		NSLog(@"WARNING: Network alerts is operating in TESTING MODE");
	
	NSOperationQueue *queue = [NSOperationQueue new];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget: self  selector: @selector(getXMLData:) object: masterURL];
	[queue addOperation: operation];
}

- (void) getXMLData: (NSURL *) URL
{	
	parser = [parser initWithContentsOfURL: URL];
    [parser setDelegate: self];
    [parser setShouldProcessNamespaces: NO];
    [parser setShouldReportNamespacePrefixes: NO];
    [parser setShouldResolveExternalEntities: NO];
    [parser parse];
    
    [self buildAlerts];
	[self performSelectorOnMainThread: @selector(displayNewAlerts) withObject: nil waitUntilDone: NO];
}

//Builds the alert which will be placed in the queue.
- (void) buildAlerts
{
    [debug log: @"Building new alerts."];
    for (NSDictionary *alert in alerts)
    {
        //[debug log: [NSString stringWithFormat: @"%@", alert]];
        NSArray *alertViewButtons = [alert objectForKey: @"buttons"];
        //Get the cancel button title. This is always the very last button in the buttons array.
        NSString *cancelButtonTitle = [alertViewButtons objectAtIndex: [alertViewButtons count] - 1];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: [alert objectForKey: @"title"] message: [alert objectForKey: @"message"] delegate: self cancelButtonTitle: cancelButtonTitle otherButtonTitles: nil];
        
        //Add the other buttons.
        for (int i = 0; i < [alertViewButtons count] - 1; i++)
        {
            [alertView addButtonWithTitle: [alertViewButtons objectAtIndex: i]];
        }
        
        [debug log: [NSString stringWithFormat: @"Adding new alert with %d buttons", ([alertViewButtons count] - 1)]];
        
        [queue addObject: alertView];
    }
}

//Goes through the queue and displays all the new alerts.
- (void) displayNewAlerts
{
    [debug log: @"Displaying alerts."];
    for (int i = 0; i < [queue count]; i++)
    {
        UIAlertView *alert = [queue objectAtIndex: i];
        
        [debug log: @"Showing an alert."];
        [alert show];
        
        //Register that we've shown this alert so it won't appear again on the next launch.
        NSDictionary *alertDict = [alerts objectAtIndex: i];
        NSString *alertName = [alertDict objectForKey: @"name"];
        [MToolsAppSettings setValue: [NSNumber numberWithBool: YES] withName: alertName];
        [debug log: [NSString stringWithFormat: @"Register alert with name: %@", alertName]];
    }
}

#pragma mark Parser delegate methods

- (void) parserDidStartDocument:(NSXMLParser *)parser
{
    [debug log: @"Parser started."];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [debug log: [NSString stringWithFormat: @"An error occured during parsing: %@", parseError]];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //[debug log: [NSString stringWithFormat: @"Started element: %@", elementName]];
    currentElement = [elementName copy];
    
    if ([elementName isEqualToString: @"alert"])
    {
        //Clear all the caches.
        currentAlert = [[NSMutableDictionary alloc] init];
        name = [[NSMutableString alloc] init];
        date = [[NSMutableString alloc] init];
        app = [[NSMutableString alloc] init];
        apps = [NSMutableArray array];
        title = [[NSMutableString alloc] init];
        message = [[NSMutableString alloc] init];
        button = [[NSMutableString alloc] init];
        buttons = [NSMutableArray array];
        testing = [[NSNumber alloc] initWithBool: 0];
        delay = [[NSNumber alloc] initWithBool: 0];
        action = [[NSMutableString alloc] init];
        actions = [NSMutableArray array];
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //[debug log: [NSString stringWithFormat: @"Ended element: %@", elementName]];
    currentElement = @"";
    
    if ([elementName isEqualToString: @"alert"])
    {
        //[debug log: [NSString stringWithFormat: @"Checking alert %@", name]];
        bool forThisApp = NO;
        //Check and see if this alert is actually for this app. If the list contains "ALL" then it will be for this app no matter what.
        for (NSString *appName in apps)
        {
            if ([appName isEqualToString: [[NSBundle mainBundle] bundleIdentifier]] || [appName isEqualToString: @"ALL"])
            {
                forThisApp = YES;
            }
        }
        //Check and see if we're at the date for this alert yet.
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];
        NSDate *releaseDate = [dateFormatter dateFromString: date];
        if ([releaseDate timeIntervalSinceNow] > 0)
        {
            [debug log: @"This alert is set for the future."];
            forThisApp = NO;
        }
        
        //Check and see if we've met the delay requirements yet.
        if ([delay intValue] > [[MToolsAppSettings getValueWithName: @"timesRun"] intValue])
        {
            [debug log: @"This alert has not met the number of times run yet."];
            forThisApp = NO;
        }
        
        //If we find something in the settings with this title, it means we've already used this alert and don't need to do anything else to it.
        if ((![MToolsAppSettings getValueWithName: name] && isTesting == [testing boolValue]) && forThisApp)
        {
            [currentAlert setObject: name forKey: @"name"];
            [currentAlert setObject: date forKey: @"date"];
            [currentAlert setObject: apps forKey: @"apps"];
            [currentAlert setObject: title forKey: @"title"];
            [currentAlert setObject: message forKey: @"message"];
            [currentAlert setObject: buttons forKey: @"buttons"];
            [currentAlert setObject: testing forKey: @"testing"];
            [currentAlert setObject: delay forKey: @"delay"];
            [currentAlert setObject: actions forKey: @"actions"];
            
            [alerts addObject: [currentAlert copy]];
            //[debug log: [NSString stringWithFormat: @"Adding alert: %@", currentAlert]];
        }
        else
        {
            [debug log: [NSString stringWithFormat:@"Already displayed alert, is not the right testing value, or not for this app; skipping %@", name]];
        }
    }
    else if ([elementName isEqualToString: @"app"])
    {
        [apps addObject: app];
        app = [[NSMutableString alloc] init];
    }
    else if ([elementName isEqualToString: @"button"])
    {
        [buttons addObject: button];
        button = [[NSMutableString alloc] init];
    }
    else if ([elementName isEqualToString: @"action"])
    {
        [actions addObject: action];
        action = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([currentElement isEqualToString: @"name"])
    {
        [name appendString: string];
    }
    else if ([currentElement isEqualToString: @"date"])
    {
        [date appendString: string];
    }
    else if ([currentElement isEqualToString: @"app"])
    {
        [app appendString: string];
    }
    else if ([currentElement isEqualToString: @"title"])
    {
        [title appendString: string];
    }
    else if ([currentElement isEqualToString: @"message"])
    {
        [message appendString: string];
    }
    else if ([currentElement isEqualToString: @"button"])
    {
        [button appendString: string];
    }
    else if ([currentElement isEqualToString: @"testing"])
    {
        testing = [NSNumber numberWithBool: [string boolValue]];
    }
    else if ([currentElement isEqualToString: @"delay"])
    {
        delay = [NSNumber numberWithInt: [string intValue]];
    }
    else if ([currentElement isEqualToString: @"action"])
    {
        [action appendString: string];
    }
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    [debug log: @"Finished parsing"];
}

#pragma mark UIAlertView Delegate Methods

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int alertIndex = [queue count] - 1;
    NSDictionary *alertDict = [alerts objectAtIndex: alertIndex];
    NSArray *alertActions = [alertDict objectForKey: @"actions"];
    NSString *alertAction;
    
    if (buttonIndex <= 0)
        alertAction = @"1";
    else
        alertAction = [alertActions objectAtIndex: buttonIndex - 1];
    
    [debug log: [NSString stringWithFormat: @"Clicked button at index: %d", buttonIndex]];
    //[debug log: [NSString stringWithFormat: @"What are we going to do with this button? %@", alertAction]];
    
    //Parse out what we're actually going to do.
    //1 - cancel
    //2 - remind
    //3 - url
    //4 - selector
    //5 - delay
    
    NSArray *actionSplit = [alertAction componentsSeparatedByString: @"|"];
    NSString *actionTypeString = [actionSplit objectAtIndex: 0];
    int actionType = [actionTypeString intValue];
    [debug log: [NSString stringWithFormat: @"Action type %d", actionType]];
    
    switch (actionType)
    {
        //cancel
        case 1:
            break;
            
        //remind
        case 2:
        {
            NSNumber *actionValue = [NSNumber numberWithInt: [[actionSplit objectAtIndex: 1] intValue]];
            [debug log: [NSString stringWithFormat: @"Reminder for %@ in %@ starts", [alertDict objectForKey: @"name"], actionValue]];
            [MToolsAppSettings scheduleDeletionForKey: [alertDict objectForKey: @"name"] startsFromNow: actionValue];
            break;
        }
            
        //url
        case 3:
        {
            NSString *actionValue = [actionSplit objectAtIndex: 1];
            [debug log: [NSString stringWithFormat: @"URL: %@", actionValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: actionValue]];
            break;
        }
            
        //selector
        case 4:
        {
            NSString *actionValue = [actionSplit objectAtIndex: 1];
            SEL selector = NSSelectorFromString(actionValue);
            if ([selectorDelegate respondsToSelector: selector])
            {
                [selectorDelegate performSelector: selector withObject: nil];
                [debug log: [NSString stringWithFormat: @"Selector: %@", actionValue]];
            }
            else
            {
                [debug log: @"Selector delegate did not respond to selector."];
            }
            
            break;
        }
    }
    
    [queue removeLastObject];
}

@end
