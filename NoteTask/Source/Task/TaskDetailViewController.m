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
                                 /*
                                 @"任务记录",
                                 @"任务记录类型筛选"
                                  */
                        ];
    return titles;
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
        [self.contentTableView reloadData];
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
    
    NSInteger idx;
    if(NSNotFound != (idx = [self tableViewCellIndexOfTaskPropertyAtIndexPath:indexPath])) {
        height = 72;
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
        [propertyCell setTitle:[self attributedStringForPropertyTitle:title]
                       content:[self attributedStringForPropertyContentOfTitle:title]
         ];
        self.optumizeHeights[indexPath] = @(propertyCell.frame.size.height);
        cell = propertyCell;
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


- (NSArray<NSString*>*)dataTaskInfoOnDays
{
    return nil;
}


- (void)taskActionFinishOnDay:(NSString*)day
{
    NSString *queryFinishAt = [[TaskInfoManager taskInfoManager] queryFinishedAtsOnSn:self.taskinfo.sn onDay:day];
    if(queryFinishAt.length > 0) {
        NSString *finishAt = [TaskInfo dateTimeStringForDisplay:queryFinishAt] ;
        [self showIndicationText:[NSString stringWithFormat:@"任务已经设定为完成:\n%@", finishAt] inTime:1];
        return ;
    }
    
    [[TaskInfoManager taskInfoManager] addFinishedAtOnSn:self.taskinfo.sn on:day committedAt:[NSString dateTimeStringNow]];
    [self actionReloadTaskContent];
}


- (void)taskActionFinish
{
    LOG_POSTION
    //任务已经完成的话, 则显示提示信息.
    if(self.taskinfo.finishedAt.length > 0) {
        NSString *finishAt = [TaskInfo dateTimeStringForDisplay:self.taskinfo.finishedAt] ;
        [self showIndicationText:[NSString stringWithFormat:@"任务已经设定为完成:\n%@", finishAt] inTime:1];
        return ;
    }
    
    NSArray<NSString*> *days = [self dataTaskInfoOnDays];
    
    if(days.count == 1) {
        [self taskActionFinishOnDay:days[0]];
    }
    else {
        [self showIndicationText:@"NotImplemented" inTime:1];
    }
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
