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
    [self.titleFontSizeSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    NSString *titleFontString = [[AppConfig sharedAppConfig] configSettingGet:@"TitleFontSizeDefault"];
    CGFloat titlePtSize = 18.0;
    if([titleFontString hasSuffix:@"px"] && (titlePtSize = [titleFontString floatValue]) >= 1.0 && titlePtSize < 100.0) {
        
    }
    self.titleFontSizeSlider.value = titlePtSize;
    
    self.titleFontSizeNameLabel = [[UILabel alloc] init];
    [self addSubview:self.titleFontSizeNameLabel];
    self.titleFontSizeNameLabel.text = @"字体-大小";
    self.titleFontSizeNameLabel.textAlignment = NSTextAlignmentCenter;
    self.titleFontSizeNameLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    
    self.titleFontSizeValueLabel = [[UILabel alloc] init];
    [self addSubview:self.titleFontSizeValueLabel];
    self.titleFontSizeValueLabel.text = @"8px";
    self.titleFontSizeValueLabel.textAlignment = NSTextAlignmentCenter;
    self.titleFontSizeValueLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
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
    [self.paragraphFontSizeSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    NSString *paragraphFontString = [[AppConfig sharedAppConfig] configSettingGet:@"ParagraphFontSizeDefault"];
    CGFloat paragraphFtSize = 16.0;
    if([paragraphFontString hasSuffix:@"px"] && (paragraphFtSize = [paragraphFontString floatValue]) >= 1.0 && paragraphFtSize < 100.0) {
        
    }
    self.paragraphFontSizeSlider.value = paragraphFtSize;
    
    self.paragraphFontSizeNameLabel = [[UILabel alloc] init];
    [self addSubview:self.paragraphFontSizeNameLabel];
    self.paragraphFontSizeNameLabel.text = @"字体-大小";
    self.paragraphFontSizeNameLabel.textAlignment = NSTextAlignmentCenter;
    self.paragraphFontSizeNameLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    
    self.paragraphFontSizeValueLabel = [[UILabel alloc] init];
    [self addSubview:self.paragraphFontSizeValueLabel];
    self.paragraphFontSizeValueLabel.text = @"8px";
    self.paragraphFontSizeValueLabel.textAlignment = NSTextAlignmentCenter;
    self.paragraphFontSizeValueLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.paragraphFontSizeValueLabel.text = [NSString stringWithFormat:@"%zdpx", (NSInteger)paragraphFtSize];
    
    
    
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
                            [FrameLayoutView viewWithName:@"titleFontSizeLine" value:36 edge:edge],
                            [FrameLayoutView viewWithName:@"_titleFontSizeSlider" value:36 edge:edge],

                            ]
     ];
    
    [f      frameLayout:@"titleFontSizeLine"
             toVertical:@[@"_titleFontSizeNameLabel", @"titleFontSizePadding", @"_titleFontSizeValueLabel"]
        withPercentages:@[@0.24, @0.64, @0.12]];
    
    [self memberViewSetFrameWith:[f nameAndFrames]];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"设置-笔记";
}


- (void)sliderChanged:(UISlider *)slider {
    
    // 更新UI
    CGFloat value        = slider.value;
    NSLog(@"value : %f", value);
    
    self.titleFontSizeValueLabel.text = [NSString stringWithFormat:@"%zdpx", (NSInteger)value];
//    NSString *string     = [NSString stringWithFormat:@"%.2f", value];
//    self.labelValue.text = string;
//    
//    // 当前的value值
//    _currentValue        = value;
//    
//    if(self.handle) {
//        NSLog(@"%.2f", value);
//        self.handle(value);
//    }
}

@end
