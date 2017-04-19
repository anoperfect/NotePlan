//
//  TaskDetailViewController.m
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//
#import "TaskDetailViewController.h"
#import "TaskCell.h"
#import "TaskRecordViewController.h"
#import "TaskTickingViewController.h"
#import "TaskEditViewController.h"


@interface TaskDetailViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITableView *contentTableView;
/*
TaskContent 
TaskProperty
 */
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath*,NSNumber*> *optumizeHeights;

@property (nonatomic, strong) TaskInfo *taskinfo;

@property (nonatomic, assign) NSInteger mode;
@property (nonatomic, strong) TaskInfoArrange *arrange;
@property (nonatomic, strong) NSString *dayString;

//根据mode和对应的参数,计算出当前任务的schedule days, 以及对应的完成状态.
@property (nonatomic, strong) NSArray<NSString*> *scheduleDateStrings;
@property (nonatomic, strong) NSArray<TaskFinishAt*> *finishedAts;
@property (nonatomic, strong) NSArray<TaskFinishAt*> *finishedAtsAll;


@property (nonatomic, strong) UITextView *textViewEditing;
@property (nonatomic, strong) UIView *textViewEditingContainer;
@property (nonatomic, assign) CGFloat           heightFitToKeyboard;


@property (nonatomic, strong) NSArray<NSString*> *actionsKeyword;

@end


@implementation TaskDetailViewController




#pragma mark - init
- (instancetype)initWithArrangeMode:(TaskInfo*)taskinfo arrange:(TaskInfoArrange*)arrange
{
    self = [super init];
    if(self) {
        self.taskinfo = taskinfo;
        self.mode = TASKINFO_MODE_ARRANGE;
        self.arrange = arrange;
        
        NSLog(@"arrange mode : %@, [%@]", self.arrange.arrangeName, [NSString arrayDescriptionConbine:self.arrange.arrangeDays seprator:@","]);
    }
    return self;
}


- (instancetype)initWithDayMode:(TaskInfo*)taskinfo day:(NSString*)dayString
{
    self = [super init];
    if(self) {
        self.taskinfo = taskinfo;
        self.mode = TASKINFO_MODE_DAY;
        self.dayString = dayString;
    }
    return self;
}


- (instancetype)initWithListMode:(TaskInfo*)taskinfo
{
    self = [super init];
    if(self) {
        self.taskinfo = taskinfo;
        self.mode = TASKINFO_MODE_LIST;
    }
    return self;
}


#pragma mark - Custom override view.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //申请各成员.
    self.optumizeHeights = [[NSMutableDictionary alloc] init];
    
    self.contentTableView = [[UITableView alloc] init];
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
    [self addSubview:self.contentTableView];
    [self.contentTableView registerClass:[UITableViewCell        class] forCellReuseIdentifier:@"TaskDetailDefaultCell" ];
    [self.contentTableView registerClass:[TaskDetailContentCell  class] forCellReuseIdentifier:@"TaskDetailContentCell" ];
    [self.contentTableView registerClass:[TaskDetailPropertyCell class] forCellReuseIdentifier:@"TaskDetailPropertyCell"];
    [self.contentTableView registerClass:[TaskRecordCell         class] forCellReuseIdentifier:@"TaskRecordCell"        ];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.textViewEditingContainer = [[UIView alloc] init];
        [self addSubview:self.textViewEditingContainer];
        self.textViewEditingContainer.hidden = YES;
        self.textViewEditingContainer.backgroundColor = [UIColor whiteColor];
        
        self.textViewEditing = [[UITextView alloc] init];
        self.textViewEditing.attributedText = [[NSAttributedString alloc] initWithString:@""];
        self.textViewEditing.editable = NO;
        [self addSubview:self.textViewEditing];
        self.textViewEditing.hidden = YES;
        self.textViewEditing.delegate = self;
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionDetectTaskUpdate:) name:@"NotificationTaskUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self actionUpdateDue:@"FinishAtCount"];
    });
    
    _actionsKeyword = @[
                        @"TaskActionTicking", @"嘀嗒",
                        @"TaskActionFinish", @"完成",
                        @"TaskActionRedo", @"重新开始",
                        @"TaskActionRecord", @"执行记录",
                        @"TaskActionEdit", @"编辑",
                        @"TaskActionUserRecord", @"笔记",
                        @"TaskActionDelete", @"删除",
                        ];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.contentTableView.frame = self.contentView.bounds;
    
    if(self.textViewEditingContainer.hidden) {
        
    }
    else {
        self.textViewEditingContainer.frame = CGRectMake(0, 0, VIEW_WIDTH, self.heightFitToKeyboard);
        self.textViewEditing.frame = UIEdgeInsetsInsetRect(self.textViewEditingContainer.frame, UIEdgeInsetsMake(10, 10, 10, 10));
        
        [self.contentView bringSubviewToFront:self.textViewEditingContainer];
        [self.contentView bringSubviewToFront:self.textViewEditing];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"任务详情";
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor purpleColor];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.title = @"";
}


