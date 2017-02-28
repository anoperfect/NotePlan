//
//  NotePCustmiseViewController.m
//  NoteTask
//
//  Created by Ben on 16/7/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NotePCustmiseViewController.h"
#import "NoteModel.h"
#import "ColorSelector.h"




@interface NoteParagraphCustmiseViewController () <UITextFieldDelegate>




@property (nonatomic, strong) NoteParagraphModel    *sampleNoteParagraph;
@property (nonatomic, assign) NSInteger sn;
@property (nonatomic, strong) UILabel       *sampleText;


/*
 前景色, 1
 背景色, 1
 字体大小, 1
 斜体,  1
 下划线, 1
 边框, 1
 边沿宽度. x
 
 
 
 */

@property (nonatomic, strong) UISlider          *fontSizeSlider;
@property (nonatomic, strong) UILabel           *fontSizeNameLabel;
@property (nonatomic, strong) UILabel           *fontSizeValueLabel;
@property (nonatomic, strong) UILabel           *fontSizeUseDefaultLabel;
@property (nonatomic, strong) UISwitch          *fontSizeUseDefaultSwitch;
@property (nonatomic, strong) NSString          *fontSizeEdit;

@property (nonatomic, strong) NSMutableArray    *fontNumbers;






@property (nonatomic, strong) UILabel  *italicLable;
@property (nonatomic, strong) UISwitch *italicSwitch;

@property (nonatomic, strong) UILabel  *underlineLable;
@property (nonatomic, strong) UISwitch *underlineSwitch;

@property (nonatomic, strong) UILabel  *borderLable;
@property (nonatomic, strong) UISwitch *borderSwitch;

@property (nonatomic, strong) UILabel  *boldLable;
@property (nonatomic, strong) UISwitch *boldSwitch;


@property (nonatomic, strong) UILabel       *textColorLabel;
@property (nonatomic, strong) UITextField   *textColorInput;
@property (nonatomic, strong) UIButton      *textColorButton;

@property (nonatomic, strong) UILabel       *textBackgroundColorLabel;
@property (nonatomic, strong) UITextField   *textBackgroundColorInput;
@property (nonatomic, strong) UIButton      *textBackgroundColorButton;

@property (nonatomic, strong) ColorSelector *textColorSelector;

@property (nonatomic, strong) void(^finishHandle)(NSDictionary *styleDictionary);





@end

@implementation NoteParagraphCustmiseViewController



#pragma mark - init
- (instancetype)initWithStyleDictionary:(NSDictionary*)styleDictionary
{
    self = [super init];
    if (self) {
        self.sampleNoteParagraph = [[NoteParagraphModel alloc] init];
        self.sampleNoteParagraph.styleDictionay = [NSMutableDictionary dictionaryWithDictionary:styleDictionary];
        self.sampleNoteParagraph.content = @"样式测试 Sample";
    }
    return self;
}


- (instancetype)initWithNoteParagraph:(NoteParagraphModel*)noteParagraph sn:(NSInteger)sn
{
    self = [super init];
    if (self) {
        self.sampleNoteParagraph = [noteParagraph copy];
        self.sn = sn;
    }
    return self;
}


- (void)setStyleFinishHandle:(void(^)(NSDictionary *styleDictionary))handle
{
    self.finishHandle = handle;
}


#pragma mark - Custom override view.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"样式设置";
    self.view.backgroundColor = [UIColor colorWithName:@"CustomBackground"];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithName:@"NavigationBackText"]];
    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    backItem.title = @"";
