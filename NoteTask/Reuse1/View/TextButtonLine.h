//
//  TextButtonLine.h
//  Reuse0
//
//  Created by Ben on 16/7/28.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TextButtonLineLayoutMode) {
    TextButtonLineLayoutModeHorizon,
    TextButtonLineLayoutModeVertical
};


@interface TextButtonLine : UIView

@property (nonatomic, assign) TextButtonLineLayoutMode  layoutMode;
@property (nonatomic, assign) NSInteger                 buttonBorderType;
@property (nonatomic, assign) NSInteger                 buttonContentType;
@property (nonatomic, strong) UIColor                   *buttonBackgroundColor;
@property (nonatomic, strong) UIColor                   *buttonBorderColor;
@property (nonatomic, strong) UIColor                   *buttonTextColor;
@property (nonatomic, assign) CGFloat                   buttonBorderWidth;
@property (nonatomic, assign) UIEdgeInsets              edge;
@property (nonatomic, strong) NSArray<NSString*>        *buttonTexts;


- (void)setTexts:(NSArray<NSString*>*)texts;
- (void)setButtonActionByText:(void (^)(NSString* text))action;



@end