- (NSArray*)taskPropertyTitles
{
    NSArray *titles = @[
                                 @"当前模式",
                                 @"任务时间",
                                 @"提交时间",
                                 @"完成情况",
                                 /*
                                 @"任务记录",
                                 @"任务记录类型筛选"
                                  */
                        ];
    return titles;
}


#pragma mark - attributedString
- (NSMutableAttributedString*)attributedStringForPropertyContentOfTitle:(NSString*)title
{
    NSString *s ;
    if([title isEqualToString:@"当前模式"]) {
        if(self.mode == TASKINFO_MODE_ARRANGE) {
            s = [NSString stringWithFormat:@"安排模式 : %@(%@)",
                           self.arrange.arrangeName,
                           [NSString arrayDescriptionConbine:self.arrange.arrangeDays seprator:@","]
                ];
            NSLog(@"%@", s);
            return [self attributedStringForPropertyContent:s];
        }
        else if(self.mode == TASKINFO_MODE_DAY) {
            s = [NSString stringWithFormat:@"日期模式 : %@", self.dayString];
            return [self attributedStringForPropertyContent:s];
        }
        else if(self.mode == TASKINFO_MODE_LIST) {
            return [self attributedStringForPropertyContent:@"列表模式"];
        }
    }
    
    if([title isEqualToString:@"任务时间"]) {
        return [self.taskinfo scheduleDateAtrributedStringWithIndent:20.0 textColor:[UIColor colorWithName:@"TaskDetailText"]];
    }
    
    if([title isEqualToString:@"提交时间"]) {
        return [self attributedStringForPropertyContent:[TaskInfo dateTimeStringForDisplay:self.taskinfo.committedAt]];
    }
    
    if([title isEqualToString:@"完成情况"]) {
        return [self attributedStringForTaskFinishStatus];
    }
    
    if([title isEqualToString:@"任务记录"]) {
        return [self attributedStringForPropertyContent:@"签到:1"];
    }
    
    if([title isEqualToString:@"任务记录类型筛选"]) {
        return [self attributedStringForPropertyContent:@"重新执行   完成   用户记录"];
    }
    
    NSLog(@"#error - [%@]", title);
    return [[NSMutableAttributedString alloc] initWithString:@"NAN"];
}


- (NSMutableAttributedString*)attributedStringForPropertyTitle:(NSString*)title
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    attributedString = [NSString attributedStringWith:title font:[UIFont fontWithName:@"TaskPropertyTitleLabel"] indent:20 textColor:[UIColor colorWithName:@"TaskDetailText"]];
    
    return attributedString;
}


- (NSMutableAttributedString*)attributedStringForPropertyContent:(NSString*)content
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    attributedString =  [NSString attributedStringWith:content
                                                  font:[UIFont fontWithName:@"TaskPropertyContentLabel"]
                                                indent:20
                                             textColor:[UIColor colorWithName:@"TaskDetailText"]
                         ];
    
    return attributedString;
}


