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
@property (nonatomic, strong) TaskInfo *taskinfoEdit;



@property (nonatomic, strong) UILabel       *createContentLabel;
@property (nonatomic, strong) UIButton      *createContentButton;
@property (nonatomic, strong) UITextView    *contentInputView;
@property (nonatomic, assign) CGFloat       heightFitToKeyboard;
@property (nonatomic, strong) UILabel       *contentLabel;



@property (nonatomic, strong) TaskCalendar  *taskCalendar;
@property (nonatomic, assign) BOOL          taskCalendarMutilMode;
@property (nonatomic, strong) NSString      *taskCalendarName;


@property (nonatomic, strong) UILabel               *createScheduleDayLabel;
@property (nonatomic, strong) UISegmentedControl *daysTypeSelector;
@property (nonatomic, strong) NSArray<NSString*> *daysTypes;

@property (nonatomic, strong) UILabel               *detailScheduleDayLabel;
@property (nonatomic, strong) UILabel               *dayButtonA;
@property (nonatomic, strong) UILabel               *dayButtonB;
@property (nonatomic, strong) UILabel               *daysInMutilMode;

@property (nonatomic, strong) UIFont                *fontScheduleDay;


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
        self.taskinfoEdit = [TaskInfo taskinfo];
        self.taskinfoEdit.sn = [NSString randomStringWithLength:7 andType:0];
        self.taskinfo = self.taskinfoEdit;
        self.isCreate = YES;
    }
    return self;
}


- (instancetype)initWithTaskInfo:(TaskInfo*)taskinfo
{
    self = [super init];
    if (self) {
        self.taskinfo = taskinfo;
        self.taskinfoEdit = [TaskInfo taskinfo];
        self.taskinfoEdit.sn = taskinfo.sn;
        [self.taskinfoEdit copyFrom:taskinfo];
        self.added = YES;
    }
    return self;
}


