//
//  TaskEditViewController.m
//  NoteTask
//
//  Created by Ben on 16/11/27.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskEditViewController.h"
#import "TaskCell.h"
#import "TaskCalendar.h"
static NSString *kStringStepCreateContent = @"1.任务内容";
static NSString *kStringStepScheduleDay = @"2.执行日期";



@interface TaskEditViewController () <UINavigationBarDelegate, UINavigationControllerDelegate>
{
    CGFloat _heightDetailScheduleDayLabel;
    CGFloat _heightDayButtonA;
    CGFloat _heightDayButtonB;
    CGFloat _heightDaysInMutilMode;
}

@property (nonatomic, strong) TaskInfo *taskinfo;



@property (nonatomic, strong) UILabel       *createContentLabel;
@property (nonatomic, strong) UIButton      *createContentButton;
@property (nonatomic, strong) UITextView    *createContentInputView;


@property (nonatomic, strong) UILabel               *createScheduleDayLabel;
@property (nonatomic, strong) UISegmentedControl *daysTypeSelector;
@property (nonatomic, strong) NSArray<NSString*> *daysTypes;

@property (nonatomic, strong) UILabel               *detailScheduleDayLabel;
@property (nonatomic, strong) UILabel               *dayButtonA;
@property (nonatomic, strong) UILabel               *dayButtonB;
@property (nonatomic, strong) UILabel               *daysInMutilMode;


@property (nonatomic, strong) NSString *daysType;

@property (nonatomic, strong) NSString              *dayString; //单天模式.
@property (nonatomic, strong) NSString              *dayStringFrom;//连续模式开始日期.
@property (nonatomic, strong) NSString              *dayStringTo;//连续模式结束日期.
@property (nonatomic, strong) NSArray<NSString*>    *dayStrings;//多天模式记录所有日期.



@property (nonatomic, assign) CGFloat optumizeHeightcreateContentInputView;

@property (nonatomic, assign) BOOL added; //标记是否已经添加到数据库.
@property (nonatomic, assign) BOOL isCreate;

@end

@implementation TaskEditViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.taskinfo = [TaskInfo taskinfo];
        self.taskinfo.sn = [NSString randomStringWithLength:7 andType:0];
        self.isCreate = YES;
        NSLog(@"%@", self.taskinfo);
    }
    return self;
}


- (instancetype)initWithTaskInfo:(TaskInfo*)taskinfo
{
    self = [super init];
    if (self) {
        self.taskinfo = taskinfo;
        NSLog(@"%@", self.taskinfo);
        self.added = YES;
    }
    return self;
}


- (instancetype)initWithEditTaskInfo:(TaskInfo*)taskinfo
{
    self = [super init];
    if (self) {
        self.taskinfo = taskinfo;
    }
    return self;
}


