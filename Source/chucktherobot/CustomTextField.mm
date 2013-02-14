//
//  CustomTextField.m
//  chuckthebot
//
//  Created by Marshall on 13/02/2013.
//
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawPlaceholderInRect:(CGRect)rect
{
	[[UIColor blackColor] setFill];
    [[self placeholder] drawInRect: CGRectMake(rect.origin.x + 1, rect.origin.y + 1, rect.size.width, rect.size.height) withFont: self.font];
	
    [[UIColor whiteColor] setFill];
    [[self placeholder] drawInRect: rect withFont: self.font];
}

@end