- (void)viewDidLoad {
    self.contentViewScrolled = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self memberObjectCreate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.contentInputView = [[UITextView alloc] init];
        self.contentInputView.font = [UIFont fontWithName:@"TaskDetailContent"];
        self.contentInputView.layer.borderWidth = 1;
        self.contentInputView.layer.borderColor = [UIColor colorWithName:@"TaskBorderCommon"].CGColor;
        if(self.taskinfoEdit.content.length > 0) {
            self.contentInputView.text = self.taskinfoEdit.content;
        }
        [self addSubview:self.contentInputView];
        self.contentInputView.hidden = YES;
    });
    

    self.contentLabel.numberOfLines = 0;
    UITapGestureRecognizer *tapContentLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionEditTaskContent)];
    [self.contentLabel addGestureRecognizer:tapContentLabel];
    self.contentLabel.userInteractionEnabled = YES;
    
    UIFont *font = FONT_MTSIZE(20);
    CGFloat indent = 10.0;
    UIColor *textColor = [UIColor colorWithName:@"TaskSectionHeaderText"];
    
    self.createContentLabel.attributedText = [NSString attributedStringWith:kStringStepCreateContent font:font indent:indent textColor:textColor];
    self.createScheduleDayLabel.attributedText = [NSString attributedStringWith:kStringStepScheduleDay font:font indent:indent textColor:textColor];
    
    CGFloat fontSize = (SCREEN_WIDTH/28.0);
    self.fontScheduleDay = FONT_MTSIZE(fontSize);
    
    self.daysInMutilMode.numberOfLines = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionOpenCalendarMuiltMode)];
    [self.daysInMutilMode addGestureRecognizer:tap];
    self.daysInMutilMode.userInteractionEnabled = YES;
    
    self.detailScheduleDayLabel.attributedText = [self detailScheduleAttributedString];
    self.detailScheduleDayLabel.numberOfLines = 0;
    
    self.dayButtonA.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tapA = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionClickDayButtonA:)];
    [self.dayButtonA addGestureRecognizer:tapA];
    self.dayButtonA.userInteractionEnabled = YES;
    
    self.dayButtonB.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tapB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionClickDayButtonB:)];
    [self.dayButtonB addGestureRecognizer:tapB];
    self.dayButtonB.userInteractionEnabled = YES;
    
    self.daysTypes = [TaskInfo scheduleStrings];
    for(NSInteger idx = 0; idx < self.daysTypes.count; idx ++) {
        [self.daysTypeSelector insertSegmentWithTitle:self.daysTypes[idx] atIndex:idx animated:YES];
    }
    [self.daysTypeSelector addTarget:self action:@selector(actionDaysTypeSelector:) forControlEvents:UIControlEventValueChanged];
    
    [self addObserver:self forKeyPath:@"daysType" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld context:nil];
    
    if(self.taskinfoEdit.scheduleType != TaskInfoScheduleTypeNone) {
        NSString *type = [TaskInfo scheduleStringWithType:self.taskinfoEdit.scheduleType];
        NSInteger idx = [self.daysTypes indexOfObject:type];
        if(idx != NSNotFound && idx < self.daysTypes.count) {
            self.daysTypeSelector.selectedSegmentIndex = idx;
        }
        
        if(self.taskinfoEdit.scheduleType == TaskInfoScheduleTypeDay) {
            self.dayString = self.taskinfoEdit.dayString;
        }
        else if(self.taskinfoEdit.scheduleType == TaskInfoScheduleTypeContinues) {
            self.dayStringFrom = self.taskinfoEdit.dayStringFrom;
            self.dayStringTo = self.taskinfoEdit.dayStringTo;
        }
        else if(self.taskinfoEdit.scheduleType == TaskInfoScheduleTypeDays) {
            self.dayStrings = [self.taskinfoEdit.dayStrings componentsSeparatedByString:@","];
        }
        
        self.daysType = type;
    }
    
    [self addSubview:self.createContentLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.createScheduleDayLabel];
    [self addSubview:self.daysTypeSelector];
    [self addSubview:self.detailScheduleDayLabel];
    [self addSubview:self.dayButtonA];
    [self addSubview:self.dayButtonB];
    [self addSubview:self.daysInMutilMode];
    
    [self updateDaysSelectorText];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIScrollView *scrollView = (UIScrollView*)self.contentView;
    if([scrollView isKindOfClass:[UIScrollView class]]) {
        scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 700);
    }
    
    [self contentLabelUpdate];
    UIEdgeInsets edgeContentLabel = UIEdgeInsetsMake(10, 10, 10, 10);
    CGFloat widthContentLabel = VIEW_WIDTH - (edgeContentLabel.left + edgeContentLabel.right);
    CGSize sizeContentLabelFit = [self.contentLabel sizeThatFits:CGSizeMake(widthContentLabel, 1000)];
    CGFloat heightContentLabel = sizeContentLabelFit.height;
    heightContentLabel += (edgeContentLabel.left + edgeContentLabel.right);
    
    if(_optumizeHeightcreateContentInputView == 0.0) {
        _optumizeHeightcreateContentInputView = 100;
    }
    
    _heightDetailScheduleDayLabel = _heightDayButtonA = _heightDayButtonB = _heightDaysInMutilMode = 0;
    if(self.daysType.length == 0) {
        _heightDetailScheduleDayLabel = 180;
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
                            [FrameLayoutView viewWithName:@"createContentLabelPadding" value:10 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_createContentLabel"     value:36 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"createContentLabelBottom" value:10 edge:UIEdgeInsetsZero],
                            [FrameLayoutView viewWithName:@"_contentLabel" value:heightContentLabel edge:edgeContentLabel],
                            [FrameLayoutView viewWithName:@"contentLabelBottom" value:10 edge:UIEdgeInsetsZero],
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
    
    //Add reminder.
     
    [self memberViewSetFrameWith:[f nameAndFrames]];
    
    f = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = self.isCreate ? @"创建任务" : @"编辑任务" ;
    [self navigationItemRightInit];
    
}


- (void)contentLabelUpdate
{
    NSString *contentString = self.taskinfoEdit.content;
    if(contentString.length == 0) {
        contentString = @"请填写任务内容.";
    }
    self.contentLabel.attributedText = [NSString attributedStringWith:contentString font:[UIFont fontWithName:@"TaskDetailContent"] indent:20 textColor:[UIColor colorWithName:@"TaskDetailText"]];
}


- (void)navigationItemRightInit
{
    PushButtonData *buttonDataCreate = [[PushButtonData alloc] init];
    buttonDataCreate.actionString = @"taskCreate";
    buttonDataCreate.imageName = @"TaskEditDone";
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


- (NSAttributedString*)detailScheduleAttributedString
{
    NSMutableAttributedString *attributedString = [NSString attributedStringWith:@"单天 : \n" font:self.fontScheduleDay indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"只给任务设置一个执行日期.\n" font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"\n" font:[UIFont systemFontOfSize:6] indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"连续 : \n" font:self.fontScheduleDay indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"设定任务日期起始.\n任务执行时间范围为此日期范围.\n" font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"\n" font:[UIFont systemFontOfSize:6] indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"多天 : \n" font:self.fontScheduleDay indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"选择多个日期执行此任务.\n" font:FONT_SYSTEM indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]]];
    [attributedString appendAttributedString:[NSString attributedStringWith:@"\n" font:[UIFont systemFontOfSize:6] indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]]];
    
    return [[NSAttributedString alloc] initWithAttributedString:attributedString];
}


