//
//  MToolsPurchaseManager.m
//  MusicTouch
//
//  Created by Marshall on 22/08/2012.
//
//

#ifdef SPARROW_PROJECT
    #import "Game.h"
#endif
#import "MToolsPurchaseManager.h"
#import "ZipArchive.h"
#import "MToolsDebug.h"
#import "MToolsAlertViewManager.h"
#import "MToolsFileManager.h"
#import "MToolsAppSettings.h"

#define kMToolsPurchaseManagerTransactionSucceededNotification @"kMToolsPurchaseManagerTransactionSucceededNotification"
#define kMToolsPurchaseManagerTransactionFailedNotification @"kMToolsPurchaseManagerTransactionFailedNotification"

@implementation SKProduct (LocalizedPrice)

- (NSString *) localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    
    return formattedString;
}

@end

@implementation MToolsPurchaseManager

@synthesize contentListName, contentServerURL, retrievingProductList, vocal, libPath, appID;

//Singleton implementation.
static MToolsPurchaseManager *sharedManager = nil;

+ (MToolsPurchaseManager *) sharedManager
{
    if (!sharedManager)
    {
        sharedManager = [[MToolsPurchaseManager alloc] init];
    }
    return sharedManager;
}

- (id) init
{
    if (self = [super init])
    {
        appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        products = [[NSMutableArray alloc] init];
        productsParse = [[NSMutableArray alloc] init];
        downloadQueue = [[NSMutableArray alloc] init];
        downloading = false;
		retrievingProductList = YES;
        libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        contentServerURL = @"http://gearsprout.com";
    }
    
    return self;
}

//Loads the store - do this on startup.
- (void) loadStore
{
    if (vocal)
        NSLog(@"Loading store");
    //Restarts any purchases that were interrupted last time.
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    
    //Get the product requests.
    [self retrieveProductsList];
}

//Call this before making any purchases.
- (bool) canMakePurchase
{
    return [SKPaymentQueue canMakePayments];
}

//Start the product payment transaction.
- (void) purchaseProduct: (int) productID
{
    if (purchasing)
    {
        [[MToolsAlertViewManager sharedManager] alertWithMessage: @"Please wait to finish your current purchase before making another selection."];
        return;
    }
    
    purchasing = YES;
    product = [products objectAtIndex: productID];
    SKPayment *payment = [SKPayment paymentWithProduct: product];
    [[SKPaymentQueue defaultQueue] addPayment: payment];
	
	//Go ahead and set the value for this to purchased.
	[MToolsAppSettings setValue: [NSNumber numberWithBool: YES] withName: [NSString stringWithFormat: @"%@Purchased", product.productIdentifier]];
}

//Finds the product by name in the products array and then attempts to purchase it.
- (void) purchaseProductByName: (NSString *) name
{
	for (int i = 0; i < [products count]; i++)
	{
		SKProduct *producti = [products objectAtIndex: i];
		
		if ([producti.productIdentifier isEqualToString: name])
		{
			[self purchaseProduct: i];
			 i = [products count];
		}
	}
}

//Checks to see if a product has already been purchased.
- (bool) productPurchased:(NSString *)name
{
	return [MToolsAppSettings getValueWithName: [NSString stringWithFormat: @"%@Receipt", name]];
}