//    self.navigationItem.backBarButtonItem = backItem;
    
    self.navigationItem.rightBarButtonItem
            = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(actionFinishCustomise)];
    
    //点击空白的地方时关闭软键盘.
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.sampleText = [[UILabel alloc] init];
    [self.contentView addSubview:self.sampleText];
    self.sampleText.numberOfLines = 0;
    self.sampleText.backgroundColor = [UIColor whiteColor];
    
    self.fontSizeSlider = [[UISlider alloc] init];
    [self.contentView addSubview:self.fontSizeSlider];
    self.fontSizeSlider.minimumValue = 8.0;
    self.fontSizeSlider.maximumValue = 36.0;
    self.fontSizeSlider.minimumTrackTintColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    self.fontSizeSlider.maximumTrackTintColor = [[UIColor grayColor] colorWithAlphaComponent:0.05f];
    [self.fontSizeSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [self.fontSizeSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateHighlighted];
    [self.fontSizeSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    CGFloat sliderValue = 16.0;
    NSString *fontString = self.sampleNoteParagraph.styleDictionay[@"font-size"];
    CGFloat ptSize = 16.0;
    if([fontString hasSuffix:@"px"] && (ptSize = [fontString floatValue]) >= 1.0 && ptSize < 100.0) {
        sliderValue = ptSize;
    }
    else {
        NSString *value = nil;
        if(self.sampleNoteParagraph.isTitle) {
            value = [[AppConfig sharedAppConfig] configSettingGet:@"NoteTitleFontSizeDefault"];
        }
        else {
            value = [[AppConfig sharedAppConfig] configSettingGet:@"NoteParagraphFontSizeDefault"];
        }
        if([value hasSuffix:@"px"] && (ptSize = [value floatValue]) >= 1.0 && ptSize < 100.0) {
            sliderValue = ptSize;
        }
    }
    self.fontSizeSlider.value = sliderValue;
    
    self.fontSizeNameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.fontSizeNameLabel];
    self.fontSizeNameLabel.text = @"字体-大小";
    self.fontSizeNameLabel.textAlignment = NSTextAlignmentLeft;
    self.fontSizeNameLabel.font = FONT_SMALL;
    
    self.fontSizeValueLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.fontSizeValueLabel];
    self.fontSizeValueLabel.text = @"8px";
    self.fontSizeValueLabel.textAlignment = NSTextAlignmentRight;
    self.fontSizeValueLabel.font = FONT_SMALL;
    NSInteger ptSizeInt = ptSize;
    self.fontSizeValueLabel.text = [NSString stringWithFormat:@"%zdpx", ptSizeInt];
    
    self.fontSizeUseDefaultLabel = [[UILabel alloc] init];
    [self addSubview:self.fontSizeUseDefaultLabel];
    self.fontSizeUseDefaultLabel.text = @"使用默认";
    self.fontSizeUseDefaultLabel.textAlignment = NSTextAlignmentRight;
    self.fontSizeUseDefaultLabel.font = FONT_SMALL;
    self.fontSizeUseDefaultSwitch = [[UISwitch alloc] init];
    [self.contentView addSubview:self.fontSizeUseDefaultSwitch];
    [self.fontSizeUseDefaultSwitch addTarget:self action:@selector(switchValueChangeFontSizeUseDefault) forControlEvents:UIControlEventValueChanged];
    if(nil == self.sampleNoteParagraph.styleDictionay[@"font-size"]) {
        self.fontSizeUseDefaultSwitch.on = YES;
    }
    else {
        self.fontSizeEdit = self.sampleNoteParagraph.styleDictionay[@"font-size"];
    }
    
    self.italicLable = [[UILabel alloc] init];
    [self.contentView addSubview:self.italicLable];
    self.italicLable.text = @"斜体";
    self.italicLable.font = FONT_SMALL;
    self.italicLable.textAlignment = NSTextAlignmentCenter;
    self.italicSwitch = [[UISwitch alloc] init];
    [self.contentView addSubview:self.italicSwitch];
    [self.italicSwitch addTarget:self action:@selector(switchValueChangeItalic) forControlEvents:UIControlEventValueChanged];
    if([self.sampleNoteParagraph.styleDictionay[@"font-style"] isEqualToString:@"italic"]) {
        self.italicSwitch.on = YES;
    }
    
    self.underlineLable = [[UILabel alloc] init];
    [self.contentView addSubview:self.underlineLable];
    self.underlineLable.text = @"下划线";
    self.underlineLable.font = FONT_SMALL;
    self.underlineLable.textAlignment = NSTextAlignmentCenter;
    self.underlineSwitch = [[UISwitch alloc] init];
    [self.contentView addSubview:self.underlineSwitch];
    [self.underlineSwitch addTarget:self action:@selector(switchValueChangeUnderline) forControlEvents:UIControlEventValueChanged];
    if([self.sampleNoteParagraph.styleDictionay[@"text-decoration"] isEqualToString:@"underline"]) {
        self.underlineSwitch.on = YES;
    }
    
    self.borderLable = [[UILabel alloc] init];
    [self.contentView addSubview:self.borderLable];
    self.borderLable.text = @"边框";
    self.borderLable.font = FONT_SMALL;
    self.borderLable.textAlignment = NSTextAlignmentCenter;
    self.borderSwitch = [[UISwitch alloc] init];
    [self.contentView addSubview:self.borderSwitch];
    [self.borderSwitch addTarget:self action:@selector(switchValueChangeBorder) forControlEvents:UIControlEventValueChanged];
    if([self.sampleNoteParagraph.styleDictionay[@"border"] isEqualToString:@"1px solid #000"]) {
        self.borderSwitch.on = YES;
    }
    
    self.boldLable = [[UILabel alloc] init];
    [self.contentView addSubview:self.boldLable];
    self.boldLable.text = @"粗体";
    self.boldLable.font = FONT_SMALL;
    self.boldLable.textAlignment = NSTextAlignmentCenter;
    self.boldSwitch = [[UISwitch alloc] init];
    [self.contentView addSubview:self.boldSwitch];
    [self.boldSwitch addTarget:self action:@selector(switchValueChangeBold) forControlEvents:UIControlEventValueChanged];
    if([self.sampleNoteParagraph.styleDictionay[@"font-weight"] isEqualToString:@"bold"]) {
        self.boldSwitch.on = YES;
    }
    