- (void)viewDidLoad {
    self.contentViewScrolled = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self memberObjectCreate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.createContentInputView = [[UITextView alloc] init];
        self.createContentInputView.font = FONT_SYSTEM;
        self.createContentInputView.layer.borderWidth = 1;
        self.createContentInputView.layer.borderColor = [UIColor colorWithName:@"TaskBorderCommon"].CGColor;
        if(self.taskinfo.content.length > 0) {
            self.createContentInputView.text = self.taskinfo.content;
        }
        [self addSubview:self.createContentInputView];
        [self viewWillLayoutSubviews];
    });
    
    
    UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:20];
    CGFloat indent = 10.0;
    UIColor *textColor = [UIColor colorWithName:@"TaskSectionHeaderText"];
    
    self.createContentLabel.attributedText = [NSString attributedStringWith:kStringStepCreateContent font:font indent:indent textColor:textColor];
    self.createScheduleDayLabel.attributedText = [NSString attributedStringWith:kStringStepScheduleDay font:font indent:indent textColor:textColor];
    
    self.daysInMutilMode.numberOfLines = 0;
    self.daysInMutilMode.font = [UIFont fontWithName:@"Terminus" size:36];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionOpenCalendarMuiltMode)];
    tap.numberOfTapsRequired = 1;
    [self.daysInMutilMode addGestureRecognizer:tap];
    self.daysInMutilMode.userInteractionEnabled = YES;
    
    NSMutableAttributedString *attributedString = [NSString attributedStringWith:@"单天 : \n" font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskTextCommon"]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"只给任务设置一个执行日期.\n" font:FONT_SMALL indent:36 textColor:[UIColor colorWithName:@"TaskTextCommon"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"\n" font:[UIFont systemFontOfSize:6] indent:36 textColor:[UIColor colorWithName:@"TaskTextCommon"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"连续 : \n" font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskTextCommon"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"设定任务日期起始.\n任务执行时间范围为此日期范围.\n" font:FONT_SMALL indent:36 textColor:[UIColor colorWithName:@"TaskTextCommon"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"\n" font:[UIFont systemFontOfSize:6] indent:36 textColor:[UIColor colorWithName:@"TaskTextCommon"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"多天 : \n" font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskTextCommon"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"选择多个日期执行此任务.\n" font:FONT_SMALL indent:36 textColor:[UIColor colorWithName:@"TaskTextCommon"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"\n" font:[UIFont systemFontOfSize:6] indent:36 textColor:[UIColor colorWithName:@"TaskTextCommon"]]];
    self.detailScheduleDayLabel.attributedText = attributedString;
    self.detailScheduleDayLabel.numberOfLines = 0;
    
    self.dayButtonA.text     = @"A";
    self.dayButtonA.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tapA = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionClickDayButtonA:)];
    [self.dayButtonA addGestureRecognizer:tapA];
    self.dayButtonA.userInteractionEnabled = YES;
    
    self.dayButtonB.text     = @"B";
    self.dayButtonB.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tapB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionClickDayButtonB:)];
    [self.dayButtonB addGestureRecognizer:tapB];
    self.dayButtonB.userInteractionEnabled = YES;
    
    self.daysInMutilMode.text           = @"qwertyuiop";
    
    self.daysTypes = [TaskInfo scheduleStrings];
    for(NSInteger idx = 0; idx < self.daysTypes.count; idx ++) {
        [self.daysTypeSelector insertSegmentWithTitle:self.daysTypes[idx] atIndex:idx animated:YES];
    }
    [self.daysTypeSelector addTarget:self action:@selector(actionDaysTypeSelector:) forControlEvents:UIControlEventValueChanged];
    
    [self addObserver:self forKeyPath:@"daysType" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld context:nil];
    
    if(self.taskinfo.scheduleType != TaskInfoScheduleTypeNone) {
        NSString *type = [TaskInfo scheduleStringWithType:self.taskinfo.scheduleType];
        NSInteger idx = [self.daysTypes indexOfObject:type];
        if(idx != NSNotFound && idx < self.daysTypes.count) {
            self.daysTypeSelector.selectedSegmentIndex = idx;
        }
        
        if(self.taskinfo.scheduleType == TaskInfoScheduleTypeDay) {
            self.dayString = self.taskinfo.dayString;
        }
        else if(self.taskinfo.scheduleType == TaskInfoScheduleTypeContinues) {
            self.dayStringFrom = self.taskinfo.dayStringFrom;
            self.dayStringTo = self.taskinfo.dayStringTo;
        }
        else if(self.taskinfo.scheduleType == TaskInfoScheduleTypeDays) {
            self.dayStrings = [self.taskinfo.dayStrings componentsSeparatedByString:@","];
        }
        
        self.daysType = type;
    }
    
    [self addSubview:self.createContentLabel];
    [self addSubview:self.createScheduleDayLabel];
    [self addSubview:self.daysTypeSelector];
    [self addSubview:self.detailScheduleDayLabel];
    [self addSubview:self.dayButtonA];
    [self addSubview:self.dayButtonB];
    [self addSubview:self.daysInMutilMode];
}


