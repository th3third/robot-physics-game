//
//  MToolsMenu.h
//  AppScaffold
//

#import <Foundation/Foundation.h>

@interface MToolsMenu : SPSprite
{
    NSMutableArray *items;
    NSMutableArray *names;
}

@property float padding;
@property float itemWidth;
@property float itemHeight;
@property (nonatomic) float offsetX;
@property (nonatomic) float offsetY;
@property (unsafe_unretained) NSString *fontName;

- (id) initWithSize: (CGSize) size;

- (void) addItem: (SPButton *) item;
- (void) addItem: (SPButton *) item withName: (NSString *) name;

@end