#if 0
    //可以设置颜色和大小. 大小通过变换.
    self.borderSwitch.onTintColor = [UIColor colorWithRed:0.984 green:0.478 blue:0.224 alpha:1.000];
    // 控件大小，不能设置frame，只能用缩放比例
    self.borderSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
#endif
    
    self.textColorLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.textColorLabel];
    self.textColorLabel.text = @"文本颜色:";
    self.textColorLabel.font = FONT_SMALL;
    self.textColorLabel.textAlignment = NSTextAlignmentCenter;
    
    self.textColorInput = [[UITextField alloc] init];
    [self.contentView addSubview:self.textColorInput];
    self.textColorInput.font = FONT_SMALL;
    self.textColorInput.layer.borderWidth = 1.0;
    self.textColorInput.layer.borderColor = [UIColor blackColor].CGColor;
    self.textColorInput.delegate = self;
    self.textColorInput.returnKeyType = UIReturnKeyDone;
    self.textColorInput.keyboardType = UIKeyboardTypeDefault;
    self.textColorInput.text = self.sampleNoteParagraph.styleDictionay[@"color"];
    
    self.textColorButton = [[UIButton alloc] init];
    [self.contentView addSubview:self.textColorButton];
    [self.textColorButton setTitle:@"颜色选择器" forState:UIControlStateNormal];
    [self.textColorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.textColorButton.titleLabel.font = FONT_SMALL;
    [self.textColorButton addTarget:self action:@selector(openTextColorSelector) forControlEvents:UIControlEventTouchDown];
    
    self.textBackgroundColorLabel = [[UILabel alloc] init];
    //[self.contentView addSubview:self.textBackgroundColorLabel];
    self.textBackgroundColorLabel.text = @"背景颜色:";
    self.textBackgroundColorLabel.font = FONT_SMALL;
    self.textBackgroundColorLabel.textAlignment = NSTextAlignmentCenter;
    
    self.textBackgroundColorInput = [[UITextField alloc] init];
    //[self.contentView addSubview:self.textBackgroundColorInput];
    self.textBackgroundColorInput.font = FONT_SMALL;
    self.textBackgroundColorInput.layer.borderWidth = 1.0;
    self.textBackgroundColorInput.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self updateSampleText];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    FrameLayout *f = [[FrameLayout alloc] initWithRootView:self.contentView];
    [f frameLayoutHerizon:FRAMELAYOUT_NAME_MAIN
                  toViews:@[
                            [FrameLayoutView viewWithName:@"_sampleText" percentage:0.36 edge:UIEdgeInsetsMake(10, 16, 10, 16)],
                            [FrameLayoutView viewWithName:@"fontSizeLinePadding" value:20 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"fontSize" value:40 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"paddingTextColorLine" value:36 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"textColorLine" value:28 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"switchLine1Padding" value:20 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"switchLine1" value:36 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"switchLine2Padding" value:20 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"switchLine2" value:36 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"bottomBlank" percentage:0.4 edge:UIEdgeInsetsZero],
                            ]
     ];
    
    [f frameLayoutVertical:@"fontSize"
                   toViews:@[
                             [FrameLayoutView viewWithName:@"fontSizeValue" percentage:0.6 edge:UIEdgeInsetsZero],
                             [FrameLayoutView viewWithName:@"fontSizeUseDefault" percentage:0.4 edge:UIEdgeInsetsZero],
                            ]];
    
    [f frameLayoutHerizon:@"fontSizeValue"
                  toViews:@[
                             [FrameLayoutView viewWithName:@"fontSizeLabel" value:20 edge:UIEdgeInsetsZero],
                             [FrameLayoutView viewWithName:@"_fontSizeSlider" value:20 edge:UIEdgeInsetsZero],
                            ]];
    
    [f frameLayoutVertical:@"fontSizeUseDefault"
                  toViews:@[
                            [FrameLayoutView viewWithName:@"_fontSizeUseDefaultLabel" value:80 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_fontSizeUseDefaultSwitch" value:1 edge:UIEdgeInsetsZero],
                            ]];
    
    
    [f      frameLayout:@"fontSizeLabel"
             toVertical:@[@"_fontSizeNameLabel", @"fontSizePadding", @"_fontSizeValueLabel"]
        withPercentages:@[@0.5, @0.0, @0.5]];
    
    [f      frameLayout:@"textColorLine"
             toVertical:@[@"_textColorLabel", @"_textColorInput", @"_textColorButton"]
        withPercentages:@[@(.20), @(.40), @(.20)]];
    
    [f      frameLayout:@"switchLine1"
             toVertical:@[@"_italicLable", @"_italicSwitch", @"switchLine1Padding", @"_underlineLable", @"_underlineSwitch"]
        withPercentages:@[@0.12, @0.16, @0.22, @0.12, @0.16]];
    
    [f      frameLayout:@"switchLine2"
             toVertical:@[@"_borderLable", @"_borderSwitch", @"switchLine2Padding", @"_boldLable", @"_boldSwitch"]
        withPercentages:@[@0.12, @0.16, @0.22, @0.12, @0.16]];
    
    [self memberViewSetFrameWith:[f nameAndFrames]];
}