- (void)viewWillLayoutSubviews
{
    LOG_POSTION
    [super viewWillLayoutSubviews];
    
    [self updateDaysSelectorText];
    
    UIScrollView *scrollView = (UIScrollView*)self.contentView;
    if([scrollView isKindOfClass:[UIScrollView class]]) {
        scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 1000);
    }
    
    if(_optumizeHeightcreateContentInputView == 0.0) {
        _optumizeHeightcreateContentInputView = 100;
    }
    
    _heightDetailScheduleDayLabel = _heightDayButtonA = _heightDayButtonB = _heightDaysInMutilMode = 0;
    if(self.daysType.length == 0) {
        _heightDetailScheduleDayLabel = 136;
    }
    else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeDay) {
        _heightDayButtonA = 36;
    }
    else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeDays) {
        _heightDaysInMutilMode = 100;
        CGSize sizeFit = [self.daysInMutilMode sizeThatFits:CGSizeMake(VIEW_WIDTH, 100)];
        if(sizeFit.height > _heightDaysInMutilMode) {
            _heightDaysInMutilMode = sizeFit.height;
        }
    }
    else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
        _heightDayButtonA = _heightDayButtonB = 36;
    }
    
    FrameLayout *f = [[FrameLayout alloc] initWithRootView:self.contentView];
    [f frameLayoutHerizon:FRAMELAYOUT_NAME_MAIN
                  toViews:@[
                            [FrameLayoutView viewWithName:@"_createContentLabel"     value:36 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"createContentLabelBottom" value:10 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_createContentInputView" value:self.optumizeHeightcreateContentInputView edge:UIEdgeInsetsMake(0, 36, 0, 36)],
                            [FrameLayoutView viewWithName:@"" value:10 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_createScheduleDayLabel" value:36 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"createScheduleDayLabelBottom" value:10 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_daysTypeSelector" value:36 edge:UIEdgeInsetsMake(2, 36, 2, 36)],
                            [FrameLayoutView viewWithName:@"daysTypeSelectorSeprator" value:20 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_detailScheduleDayLabel" value:_heightDetailScheduleDayLabel edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_dayButtonA" value:_heightDayButtonA edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_dayButtonB" value:_heightDayButtonB edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_daysInMutilMode" value:_heightDaysInMutilMode edge:UIEdgeInsetsZero],
                            ]
    ];
     
    [self memberViewSetFrameWith:[f nameAndFrames]];
    
    NSLog(@"%@", f);
    
    
    
    f = nil;
    
    

    
    
}


- (void)navigationItemRightInit
{
    PushButtonData *buttonDataCreate = [[PushButtonData alloc] init];
    buttonDataCreate.actionString = @"taskCreate";
    buttonDataCreate.imageName = @"finish";
    PushButton *buttonCreate = [[PushButton alloc] init];
    buttonCreate.frame = CGRectMake(0, 0, 44, 44);
    buttonCreate.actionData = buttonDataCreate;
    buttonCreate.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [buttonCreate setImage:[UIImage imageNamed:buttonDataCreate.imageName] forState:UIControlStateNormal];
    [buttonCreate addTarget:self action:@selector(actionCreate) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemCreate = [[UIBarButtonItem alloc] initWithCustomView:buttonCreate];
    
    self.navigationItem.rightBarButtonItems = @[
                                                itemCreate,
                                                ];

}


- (void)actionCreate
{
    NSDictionary *dict = [self.taskinfo toDictionary];
    NSLog(@"%@", dict);
    
    TaskInfo *taskinfo = [TaskInfo taskinfo];
    NSString *errorMessage = [self dataUpdateToTaskInfo:taskinfo];
    if(errorMessage.length > 0) {
        [self showIndicationText:errorMessage inTime:1];
        return ;
    }
    
    //新增的话, 直接使用所有内容.
    if(!self.added) {
        [self.taskinfo copyFrom:taskinfo];
        [[TaskInfoManager taskInfoManager] addTaskInfo:self.taskinfo];
        self.added = YES;
    }
    else {
        NSString *updateDetail = [self.taskinfo updateFrom:taskinfo];
        if(updateDetail.length > 0) {
            [[TaskInfoManager taskInfoManager] updateTaskInfo:self.taskinfo addUpdateDetail:updateDetail];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self showIndicationText:@"任务信息未修改" inTime:1];
        }
    }
    
    
}