- (void)actionCreate
{
    NSString *errorMessage = [self dataUpdateToTaskInfo];
    if(errorMessage.length > 0) {
        [self showIndicationText:errorMessage inTime:1];
        return ;
    }
    
    //新增的话, 直接使用所有内容.
    if(self.isCreate) {
        [[TaskInfoManager taskInfoManager] addTaskInfo:self.taskinfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationTaskCreate" object:self.taskinfo userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        NSDictionary *diffs = [self.taskinfo differentFrom:self.taskinfoEdit];
        if(diffs.count > 0) {
            [self.taskinfo updateFrom:self.taskinfoEdit];
            NSString *updateDetail = diffs[@"detail"];
            [[TaskInfoManager taskInfoManager] updateTaskInfo:self.taskinfo addUpdateDetail:updateDetail];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationTaskUpdate" object:diffs userInfo:nil];
        }
        else {
            [self showIndicationText:@"任务信息未修改" inTime:1];
        }
    }
}


- (void)actionEditTaskContent
{
    UIToolbar *keyboardAccessory = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, 36)];
    keyboardAccessory.backgroundColor = [UIColor whiteColor];
    [keyboardAccessory setItems:@[
                                  [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(actionEditTaskContentWithDraw)],
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  [[UIBarButtonItem alloc] initWithTitle:@"输入完成" style:UIBarButtonItemStylePlain target:self action:@selector(actionEditTaskContentFinish)]
                                  ]
                       animated:YES];
    
    //重用cell中的textview有刷新逻辑设计的问题. 用一个单独的textview用于编辑.
    self.heightFitToKeyboard = self.heightFitToKeyboard < 1 ? 200. : self.heightFitToKeyboard;
    self.contentInputView.frame = CGRectMake(10, 10 + 36, VIEW_WIDTH - 10 - 10, self.heightFitToKeyboard - (10 + 36));
    self.contentInputView.text = self.taskinfoEdit.content;
    self.contentInputView.hidden = NO;
    self.contentInputView.editable = YES;
    self.contentInputView.inputAccessoryView = keyboardAccessory;
    [self.contentView bringSubviewToFront:self.contentInputView];
    [self.contentInputView becomeFirstResponder];
}


- (void)actionEditTaskContentWithDraw
{
    [self.contentInputView resignFirstResponder];
    self.contentInputView.hidden = YES;
}


- (void)actionEditTaskContentFinish
{
    self.taskinfoEdit.content = self.contentInputView.text;
    
    [self.contentInputView resignFirstResponder];
    self.contentInputView.hidden = YES;
    [self.view setNeedsLayout];
}


- (void)keyboardChangeFrame:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGRect softKeyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //判断软键盘是否隐藏.
    if(!CGRectIntersectsRect(softKeyboardFrame, self.view.frame)) {
        NSLog(@"soft keypad not shown.");
        self.heightFitToKeyboard = 0.0;
        
    }
    else {
        NSLog(@"soft keypad shown.");
        if(self.heightFitToKeyboard != self.contentView.frame.size.height - softKeyboardFrame.size.height) {
            self.heightFitToKeyboard = self.contentView.frame.size.height - softKeyboardFrame.size.height;
        }
    }
    
    self.contentInputView.frame = CGRectMake(10, (10 + 36), VIEW_WIDTH - 10 - 10, self.heightFitToKeyboard - (10 + 36));
}



