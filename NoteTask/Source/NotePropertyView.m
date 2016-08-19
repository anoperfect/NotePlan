//
//  NotePropertyView.m
//  NoteTask
//
//  Created by Ben on 16/7/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NotePropertyView.h"






@interface NotePropertyView ()

@property (nonatomic, strong) YYLabel *classificationLabel;
@property (nonatomic, strong) YYLabel *colorLabel;
@property (nonatomic, strong) UILabel *createdAtLabel;
@property (nonatomic, strong) UILabel *editedAtLabel;



@property (nonatomic, strong) void(^actionPressed)(NSString *item);


@end



@implementation NotePropertyView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.classificationLabel = [[YYLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 0.66 - 20, frame.size.height)];
        self.classificationLabel.textAlignment = NSTextAlignmentCenter;
        self.classificationLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        self.classificationLabel.numberOfLines = 0;
        [self addSubview:self.classificationLabel];
        
        self.colorLabel = [[YYLabel alloc] initWithFrame:CGRectMake(frame.size.width * 0.66, 0, frame.size.width * 0.34 - 20, frame.size.height)];
        self.colorLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.colorLabel];
    }
    return self;
}


- (void)setClassification:(NSString*)classification color:(NSString*)color
{
    NSLog(@"setClassification : %@, color : %@", classification, color);
    NSString *displayclassification = classification.length > 0 ? [NSString stringWithFormat:@"类别:%@   ", classification] : @"类别:未定义   ";
#if 0
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:displayclassification];
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
    
    NSMutableAttributedString *textclassification = [[NSMutableAttributedString alloc] init];
    
    NSMutableAttributedString *pad = [[NSMutableAttributedString alloc] initWithString:@"\n"];
    [pad setYy_font:[UIFont systemFontOfSize:4]];
    
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:displayclassification];
    
    [one setYy_font:[UIFont systemFontOfSize:12]];
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
//    __weak typeof(self) weakSelf = self;
//    highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
//        [weakSelf showclassificationSelection];
//    };
    //[one yy_setTextHighlight:highlight range:NSMakeRange(0, one.length)];
    
    //对齐调整和上边框的显示有问题. 根据demo使用pad.
    [textclassification appendAttributedString:pad];
    [textclassification appendAttributedString:one];
    [textclassification appendAttributedString:pad];
    [textclassification appendAttributedString:pad];
    
    self.classificationLabel.attributedText = textclassification;
//    self.classificationLabel.backgroundColor = [UIColor blueColor];
    self.classificationLabel.textAlignment = NSTextAlignmentRight;
    
    NSMutableAttributedString *textColor = [[NSMutableAttributedString alloc] init];
    
    NSString *displayColor;
    UIColor *signColor;
    
    if([color isEqualToString:@"red"]) {
        displayColor = @"◉红色";
        signColor = [UIColor redColor];
    }
    else if([color isEqualToString:@"yellow"]) {
        displayColor = @"◉黄色";
        signColor = [UIColor colorFromString:@"f1cc56"];
    }
    else if([color isEqualToString:@"blue"]) {
        displayColor = @"◉蓝色";
        signColor = [UIColor blueColor];
    }
    else {
        displayColor = @"◉未标记";
        signColor = [UIColor blackColor];
    }
    
    UIFont *font = [UIFont systemFontOfSize:12];
    
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


- (void)showclassificationSelection
{
    if(self.actionPressed) {
        self.actionPressed(@"Classification");
    }
}












/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