- (NSMutableAttributedString*)attributedStringForTaskFinishStatusString:(NSString*)s
{
    UIFont *font = FONT_SMALL;
    font = [UIFont fontWithName:@"Menlo-Regular" size:11];
    UIColor *textColor = [UIColor colorWithName:@"TaskDetailText"];
    return [NSString attributedStringWith:s font:font indent:20 textColor:textColor backgroundColor:nil underlineColor:nil throughColor:nil textAlignment:NSTextAlignmentLeft];
}


- (NSMutableAttributedString*)attributedStringForTaskFinishStatus
{

    NSString *s = @"";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    if(self.taskinfo.finishedAt.length > 0) {
        s = [NSString stringWithFormat:@"总任务完成 : %@\n", [TaskInfo dateTimeStringForDisplay:self.taskinfo.finishedAt]];
    }
    else {
        s = @"总任务未完成\n";
    }
    
    [attributedString appendAttributedString:[NSString attributedStringWith:s
                                                                       font:[UIFont fontWithName:@"TaskPropertyContentLabel"]
                                                                     indent:20
                                                                  textColor:[UIColor colorWithName:@"TaskDetailText"]
                                              ]];
    
//    for(TaskFinishAt *status in self.finishedAtsAll) {
//        if(status.finishedAt.length > 0) {
//            s = [NSString stringWithFormat:@"%@ : %@\n", status.dayString, [TaskInfo dateTimeStringForDisplay:status.finishedAt]];
//        }
//        else {
//            s = [NSString stringWithFormat:@"%@\n", status.dayString];
//        }
//        [attributedString appendAttributedString:[self attributedStringForTaskFinishStatusString:s]];
//    }
    
    return attributedString;
}


#pragma mark - action
- (void)actionUpdateDue:(NSString*)due
{
    self.scheduleDateStrings = [NSArray arrayWithArray:[self dataTaskInfoOnDays]];
    self.finishedAts = [[TaskInfoManager taskInfoManager] queryFinishedAtsOnTaskInfo:self.taskinfo onDays:self.scheduleDateStrings];
    self.finishedAtsAll = [[TaskInfoManager taskInfoManager] queryFinishedAtsOnTaskInfo:self.taskinfo onDays:nil];
    self.finishedAts = [self.finishedAts sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TaskFinishAt *taskFinishAt1 = obj1;
        TaskFinishAt *taskFinishAt2 = obj1;
        return [taskFinishAt1.dayString compare:taskFinishAt2.dayString];
    }];
    
    self.finishedAtsAll = [self.finishedAtsAll sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TaskFinishAt *taskFinishAt1 = obj1;
        TaskFinishAt *taskFinishAt2 = obj1;
        return [taskFinishAt1.dayString compare:taskFinishAt2.dayString];
    }];
    
    NSLog(@"%@", self.finishedAts);
    NSLog(@"%@", self.finishedAtsAll);
    
    [self.contentTableView reloadData];
}


- (void)actionDetectTaskUpdate:(NSNotification*)notification
{
    NSDictionary *diffs = notification.object;
    NSLog(@"%@", diffs);
    BOOL needToPop = YES;

    NSArray *diffKeys = diffs[@"diffKeys"];
    LOG_POSTION
    if(diffKeys.count == 0) {
        needToPop = NO;
        NSLog(@"NO need to pop. diffKeys count 0");
    }
    else if(diffKeys.count == 1 && [diffKeys[0] isEqualToString:@"content"]) {
        needToPop = NO;
        NSLog(@"NO need to pop. diffKeys is content");
    }
    else {
        if(self.mode == TASKINFO_MODE_LIST) {
            needToPop = NO;
            NSLog(@"NO need to pop. TASKINFO_MODE_LIST");
        }
        else if(self.mode == TASKINFO_MODE_DAY) {
            if([self.taskinfo.daysOnTask indexOfObject:self.dayString] != NSNotFound) {
                needToPop = NO;
                NSLog(@"NO need to pop. TASKINFO_MODE_DAY. day task still on.")
            }
            else {
                NSLog(@"need to pop. day task off.")
            }
        }
        else if(self.mode == TASKINFO_MODE_ARRANGE){
            NSDictionary *arrangeParse = [TaskInfoManager taskinfoArrange:self.taskinfo];
            NSString *name = self.arrange.arrangeName;
            NSArray *days ;
            if(name.length > 0 && nil != (days = arrangeParse[name]) && days.count > 0) {
                needToPop = NO;
                NSLog(@"NO need to pop. TASKINFO_MODE_ARRANGE. day task still on(%@).", name);
            }
        }
    }
    
    if(needToPop) {
        [self showIndicationText:@"任务执行信息修改.\n返回到上一页."];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self actionUpdateDue:@"TaskInfoEdit"];
    }
}


