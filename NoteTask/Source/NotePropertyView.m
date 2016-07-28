//
//  NotePropertyView.m
//  NoteTask
//
//  Created by Ben on 16/7/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NotePropertyView.h"






@interface NotePropertyView ()

@property (nonatomic, strong) YYLabel *categoryLabel;
@property (nonatomic, strong) YYLabel *colorLabel;
@property (nonatomic, strong) UILabel *createdAtLabel;
@property (nonatomic, strong) UILabel *editedAtLabel;



@end



@implementation NotePropertyView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.categoryLabel = [[YYLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 2 - 20, frame.size.height)];
        self.categoryLabel.textAlignment = NSTextAlignmentCenter;
        self.categoryLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        self.categoryLabel.numberOfLines = 0;
        [self addSubview:self.categoryLabel];
        
        self.colorLabel = [[YYLabel alloc] initWithFrame:CGRectMake(frame.size.width / 2, 0, frame.size.width / 2 - 20, frame.size.height)];
        self.colorLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.colorLabel];
    }
    return self;
}


- (void)setClassification:(NSString*)category color:(NSString*)color
{
    NSString *displayCategory = category.length > 0 ? [NSString stringWithFormat:@"类别:%@   ", category] : @"类别:未定义   ";
#if 0
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:displayCategory];
    [one setYy_font:[UIFont boldSystemFontOfSize:12]];
    [one setYy_color:[UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000]];
    
    YYTextBorder *border = [YYTextBorder new];
    border.strokeColor = [UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000];
    border.strokeWidth = 1;
    border.lineStyle = YYTextLineStylePatternCircleDot;
    border.cornerRadius = 3;
    border.insets = UIEdgeInsetsMake(0, -4, 0, -4);
    [one yy_setTextBackgroundBorder:border range:NSMakeRange(0, one.length)];
#endif
    
    NSMutableAttributedString *textCategory = [[NSMutableAttributedString alloc] init];
    
    NSMutableAttributedString *pad = [[NSMutableAttributedString alloc] initWithString:@"\n"];
    [pad setYy_font:[UIFont systemFontOfSize:4]];
    
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:displayCategory];
    
    [one setYy_font:[UIFont systemFontOfSize:16]];
    //[one setYy_color:[UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000]];
    [one setYy_color:[UIColor blackColor]];
    
    YYTextBorder *border = [YYTextBorder new];
    border.cornerRadius = 0;
    border.insets = UIEdgeInsetsMake(0, -10, 0, -10);
    border.strokeWidth = 1.0;
    border.strokeColor = [one yy_color];
    border.lineStyle = YYTextLineStyleSingle;
    //[one yy_setTextBackgroundBorder:border range:NSMakeRange(0, one.length)];
    
    YYTextBorder *highlightBorder = border.copy;
    highlightBorder.strokeWidth = 0;
    highlightBorder.strokeColor = [one yy_color];;
    highlightBorder.fillColor = [one yy_color];
    
    YYTextHighlight *highlight = [YYTextHighlight new];
    [highlight setColor:[UIColor purpleColor]];
    [highlight setBackgroundBorder:highlightBorder];
    __weak typeof(self) weakSelf = self;
    highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        [weakSelf showCategorySelection];
    };
    [one yy_setTextHighlight:highlight range:NSMakeRange(0, one.length)];
    
    //对齐调整和上边框的显示有问题. 根据demo使用pad.
    [textCategory appendAttributedString:pad];
    [textCategory appendAttributedString:one];
    [textCategory appendAttributedString:pad];
    [textCategory appendAttributedString:pad];
    
    self.categoryLabel.attributedText = textCategory;
//    self.categoryLabel.backgroundColor = [UIColor blueColor];
    self.categoryLabel.textAlignment = NSTextAlignmentRight;
    
    NSMutableAttributedString *textColor = [[NSMutableAttributedString alloc] init];
    
    NSString *displayColor;
    UIColor *signColor;
    
    if([color isEqualToString:@"red"]) {
        displayColor = @"◉红色";
        signColor = [UIColor redColor];
    }
    else if([color isEqualToString:@"yellow"]) {
        displayColor = @"◉黄色";
        signColor = [UIColor yellowColor];
    }
    else if([color isEqualToString:@"blue"]) {
        displayColor = @"◉蓝色";
        signColor = [UIColor blueColor];
    }
    else {
        displayColor = @"◉未标记";
        signColor = [UIColor blackColor];
    }
    
    UIFont *font = [UIFont systemFontOfSize:16];
    
    UIColor *tagStrokeColor = [UIColor colorFromString:@"#fa3f39"];
    UIColor *tagFillColor = [UIColor colorFromString:@"#fb6560"];
    NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:displayColor];
    [tagText yy_insertString:@"   " atIndex:0];
    [tagText yy_appendString:@"   "];
    [tagText setYy_font:font];
    [tagText setYy_color:signColor];
    
    [tagText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:NSMakeRange(0, tagText.length)];
    
    border = [YYTextBorder new];
    border.strokeWidth = 1.5;
    border.strokeColor = tagStrokeColor;
    border.fillColor = tagFillColor;
    border.cornerRadius = 0; // a huge value
    border.insets = UIEdgeInsetsMake(0, -10, 0, -10);
    //[tagText yy_setTextBackgroundBorder:border range:[tagText.string rangeOfString:tag]];
    
    //[textColor appendAttributedString:pad];
    [textColor appendAttributedString:tagText];
    //[textColor appendAttributedString:pad];mnnhgv bhy
    
    
    self.colorLabel.attributedText = textColor;
    self.colorLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    //self.colorLabel.text = displayColor;
}


- (void)showCategorySelection
{
    
    
}









/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
