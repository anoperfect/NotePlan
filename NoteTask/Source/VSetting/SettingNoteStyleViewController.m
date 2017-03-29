//
//  SettingNoteStyleViewController.m
//  NoteTask
//
//  Created by Ben on 16/12/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "SettingNoteStyleViewController.h"






@interface SettingNoteStyleViewController ()

@property (nonatomic, strong) UILabel   *titleLabel;
@property (nonatomic, strong) UISlider  *titleFontSizeSlider;
@property (nonatomic, strong) UILabel   *titleFontSizeNameLabel;
@property (nonatomic, strong) UILabel   *titleFontSizeValueLabel;


@property (nonatomic, strong) UILabel   *paragraphLabel;
@property (nonatomic, strong) UISlider  *paragraphFontSizeSlider;
@property (nonatomic, strong) UILabel   *paragraphFontSizeNameLabel;
@property (nonatomic, strong) UILabel   *paragraphFontSizeValueLabel;


@end






@implementation SettingNoteStyleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel = [[UILabel alloc] init];
    [self addSubview:self.titleLabel];
    self.titleLabel.text = @"标题";
    
    self.titleFontSizeSlider = [[UISlider alloc] init];
    [self addSubview:self.titleFontSizeSlider];
    self.titleFontSizeSlider.minimumValue = 8.0;
    self.titleFontSizeSlider.maximumValue = 36.0;
    self.titleFontSizeSlider.minimumTrackTintColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    self.titleFontSizeSlider.maximumTrackTintColor = [[UIColor grayColor] colorWithAlphaComponent:0.05f];
    [self.titleFontSizeSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [self.titleFontSizeSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateHighlighted];
    [self.titleFontSizeSlider addTarget:self action:@selector(titleSliderChanged:) forControlEvents:UIControlEventValueChanged];
    NSString *titleFontString = [[AppConfig sharedAppConfig] configSettingGet:@"NoteTitleFontSizeDefault"];
    CGFloat titlePtSize = 18.0;
    if([titleFontString hasSuffix:@"px"] && (titlePtSize = [titleFontString floatValue]) >= 1.0 && titlePtSize < 100.0) {
        
    }
    self.titleFontSizeSlider.value = titlePtSize;
    
    self.titleFontSizeNameLabel = [[UILabel alloc] init];
    [self addSubview:self.titleFontSizeNameLabel];
    self.titleFontSizeNameLabel.text = @"默认字体大小";
    self.titleFontSizeNameLabel.textAlignment = NSTextAlignmentCenter;
    self.titleFontSizeNameLabel.font = FONT_SMALL;
    
    self.titleFontSizeValueLabel = [[UILabel alloc] init];
    [self addSubview:self.titleFontSizeValueLabel];
    self.titleFontSizeValueLabel.text = @"8px";
    self.titleFontSizeValueLabel.textAlignment = NSTextAlignmentCenter;
    self.titleFontSizeValueLabel.font = FONT_SMALL;
    NSInteger titlePtSizeInt = titlePtSize;
    self.titleFontSizeValueLabel.text = [NSString stringWithFormat:@"%zdpx", titlePtSizeInt];
    
    
    
    
    
    self.paragraphLabel = [[UILabel alloc] init];
    [self addSubview:self.paragraphLabel];
    self.paragraphLabel.text = @"正文";
    
    self.paragraphFontSizeSlider = [[UISlider alloc] init];
    [self addSubview:self.paragraphFontSizeSlider];
    self.paragraphFontSizeSlider.minimumValue = 8.0;
    self.paragraphFontSizeSlider.maximumValue = 36.0;
    self.paragraphFontSizeSlider.minimumTrackTintColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    self.paragraphFontSizeSlider.maximumTrackTintColor = [[UIColor grayColor] colorWithAlphaComponent:0.05f];
    [self.paragraphFontSizeSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [self.paragraphFontSizeSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateHighlighted];
    [self.paragraphFontSizeSlider addTarget:self action:@selector(paragraphSliderChanged:) forControlEvents:UIControlEventValueChanged];
    NSString *paragraphFontString = [[AppConfig sharedAppConfig] configSettingGet:@"NoteParagraphFontSizeDefault"];
    CGFloat paragraphFtSize = 16.0;
    if([paragraphFontString hasSuffix:@"px"] && (paragraphFtSize = [paragraphFontString floatValue]) >= 1.0 && paragraphFtSize < 100.0) {
        
    }
    self.paragraphFontSizeSlider.value = paragraphFtSize;
    
    self.paragraphFontSizeNameLabel = [[UILabel alloc] init];
    [self addSubview:self.paragraphFontSizeNameLabel];
    self.paragraphFontSizeNameLabel.text = @"默认字体大小";
    self.paragraphFontSizeNameLabel.textAlignment = NSTextAlignmentCenter;
    self.paragraphFontSizeNameLabel.font = FONT_SMALL;
    
    self.paragraphFontSizeValueLabel = [[UILabel alloc] init];
    [self addSubview:self.paragraphFontSizeValueLabel];
    self.paragraphFontSizeValueLabel.text = @"8px";
    self.paragraphFontSizeValueLabel.textAlignment = NSTextAlignmentCenter;
    self.paragraphFontSizeValueLabel.font = FONT_SMALL;
    self.paragraphFontSizeValueLabel.text = [NSString stringWithFormat:@"%zdpx", (NSInteger)paragraphFtSize];
    
    
    [self navigationItemRightInit];
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIEdgeInsets edge = UIEdgeInsetsMake(0, 20, 0, 20);
    FrameLayout *f = [[FrameLayout alloc] initWithRootView:self.contentView];
    [f frameLayoutHerizon:FRAMELAYOUT_NAME_MAIN
                  toViews:@[

                            [FrameLayoutView viewWithName:@"titleLabelPadding" value:20 edge:edge],
                            [FrameLayoutView viewWithName:@"_titleLabel" value:36 edge:edge],
                            [FrameLayoutView viewWithName:@"titleFontSizeLine" value:20 edge:edge],
                            [FrameLayoutView viewWithName:@"_titleFontSizeSlider" value:20 edge:edge],
                            
                            
                            [FrameLayoutView viewWithName:@"paragraphLabelPadding" value:60 edge:edge],
                            [FrameLayoutView viewWithName:@"_paragraphLabel" value:36 edge:edge],
                            [FrameLayoutView viewWithName:@"paragraphFontSizeLine" value:20 edge:edge],
                            [FrameLayoutView viewWithName:@"_paragraphFontSizeSlider" value:20 edge:edge],

                            ]
     ];
    
    [f frameLayoutVertical:@"titleFontSizeLine"
                   toViews:@[
                             [FrameLayoutView viewWithName:@"_titleFontSizeNameLabel" percentage:0.36],
                             [FrameLayoutView viewWithName:@"titleFontSizePadding" percentage:0.46],
                             [FrameLayoutView viewWithName:@"_titleFontSizeValueLabel" percentage:0.16],
                            ]];
    
    [f frameLayoutVertical:@"paragraphFontSizeLine"
                   toViews:@[
                             [FrameLayoutView viewWithName:@"_paragraphFontSizeNameLabel" percentage:0.36],
                             [FrameLayoutView viewWithName:@"paragraphFontSizePadding" percentage:0.46],
                             [FrameLayoutView viewWithName:@"_paragraphFontSizeValueLabel" percentage:0.16],
                            ]];
    
    [self memberViewSetFrameWith:[f nameAndFrames]];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"设置-笔记";
//    [self navigationItemRightInit];
}


- (void)navigationItemRightInit
{
    PushButtonData *buttonDataChecked = [[PushButtonData alloc] init];
    buttonDataChecked.actionString = @"settingChecked";
    buttonDataChecked.imageName = @"SettingChecked";
    PushButton *buttonChecked = [[PushButton alloc] init];
    buttonChecked.frame = CGRectMake(0, 0, 44, 44);
    buttonChecked.actionData = buttonDataChecked;
    buttonChecked.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [buttonChecked setImage:[UIImage imageNamed:buttonDataChecked.imageName] forState:UIControlStateNormal];
    [buttonChecked addTarget:self action:@selector(settingChecked) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemChecked = [[UIBarButtonItem alloc] initWithCustomView:buttonChecked];
    
    NSLog(@"%@", [UIImage imageNamed:buttonDataChecked.imageName]);

    
    self.navigationItem.rightBarButtonItems = @[
                                                itemChecked,
                                                ];
    
    
    
    
}


- (void)titleSliderChanged:(UISlider *)slider {
    
    // 更新UI
    CGFloat value        = slider.value;
    NSLog(@"value : %f", value);
    
    self.titleFontSizeValueLabel.text = [NSString stringWithFormat:@"%zdpx", (NSInteger)value];
}


- (void)paragraphSliderChanged:(UISlider *)slider
{
    // 更新UI
    CGFloat value        = slider.value;
    NSLog(@"value : %f", value);
    
    self.paragraphFontSizeValueLabel.text = [NSString stringWithFormat:@"%zdpx", (NSInteger)value];
}


- (void)settingChecked
{
    NSLog(@"%@", self.titleFontSizeValueLabel.text);
    NSLog(@"%@", self.paragraphFontSizeValueLabel.text);
    
    [[AppConfig sharedAppConfig] configSettingSetKey:@"NoteTitleFontSizeDefault" toValue:self.titleFontSizeValueLabel.text replace:YES];
    [[AppConfig sharedAppConfig] configSettingSetKey:@"NoteParagraphFontSizeDefault" toValue:self.paragraphFontSizeValueLabel.text replace:YES];
    
    [self showIndicationText:@"设置已保存."];
}



@end
