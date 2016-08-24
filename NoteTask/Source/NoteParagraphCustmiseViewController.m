//
//  NoteParagraphCustmiseViewController.m
//  NoteTask
//
//  Created by Ben on 16/7/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteParagraphCustmiseViewController.h"
#import "NoteModel.h"
#import "ColorSelector.h"




@interface NoteParagraphCustmiseViewController ()




@property (nonatomic, strong) NSDictionary  *styleDictionary;
@property (nonatomic, strong) YYLabel       *sampleText;


/*
 前景色, 1
 背景色, 1
 字体大小, 1
 斜体,  1
 下划线, 1
 边框, 1
 边沿宽度. x
 
 
 
 */

@property (nonatomic, strong) RangeValueView *fontsizeView;

@property (nonatomic, strong) UILabel  *italicLable;
@property (nonatomic, strong) UISwitch *italicSwitch;

@property (nonatomic, strong) UILabel  *underlineLable;
@property (nonatomic, strong) UISwitch *underlineSwitch;

@property (nonatomic, strong) UILabel  *borderLable;
@property (nonatomic, strong) UISwitch *borderSwitch;


@property (nonatomic, strong) UILabel       *textColorLabel;
@property (nonatomic, strong) UITextField   *textColorInput;
@property (nonatomic, strong) UIButton      *textColorButton;

@property (nonatomic, strong) UILabel       *textBackgroundColorLabel;
@property (nonatomic, strong) UITextField   *textBackgroundColorInput;
@property (nonatomic, strong) UIButton      *textBackgroundColorButton;

@end

@implementation NoteParagraphCustmiseViewController


- (instancetype)initWithStyleDictionary:(NSDictionary*)styleDictionary
{
    self = [super init];
    if (self) {
        self.styleDictionary = [NSDictionary dictionaryWithDictionary:styleDictionary];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"样式设置";
    self.view.backgroundColor = [UIColor colorWithName:@"CustomBackground"];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithName:@"NavigationBackText"]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.navigationItem.rightBarButtonItem
            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish)];
    
    
    self.sampleText = [[YYLabel alloc] init];
    self.sampleText.text = @"样式测试 Sample";
    [self.contentView addSubview:self.sampleText];
    
    self.fontsizeView = [RangeValueView rangeValueViewWithFrame:CGRectMake(10, 100, Width-20, 0)
                                                           name:@"字体大小 - font-size"
                                                       minValue:8.0
                                                       maxValue:36.0 defaultValue:16];
    [self.contentView addSubview:self.fontsizeView];
    
    self.italicLable = [[UILabel alloc] init];
    self.italicLable.text = @"斜体";
    self.italicLable.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.italicLable.textAlignment = NSTextAlignmentCenter;
    self.italicSwitch = [[UISwitch alloc] init];
    [self.italicSwitch addTarget:self action:@selector(switchValueChangeItalic) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.italicLable];
    [self.contentView addSubview:self.italicSwitch];
    
    self.underlineLable = [[UILabel alloc] init];
    self.underlineLable.text = @"下划线";
    self.underlineLable.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.underlineLable.textAlignment = NSTextAlignmentCenter;
    self.underlineSwitch = [[UISwitch alloc] init];
    [self.underlineSwitch addTarget:self action:@selector(switchValueChangeUnderline) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.underlineLable];
    [self.contentView addSubview:self.underlineSwitch];
    
    self.borderLable = [[UILabel alloc] init];
    self.borderLable.text = @"边框";
    self.borderLable.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.borderLable.textAlignment = NSTextAlignmentCenter;
    self.borderSwitch = [[UISwitch alloc] init];
    [self.borderSwitch addTarget:self action:@selector(switchValueChangeBorder) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.borderLable];
    [self.contentView addSubview:self.borderSwitch];
    
#if 0
    //可以设置颜色和大小. 大小通过变换.
    self.borderSwitch.onTintColor = [UIColor colorWithRed:0.984 green:0.478 blue:0.224 alpha:1.000];
    // 控件大小，不能设置frame，只能用缩放比例
    self.borderSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
#endif
    
    self.textColorLabel = [[UILabel alloc] init];
    self.textColorLabel.text = @"文本颜色:";
    self.textColorLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.textColorLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.textColorLabel];
    
    self.textColorInput = [[UITextField alloc] init];
    self.textColorInput.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.textColorInput.layer.borderWidth = 1.0;
    self.textColorInput.layer.borderColor = [UIColor blackColor].CGColor;
    [self.contentView addSubview:self.textColorInput];
    
    self.textColorButton = [[UIButton alloc] init];
    [self.textColorButton setTitle:@"颜色选择器" forState:UIControlStateNormal];
    [self.textColorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.textColorButton.titleLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    [self.textColorButton addTarget:self action:@selector(openTextColorSelector) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:self.textColorButton];
    
    self.textBackgroundColorLabel = [[UILabel alloc] init];
    self.textBackgroundColorLabel.text = @"背景颜色:";
    self.textBackgroundColorLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.textBackgroundColorLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.textBackgroundColorLabel];
    
    self.textBackgroundColorInput = [[UITextField alloc] init];
    self.textBackgroundColorInput.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.textBackgroundColorInput.layer.borderWidth = 1.0;
    self.textBackgroundColorInput.layer.borderColor = [UIColor blackColor].CGColor;
    [self.contentView addSubview:self.textBackgroundColorInput];
    
    
    
    
    
    
    
    
    
    
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    FrameSplite *frameSplite = [[FrameSplite alloc] initWithRootView:self.contentView];
    [frameSplite frameSplite:FRAMESPLITE_NAME_MAIN
                          to:@[@"sample", @"colorsDefault", @"colorsRecent", @"fontSize", @"switchs", @"textColorLine", @"paddingTextColor", @"textBackgroundColorLine"]
             withPercentages:@[@(0.1),    @(0.27),          @(0.1),          @(0.1),      @(0.06),     @(0.036),        @(0.01),  @(0.036)]];
    