//更新taskinfo. 如果有内容填写不充足的则返回错误信息.
- (NSString*)dataUpdateToTaskInfo
{
    NSMutableString *errorMessage = [[NSMutableString alloc] init];
    if(self.taskinfoEdit.content.length == 0) {
        [errorMessage appendString:@"请设置任务内容"];
        return [NSString stringWithString:errorMessage];
    }
    
    if(self.isCreate) {
        self.taskinfoEdit.committedAt = [NSString dateTimeStringNow];
        self.taskinfoEdit.modifiedAt = self.taskinfoEdit.committedAt;
    }
    else {
        self.taskinfoEdit.modifiedAt = [NSString dateTimeStringNow];
    }
    
    self.taskinfoEdit.scheduleType =  [TaskInfo scheduleTypeFromString:self.daysType];
    if(self.taskinfoEdit.scheduleType == TaskInfoScheduleTypeNone) {
        [errorMessage appendString:@"请设置执行日期类型,\n然后设置对应日期."];
        return [NSString stringWithString:errorMessage];
    }
    else if(self.taskinfoEdit.scheduleType == TaskInfoScheduleTypeDay) {
        if([NSString dateStringIsValid:self.dayString]) {
            self.taskinfoEdit.dayString = self.dayString;
        }
        else {
            [errorMessage appendString:@"请正确设置单天执行日期."];
            return [NSString stringWithString:errorMessage];
        }
    }
    else if(self.taskinfoEdit.scheduleType == TaskInfoScheduleTypeContinues) {
        if([NSString dateStringIsValid:self.dayStringFrom]
           && [NSString dateStringIsValid:self.dayStringTo]
           && [self.dayStringFrom compare:self.dayStringTo] == NSOrderedAscending) {
            self.taskinfoEdit.dayStringFrom = self.dayStringFrom;
            self.taskinfoEdit.dayStringTo = self.dayStringTo;
        }
        else {
            [errorMessage appendString:@"请正确设置开始日期和结束日期."];
            return [NSString stringWithString:errorMessage];
        }
    }
    else if(self.taskinfoEdit.scheduleType == TaskInfoScheduleTypeDays) {
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
            self.taskinfoEdit.dayStrings = [NSString arrayDescriptionConbine:self.dayStrings seprator:@","];//多天模式.
            NSLog(@"---%@", self.taskinfoEdit.dayStrings);
        }
        else {
            [errorMessage appendString:@"请正确设置多个执行日期."];
            return [NSString stringWithString:errorMessage];
        }
    }
    
    [self.taskinfoEdit generateDaysOnTask];
    NSLog(@"%@", self.taskinfoEdit);
    
    return @"";
}










- (void)updateDaysSelectorText
{
    if(self.daysType.length == 0) {
        
    }
    else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeDay) {
        NSMutableAttributedString *attributedString = [NSString attributedStringWith:@"任务执行日期 : " font:self.fontScheduleDay indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]];
        if(self.dayString.length == 0) {
            self.dayString = [NSString dateStringToday];
        }
        NSString *dayString = self.dayString;
        NSMutableAttributedString *attributedStringDayString =
                [NSString attributedStringWith:dayString
                                          font:self.fontScheduleDay
                                        indent:0
                                     textColor:[UIColor colorWithName:@"TaskDetailText"]
                               backgroundColor:nil
                                underlineColor:[UIColor colorWithName:@"TaskDetailText"]
                                  throughColor:nil
                                 textAlignment:NSTextAlignmentLeft];
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
        
        NSMutableAttributedString *attributedString = [NSString attributedStringWith:s font:self.fontScheduleDay indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"] backgroundColor:nil underlineColor:nil throughColor:nil textAlignment:NSTextAlignmentCenter];
        self.daysInMutilMode.attributedText = attributedString;
    }
    else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
        NSMutableAttributedString *attributedString = [NSString attributedStringWith:@"任务开始日期 : " font:self.fontScheduleDay indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]];
        
        if(![NSString dateStringIsValid:self.dayStringFrom]) {
            self.dayStringFrom = [NSString dateStringToday];
        }
        NSString *dayString = self.dayStringFrom;
        NSMutableAttributedString *attributedStringDayString =
        [NSString attributedStringWith:dayString
                                  font:self.fontScheduleDay
                                indent:0
                             textColor:[UIColor colorWithName:@"TaskDetailText"]
                       backgroundColor:nil
                        underlineColor:[UIColor colorWithName:@"TaskDetailText"]
                          throughColor:nil
                         textAlignment:NSTextAlignmentLeft];
        [attributedString appendAttributedString:attributedStringDayString];
        self.dayButtonA.attributedText = attributedString;
        
        attributedString = [NSString attributedStringWith:@"任务结束日期 : " font:self.fontScheduleDay indent:36 textColor:[UIColor colorWithName:@"TaskDetailText"]];
        if(![NSString dateStringIsValid:self.dayStringTo]) {
            self.dayStringTo = [NSString dateStringTomorrow];
        }
        
        dayString = self.dayStringTo;
        attributedStringDayString =
        [NSString attributedStringWith:dayString
                                  font:self.fontScheduleDay
                                indent:0
                             textColor:[UIColor colorWithName:@"TaskDetailText"]
                       backgroundColor:nil
                        underlineColor:[UIColor colorWithName:@"TaskDetailText"]
                          throughColor:nil
                         textAlignment:NSTextAlignmentLeft];
        [attributedString appendAttributedString:attributedStringDayString];
        self.dayButtonB.attributedText = attributedString;
    }
    
    [self.view setNeedsLayout];
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
    [self.contentInputView resignFirstResponder];
    
    NSInteger idx = segmentedControl.selectedSegmentIndex;
    if(idx >= 0 && idx < self.daysTypes.count) {
        self.daysType = self.daysTypes[idx];
        [self updateDaysSelectorText];
    }
}