- (void)actionClickScheduleDays
{
    LOG_POSTION
}


- (void)actionUpdateTaskScheduleDaysContent
{
    
    
}


- (void)actionUpdateCommittedAtContent
{
    //NSString *s = @"2016-11-07 12:34:56";
    //self.taskCommittedAtContent.attributedText = [self attributedStringForPropertyContent:s];
}


- (void)actionUpdateRecordContent
{
    
    
}


- (void)actionStringOnTaskContent:(NSString*)actionString
{
    NSLog(@"action string : %@", actionString);
    NSDictionary *actionStringToSELString = @{
                                              @"TaskActionFinish":@"taskActionFinish",
                                              @"TaskActionRedo":@"taskActionRedo",
                                              @"TaskActionTicking":@"taskActionTicking",
                                              @"TaskActionRecord":@"taskActionRecord",
                                              @"TaskActionEdit":@"taskActionEdit",
                                              @"TaskActionUserRecord":@"taskActionUserRecord",
                                              @"TaskActionMore":@"taskActionMore",
                                              @"TaskActionDelete":@"taskActionDelete",
                                              
                                              };
    
    NSString *selString = actionStringToSELString[actionString];
    [self performSelectorByString:selString];
}


- (void)transitionToTaskRecordViewController
{
    TaskRecordViewController *vc = [[TaskRecordViewController alloc] init];
    vc.taskinfo = self.taskinfo;
    [self.navigationController pushViewController:vc animated:YES];
}


- (NSMutableArray<NSString*>*)dataTaskInfoOnDays
{
    if(self.mode == TASKINFO_MODE_ARRANGE) {
        return self.arrange.arrangeDays;
    }
    else if(self.mode == TASKINFO_MODE_DAY) {
        return [[NSMutableArray alloc] initWithObjects:self.dayString, nil];
    }
    else if(self.mode == TASKINFO_MODE_LIST) {
        return self.taskinfo.daysOnTask;
    }
    
    return nil;
}








#pragma mark - taskAction
- (void)taskAction:(UIButton*)button
{
    [self dismissPopupView];
    NSInteger idx = button.tag - 1000;
    [self actionStringOnTaskContent:_actionsKeyword[idx*2]];
}


- (void)taskActionFinishOnDay:(NSString*)day at:(NSString*)dateTimeString
{
    [[TaskInfoManager taskInfoManager] addFinishedAtOnTaskInfo:self.taskinfo on:day committedAt:dateTimeString];
    [self actionUpdateDue:@"FinishOnDay"];
}