//    [frameSplite frameSpliteEqual:@"switchs" to:@[@"switchLabelLine", @"switchLine"]];
//    [frameSplite frameSpliteEqual:@"switchLabelLine" toVertical:@[@"italicLabel", @"underlineLabel", @"borderLabel"]];
//    [frameSplite frameSpliteEqual:@"switchLine" toVertical:@[@"italicSwitch", @"underlineSwitch", @"borderSwitch"]];
    
    [frameSplite frameSplite:@"switchs"
                  toVertical:@[@"italicLabel", @"italicSwitch", @"underlineLabel", @"underlineSwitch", @"borderLabel", @"borderSwitch"]
             withPercentages:@[@(.12), @(.21), @(.12), @(.21), @(.12), @(.21)]];
    
    FrameAssign(self.sampleText, @"sample", frameSplite)
    
    
    
    
    self.fontsizeView.frame = [frameSplite frameSpliteGet:@"fontSize"];
    
    self.italicLable.frame      = [frameSplite frameSpliteGet:@"italicLabel"];
    self.italicSwitch.frame     = [frameSplite frameSpliteGet:@"italicSwitch"];
    
    self.underlineLable.frame   = [frameSplite frameSpliteGet:@"underlineLabel"];
    self.underlineSwitch.frame  = [frameSplite frameSpliteGet:@"underlineSwitch"];
    
    self.borderLable.frame      = [frameSplite frameSpliteGet:@"borderLabel"];
    self.borderSwitch.frame     = [frameSplite frameSpliteGet:@"borderSwitch"];
    
    
    [frameSplite frameSplite:@"textColorLine"
                  toVertical:@[@"textColorLabel", @"textColorInput", @"textColorButton"]
             withPercentages:@[@(.20), @(.40), @(.20)]];
    
    FrameAssign(self.textColorLabel, @"textColorLabel", frameSplite)
    FrameAssign(self.textColorInput, @"textColorInput", frameSplite)
    FrameAssign(self.textColorButton, @"textColorButton", frameSplite)
    
    [frameSplite frameSplite:@"textBackgroundColorLine"
                  toVertical:@[@"textBackgroundColorLabel", @"textBackgroundColorInput"]
             withPercentages:@[@(.36), @(.60), @(.12), @(.21), @(.12), @(.21)]];
    
    FrameAssign(self.textBackgroundColorLabel, @"textBackgroundColorLabel", frameSplite)
    FrameAssign(self.textBackgroundColorInput, @"textBackgroundColorInput", frameSplite)
    
    
    

}


- (void)switchValueChangeItalic
{
    NSLog(@"Italic : %d", self.italicSwitch.on);
    
    
    
}


- (void)switchValueChangeUnderline
{
    NSLog(@"Underline : %d", self.underlineSwitch.on);
    
    
}


- (void)switchValueChangeBorder
{
    NSLog(@"Border : %d", self.borderSwitch.on);
    
    
}


- (void)sampleTextUpdate
{
#if 0
    
    //字体,颜色.
    UIFont *font    = [noteParagraphModel textFont];
    UIColor *color  = [noteParagraphModel textColor];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.length)];
    
    //对齐方式.
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.headIndent = 20.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 2.0;
    NSDictionary * attributes = @{NSParagraphStyleAttributeName:paragraphStyle};
    [attributedString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
    
    
#endif
    
    
}




- (void)finish
{
    //CGFloat fontSize = self.fontsizeView.currentValue;
    
    
}


- (void)openTextColorSelector
{
    LOG_POSTION
    
    CGFloat width = self.contentView.bounds.size.width * 0.8;
    CGRect frameInit = CGRectMake(self.contentView.frame.size.width - 0, 0, width, self.contentView.frame.size.height);
    CGRect frameShow = CGRectMake(self.contentView.frame.size.width - width, 0, width, self.contentView.frame.size.height);
    CGRect frameRemove = CGRectMake(self.contentView.frame.size.width - 0, 0, width, self.contentView.frame.size.height);
    
    __weak typeof(self) _self = self;
    ColorSelector *v = [[ColorSelector alloc] initWithFrame:frameInit
                                                 cellHeight:36.0
                                               colorPresets:@[]
                                                isTextColor:YES
                                               selectHandle:^(NSString *selectedColorString) {
                                                   __weak ColorSelector *_v = v;
                                                   [UIView animateWithDuration:1.0 animations:^{
                                                       _v.frame = frameRemove;
                                                       
                                                   } completion:^(BOOL finished) {
                                                       [_v removeFromSuperview];
                                                   }];
                                                   [_self selectedTextColorString:selectedColorString];
                                                   
                                            }];
    [self.contentView addSubview:v];
    v.backgroundColor = [UIColor blueColor];
    
    [UIView animateWithDuration:1.0 animations:^{
        v.frame = frameShow;
    LOG_POSTION
        LOG_VIEW_RECT(v, @"v")
    } completion:^(BOOL finished) {
        LOG_VIEW_RECT(v, @"v")
    LOG_POSTION
        
    }];
}


- (void)selectedTextColorString:(NSString*)selectedColorString
{
    NSLog(@"selectedTextColorString : %@", selectedColorString);
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