//Restores all previous purchases.
- (void) restorePurchases
{
    if (vocal)
        NSLog(@"Restoring purchases.");
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

//Save a record of the transaction to disk.
- (void) recordTransaction: (SKPaymentTransaction *) transaction
{
	[MToolsAppSettings setValue: transaction.transactionReceipt withName: [NSString stringWithFormat:@"%@Receipt", transaction.payment.productIdentifier]];
}

- (void) requestProductData: (NSArray *) productIDs
{
    NSSet *productIdentifiers = [NSSet setWithArray: productIDs];
    if (vocal)
        NSLog(@"Requesting product data from Apple for: %@", productIdentifiers);
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

//Provided the content.
- (void) provideContent: (NSString *) productID
{
	if (self.downloadableMode)
		[[MToolsAlertViewManager sharedManager] alertWithMessage: @"Thank you for your purchase! Your item is now being downloaded and activated. For large files, this may take a few minutes depending on your connection speed"];
	else
		[[MToolsAlertViewManager sharedManager] alertWithMessage: @"Thank you for your purchase! Your item has been activated and are ready to use."];
	
    if (vocal)
        NSLog(@"%@ was purchased.", productID);
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey:[NSString stringWithFormat:@"is%@Purchased", productID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
	if (self.downloadableMode)
	{
		//Start the spinner.
		[self startActivity];
    
		[self performSelectorInBackground: @selector(downloadProduct:) withObject: productID];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(didRetrieveProduct) withObject:nil waitUntilDone:YES];
	}
}

//Finish up the transaction.
- (void) finishTransaction: (SKPaymentTransaction *) transaction wasSuccessful: (bool)wasSuccessful
{
    purchasing = NO;
    
    if (vocal)
        NSLog(@"Finishing transaction.");
    //Remove it from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction", nil];
    
    if (wasSuccessful)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMToolsPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMToolsPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

- (void) completeTransaction: (SKPaymentTransaction *) transaction
{
    if (vocal)
        NSLog(@"Completing transaction.");
    [self recordTransaction: transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction: transaction wasSuccessful: true];
}

- (void) restoreTransaction: (SKPaymentTransaction *) transaction
{
    [self recordTransaction: transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction: transaction wasSuccessful: true];
}

//Processes transaction failures.
- (void) failedTransaction: (SKPaymentTransaction *) transaction
{
    purchasing = NO;
    
    if (vocal)
        NSLog(@"The transaction failed: %@", transaction.error);
    
    //Something went wrong with the transaction.
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        [self finishTransaction: transaction wasSuccessful: false];
        [[MToolsAlertViewManager sharedManager] alertWithMessage: @"Sorry, something went wrong with the transaction. Please try again or contact GearSprout support for more help."];
    }
    //Users cancelled.
    else
    {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
}

//Called when the transaction status is updated.
- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    if (vocal)
        NSLog(@"Payment queue updated a transaction.");
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction: transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [self failedTransaction: transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction: transaction];
                break;
                
            default:
                break;
        }
    }
}

//Transactions were NOT restored successfully.
- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (vocal)
        NSLog(@"There was an error restoring completed transactions: %@", error);
}

//Transactions were restored successfully.
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if (vocal)
        NSLog(@"Successfully restored transactions.");
}

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (vocal)
        NSLog(@"Received response from %@ with %d products", request, [response.products count]);
    products = response.products;
    
    for (SKProduct *prodRecv in products)
    {
        if (vocal)
            NSLog(@"Title: %@", prodRecv.localizedTitle);
        if (vocal)
            NSLog(@"Description: %@", prodRecv.localizedDescription);
        if (vocal)
            NSLog(@"Price: %@", prodRecv.localizedPrice);
        if (vocal)
            NSLog(@"Identifier: %@", prodRecv.productIdentifier);
    }
    
    for (NSString *invalidProductID in response.invalidProductIdentifiers)
    {
        if (vocal)
            NSLog(@"Invalid product ID: %@", invalidProductID);
    }
    
    retrievingProductList = NO;
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"kInAppMToolsPurchaseManagerProductsFetchedNotification" object:self userInfo:nil];
}

//Pull the in-app product list from a predetermined URL.
- (void) retrieveProductsList
{
	retrievingProductList = YES;
	NSOperationQueue *queue = [NSOperationQueue new];
    
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(retrieveProductListFromInternet) object:nil];
	[queue addOperation:operation];
}

- (void) retrieveProductListFromInternet
{
	//save to a temp file
    NSString *filePath = [libPath stringByAppendingString: @"/content.txt"];
	NSString *contentFilePath = [contentServerURL stringByAppendingFormat: @"/content/%@/content.txt", appID];
    NSData *contentFileData = [NSData dataWithContentsOfURL: [NSURL URLWithString: contentFilePath]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: [filePath stringByDeletingLastPathComponent]])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath: [filePath stringByDeletingLastPathComponent]
                                  withIntermediateDirectories: YES
                                                   attributes: nil
                                                        error: NULL];       
    }
    
    if (vocal)
        NSLog(@"Creating file at path %@", filePath);
    [[NSFileManager defaultManager] createFileAtPath: filePath contents: contentFileData attributes:nil];
    [MToolsFileManager addSkipBackupAttributeToItemAtString: filePath];

	NSString *contentFile = [[NSString alloc] initWithContentsOfFile: filePath encoding: NSUTF8StringEncoding error:NULL];
    
    if (!contentFile)
    {
        if (vocal)
            NSLog(@"Could not retrieve content listing file from server.");
    }
    else
    {
        //Parse out the contents of the file.
        productsParse = [contentFile componentsSeparatedByString:@"\n"];
        if (vocal)
            NSLog(@"Received content listing from server: %@", productsParse);
        
        [self performSelectorOnMainThread:@selector(didRetrieveProductList) withObject:nil waitUntilDone:YES];
    }
}

