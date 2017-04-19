//
//  TextButtonLine.m
//  Reuse0
//
//  Created by Ben on 16/7/28.
//  Copyright © 2016年 Ben. All rights reserved.
//
#import "TextButtonLine.h"
@interface TextButtonLine ()

@property (nonatomic, strong) void (^action)(NSString* text);

@end

@implementation TextButtonLine

- (instancetype)init
{
    self = [super init];
    if (self) {
        _buttonBackgroundColor = [UIColor whiteColor];
        _buttonBorderColor = [UIColor blackColor];
        _buttonTextColor = [UIColor blackColor];
        _buttonBorderWidth = 1.7;
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buttonBackgroundColor = [UIColor whiteColor];
        _buttonBorderColor = [UIColor blackColor];
        _buttonTextColor = [UIColor blackColor];
        _buttonBorderWidth = 1.7;
    }
    return self;
}


- (void)setTexts:(NSArray<NSString*>*)texts
{
    _buttonTexts = texts;
//    [self startDisplay];
}


- (void)layoutSubviews
{
    LOG_POSTION
    [super layoutSubviews];
    [self startDisplay];
}


- (void)startDisplay1
{
    NSInteger index = 0;
    NSInteger count = _buttonTexts.count;
    CGFloat buttonWidth = self.frame.size.width;
    CGFloat buttonHeight = self.frame.size.width;
    CGFloat widthInterval = (self.frame.size.width - buttonWidth) / (count - 1);
    
    CGFloat heightInterval = buttonHeight * 1.27;
    for(NSString *text in _buttonTexts) {
        
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
        [button setTitle:text forState:UIControlStateNormal];
        button.center = CGPointMake(buttonWidth/2, buttonHeight/2);
#define TEXTBUTTONLINE_BUTTON_TAG      6000
        button.tag = index + TEXTBUTTONLINE_BUTTON_TAG;
        //button.backgroundColor = [UIColor blueColor];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
        button.layer.borderColor = self.buttonBorderColor.CGColor;
        button.layer.borderWidth = self.buttonBorderWidth;
        button.layer.cornerRadius = button.frame.size.width / 2;
        [button setTitleColor:self.buttonTextColor forState:UIControlStateNormal];
        button.backgroundColor = self.buttonBackgroundColor;
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.font = FONT_SMALL;
        //button.edgeTitleLabel = UIEdgeInsetsMake(12, 12, 12, 12);
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        
        [self addSubview:button];
        
        index ++;
    }
    
    widthInterval = 0;
    
    [UIView animateWithDuration:0.6
                     animations:^{
                         for(NSInteger index = 0; index < count ; index ++) {
                             UIView *view = [self viewWithTag:index+TEXTBUTTONLINE_BUTTON_TAG];
                             view.center = CGPointMake(buttonWidth/2, buttonHeight/2 + index * (heightInterval+6));
                         }
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              for(NSInteger index = 0; index < count ; index ++) {
                                                  UIView *view = [self viewWithTag:index+TEXTBUTTONLINE_BUTTON_TAG];
                                                  view.center = CGPointMake(buttonWidth/2, buttonHeight/2 + index * heightInterval);
                                              }
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                              
                                              
                                          }
                          ];
                         
                         
                         
                     }
     ];
}


- (void)startDisplay
{
    NSInteger idx = 0;
    CGFloat buttonWidth = 60;
    NSInteger count = _buttonTexts.count;
    for(NSString *text in _buttonTexts) {
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(0, 0, buttonWidth, buttonWidth);
        [button setTitle:text forState:UIControlStateNormal];
        button.center = CGPointMake(self.frame.size.width - buttonWidth + buttonWidth / 2, buttonWidth / 2);
        
        #define TEXTBUTTONLINE_BUTTON_TAG      6000
        button.tag = idx + TEXTBUTTONLINE_BUTTON_TAG;
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];

        CALayer *borderLayer = [CALayer layer];
        CGFloat padding = buttonWidth * 0.125;
        borderLayer.frame = CGRectMake(padding, padding, buttonWidth - 2 * padding, buttonWidth - 2 * padding);
        borderLayer.borderColor = self.buttonBorderColor.CGColor;
        borderLayer.borderWidth = 1;
        borderLayer.cornerRadius = borderLayer.frame.size.width / 2;
        borderLayer.name = @"round";
        [button.layer addSublayer:borderLayer];
        
        [button setTitleColor:self.buttonTextColor forState:UIControlStateNormal];
//        button.backgroundColor = self.buttonBackgroundColor;
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.font = FONT_SMALL;
        //button.edgeTitleLabel = UIEdgeInsetsMake(12, 12, 12, 12);
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 17, 0, 17);//测试经验值.
        button.hidden = YES;
        
        [self addSubview:button];
        
        idx ++;
    }
    
    [UIView animateWithDuration:0.6
                     animations:^{
                         for(NSInteger idx = 0; idx < count ; idx ++) {
                             UIView *view = [self viewWithTag:idx+TEXTBUTTONLINE_BUTTON_TAG];
                             view.center = CGPointMake(self.frame.size.width - buttonWidth + buttonWidth / 2, (idx * buttonWidth + buttonWidth / 2) * 1.1);
                             view.hidden = NO;
                         }
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              for(NSInteger idx = 0; idx < count ; idx ++) {
                                                  UIView *view = [self viewWithTag:idx+TEXTBUTTONLINE_BUTTON_TAG];
                                                  view.center = CGPointMake(self.frame.size.width - buttonWidth + buttonWidth / 2, (idx * buttonWidth + buttonWidth / 2) * 1.0);
                                              }
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                              
                                              
                                          }
                          ];
                         
                         
                         
                     }
     ];
}



- (void)setButtonActionByText:(void (^)(NSString* text))action
{
    self.action = [action copy];
}


- (void)buttonClick:(UIButton*)button
{
    NSInteger index = button.tag - TEXTBUTTONLINE_BUTTON_TAG;
    if(index >= 0 && index < _buttonTexts.count && self.action) {
        //        button.backgroundColor = [UIColor colorWithName:@"RowActionButtonClickBackground"];
        
        [UIView animateWithDuration:0.6
                         animations:^{
                             for(CALayer *layer in button.layer.sublayers) {
                                 if([layer.name isEqualToString:@"round"]) {
                                     layer.borderWidth = 3.6;
                                     //                             button.layer.backgroundColor = [UIColor purpleColor].CGColor;
                                     
                                     layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
                                     layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
                                     layer.shadowOpacity = 0.8;//阴影透明度，默认0
                                     layer.shadowRadius = 4;//阴影半径，默认3
                                     
                                     break;
                                 }
                             }
                         }
                         completion:^(BOOL finished) {
                             //                             button.layer.borderWidth = 1.7;
                             
                         }
         ];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.action(_buttonTexts[index]);
        });
    }
}

@end
