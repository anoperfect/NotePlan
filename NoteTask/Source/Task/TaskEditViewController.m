//
//  TaskEditViewController.m
//  NoteTask
//
//  Created by Ben on 16/11/27.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskEditViewController.h"
#import "TaskCell.h"
static NSString *kStringStepCreateTitle = @"1. 任务内容";
static NSString *kStringStepScheduleDay = @"2. 执行日期";



@interface TaskEditViewController () <UINavigationBarDelegate, UINavigationControllerDelegate>
{
    CGFloat _heightDetailScheduleDayLabel;
    CGFloat _heightDayButtonA;
    CGFloat _heightDayButtonB;
    CGFloat _heightDaysInMutilMode;
}

@property (nonatomic, strong) TaskInfo *taskinfo;



@property (nonatomic, strong) UILabel       *createTitleLabel;
@property (nonatomic, strong) UIButton      *createTitleButton;
@property (nonatomic, strong) UITextView    *createTitleInputView;


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



@property (nonatomic, assign) CGFloat optumizeHeightCreateTitleInputView;


@end

@implementation TaskEditViewController


- (instancetype)init
{
    LOG_POSTION
    self = [super init];
    if (self) {
        self.taskinfo = [TaskInfo taskinfo];
        self.taskinfo.sn = [NSString randomStringWithLength:7 andType:0];
        NSLog(@"%@", self.taskinfo);
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
    
    self.taskinfo = [TaskInfo taskinfo];
    self.taskinfo.sn = [NSString randomStringWithLength:7 andType:0];
    NSLog(@"%@", self.taskinfo);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.createTitleInputView = [[UITextView alloc] init];
        [self addSubview:self.createTitleInputView];
        [self viewWillLayoutSubviews];
    });
    
    self.createTitleLabel.text          = kStringStepCreateTitle;
    self.createScheduleDayLabel.text    = kStringStepScheduleDay;
    self.detailScheduleDayLabel.text    = @"单天\n连续\n多天\n";
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
    
    self.daysTypes = @[kStringSelectorDay, kStringSelectorDays, kStringSelectorContinuous];
    for(NSInteger idx = 0; idx < self.daysTypes.count; idx ++) {
        [self.daysTypeSelector insertSegmentWithTitle:self.daysTypes[idx] atIndex:idx animated:YES];
    }
    [self.daysTypeSelector addTarget:self action:@selector(actionDaysTypeSelector:) forControlEvents:UIControlEventValueChanged];
    
    [self addObserver:self forKeyPath:@"daysType" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld context:nil];
    
    
    [self addSubview:self.createTitleLabel];
    [self addSubview:self.createScheduleDayLabel];
    [self addSubview:self.daysTypeSelector];
    [self addSubview:self.detailScheduleDayLabel];
    [self addSubview:self.dayButtonA];
    [self addSubview:self.dayButtonB];
    [self addSubview:self.daysInMutilMode];
    
    
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateDaysSelectorText];
    
    UIScrollView *scrollView = (UIScrollView*)self.contentView;
    if([scrollView isKindOfClass:[UIScrollView class]]) {
        scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 1000);
    }
    
    if(_optumizeHeightCreateTitleInputView == 0.0) {
        _optumizeHeightCreateTitleInputView = 72;
    }
    
    _heightDetailScheduleDayLabel = _heightDayButtonA = _heightDayButtonB = _heightDaysInMutilMode = 0;
    if(self.daysType.length == 0) {
        _heightDetailScheduleDayLabel = 100;
    }
    else if([self.daysType isEqualToString:kStringSelectorDay]) {
        _heightDayButtonA = 36;
    }
    else if([self.daysType isEqualToString:kStringSelectorDays]) {
        _heightDaysInMutilMode = 100;
    }
    else if([self.daysType isEqualToString:kStringSelectorContinuous]) {
        _heightDayButtonA = _heightDayButtonB = 36;
    }
    
    FrameLayout *f = [[FrameLayout alloc] initWithRootView:self.contentView];
    [f frameLayoutHerizon:FRAMELAYOUT_NAME_MAIN
                  toViews:@[
                            [FrameLayoutView viewWithName:@"_createTitleLabel"     value:36 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_createTitleInputView" value:self.optumizeHeightCreateTitleInputView edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_createScheduleDayLabel" value:36 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_daysTypeSelector" value:36 edge:UIEdgeInsetsMake(2, 36, 2, 36)],
                            [FrameLayoutView viewWithName:@"_detailScheduleDayLabel" value:_heightDetailScheduleDayLabel edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_dayButtonA" value:_heightDayButtonA edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_dayButtonB" value:_heightDayButtonB edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_daysInMutilMode" value:_heightDaysInMutilMode edge:UIEdgeInsetsZero],
                            ]
    ];
     
    [self memberViewSetFrameWith:[f nameAndFrames]];
    
    
    
    
    f = nil;

    
    
}


- (void)navigationItemRightInit
{
    PushButtonData *buttonDataCreate = [[PushButtonData alloc] init];
    buttonDataCreate.actionString = @"taskCreate";
    buttonDataCreate.imageName = @"TaskAdd";
    PushButton *buttonCreate = [[PushButton alloc] init];
    buttonCreate.frame = CGRectMake(0, 0, 44, 44);
    buttonCreate.actionData = buttonDataCreate;
    buttonCreate.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [buttonCreate setImage:[UIImage imageNamed:buttonDataCreate.imageName] forState:UIControlStateNormal];
    [buttonCreate addTarget:self action:@selector(actionCreate) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemCreate = [[UIBarButtonItem alloc] initWithCustomView:buttonCreate];
    
    self.navigationItem.rightBarButtonItems = @[
                                                itemCreate,
                                                ];

}


- (void)actionCreate
{
    [self storeToLocal];
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


- (void)storeToLocal
{
    NSLog(@"%@", self.taskinfo);
    self.taskinfo.content = self.createTitleInputView.text;
    self.taskinfo.daysStrings = self.dayString;
    
    [[AppConfig sharedAppConfig] configTaskInfoAdd:self.taskinfo];
    
    self.navigationController.delegate = self;
}





- (void)updateDaysSelectorText
{
    if(self.daysType.length == 0) {
        
    }
    else if([self.daysType isEqualToString:kStringSelectorDay]) {
        NSMutableAttributedString *attributedString = [NSString attributedStringWith:@"任务执行日期 : " font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskEditTextColor"]];
        NSString *dayString = self.dayString.length == 0 ? @"yyyy-MM-dd" : self.dayString;
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
    else if([self.daysType isEqualToString:kStringSelectorDays]) {
        NSMutableString *s = [[NSMutableString alloc] init];
        if(self.dayStrings.count == 0) {
            [s appendString:@"日历中选择多个执行日期."];
        }
        else {
            for(NSString *dayString in self.dayStrings) {
                [s appendFormat:@"%@ ", dayString];
            }
        }
        
        NSMutableAttributedString *attributedString = [NSString attributedStringWith:s font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskEditTextColor"] backgroundColor:nil underlineColor:nil throughColor:nil];
        self.daysInMutilMode.attributedText = attributedString;
    }
    else if([self.daysType isEqualToString:kStringSelectorContinuous]) {
        NSMutableAttributedString *attributedString = [NSString attributedStringWith:@"任务开始日期 : " font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskEditTextColor"]];
        NSString *dayString = self.dayStringFrom.length == 0 ? @"yyyy-MM-dd" : self.dayStringFrom;
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
        
        attributedString = [NSString attributedStringWith:@"任务开始日期 : " font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskEditTextColor"]];
        dayString = self.dayStringTo.length == 0 ? @"yyyy-MM-dd" : self.dayStringTo;
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
    LOG_POSTION
    TaskCalendar *taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS];
    __weak TaskCalendar *_taskCalendar = taskCalendar;
    __weak typeof(self) _self = self;
    [self showPopupView:taskCalendar containerAlpha:0.9 dismiss:^{
        if([_self.daysType isEqualToString:kStringSelectorDay]) {
            _self.dayString = _taskCalendar.dayString;
        }
        else if([self.daysType isEqualToString:kStringSelectorContinuous]) {
            _self.dayStringFrom = _taskCalendar.dayString;
        }
        
        [_self updateDaysSelectorText];
    }];
}


- (void)actionClickDayButtonB:(id)sender
{
    LOG_POSTION
    TaskCalendar *taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS];
    __weak TaskCalendar *_taskCalendar = taskCalendar;
    __weak typeof(self) _self = self;
    [self showPopupView:taskCalendar containerAlpha:0.9 dismiss:^{
        if([self.daysType isEqualToString:kStringSelectorContinuous]) {
            _self.dayStringTo = _taskCalendar.dayString;
        }
        
        [_self updateDaysSelectorText];
    }];
}


- (void)actionDaysTypeSelector:(UISegmentedControl*)segmentedControl
{
    LOG_POSTION
    NSInteger idx = segmentedControl.selectedSegmentIndex;
    if(idx >= 0 && idx < self.daysTypes.count) {
        LOG_POSTION
        self.daysType = self.daysTypes[idx];
        [self viewWillLayoutSubviews];
    }
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
