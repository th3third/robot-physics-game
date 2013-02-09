//
//  MToolsMenu.m
//  AppScaffold
//

#import "MToolsMenu.h"
#import "MToolsMedia.h"



@implementation MToolsMenu

@synthesize padding;
@synthesize itemHeight;
@synthesize itemWidth;
@synthesize fontName;
@synthesize offsetX, offsetY;

- (id) initWithSize: (CGSize) size
{
    if (self = [super init])
    {
        SPQuad *spacer = [SPQuad quadWithWidth: size.width height: size.height];
        spacer.alpha = 0.00f;
        [self addChild: spacer];
        
        //Initial properties
        fontName = @"ChalkboardSE-Regular";
        itemWidth = size.width;
        itemHeight = 50;
        
        //Alloc and init class stuff.
        items = [NSMutableArray array];
        names = [NSMutableArray array];
    }
    
    return self;
}

- (void) addItem: (SPButton *) item
{
    [self addItem: item withName: @""];
}

- (void) addItem: (SPButton *) item withName: (NSString *) name;
{
    [items addObject: item];
    [names addObject: name];
    
    //Make sure we don't go outside the boundries.
    if (item.width >= self.width)
    {
        float scale = self.width / item.width;
        item.width = self.width;
        item.height = item.height * scale;
    }
    if (item.height >= self.height)
    {
        float scale = self.width / item.width;
        item.height = self.height;
        item.width = item.width * scale;
    }
    
    [self drawMenu];
}

- (void) setOffsetX: (float) value
{
    offsetX = value;
    [self drawMenu];
}

- (void) setOffsetY: (float) value
{
    offsetY = value;
    [self drawMenu];
}

//Called every time we need to redraw the menu - like when it is changed.
- (void) drawMenu
{    
    float spacerWidth = self.width;
    float spacerHeight = self.height;
    
    [self removeAllChildren];
    
    //Redraw the spacer.
    SPQuad *spacer = [SPQuad quadWithWidth: spacerWidth height: spacerHeight];
    spacer.color = 0xFFFFFF;
    spacer.alpha = 0.00f;
    [self addChild: spacer];
    
    //float baseX = 0;
    float baseY = 0;
    
    for (int i = 0; i < [items count]; i++)
    {
        SPButton *item = [items objectAtIndex: i];
        NSString *name = [names objectAtIndex: i];
        
        //Adjust the height and width if need be.
        /*if (item.width != itemWidth)
        {
            item.width = itemWidth;
        }
        if (item.height != itemHeight)
        {
            item.height = itemHeight;
        }*/
        
        //Put in the button.
        //item.x = self.width / 2 - item.width / 2 + offsetX;
        item.x = offsetX;
        item.y = (padding + item.height) * i + offsetY;
        if (![name isEqualToString: @""])
            item.text = name;
        item.fontSize = item.height / 4;
        item.textBounds = [SPRectangle rectangleWithX: item.height * 0.20 y: 0 width: item.width height: item.height];
        item.fontName = fontName;
        item.fontSize = item.height / 2.25;

        
        //if ([item.text isEqualToString: @""])
        //    item.text = name;
        //if (fontName)
        //    item.fontName = fontName;

        //item.fontSize = item.height / 2;
        //float textY = (item.height / 3 - item.fontSize / 2);
        //float textX = (item.width / 2 - item.bounds.width / 2);
        //item.textBounds = [SPRectangle rectangleWithX: textX y: textY width: item.width height: item.height];
        
        //Now put in the text field.
        /*SPTextField *textField = [SPTextField textFieldWithText: name];
        textField.height = item.height;
        textField.hAlign = SPHAlignLeft;
        textField.vAlign = SPVAlignCenter;
        textField.fontName = @"";
        textField.x = item.x + item.width + 15;
        textField.y = item.y;*/
        
        /*SPQuad *quad = [SPQuad quadWithWidth: item.width height: item.height color: 0xFFFFFF];
        quad.x = item.x;
        quad.y = item.y;
        quad.width += 6;
        quad.height += 6;
        quad.x -= 3;
        quad.y -= 3;
        quad.alpha = 0.75f;
        
        SPQuad *outline = [SPQuad quadWithWidth: quad.width height: quad.height color: 0x000000];
        outline.x = quad.x;
        outline.y = quad.y;
        outline.alpha = 0.15f;
        outline.width += 4;
        outline.height += 4;
        outline.x -= 2;
        outline.y -= 2;*/
        
        baseY += item.height + self.padding;
        
        //[self addChild: outline];
        //[self addChild: quad];
        [self addChild: item];
        //[self addChild: textField];
    }
}

@end
