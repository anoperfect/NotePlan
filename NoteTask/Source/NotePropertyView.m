//
//  NotePropertyView.m
//  NoteTask
//
//  Created by Ben on 16/7/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NotePropertyView.h"






@interface NotePropertyView ()

@property (nonatomic, strong) UILabel *classificationLabel;
@property (nonatomic, strong) UILabel *colorLabel;
@property (nonatomic, strong) UILabel *createdAtLabel;
@property (nonatomic, strong) UILabel *editedAtLabel;



@property (nonatomic, strong) void(^actionPressed)(NSString *item);


@end



@implementation NotePropertyView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.classificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 0.66 - 20, frame.size.height)];
        self.classificationLabel.textAlignment = NSTextAlignmentCenter;
        self.classificationLabel.numberOfLines = 0;
        [self addSubview:self.classificationLabel];
        
        self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * 0.66, 0, frame.size.width * 0.34 - 20, frame.size.height)];
        self.colorLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.colorLabel];
    }
    return self;
}


- (void)setClassification:(NSString*)classification color:(NSString*)color
{
    NSLog(@"setClassification : %@, color : %@", classification, color);
    
    self.classificationLabel.frame = CGRectMake(0, 0, self.frame.size.width * 0.66 - 20, self.frame.size.height);
    self.colorLabel.frame = CGRectMake(self.frame.size.width * 0.66, 0, self.frame.size.width * 0.34 - 20, self.frame.size.height);
    
    NSString *displayclassification = classification.length > 0 ? [NSString stringWithFormat:@"类别:%@   ", classification] : @"类别:未定义   ";
    NSMutableAttributedString *textclassification = [[NSMutableAttributedString alloc] init];
    
    UIFont *font = [UIFont systemFontOfSize:12];
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:displayclassification];

    [one addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, one.length)];
    [textclassification appendAttributedString:one];
    
    self.classificationLabel.attributedText = textclassification;
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
    
    NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:displayColor];
    [tagText addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, tagText.length)];
    [tagText addAttribute:NSForegroundColorAttributeName value:signColor range:NSMakeRange(0, tagText.length)];
    [textColor appendAttributedString:tagText];
    
    self.colorLabel.attributedText = textColor;
    self.colorLabel.textAlignment = NSTextAlignmentCenter;
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










//限制输入框的字数限制.
#if 0
//方法一

- (BOOL)textField1:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (range.location>= 10) {
        return NO;
    }
    
    return YES;
    
}


//方法二
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (toBeString.length > 10) {
        textField.text = [toBeString substringToIndex:10];
        return NO;
    }
    
    return YES;
}


#endif