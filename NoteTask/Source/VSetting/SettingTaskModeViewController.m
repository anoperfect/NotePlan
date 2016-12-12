//
//  SettingTaskModeViewController.m
//  NoteTask
//
//  Created by Ben on 16/12/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "SettingTaskModeViewController.h"
#import "TaskModel.h"
#import "TaskInfoManager.h"





@interface SettingTaskModeViewController ()

@property (nonatomic, strong) UILabel *titleDefaultMode;
@property (nonatomic, strong) UISegmentedControl *selectorMode;
@property (nonatomic, strong) NSDictionary *modeIndexAndNames;
@property (nonatomic, strong) NSArray *modeNames;


@end


@implementation SettingTaskModeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self memberObjectCreate];
    
    self.titleDefaultMode.text = @"默认显示模式";
    self.modeIndexAndNames = @{
                               @(TASKINFO_MODE_ARRANGE):@"安排",
                               @(TASKINFO_MODE_DAY):@"日期",
                               @(TASKINFO_MODE_LIST):@"列表"
                               };
    self.modeNames = self.modeIndexAndNames.allValues;
    
    for(NSInteger idx = 0; idx < self.modeNames.count; idx ++) {
        [self.selectorMode insertSegmentWithTitle:self.modeNames[idx] atIndex:idx animated:YES];
    }
    [self.selectorMode addTarget:self action:@selector(actionModeTypeSelector:) forControlEvents:UIControlEventValueChanged];
    
    NSString *modeString = [[AppConfig sharedAppConfig] configSettingGet:@"TaskModeDefault"];
    NSInteger idx = [modeString integerValue];
    if(modeString.length > 0 && NSNotFound != [self.modeIndexAndNames.allKeys indexOfObject:@(idx)]) {
        self.selectorMode.selectedSegmentIndex = idx ;
    }
    
    [self addSubview:self.titleDefaultMode];
    [self addSubview:self.selectorMode];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIEdgeInsets edge = UIEdgeInsetsMake(0, 20, 0, 20);
    FrameLayout *f = [[FrameLayout alloc] initWithRootView:self.contentView];
    [f frameLayoutHerizon:FRAMELAYOUT_NAME_MAIN
                  toViews:@[
                            
                            [FrameLayoutView viewWithName:@"titleDefaultModePadding" value:20 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_titleDefaultMode" value:36 edge:edge],
                            [FrameLayoutView viewWithName:@"_selectorMode" value:36 edge:edge],
                            
                            ]
     ];
    
    [self memberViewSetFrameWith:[f nameAndFrames]];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"设置-任务";
    
    
}


- (void)actionModeTypeSelector:(UISegmentedControl*)segmentedControl
{
    NSInteger idx = segmentedControl.selectedSegmentIndex;
    NSLog(@"idx : %zd, name : %@", idx, self.modeNames[idx]);
    
    
    
    
}


@end