#pragma mark - slider and switch
- (void)sliderChanged:(UISlider*)slider
{
    CGFloat value        = slider.value;
    value = roundf(value);
    NSInteger valuex = value;
    
    NSString *fontSizeString = [NSString stringWithFormat:@"%zdpx", valuex];
    if([fontSizeString isEqualToString:self.fontSizeValueLabel.text]) {
        
    }
    else {
        self.fontSizeValueLabel.text = fontSizeString;
        self.sampleNoteParagraph.styleDictionay[@"font-size"] = fontSizeString;
        /*#  sn .*/
        self.sampleText.attributedText = [self.sampleNoteParagraph attributedTextGeneratedOnSn:0 onMode:NOTEPARAGRAPH_MODE_DISPLAY];
        if(self.fontSizeUseDefaultSwitch.on) {
            self.fontSizeUseDefaultSwitch.on = NO;
        }
    }
    
    return ;
    
    
#if 0 //使用动画的方式让游标滑动到整数位置.下面的方法不能实现.
    NSString *string     = [NSString stringWithFormat:@"%.2f", value];
    
    if(!self.fontNumbers) {
        self.fontNumbers = [[NSMutableArray alloc] init];
    }
    [self.fontNumbers addObject:[NSNumber numberWithFloat:value]];
    NSLog(@"string : %@, %f", string, value);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat valueLast = [[self.fontNumbers lastObject] floatValue];
        if(valueLast == value) {
            NSLog(@"%f", value);
        }
        
        [UIView animateWithDuration:0.6 animations:^{
            slider.value = 10;
        }];
        
        
    });
#endif
}