- (void)taskActionFinish
{
    LOG_POSTION
    //任务已经完成的话, 则显示提示信息.
    if(self.taskinfo.finishedAt.length > 0) {
        NSLog(@"Task already set to finished at : %@", self.taskinfo.finishedAt);
        NSString *finishAt = [TaskInfo dateTimeStringForDisplay:self.taskinfo.finishedAt] ;
        [self showIndicationText:[NSString stringWithFormat:@"任务已经设定为完成:\n%@", finishAt]];
        return ;
    }
    
    if(self.finishedAts.count == 0) {
        NSLog(@"#error : scheduleDateStrings count 0.");
        [self showIndicationText:@"任务信息解析出错"];
        return ;
    }
    
    if(self.finishedAts.count == 1) {
        TaskFinishAt *finishAt = [self.finishedAts firstObject];
        NSString *finishAtDateTime = finishAt.finishedAt;
        if(finishAtDateTime.length > 0) {
            NSLog(@"Task on %@ already set to finished at : %@", finishAt.dayString, finishAtDateTime);
            [self showIndicationText:[NSString stringWithFormat:@"任务日期(%@)\n已经设定为完成:\n%@", finishAt.dayString, [TaskInfo dateTimeStringForDisplay:finishAtDateTime]]];
        }
        else {
            NSString *dateTimeNow = [NSString dateTimeStringNow];
            [self taskActionFinishOnDay:finishAt.dayString at:dateTimeNow];
            finishAt.finishedAt = dateTimeNow;
            [self showIndicationText:[NSString stringWithFormat:@"设置为完成状态\n任务日期(%@)", finishAt.dayString]];
        }
    }
    else {
        NSString *totalFinishAt = [TaskFinishAt checkAllFinishAts:self.finishedAts];
        if(totalFinishAt.length > 0) {
            [self showIndicationText:[NSString stringWithFormat:@"任务(%@)已经完成", self.mode==TASKINFO_MODE_ARRANGE? self.arrange.arrangeName:@"全部"]];
        }
        else {
            NSLog(@"show days menu.");
            
            NSMutableString *text = [[NSMutableString alloc] init];
            
            NSMutableArray *menus = [[NSMutableArray alloc] init];
            
            if(self.mode == TASKINFO_MODE_ARRANGE) {
                [text appendFormat:@"安排模式:%@\n", self.arrange.arrangeName];
            }
            
            for(TaskFinishAt *status in self.finishedAts) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                dict[@"text"] = status.dayString;
                if(status.finishedAt.length > 0) {
                    dict[@"detailText"] = [NSString stringWithFormat:@"%@", [TaskInfo dateTimeStringForDisplay:status.finishedAt]];
                    dict[@"accessoryType"] = @(UITableViewCellAccessoryCheckmark);
                    dict[@"disableSelction"] = @1;
                }
                
                [menus addObject:[NSDictionary dictionaryWithDictionary:dict]];
            }
            
            [text appendString:@"已经完成的任务显示对勾和完成时间"];
            [text appendString:@"\n可点击未完成日期标记为完成"];
            
            
            __weak typeof(self) _self = self;
            [self showMenus:menus text:text selectAction:^(NSInteger idx, NSDictionary *menu) {
                NSLog(@"select %@", menu);
                [_self dismissMenus];
                NSString *dateString = menu[@"text"];
                [_self taskActionFinishOnDay:dateString at:[NSString dateTimeStringNow]];
                [_self showIndicationText:[NSString stringWithFormat:@"设置为完成状态\n任务日期(%@)", dateString]];
            }];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationTaskUpdate" object:nil userInfo:nil];
}


- (void)taskActionRedoOnDay:(NSString*)day at:(NSString*)dateTimeString
{
    [[TaskInfoManager taskInfoManager] addRedoAtOnTaskInfo:self.taskinfo on:day committedAt:dateTimeString];
    [self actionUpdateDue:@"RedoOnDay"];
}


- (void)taskActionRedo
{
    LOG_POSTION
    
    if(self.finishedAts.count == 0) {
        NSLog(@"#error : scheduleDateStrings count 0.");
        [self showIndicationText:@"任务信息解析出错"];
        return ;
    }
    
    if(self.finishedAts.count == 1) {
        TaskFinishAt *finishAt = [self.finishedAts firstObject];
        NSString *finishAtDateTime = finishAt.finishedAt;
        if(finishAtDateTime.length == 0) {
            NSLog(@"Task on %@ already set to not finished.", finishAt.dayString);
            [self showIndicationText:[NSString stringWithFormat:@"任务日期(%@)未完成. \n无需执行重作任务.\n", finishAt.dayString]];
        }
        else {
            NSString *dateTimeNow = [NSString dateTimeStringNow];
            [self taskActionRedoOnDay:finishAt.dayString at:dateTimeNow];
            finishAt.finishedAt = @"";
            [self showIndicationText:[NSString stringWithFormat:@"设置为未完成状态\n任务日期(%@)", finishAt.dayString]];
        }
    }
    else {
        NSLog(@"show days menu.");
        NSMutableArray *menus = [[NSMutableArray alloc] init];
        
        NSMutableString *text = [[NSMutableString alloc] init];
        if(self.mode == TASKINFO_MODE_ARRANGE) {
            [text appendFormat:@"安排模式:%@\n", self.arrange.arrangeName];
        }
        
        for(TaskFinishAt *status in self.finishedAts) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            dict[@"text"] = status.dayString;
            if(status.finishedAt.length > 0) {
                dict[@"detailText"] = [NSString stringWithFormat:@"%@", [TaskInfo dateTimeStringForDisplay:status.finishedAt]];
                dict[@"accessoryType"] = @(UITableViewCellAccessoryCheckmark);
            }
            else {
                dict[@"disableSelction"] = @1;
            }
            
            [menus addObject:[NSDictionary dictionaryWithDictionary:dict]];
        }
        
        [text appendString:@"已经完成的任务显示对勾和完成时间"];
        [text appendString:@"\n可点击已完成日期标记为重新开始"];
        
        __weak typeof(self) _self = self;
        [self showMenus:menus text:text selectAction:^(NSInteger idx, NSDictionary *menu) {
            NSLog(@"select %@", menu);
            [_self dismissMenus];
            NSString *dateString = menu[@"text"];
            [_self taskActionRedoOnDay:dateString at:[NSString dateTimeStringNow]];
            [_self showIndicationText:[NSString stringWithFormat:@"设置为未完成状态\n任务日期(%@)", dateString]];
        }];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationTaskUpdate" object:nil userInfo:nil];
}




- (void)taskActionShowScheduleDaysFinishStatus
{
    LOG_POSTION
    NSMutableArray *menus = [[NSMutableArray alloc] init];
    for(TaskFinishAt *status in self.finishedAtsAll) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"text"] = status.dayString;
        dict[@"disableSelction"] = @1;
        if(status.finishedAt.length > 0) {
            dict[@"detailText"] = [NSString stringWithFormat:@"%@", [TaskInfo dateTimeStringForDisplay:status.finishedAt]];
            dict[@"accessoryType"] = @(UITableViewCellAccessoryCheckmark);
        }
        else {
            
        }
        
        [menus addObject:[NSDictionary dictionaryWithDictionary:dict]];
    }
    
    NSString *text = @"显示任务所有日期的完成情况";
    [self showMenus:menus text:text selectAction:^(NSInteger idx, NSDictionary *menu) {}];
}