//更新taskinfo. 如果有内容填写不充足的则返回错误信息.
- (NSString*)dataUpdateToTaskInfo:(TaskInfo*)taskinfo
{
    NSMutableString *errorMessage = [[NSMutableString alloc] init];
    taskinfo.content = self.createContentInputView.text;
    if(taskinfo.content.length == 0) {
        [errorMessage appendString:@"请设置任务内容.\n"];
        return [NSString stringWithString:errorMessage];
    }
    taskinfo.status = 0;
    taskinfo.committedAt = [NSString dateTimeStringNow];
    taskinfo.modifiedAt = taskinfo.committedAt;
    
    taskinfo.scheduleType =  [TaskInfo scheduleTypeFromString:self.daysType];
    if(taskinfo.scheduleType == TaskInfoScheduleTypeNone) {
        [errorMessage appendString:@"请设置执行日期类型,然后设置对应日期."];
        return [NSString stringWithString:errorMessage];
    }
    else if(taskinfo.scheduleType == TaskInfoScheduleTypeDay) {
        if([NSString dateStringIsValid:self.dayString]) {
            taskinfo.dayString = self.dayString;
        }
        else {
            [errorMessage appendString:@"请正确设置单天执行日期."];
            return [NSString stringWithString:errorMessage];
        }
    }
    else if(taskinfo.scheduleType == TaskInfoScheduleTypeContinues) {
        if([NSString dateStringIsValid:self.dayStringFrom]
           && [NSString dateStringIsValid:self.dayStringTo]
           && [self.dayStringFrom compare:self.dayStringTo] == NSOrderedAscending) {
            taskinfo.dayStringFrom = self.dayStringFrom;
            taskinfo.dayStringTo = self.dayStringTo;
        }
        else {
            [errorMessage appendString:@"请正确设置开始日期和结束日期."];
            return [NSString stringWithString:errorMessage];
        }
    }
    else if(taskinfo.scheduleType == TaskInfoScheduleTypeDays) {
        BOOL checked = YES;
        for(NSString *day in self.dayStrings) {
            if([NSString dateStringIsValid:day]) {
                
            }
            else {
                checked = NO;
                break;
            }
        }
        if(self.dayStrings.count > 0 && checked) {
            taskinfo.dayStrings = [NSString arrayDescriptionConbine:self.dayStrings seprator:@","];//多天模式.
            NSLog(@"---%@", taskinfo.dayStrings);
        }
        else {
            [errorMessage appendString:@"请正确设置多个执行日期."];
            return [NSString stringWithString:errorMessage];
        }
    }
    
    NSDictionary *dict = [taskinfo toDictionary];
    NSLog(@"%@", dict);
    return @"";
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"创建任务";
    [self navigationItemRightInit];

}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}


