//
//  PushButton.m
//  Reuse0
//
//  Created by Ben on 16/3/31.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "PushButton.h"
#import "UIpConfig.h"





@implementation PushButtonData


@end







@implementation PushButton




- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showsTouchWhenHighlighted = YES;
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsTouchWhenHighlighted = YES;
    }
    return self;
}


- (void)setButtonData:(PushButtonData*)data
{
    _buttonData = data;
    
    if(_buttonData.imageName) {
        [self setImage:[UIImage imageNamed:_buttonData.imageName] forState:UIControlStateNormal];
    }
    
    
    
    
    
    
    
    
    
    
    
#if 0
    //[self setTitle:@"收藏" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
    
    //[self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, widthButton - heightButton)];
    //[self setTitleEdgeInsets:UIEdgeInsetsMake(0, heightButton, 0, 0)];
    
    CGRect frame = button.imageView.frame;
    LOG_RECT(frame, @"button-image");
    frame = button.titleLabel.frame;
    LOG_RECT(frame, @"button-title");
#endif
}


#if 0
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat btnCornerRedius = 1;
    CGFloat titleW = contentRect.size.width - btnCornerRedius;
    CGFloat titleH = self.frame.size.height;
    CGFloat titleX = self.frame.size.height + btnCornerRedius;
    CGFloat titleY = 0;
    contentRect = (CGRect){{titleX,titleY},{titleW,titleH}};
    return contentRect;
    
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
//    CGFloat btnCornerRedius = 1;
    CGFloat imageW = self.frame.size.height -10;
    CGFloat imageH = self.frame.size.height -10;
    CGFloat imageX = 5;
    CGFloat imageY = 5;
    contentRect = (CGRect){{imageX,imageY},{imageW,imageH}};
    return contentRect;
    
}
#endif



//- (CGRect)titleRectForContentRect:(CGRect)contentRect
//{
//    return contentRect;
//
//    
//}
//
//- (CGRect)imageRectForContentRect:(CGRect)contentRect
//{
////    return UIEdgeInsetsInsetRect(contentRect, UIEdgeInsetsMake(6, 6, 6, 6));
////    return contentRect;
//    return CGRectMake(0, 0, 0, 0);
//
//}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end



































































@implementation UIButton (UIButtonImageWithLable)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title titleFont:(UIFont*)font forState:(UIControlState)stateType {
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
    CGSize titleSize ;
    NSAttributedString * s = [NSString attributedStringWith:title font:font indent:0 textColor:nil];
    
    NSRange range = NSMakeRange(0, title.length);
    titleSize = [title sizeWithAttributes:[s attributesAtIndex:0 effectiveRange:&range]];
    [self.imageView setContentMode:UIViewContentModeCenter];
//    [self setImageEdgeInsets:UIEdgeInsetsMake(-8.0,
//                                              0.0,
//                                              0.0,
//                                              -titleSize.width)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:font];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(30.0,
                                              -20,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
}

@end





