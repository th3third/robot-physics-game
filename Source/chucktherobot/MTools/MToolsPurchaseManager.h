//
//  MToolsPurchaseManager.h
//  MusicTouch
//
//  Created by Marshall on 22/08/2012.
//
//

#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>

@interface SKProduct (LocalizedPrice)

    @property (nonatomic, readonly) NSString *localizedPrice;

@end

@class Game;
@interface MToolsPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProduct *product;
    SKProductsRequest *productsRequest;
    NSString *appID;
    UIActivityIndicatorView *spinner;
    bool downloading;
    bool purchasing;
    
    NSArray *products;
    NSArray *productsParse;
    NSMutableArray *downloadQueue;
}

@property (unsafe_unretained) NSString* contentServerURL;
@property (unsafe_unretained) NSString* contentListName;

@property bool retrievingProductList;
@property bool vocal;
@property (unsafe_unretained) NSString *libPath;

+ (MToolsPurchaseManager *) sharedManager;

- (void) loadStore;
- (bool) canMakePurchase;
- (void) purchaseProduct: (int) productID;
- (void) restorePurchases;

- (void) retrieveProductsList;
- (NSArray *) getProducts;

@end