- (void)updateDaysSelectorText
{
    if(self.daysType.length == 0) {
        
    }
    else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeDay) {
        NSMutableAttributedString *attributedString = [NSString attributedStringWith:@"任务执行日期 : " font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskEditTextColor"]];
        if(self.dayString.length == 0) {
            self.dayString = [NSString dateStringToday];
        }
        NSString *dayString = self.dayString;
        NSMutableAttributedString *attributedStringDayString =
                [NSString attributedStringWith:dayString
                                          font:FONT_SYSTEM
                                        indent:0
                                     textColor:[UIColor colorWithName:@"TaskEditTextColor"]
                               backgroundColor:nil
                                underlineColor:[UIColor colorWithName:@"TaskEditTextColor"]
                                  throughColor:nil];
        [attributedString appendAttributedString:attributedStringDayString];
        self.dayButtonA.attributedText = attributedString;
    }
    else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeDays) {
        NSMutableString *s = [[NSMutableString alloc] init];
        if(self.dayStrings.count == 0) {
            [s appendString:@"日历中选择多个执行日期."];
        }
        else {
            for(NSString *dayString in self.dayStrings) {
                [s appendFormat:@"%@  ", dayString];
            }
        }
        
        UIFont *font = FONT_SYSTEM;
        font = [UIFont fontWithName:@"ArialMT" size:18];
        NSMutableAttributedString *attributedString = [NSString attributedStringWith:s font:font indent:36 textColor:[UIColor colorWithName:@"TaskEditTextColor"] backgroundColor:nil underlineColor:nil throughColor:nil];
        self.daysInMutilMode.attributedText = attributedString;
    
    }
    else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
        NSMutableAttributedString *attributedString = [NSString attributedStringWith:@"任务开始日期 : " font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskEditTextColor"]];
        
        if(![NSString dateStringIsValid:self.dayStringFrom]) {
            self.dayStringFrom = [NSString dateStringToday];
        }
        NSString *dayString = self.dayStringFrom;
        NSMutableAttributedString *attributedStringDayString =
        [NSString attributedStringWith:dayString
                                  font:FONT_SYSTEM
                                indent:0
                             textColor:[UIColor colorWithName:@"TaskEditTextColor"]
                       backgroundColor:nil
                        underlineColor:[UIColor colorWithName:@"TaskEditTextColor"]
                          throughColor:nil];
        [attributedString appendAttributedString:attributedStringDayString];
        self.dayButtonA.attributedText = attributedString;
        
        attributedString = [NSString attributedStringWith:@"任务结束日期 : " font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskEditTextColor"]];
        if(![NSString dateStringIsValid:self.dayStringTo]) {
            self.dayStringTo = [NSString dateStringTomorrow];
        }
        
        dayString = self.dayStringTo;
        attributedStringDayString =
        [NSString attributedStringWith:dayString
                                  font:FONT_SYSTEM
                                indent:0
                             textColor:[UIColor colorWithName:@"TaskEditTextColor"]
                       backgroundColor:nil
                        underlineColor:[UIColor colorWithName:@"TaskEditTextColor"]
                          throughColor:nil];
        [attributedString appendAttributedString:attributedStringDayString];
        self.dayButtonB.attributedText = attributedString;
    }
    
    
    
    
    
    
}




- (void)actionClickDayButtonA:(id)sender
{
    [self openCalendarMutilMode:NO withName:@"ButtonA"];
}


- (void)actionClickDayButtonB:(id)sender
{
    [self openCalendarMutilMode:NO withName:@"ButtonB"];
}


- (void)actionDaysTypeSelector:(UISegmentedControl*)segmentedControl
{
    [self.createContentInputView resignFirstResponder];
    
    NSInteger idx = segmentedControl.selectedSegmentIndex;
    if(idx >= 0 && idx < self.daysTypes.count) {
        self.daysType = self.daysTypes[idx];
        [self viewWillLayoutSubviews];
    }
}


- (void)actionOpenCalendarMuiltMode
{
    [self openCalendarMutilMode:YES withName:@"MutilMode"];
}


- (void)openCalendarMutilMode:(BOOL)mutilMode withName:(NSString*)name
{
    LOG_POSTION
    TaskCalendar *taskCalendar = nil;
    if(mutilMode) {
        taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS andDayStrings:self.dayStrings];
    }
    else {
        if([name isEqualToString:@"ButtonA"]) {
            if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeDay) {
                taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS andDayString:self.dayString];
            }
            else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
                taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS andDayString:self.dayStringFrom];
            }
            
        }
        else if([name isEqualToString:@"ButtonB"]) {
            if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
                taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS andDayString:self.dayStringTo];
            }
        }
    }
    
    __weak typeof(self) _self = self;
    __weak typeof(taskCalendar) _taskCalendar = taskCalendar;
    __block BOOL _bMuiltMode = mutilMode;
    [self showPopupView:taskCalendar containerAlpha:0.9 dismiss:^{
        if(_bMuiltMode) {
            NSLog(@"%@", _taskCalendar.dayStrings);
            _self.dayStrings = _taskCalendar.dayStrings;
        }
        else {
            if([name isEqualToString:@"ButtonA"]) {
                if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeDay) {
                    _self.dayString = _taskCalendar.dayString;
                }
                else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
                    _self.dayStringFrom = _taskCalendar.dayString;
                }
                
            }
            else if([name isEqualToString:@"ButtonB"]) {
                if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
                    _self.dayStringTo = _taskCalendar.dayString;
                }
            }
        }
        
        //更新显示.
        [_self updateDaysSelectorText];
    }];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"daysType"]) {
        [self updateDayScheduleLayout];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)updateDayScheduleLayout
{
    [self viewWillLayoutSubviews];
}


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"daysType" context:nil];
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
