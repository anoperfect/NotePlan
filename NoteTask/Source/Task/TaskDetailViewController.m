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


@interface TaskDetailViewController () <UITableViewDataSource, UITableViewDelegate>

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


@end


@implementation TaskDetailViewController




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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionDetectTaskUpdate:) name:@"NotificationTaskUpdate" object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self actionUpdateDue:@"FinishAtCount"];
    });
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.contentTableView.frame = self.contentView.bounds;
    
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
        return [self.taskinfo scheduleDateAtrributedStringWithIndent:20.0 andTextColor:[UIColor colorWithName:@"TaskDetailText"]];
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
        [self showIndicationText:@"任务执行信息修改.\n返回到上一页." inTime:1];
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
        UIEdgeInsets edge = contentCell.separatorInset;
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


- (void)actionStringOnTaskContent:(NSString*)actionString
{
    NSLog(@"action string : %@", actionString);
    NSDictionary *actionStringToSELString = @{
                                              @"TaskActionFinish":@"taskActionFinish",
                                              @"TaskActionTicking":@"taskActionTicking",
                                              @"TaskActionRecord":@"taskActionRecord",
                                              @"TaskActionEdit":@"taskActionEdit",
                                              @"TaskActionMore":@"taskActionMore",
                                              
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
        [self showIndicationText:[NSString stringWithFormat:@"任务已经设定为完成:\n%@", finishAt] inTime:1];
        return ;
    }
    
    if(self.finishedAts.count == 0) {
        NSLog(@"#error : scheduleDateStrings count 0.");
        [self showIndicationText:@"任务信息解析出错" inTime:1];
        return ;
    }
    
    if(self.finishedAts.count == 1) {
        TaskFinishAt *finishAt = [self.finishedAts firstObject];
        NSString *finishAtDateTime = finishAt.finishedAt;
        if(finishAtDateTime.length > 0) {
            NSLog(@"Task on %@ already set to finished at : %@", finishAt.dayString, finishAtDateTime);
            [self showIndicationText:[NSString stringWithFormat:@"任务日期(%@)已经设定为完成:\n%@", finishAt.dayString, [TaskInfo dateTimeStringForDisplay:finishAtDateTime]] inTime:1];
        }
        else {
            NSString *dateTimeNow = [NSString dateTimeStringNow];
            [self taskActionFinishOnDay:finishAt.dayString at:dateTimeNow];
            finishAt.finishedAt = dateTimeNow;
            [self showIndicationText:[NSString stringWithFormat:@"设置任务日期(%@)为完成状态", finishAt.dayString] inTime:2];
        }
    }
    else {
//        [self showIndicationText:@"NotImplemented" inTime:1];
        
        NSString *totalFinishAt = [TaskFinishAt checkAllFinishAts:self.finishedAts];
        if(totalFinishAt.length > 0) {
            [self showIndicationText:[NSString stringWithFormat:@"任务(%@)已经完成", self.mode==TASKINFO_MODE_ARRANGE? self.arrange.arrangeName:@"全部"] inTime:3];
        }
        else {
            NSLog(@"show days menu.");
            NSMutableArray *menus = [[NSMutableArray alloc] init];
            
            if(self.mode == TASKINFO_MODE_ARRANGE) {
                [menus addObject:@{
                                   @"text" : self.arrange.arrangeName,
                                   @"disableSelction" : @1
                                   }];
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
            
            __weak typeof(self) _self = self;
            [self showMenus:menus selectAction:^(NSInteger idx, NSDictionary *menu) {
                NSLog(@"select %@", menu);
                [_self dismissMenus];
                NSString *dateString = menu[@"text"];
                [_self taskActionFinishOnDay:dateString at:[NSString dateTimeStringNow]];
                [_self showIndicationText:[NSString stringWithFormat:@"设置任务日期(%@)为完成状态", dateString] inTime:2];
            }];
        }
    }
}


- (void)taskActionShowScheduleDaysFinishStatus
{
    NSMutableArray *menus = [[NSMutableArray alloc] init];
    for(TaskFinishAt *status in self.finishedAtsAll) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"text"] = status.dayString;
        if(status.finishedAt.length > 0) {
            dict[@"detailText"] = [NSString stringWithFormat:@"%@", [TaskInfo dateTimeStringForDisplay:status.finishedAt]];
            dict[@"accessoryType"] = @(UITableViewCellAccessoryCheckmark);
            dict[@"disableSelction"] = @1;
        }
        
        [menus addObject:[NSDictionary dictionaryWithDictionary:dict]];
    }
    
    [self showMenus:menus selectAction:^(NSInteger idx, NSDictionary *menu) {

    }];
}


- (void)taskActionSignIn
{
    [self showIndicationText:@"Not implemented" inTime:1];
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
    
//    NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
//    [vcs removeObject:self];
//    self.navigationController.viewControllers = [NSArray arrayWithArray:vcs];
}


- (void)taskActionMore
{
    LOG_POSTION
    [self showMenus:@[
                      @{@"text":@"完成"}, 
                      
                      
                      ]
       selectAction:^(NSInteger idx, NSDictionary *menu) {
           [self dismissMenus];
       }
     ];
    
    
}


- (void)actionReloadTaskContent
{
    NSLog(@"actionReloadTaskContent");
    
    
}


- (void)actionRedo
{
    LOG_POSTION
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





@end
