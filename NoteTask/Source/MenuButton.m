//
//  MenuButton.m
//  NoteTask
//
//  Created by Ben on 16/6/28.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "MenuButton.h"
#import "UIColor+Util.h"
@implementation MenuButtonData





- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        self.name       = dictionary[@"name"];
        self.title      = dictionary[@"title"];
        self.imageName  = dictionary[@"imageName"];
    }
    return self;
}




@end





@interface MenuButton ()

@property (nonatomic, strong) MenuButtonData *data;

@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) CGFloat titleWidth;
@property (nonatomic, assign) CGFloat titleHeight;

@end



@implementation MenuButton




- (void)setMenuButtonData:(MenuButtonData*)data
{
    _imageWidth     = 40;
    _imageHeight    = 40;
    _titleWidth     = 60;
    _titleHeight    = 20;
    
    [self setTitle:data.title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:data.imageName] forState:UIControlStateNormal];
    self.backgroundColor = [UIColor colorWithHex:0x1e2324 alpha:1.0];
    
    self.titleLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 0.0;
}


- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect imageRect = CGRectMake((contentRect.size.width - _imageWidth) / 2, (contentRect.size.height - _imageHeight - _titleHeight) / 2, _imageWidth, _imageHeight);
    return imageRect;
}




- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect titleRect = CGRectMake((contentRect.size.width - _titleWidth) / 2, (contentRect.size.height - _imageHeight - _titleHeight) / 2 + _imageHeight, _titleWidth, _titleHeight);
    return titleRect;
    
}






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