- (void) downloadProduct: (NSString *) name
{
    //Add the product to the queue if there's already a download going on.
    if (downloading)
    {
        if (vocal)
            NSLog(@"Currently downloading, adding request to queue.");
        [downloadQueue addObject: name];
        return;
    }
    
    downloading = true;
    
	//save to a temp file
	NSString *filePath = [[NSTemporaryDirectory() stringByStandardizingPath] stringByAppendingFormat: @"/%@.zip", name];
	NSString *updateURL = [contentServerURL stringByAppendingFormat: @"/content/%@/%@.zip", appID, name];
	if (vocal)
        NSLog(@"Checking for product at %@ and downloading.", updateURL);
	NSData* updateData = [NSData dataWithContentsOfURL: [NSURL URLWithString: updateURL] ];
    
	[[NSFileManager defaultManager] createFileAtPath:filePath contents:updateData attributes:nil];
    
	ZipArchive *zipArchive = [[ZipArchive alloc] init];
    
	if([zipArchive UnzipOpenFile: filePath])
    {
		if ([zipArchive UnzipFileTo: libPath overWrite:YES])
        {
            if (vocal)
                NSLog(@"Unzipping to %@ succeeded", libPath);
			[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
            [self performSelectorOnMainThread:@selector(didRetrieveProduct) withObject:nil waitUntilDone:YES];
		}
        else
        {
            NSLog(@"Unzipping failed.");
		}
        
	}
    else
    {
        NSLog(@"Opening archive failed.");
	}
}

- (void) didRetrieveProduct
{
    if (vocal)
        NSLog(@"Finished retrieving product.");
    
    downloading = false;
    
    //Do any downloads that are still in the queue.
    if ([downloadQueue count] > 0)
    {
        if (vocal)
            NSLog(@"Continuing download queue.");
        [self performSelectorInBackground: @selector(downloadProduct:) withObject: [downloadQueue objectAtIndex: [downloadQueue count] - 1]];
        [downloadQueue removeLastObject];
    }
    else
    {
        if (vocal)
            NSLog(@"Finished download queue.");
		
		if (self.downloadableMode)
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Download completed" message:@"Your purchases have finished downloading. Thank you again!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
			alert.alertViewStyle = UIAlertViewStyleDefault;
			[alert show];
		}
        
        [spinner stopAnimating];
        [spinner setAlpha: 0.00f];
    }
	
	if (self.callback)
	{
		if ([self.callback respondsToSelector: @selector(retrievedProduct)])
		{
			[self.callback performSelector: @selector(retrievedProduct)];
		}
	}
}

- (void) didRetrieveProductList
{
    if (vocal)
        NSLog(@"Finished retrieving product list.");
    [self requestProductData: productsParse];
}

- (void) startActivity
{
    if (!spinner)
    {
        spinner = [[UIActivityIndicatorView alloc] init];
        
        UIView *mainView;
        #ifdef SPARROW_PROJECT
                mainView = [SPStage mainStage].nativeView;
        #else
                mainView = [[UIApplication sharedApplication] keyWindow];
        #endif
        
        [spinner setFrame: CGRectMake(0, 0, 35, 35)];
        [spinner sizeToFit];
        [mainView addSubview: spinner];
    }
    
    [spinner setAlpha: 1.00f];
    [spinner startAnimating];
}

- (void) stopActivity
{
    if (!spinner)
        return;
    
    [spinner stopAnimating];
    [spinner setAlpha: 0.00f];
}

//GETTERS

- (NSArray *) getProducts
{
    return products;
}

@end