- (void)taskActionSignIn
{
    [self showIndicationText:@"Not implemented"];
}


- (void)taskActionTicking
{
    TaskTickingViewController *vc = [[TaskTickingViewController alloc] init];
    [self pushViewController:vc animated:YES];
}


- (void)taskActionRecord
{
    TaskRecordViewController *vc = [[TaskRecordViewController alloc] init];
    vc.taskinfo = self.taskinfo;
    [self pushViewController:vc animated:YES];
}


- (void)taskActionEdit
{
    NSLog(@"original : %@", self.taskinfo);
    TaskEditViewController *vc = [[TaskEditViewController alloc] initWithTaskInfo:self.taskinfo];
    [self pushViewController:vc animated:YES];

}


- (void)taskActionUserRecord
{
    UIToolbar *keyboardAccessory = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, 36)];
    keyboardAccessory.backgroundColor = [UIColor whiteColor];
    [keyboardAccessory setItems:@[
                                  [[UIBarButtonItem alloc] initWithTitle:@"撤销" style:UIBarButtonItemStylePlain target:self action:@selector(taskActionUserRecordWithdraw)],
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  [[UIBarButtonItem alloc] initWithTitle:@"输入完成" style:UIBarButtonItemStylePlain target:self action:@selector(taskActionUserRecordCommit)]
                                  ]
                       animated:YES];
    
    //重用cell中的textview有刷新逻辑设计的问题. 用一个单独的textview用于编辑.
    self.heightFitToKeyboard = self.heightFitToKeyboard < 1 ? 200. : self.heightFitToKeyboard;
    
    self.textViewEditing.editable = YES;
    self.textViewEditing.inputAccessoryView = keyboardAccessory;
    [self.contentView bringSubviewToFront:self.textViewEditing];
    [self.textViewEditing becomeFirstResponder];
    
    self.textViewEditing.hidden = NO;
    self.textViewEditingContainer.hidden = NO;
    
    [self.view setNeedsLayout];
    
}