- (void)switchValueChangeFontSizeUseDefault
{
    NSLog(@"font size use default : %zd", self.fontSizeUseDefaultSwitch.on);
    CGFloat pxSize = 0;
    if(self.fontSizeUseDefaultSwitch.on) {
        self.fontSizeEdit = self.sampleNoteParagraph.styleDictionay[@"font-size"];
        self.sampleNoteParagraph.styleDictionay[@"font-size"] = nil;
        pxSize = self.sampleNoteParagraph.isTitle? 18 : 16;
        NSString *fontValue;
        NSInteger fontSize = 16;
        if(self.sampleNoteParagraph.isTitle
           && nil != (fontValue = [[AppConfig sharedAppConfig] configSettingGet:@"NoteTitleFontSizeDefault"])
           && (fontSize = [fontValue integerValue]) >= 6
           && fontSize <= 100
           ) {
            pxSize = fontSize;
        }
        else if(!self.sampleNoteParagraph.isTitle
           && nil != (fontValue = [[AppConfig sharedAppConfig] configSettingGet:@"NoteParagraphFontSizeDefault"])
           && (fontSize = [fontValue integerValue]) >= 6
           && fontSize <= 100
           ) {
            pxSize = fontSize;
        }
        
        self.fontSizeValueLabel.text = [NSString stringWithFormat:@"%zdpx", (NSInteger)pxSize];
        self.fontSizeSlider.value = pxSize;
    }
    else {
        NSLog(@"- %@", self.fontSizeEdit);
        if(self.fontSizeEdit
            && [self.fontSizeEdit hasSuffix:@"px"]
            && (pxSize = [self.fontSizeEdit floatValue]) >= self.fontSizeSlider.minimumValue
            && pxSize <= self.fontSizeSlider.maximumValue) {

        }
        else {
            pxSize = self.sampleNoteParagraph.isTitle? 18 : 16;
            NSString *fontValue;
            NSInteger fontSize = 16;
            if(self.sampleNoteParagraph.isTitle
               && nil != (fontValue = [[AppConfig sharedAppConfig] configSettingGet:@"NoteTitleFontSizeDefault"])
               && (fontSize = [fontValue integerValue]) >= 6
               && fontSize <= 100
               ) {
                pxSize = fontSize;
            }
            else if(!self.sampleNoteParagraph.isTitle
                    && nil != (fontValue = [[AppConfig sharedAppConfig] configSettingGet:@"NoteParagraphFontSizeDefault"])
                    && (fontSize = [fontValue integerValue]) >= 6
                    && fontSize <= 100
                    ) {
                pxSize = fontSize;
            }
        }
        self.fontSizeValueLabel.text = [NSString stringWithFormat:@"%zdpx", (NSInteger)pxSize];
        self.fontSizeSlider.value = pxSize;
        self.sampleNoteParagraph.styleDictionay[@"font-size"] = [NSString stringWithFormat:@"%zdpx", (NSInteger)pxSize];
    }
    [self updateSampleText];
}


- (void)switchValueChangeItalic
{
    NSLog(@"Italic : %d", self.italicSwitch.on);
    if(self.italicSwitch.on) {
        self.sampleNoteParagraph.styleDictionay[@"font-style"] = @"italic";
    }
    else {
        [self.sampleNoteParagraph.styleDictionay removeObjectForKey:@"font-style"];
    }
    
    [self updateSampleText];
}


- (void)switchValueChangeUnderline
{
    NSLog(@"Underline : %d", self.underlineSwitch.on);
    
    if(self.underlineSwitch.on) {
        self.sampleNoteParagraph.styleDictionay[@"text-decoration"] = @"underline";
    }
    else {
        [self.sampleNoteParagraph.styleDictionay removeObjectForKey:@"text-decoration"];
    }
    
    [self updateSampleText];
}


- (void)switchValueChangeBorder
{
    NSLog(@"Border : %d", self.borderSwitch.on);
    
    if(self.borderSwitch.on) {
        self.sampleNoteParagraph.styleDictionay[@"border"] = @"1px solid #000";
    }
    else {
        [self.sampleNoteParagraph.styleDictionay removeObjectForKey:@"border"];
    }
    
    [self updateSampleText];
}


- (void)switchValueChangeBold
{
    NSLog(@"Bold : %d", self.boldSwitch.on);
    
    if(self.boldSwitch.on) {
        self.sampleNoteParagraph.styleDictionay[@"font-weight"] = @"bold";
    }
    else {
        [self.sampleNoteParagraph.styleDictionay removeObjectForKey:@"font-weight"];
    }
    
    [self updateSampleText];
}