- (void)actionOpenCalendarMuiltMode
{
    [self openCalendarMutilMode:YES withName:@"MutilMode"];
}


- (void)openCalendarMutilMode:(BOOL)mutilMode withName:(NSString*)name
{
    LOG_POSTION
    
    self.taskCalendarMutilMode = mutilMode;
    self.taskCalendarName = name;
    
    if(mutilMode) {
        self.taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS andDayStrings:self.dayStrings];
    }
    else {
        if([name isEqualToString:@"ButtonA"]) {
            if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeDay) {
                self.taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS andDayString:self.dayString];
            }
            else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
                self.taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS andDayString:self.dayStringFrom];
            }
            
        }
        else if([name isEqualToString:@"ButtonB"]) {
            if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
                self.taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS andDayString:self.dayStringTo];
            }
        }
    }
    
    [self.taskCalendar.buttonOK addTarget:self action:@selector(actionTaskCalendarInput) forControlEvents:UIControlEventTouchDown];
    [self.taskCalendar.buttonDelete addTarget:self action:@selector(actionTaskCalendarInputDelete) forControlEvents:UIControlEventTouchDown];
    
    [self showPopupView:self.taskCalendar commission:nil clickToDismiss:NO dismiss:nil];
    
#if 0
    __weak typeof(self) _self = self;
    __weak typeof(taskCalendar) _taskCalendar = taskCalendar;
    __block BOOL _bMuiltMode = mutilMode;
    [self showPopupView:taskCalendar containerAlpha:0.9 dismiss:^{

    }];
#endif
}


- (void)actionTaskCalendarInput
{
    [self dismissPopupView];
    if(self.taskCalendarMutilMode) {
        NSLog(@"%@", _taskCalendar.dayStrings);
        self.dayStrings = _taskCalendar.dayStrings;
    }
    else {
        if([self.taskCalendarName isEqualToString:@"ButtonA"]) {
            if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeDay) {
                self.dayString = _taskCalendar.dayString;
            }
            else if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
                self.dayStringFrom = _taskCalendar.dayString;
            }
            
        }
        else if([self.taskCalendarName isEqualToString:@"ButtonB"]) {
            if([TaskInfo scheduleTypeFromString:self.daysType] == TaskInfoScheduleTypeContinues) {
                self.dayStringTo = _taskCalendar.dayString;
            }
        }
    }
    
    self.taskCalendar = nil;
    
    //更新显示.
    [self updateDaysSelectorText];
}


- (void)actionTaskCalendarInputDelete
{
    [self dismissPopupView];
    self.taskCalendar = nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"daysType"]) {
        [self updateDaysSelectorText];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"daysType" context:nil];
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