- (void)taskActionUserRecordCommit
{
    NSString *text = self.textViewEditing.text;
    
    [self.textViewEditing resignFirstResponder];
    self.textViewEditing.hidden = YES;
    self.textViewEditingContainer.hidden = YES;
    
    NSString *day = @"NAN";
    if(self.mode == TASKINFO_MODE_ARRANGE) {
        day = self.arrange.arrangeName;
    }
    else if(self.mode == TASKINFO_MODE_DAY) {
        day = self.dayString;
    }
    else if(self.mode == TASKINFO_MODE_LIST) {
        day = @"";
    }
    
    [[TaskInfoManager taskInfoManager] addUserRecordOnTaskInfo:self.taskinfo text:text on:day committedAt:[NSString dateTimeStringNow]];
}


- (void)taskActionUserRecordWithdraw
{
    [self.textViewEditing resignFirstResponder];
    self.textViewEditing.hidden = YES;
    self.textViewEditingContainer.hidden = YES;
}


- (void)taskActionMore
{
    LOG_POSTION
//    [self showMenus:@[
//                      @{@"text":@"完成"}, 
//                      
//                      
//                      ]
//       selectAction:^(NSInteger idx, NSDictionary *menu) {
//           [self dismissMenus];
//       }
//     ];
    

    
    
    
    
    
    
    CGFloat xContainer = 10;
    CGFloat yContainer = 10;
    
    CGFloat widthButton = (VIEW_WIDTH - xContainer * 2) / 4;
    CGFloat heightContainer = 2 * widthButton + 2 * yContainer + 64;
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - heightContainer, VIEW_WIDTH, heightContainer)];
    container.backgroundColor = [UIColor colorWithName:@"CustomBackground"];
    for(NSInteger idx = 0; idx < 8 ; idx ++) {
        if(idx >= _actionsKeyword.count / 2) {
            break;
        }
        NSString *title = _actionsKeyword[idx*2+1];
        UIImage *image = [UIImage imageNamed:_actionsKeyword[idx*2]];
        CGFloat widthImage = 20;
        
            CGSize itemSize = CGSizeMake(widthImage, widthImage);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [image drawInRect:imageRect];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        
        CGFloat xButton = 10 + (idx % 4) * widthButton;
        CGFloat yButton = 10 + (idx / 4) * widthButton;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(xButton, yButton, widthButton, widthButton)];
        button.tag = 1000 + idx;
        [button setTitle:title forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(taskAction:) forControlEvents:UIControlEventTouchDown];
        button.titleLabel.font = FONT_SMALL;
        CGFloat yImage = 20;
        yImage = (widthButton - 40) / 2 ;
        button.imageEdgeInsets = UIEdgeInsetsMake(yImage, (widthButton-widthImage)/2, widthButton-widthImage - yImage, (widthButton-widthImage)/2);
        button.titleEdgeInsets = UIEdgeInsetsMake(yImage + 16, -widthImage, 0, 0);
        [button.titleLabel setContentMode:UIViewContentModeCenter];
        
        CALayer *layer = [CALayer layer];
        layer.bounds = CGRectMake(0, 0, widthButton - 10, widthButton - 10);
        layer.position = CGPointMake(widthButton/2, widthButton/2);
        layer.borderWidth = 1;
        layer.borderColor = [UIColor blackColor].CGColor;
        layer.cornerRadius = 5;
        [button.layer addSublayer:layer];
        
        [container addSubview:button];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 2 * widthButton + 2 * yContainer, VIEW_WIDTH, 64)];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissPopupView) forControlEvents:UIControlEventTouchDown];
    [container addSubview:button];
    
    [self showPopupView:container
             commission:@{
                          @"containerBackgroundColor":[UIColor clearColor],
                          @"popAnimation":@1,
                          }
         clickToDismiss:YES
                dismiss:nil];
    
}