#pragma mark - action
- (void)actionFinishCustomise
{
    NSLog(@"finishCustomise. styple : %@", self.sampleNoteParagraph.styleDictionay);
    if(self.finishHandle) {
        self.finishHandle([NSDictionary dictionaryWithDictionary:self.sampleNoteParagraph.styleDictionay]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)openTextColorSelector
{
    LOG_POSTION
    if(self.textColorSelector) {
        NSLog(@"textColorSelector already open");
        return ;
    }
    
    CGFloat width = VIEW_WIDTH * 0.8;
    CGRect frameInit = CGRectMake(VIEW_WIDTH - 0, 0, width, VIEW_HEIGHT);
    CGRect frameShow = CGRectMake(VIEW_WIDTH - width, 0, width, VIEW_HEIGHT);
    
    __weak typeof(self) _self = self;
    self.textColorSelector = [[ColorSelector alloc] initWithFrame:frameInit
                                                       cellHeight:36.0
                                                     colorPresets:@[]
                                                      isTextColor:YES
                                                     selectHandle:^(NSString* selectedColorString, NSString *selectedColorText) {
                                                         [_self selectedColorString:selectedColorString andColorText:selectedColorText];
                                                     }];
    [self.contentView addSubview:self.textColorSelector];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.textColorSelector.frame = frameShow;
    } completion:^(BOOL finished) {
        
    }];
}


- (void)selectedColorString:(NSString*)selectedColorString andColorText:(NSString *)selectedColorText
{
    NSLog(@"selectedTextColorString : %@, %@", selectedColorText, selectedColorString);
    
    //关闭颜色选择器.
    CGFloat width = VIEW_WIDTH * 0.8;
    CGRect frameRemove = CGRectMake(VIEW_WIDTH - 0, 0, width, VIEW_HEIGHT);
    
    [UIView animateWithDuration:1.0 animations:^{
        self.textColorSelector.frame = frameRemove;
    } completion:^(BOOL finished) {
        [self.textColorSelector removeFromSuperview];
        self.textColorSelector = nil;
    }];
    
    self.textColorInput.text = [NSString stringWithFormat:@"%@(%@)", selectedColorString, selectedColorText];

    //重新刷下sample.
    self.sampleNoteParagraph.styleDictionay[@"color"] = selectedColorString;
    
    [self updateSampleText];
}


- (void)updateSampleText
{
    NSLog(@"sampleNoteParagraph : %@", self.sampleNoteParagraph);
    NSLog(@"styple : %@", self.sampleNoteParagraph.styleDictionay);
    self.sampleText.attributedText = [self sampleNoteParagraphAttrbutedString];
    if([self.sampleNoteParagraph.styleDictionay[@"border"] isEqualToString:@"1px solid #000"]) {
        self.sampleText.layer.borderColor = [self.sampleNoteParagraph textColor].CGColor;
        self.sampleText.layer.borderWidth = 1.0f;
    }
    else {
        self.sampleText.layer.borderWidth = 0.0f;
    }
}


//noteParagraph内容显示到Lable和Text的NSMutableAttributedString.
- (NSMutableAttributedString*)sampleNoteParagraphAttrbutedString
{
    NoteParagraphModel *noteParagraph = self.sampleNoteParagraph;
    if(noteParagraph.content.length == 0) {
        noteParagraph.content = @"显示示例文字";
    }
    return [noteParagraph attributedTextGeneratedOnSn:self.sn onMode:NOTEPARAGRAPH_MODE_DISPLAY];
}


- (void)keyboardHide:(id)sender
{
    //关闭所有编辑.
    [self.view endEditing:YES];
    
    //针对控件关闭.
    //[self.textColorInput resignFirstResponder];
}


#pragma mark - 键盘显示事件
- (void) keyboardWillShow:(NSNotification *)notification {
    LOG_POSTION
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRect frameContentView = self.contentView.frame;
//    frameContentView.origin.y -= kbHeight;
    
    CGRect frameTextColorInput = self.textColorInput.frame;
    CGFloat bottomSpace = VIEW_HEIGHT - frameTextColorInput.origin.y - frameTextColorInput.size.height;
    bottomSpace -= 10;
    if(bottomSpace < kbHeight) {
        frameContentView.origin.y -= (kbHeight - bottomSpace);
    }
    else {
        frameContentView.origin.y -= 0;
    }
    
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //将视图上移计算好的偏移
    [UIView animateWithDuration:duration animations:^{
        self.contentView.frame = frameContentView;
    }];
    LOG_POSTION
}


///键盘消失事件
- (void) keyboardWillHide:(NSNotification *)notification {
    //获取键盘高度，在不同设备上，以及中英文下是不同的
//    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    // 键盘动画时间
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect frameContentView = self.contentView.frame;
//    frameContentView.origin.y += kbHeight;
    frameContentView.origin.y = 0;
    
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
         self.contentView.frame = frameContentView;
    }];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