- (void)taskActionDelete
{
    [self showIndicationText:@"任务已删除"];
    [[AppConfig sharedAppConfig] configTaskInfoRemoveBySn:@[self.taskinfo.sn]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationTaskUpdate" object:nil userInfo:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)actionReloadTaskContent
{
    NSLog(@"actionReloadTaskContent");
}


#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return 0;
    }
    return 72.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    NSNumber *heightNumber = [self.optumizeHeights objectForKey:indexPath];
    if([heightNumber isKindOfClass:[NSNumber class]]) {
        height = [heightNumber floatValue];
    }
    else {
        NSInteger idx;
        if(NSNotFound != (idx = [self tableViewCellIndexOfTaskPropertyAtIndexPath:indexPath])) {
            height = 72;
        }
    }
    
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections ;
    sections = 1;
    return sections;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return @"";
    }
    else if(section == 1) {
        return @"任务记录";
    }
    
    return @"NAN";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if(section == 0) {
        rows = 1 + [self taskPropertyTitles].count;
        rows = 10;
    }
    else if(section == 1) {
        
    }
    return rows;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if([self tableViewCellIsTaskContentForRowAtIndexPath:indexPath]) {
        TaskDetailContentCell *contentCell = [tableView dequeueReusableCellWithIdentifier:@"TaskDetailContentCell" forIndexPath:indexPath];
        contentCell.taskinfo = self.taskinfo;
        typeof(self) _self = self;
        contentCell.actionOn = ^(NSString *actionString){
            [_self actionStringOnTaskContent:actionString];
        };
        
        self.optumizeHeights[indexPath] = @(contentCell.frame.size.height);
        UIEdgeInsets edge = contentCell.separatorInset;edge = edge;
        NSLog(@"%f, %f, %f, %f", edge.top, edge.left, edge.bottom, edge.right);
        cell = contentCell;
    }
    
    NSInteger idx = 0;
    if(NSNotFound != (idx=[self tableViewCellIndexOfTaskPropertyAtIndexPath:indexPath])) {
        TaskDetailPropertyCell *propertyCell = [tableView dequeueReusableCellWithIdentifier:@"TaskDetailPropertyCell" forIndexPath:indexPath];
        NSString *title = [self taskPropertyTitles][idx];
        propertyCell.optumizeHeight = 72;
        [propertyCell setTitle:[self attributedStringForPropertyTitle:title]
                       content:[self attributedStringForPropertyContentOfTitle:title]
         ];
        self.optumizeHeights[indexPath] = @(propertyCell.frame.size.height);
        self.optumizeHeights[indexPath] = @(propertyCell.optumizeHeight);
        cell = propertyCell;
        if([title isEqualToString:@"完成情况"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    if(!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskDetailDefaultCell" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"%zd:%zd", indexPath.section, indexPath.row];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSInteger idx = 0;
    if(NSNotFound != (idx=[self tableViewCellIndexOfTaskPropertyAtIndexPath:indexPath])) {
        NSString *title = [self taskPropertyTitles][idx];
        if([title isEqualToString:@"完成情况"]) {
            [self taskActionShowScheduleDaysFinishStatus];
        }
    }
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


- (BOOL)tableViewCellIsTaskContentForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == 0 && indexPath.row == 0;
}


- (NSInteger)tableViewCellIndexOfTaskPropertyAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger offsetIndexOfProperty = 1;
    NSInteger countOfProperty = [self taskPropertyTitles].count;
    
    if(indexPath.section == 0 && (indexPath.row >= offsetIndexOfProperty && indexPath.row < (offsetIndexOfProperty + countOfProperty))) {
        return indexPath.row - 1;
    }
    else {
        return NSNotFound;
    }
}


- (BOOL)tableViewCellIsTaskRecordSummaryForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == 0 && indexPath.row == 2;
}


- (NSInteger)tableViewCellIndexOfTaskRecordAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.section == 1) {
        return indexPath.row;
    }
    
    return NSNotFound;
}


#pragma mark - UItextView for editing delegate.
-(BOOL) textViewShouldBeginEditing:(UITextView*)textView
{
    LOG_POSTION
    return YES;
}


-(void)textViewDidChange:(UITextView*)textView
{
    LOG_POSTION
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
    
    [self.view setNeedsLayout];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end








