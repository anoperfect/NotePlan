//
//  TaskViewController.m
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskViewController.h"
#import "TaskModel.h"
#import "TaskInfoManager.h"
#import "TaskRecord.h"
#import "TaskCell.h"
#import "AppConfig.h"
#import "TaskDetailViewController.h"


@interface TaskViewController () <UITableViewDelegate, UITableViewDataSource
                                    >

@property (nonatomic, strong) UITableView *tasksView;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath*,NSNumber*> *taskCellOptumizeHeights;




@property (nonatomic, assign) NSInteger mode; //0.arrange mode. 1.day mode. 2.list mode.

@property (nonatomic, strong) TaskInfoManager *taskInfoManager;

@property (nonatomic, strong) NSIndexPath *indexPathDetaied; //只有一个可以点击后展开状态. 展开前需关闭前一个.
@property (nonatomic, assign) CGFloat heightDetailedCell; //纪录下展开的cell的fit高度.


@property (nonatomic, strong) NSMutableArray *sectionsHide;
@property (nonatomic, strong) NSMutableArray *sectionsOpenedOnArrangeMode;
@property (nonatomic, strong) NSMutableArray *sectionsOpenedOnDayMode;
@property (nonatomic, strong) NSMutableArray *sectionsOpenedOnListMode;
@property (nonatomic, assign) BOOL isDisplayBeforeTask;
@property (nonatomic, assign) CGFloat contentOffsetYMonitor; //监测上拉距离. 以打开section之前.

@end





@implementation TaskViewController
#pragma mark - Custom override view.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mode = TASKINFO_MODE_ARRANGE;

    [self dataSectionOpenInit];

    self.taskCellOptumizeHeights = [[NSMutableDictionary alloc] init];
    
    [self dataTasksReload];
    
    [self subviewBuild];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionDetectTaskUpdate:) name:@"NotificationTaskUpdate" object:nil];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tasksView.frame = VIEW_BOUNDS;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"任务";
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithName:@"NavigationBackText"]];
    self.navigationController.navigationBarHidden = NO;
    
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
#if 0
    //    导航栏变为透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:0];
    //    让黑线消失的方法
    self.navigationController.navigationBar.shadowImage=[UIImage new];
#endif
 
    self.navigationController.navigationBar.translucent = NO;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - View build and customize.
- (void)subviewBuild
{
    [self navigationItemRightInit];
    [self tasksViewBuild];
}


- (void)navigationItemRightInit
{
    PushButtonData *buttonDataCreate = [[PushButtonData alloc] init];
    buttonDataCreate.actionString = @"taskCreate";
    buttonDataCreate.imageName = @"TaskAdd";
    PushButton *buttonCreate = [[PushButton alloc] init];
    buttonCreate.frame = CGRectMake(0, 0, 44, 44);
    buttonCreate.actionData = buttonDataCreate;
    buttonCreate.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [buttonCreate setImage:[UIImage imageNamed:buttonDataCreate.imageName] forState:UIControlStateNormal];
    [buttonCreate addTarget:self action:@selector(actionCreate) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemCreate = [[UIBarButtonItem alloc] initWithCustomView:buttonCreate];
    
    
    PushButtonData *buttonDataMore = [[PushButtonData alloc] init];
    buttonDataMore.actionString = @"more";
    buttonDataMore.imageName = @"more";
    PushButton *buttonMore = [[PushButton alloc] init];
    buttonMore.frame = CGRectMake(0, 0, 44, 44);
    buttonMore.actionData = buttonDataMore;
    buttonMore.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [buttonMore setImage:[UIImage imageNamed:buttonDataMore.imageName] forState:UIControlStateNormal];
    [buttonMore addTarget:self action:@selector(actionMore) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemMore = [[UIBarButtonItem alloc] initWithCustomView:buttonMore];
    
    self.navigationItem.rightBarButtonItems = @[
                                                itemMore,
                                                itemCreate,
                                                ];
    
    
    
    
}


- (void)tasksViewBuild
{
    self.tasksView = [[UITableView alloc] initWithFrame:VIEW_BOUNDS style:UITableViewStylePlain];
    [self.contentView addSubview:self.tasksView];
    self.tasksView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tasksView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tasksView.dataSource   = self;
    self.tasksView.delegate     = self;
    self.tasksView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //注册UITableViewCell重用.
    [self.tasksView registerClass:[TaskCell class] forCellReuseIdentifier:@"TaskCell"];
    
    /*添加轻扫手势*/
    //注意一个轻扫手势只能控制一个方向，默认向右，通过direction进行方向控制
    UISwipeGestureRecognizer *swipeGestureToRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tableViewSwipeToRight:)];
    //swipeGestureToRight.direction=UISwipeGestureRecognizerDirectionRight;//默认为向右轻扫
    [self.tasksView addGestureRecognizer:swipeGestureToRight];
    
    UISwipeGestureRecognizer *swipeGestureToLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tableViewSwipeToLeft:)];
    swipeGestureToLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.tasksView addGestureRecognizer:swipeGestureToLeft];
}


- (void)tableViewSwipeToRight:(UISwipeGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:self.tasksView];
    NSIndexPath *indexPath = [self.tasksView indexPathForRowAtPoint:point];
    if(indexPath) {
        [self actionOnIndexPath:indexPath byString:@"finish"];
    }
}


- (void)tableViewSwipeToLeft:(UISwipeGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:self.tasksView];
    NSIndexPath *indexPath = [self.tasksView indexPathForRowAtPoint:point];
    if(indexPath) {
        [self actionOnIndexPath:indexPath byString:@"redo"];
    }
}


#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat heightSectionHeader = 45.0;
    
//    
//    if(self.mode == TASKINFO_MODE_ARRANGE) {
//        TaskArrangeGroup *taskArrangeGroup = self.taskInfoManager.taskArrangeGroups[section];
//        if(!self.isDisplayBeforeTask && [taskArrangeGroup.arrangeName isEqualToString:@"之前"]) {
//            
//        }
//        else {
//            heightSectionHeader = 45.0;
//        }
//    }
//    else if(self.mode == TASKINFO_MODE_DAY) {
//        heightSectionHeader = 45.0;
//    }
//    else if(self.mode == TASKINFO_MODE_LIST) {
//        heightSectionHeader = 45.0;
//    }
    
    return heightSectionHeader;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45.0)];
    sectionHeaderView.tag = section;
    
    UIEdgeInsets edgeContainer = UIEdgeInsetsMake(2, 0, 2, 0);
    CGRect frameContainer = UIEdgeInsetsInsetRect(sectionHeaderView.bounds, edgeContainer);
    UIView *container = [[UIView alloc] initWithFrame:frameContainer];
    [sectionHeaderView addSubview:container];
    container.backgroundColor = [UIColor colorWithName:@"TaskSectionHeaderBackground"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:container.bounds];
    [container addSubview:label];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionSectionTap:)];
    tap.numberOfTapsRequired = 1;
    [sectionHeaderView addGestureRecognizer:tap];
    
//    UIFont *font = [UIFont fontWithName:@"TaskSectionHeader"];
    UIFont *font = FONT_MTSIZE(20);
    CGFloat indent = 36.0;
    UIColor *textColor = [UIColor colorWithName:@"TaskSectionHeaderText"];
    
    UIFont *fontNumber = [UIFont fontWithName:@"small"];
    CGFloat indentNumber = 0;
    UIColor *textColorNumber = [UIColor colorWithName:@"TaskSectionHeaderText"];
    
    
    NSMutableAttributedString *attributedString = nil;
    
    NSString *title = [self dataSectionTitleOnSection:section];
    NSInteger number = [self dataSectionNumberOfTaskInfoOnSection:section];
    attributedString = [NSString attributedStringWith:title
                                                 font:font
                                               indent:indent
                                            textColor:textColor
                        ];
    
    NSString *numberTasks = [NSString stringWithFormat:@"[%zd]", number];
    [attributedString appendAttributedString:[NSString attributedStringWith:numberTasks
                                                                       font:fontNumber
                                                                     indent:indentNumber
                                                                  textColor:textColorNumber
                                              ]
     ];

    label.attributedText = attributedString;
    
    CAShapeLayer *indicatorLayer = nil;
    for(CALayer *layer in label.layer.sublayers) {
        if([layer.name isEqualToString:@"indicator"]) {
            indicatorLayer = (CAShapeLayer *)layer;
            break;
        }
    }
    
    if(number == 0 && !indicatorLayer) {
        //nothing.
    }
    if(number == 0 && indicatorLayer) {
        [indicatorLayer removeFromSuperlayer];
    }
    else if(number > 0) {
        if(!indicatorLayer) {
            indicatorLayer = [self createIndicatorWithColor:[UIColor colorWithName:@"TaskSectionHeaderText"] andPosition:CGPointMake(label.frame.size.width - 36, 22.5)];
            indicatorLayer.name = @"indicator";
            [label.layer addSublayer:indicatorLayer];
        }
        
        //
        if([self dataSectionIsOpenedOnSection:section]) {
            indicatorLayer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
        }
    }

    return sectionHeaderView;
}



- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 7)];
    [path addLineToPoint:CGPointMake(12, 7)];
    [path addLineToPoint:CGPointMake(6, 0)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.fillColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    
    CGPathRelease(bound);
    
    layer.position = point;
    
    return layer;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 80.0;
    if([self.indexPathDetaied isEqual:indexPath]) {
        height = self.heightDetailedCell;
    }
    
    NSNumber *heightNumber;
    if(nil != (heightNumber = self.taskCellOptumizeHeights[indexPath])) {
        height = [heightNumber floatValue];
    }
    
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 1;
    
    if(self.mode == TASKINFO_MODE_ARRANGE) {
        sections = self.taskInfoManager.taskArrangeGroups.count;
    }
    else if(self.mode == TASKINFO_MODE_DAY) {
        sections = self.taskInfoManager.tasksDayMode.count;
    }
    else if(self.mode == TASKINFO_MODE_LIST) {
        sections = 1;
    }
    
    return sections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if([self dataSectionIsOpenedOnSection:section]) {
        rows = [self dataSectionNumberOfTaskInfoOnSection:section];
    }
    else {
        rows = 0;
    }
     
    return rows;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_POSTION
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
    
    TaskInfo *taskinfo = nil;
    NSArray<TaskFinishAt*> *finishedAts = nil;
    
    if(self.mode == TASKINFO_MODE_ARRANGE) {
        TaskInfoArrange *taskInfoArrange = [self dataTaskInfoArrangeOnIndexPath:indexPath];
        taskinfo = taskInfoArrange.taskinfo;
        finishedAts = [self.taskInfoManager queryFinishedAtsOnTaskInfo:taskinfo onDays:taskInfoArrange.arrangeDays];
        [cell setTaskInfo:taskinfo finishedAts:finishedAts];
    }
    else if(self.mode == TASKINFO_MODE_DAY) {
        NSString *day = self.taskInfoManager.tasksDay[section];
        NSMutableArray<TaskInfo*> *taskinfos = self.taskInfoManager.tasksDayMode[day];
        taskinfo = taskinfos[row];
        NSString *finishedAt = [self.taskInfoManager queryFinishedAtsOnSn:taskinfo.sn onDay:day];
        TaskFinishAt *taskFinishAt = [[TaskFinishAt alloc] init];
        taskFinishAt.snTaskInfo = taskinfo.sn;
        taskFinishAt.dayString = day;
        taskFinishAt.finishedAt = finishedAt;
        [cell setTaskInfo:taskinfo finishedAts:@[taskFinishAt]];
    }
    else if(self.mode == TASKINFO_MODE_LIST) {
        taskinfo = self.taskInfoManager.taskinfos[row];
        finishedAts = [self.taskInfoManager queryFinishedAtsOnTaskInfo:taskinfo onDays:taskinfo.daysOnTask];
        NSLog(@"row %zd : %@", row, taskinfo);
        [cell setTaskInfo:taskinfo finishedAts:finishedAts];
    }
    
    self.taskCellOptumizeHeights[indexPath] = @(cell.frame.size.height);

    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    LOG_POSTION
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.mode == TASKINFO_MODE_ARRANGE) {
        TaskInfoArrange *taskInfoArrange = [self dataTaskInfoArrangeOnIndexPath:indexPath];
        [self enterTaskDetail:taskInfoArrange.taskinfo arrange:taskInfoArrange];
    }
    else if(self.mode == TASKINFO_MODE_DAY) {
        NSString *day = self.taskInfoManager.tasksDay[section];
        NSMutableArray<TaskInfo*> *taskinfos = self.taskInfoManager.tasksDayMode[day];
        TaskInfo *taskinfo = taskinfos[row];
        [self enterTaskDetail:taskinfo onDay:day];
    }
    else if(self.mode == TASKINFO_MODE_LIST) {
        TaskInfo *taskinfo = self.taskInfoManager.taskinfos[row];
        [self enterTaskDetail:taskinfo];
    }
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


//上弹超过限定值的话,将之前显示出来.
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    NSLog(@"%f, %f", point.x, point.y);
    
    if(self.mode == TASKINFO_MODE_ARRANGE) {
        //模式不显示之前. 当下拉回弹达到一定高度时, 显示"之前".
        if(!self.isDisplayBeforeTask) {
            if(point.y < self.contentOffsetYMonitor) {
                self.contentOffsetYMonitor = point.y;
            }
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    LOG_POSTION
//    //模式不显示之前. 当下拉回弹达到一定高度时, 显示"之前".
//    if(self.contentOffsetYMonitor < - 100 && !self.isDisplayBeforeTask) {
//        NSLog(@"- drag to display tasks Before.")
//        self.contentOffsetYMonitor = 0;
//        self.isDisplayBeforeTask = YES;
//        [self.sectionsWrap addObject:@0];
//        [self.tasksView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
//    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%zd : %zd", indexPath.section, indexPath.row);
}


- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    NSLog(@"%zd ", section);
}





#pragma mark - data

- (void)dataSectionOpenInit
{
    self.sectionsOpenedOnArrangeMode = [[NSMutableArray alloc] initWithObjects:@"今天", @"明天", nil];
    self.sectionsOpenedOnDayMode = [[NSMutableArray alloc] initWithObjects:[NSString dateStringToday]
                                                                           , [NSString dateStringTomorrow]
                                                                           , nil];
    self.sectionsOpenedOnListMode = [[NSMutableArray alloc] initWithObjects:@"所有任务", nil];
}


- (NSMutableArray*)dataSectionOpened
{
    NSMutableArray *sectionOpened = [[NSMutableArray alloc] init];
    if(self.mode == TASKINFO_MODE_ARRANGE) {
        sectionOpened = self.sectionsOpenedOnArrangeMode;
    }
    else if(self.mode == TASKINFO_MODE_DAY) {
        sectionOpened = self.sectionsOpenedOnDayMode;
    }
    else if(self.mode == TASKINFO_MODE_LIST) {
        sectionOpened= self.sectionsOpenedOnListMode;
    }
    
    return sectionOpened;
}


- (BOOL)dataSectionIsOpenedOnSection:(NSInteger)section
{
    NSString *title = [self dataSectionTitleOnSection:section];
    NSMutableArray *sectionsOpened = [self dataSectionOpened];
    if(sectionsOpened && NSNotFound != [sectionsOpened indexOfObject:title]) {
        return YES;
    }
    else {
        return NO;
    }
    
    return YES;
}


//返回反转后的状态.
- (BOOL)dataSectionOpenReverseOnSection:(NSInteger)section
{
    BOOL opened = YES;
    NSString *title = [self dataSectionTitleOnSection:section];
    NSMutableArray *sectionsOpened = [self dataSectionOpened];

    if(NSNotFound != [sectionsOpened indexOfObject:title]) {
        [sectionsOpened removeObject:title];
        opened = NO;
    }
    else {
        [sectionsOpened addObject:title];
        opened = YES;
    }

    return opened;
}


- (NSString*)dataSectionTitleOnSection:(NSInteger)section
{
    NSString *title = @"NAN";
    if(self.mode == TASKINFO_MODE_ARRANGE) {
        TaskArrangeGroup *taskArrangeGroup = self.taskInfoManager.taskArrangeGroups[section];
        title = taskArrangeGroup.arrangeName;
    }
    else if(self.mode == TASKINFO_MODE_DAY) {
        title = self.taskInfoManager.tasksDay[section];
    }
    else {
        title = @"所有任务";
    }
    
    return title;
}


- (NSInteger)dataSectionNumberOfTaskInfoOnSection:(NSInteger)section
{
    NSInteger number = 0;
    if(self.mode == TASKINFO_MODE_ARRANGE) {
        TaskArrangeGroup *taskArrangeGroup = self.taskInfoManager.taskArrangeGroups[section];
        number = taskArrangeGroup.taskInfoArranges.count;
    }
    else if(self.mode == TASKINFO_MODE_DAY) {
        NSString *day = self.taskInfoManager.tasksDay[section];
        NSMutableArray<TaskInfo*> *taskinfos = self.taskInfoManager.tasksDayMode[day];
        number = taskinfos.count;
    }
    else if(self.mode == TASKINFO_MODE_LIST) {
        number = self.taskInfoManager.taskinfos.count;
    }
    
    return number;
}


- (BOOL)detailModeOnIndexPath:(NSIndexPath*)indexPath
{
    return NO;
//    return [self.indexPathDetaied isEqual:indexPath];
}


- (void)dataTasksReload
{
    self.taskInfoManager = [TaskInfoManager taskInfoManager];
    [self.taskInfoManager reloadAll];
    
    NSLog(@"%@", self.taskInfoManager);
}


- (TaskInfoArrange*)dataTaskInfoArrangeOnIndexPath:(NSIndexPath*)indexPath
{
    TaskArrangeGroup *taskArrangeGroup = self.taskInfoManager.taskArrangeGroups[indexPath.section];
    return taskArrangeGroup.taskInfoArranges[indexPath.row];
}


#pragma mark - action

- (void)actionCreate
{
    [self pushViewControllerByName:@"TaskEditViewController"];
}


- (void)pushBackAction
{
    NSLog(@"--------------------------------");
    [self dataTasksReload];
    [self actionReloadTasksView];
}


- (void)showActionMenu
{
    LOG_POSTION
    CGFloat width = 60;
    TextButtonLine *v = [[TextButtonLine alloc] initWithFrame:CGRectMake(VIEW_WIDTH - width, 64, width, VIEW_HEIGHT - 10 * 2)];
    v.layoutMode = TextButtonLineLayoutModeVertical;
    
    NSArray<NSString*> *actionStrings = nil;
    if(self.mode == TASKINFO_MODE_ARRANGE) {
        actionStrings = @[@"列表模式", @"日期模式"];
    }
    else if(self.mode == TASKINFO_MODE_DAY){
        actionStrings = @[@"列表模式", @"安排模式"];
    }
    else {
        actionStrings = @[@"日期模式", @"安排模式"];
    }
    [v setTexts:actionStrings];
    
    __weak typeof(self) _self = self;
    [v setButtonActionByText:^(NSString* actionText) {
        NSLog(@"action : %@", actionText);
        [_self dismissPopupView];
        [_self actionMenuString:actionText];
        return ;
    }];
    
    [self showPopupView:v commission:nil clickToDismiss:YES dismiss:nil];
}


- (void)actionMenuString:(NSString*)actionText
{
    NSLog(@"actionText : %@", actionText);
    NSDictionary *menuStringAndSELStrings = @{
                                              @"安排模式":@"actionChangeToArrangeMode",
                                              @"列表模式":@"actionChangeToListMode",
                                              @"日期模式":@"actionChangeToDayMode",
                                              };
    
    [self performSelectorByString:menuStringAndSELStrings[actionText]];
}


- (void)actionChangeToArrangeMode
{
    self.mode = TASKINFO_MODE_ARRANGE;
    [self actionReloadTasksView];
}


- (void)actionChangeToDayMode
{
    self.mode = TASKINFO_MODE_DAY;
    [self actionReloadTasksView];
}


- (void)actionChangeToListMode
{
    self.mode = TASKINFO_MODE_LIST;
    [self actionReloadTasksView];
}


- (void)actionMore
{
    [self showActionMenu];
}


- (void)actionOpenDetailedOnIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath *prevIndexPath = self.indexPathDetaied;
    self.indexPathDetaied = indexPath;
    
    if(prevIndexPath) {
        [self actionReloadTasksViewOnIndexPaths:@[prevIndexPath, indexPath]];
    }
    else {
        [self actionReloadTasksViewOnIndexPath:indexPath];
    }
}


- (void)actionCloseDetailedOnIndexPath:(NSIndexPath*)indexPath
{
    self.indexPathDetaied = nil;
    [self actionReloadTasksViewOnIndexPath:indexPath];
}




- (void)actionSectionTap:(UITapGestureRecognizer*)sender
{
    NS0Log(@"---%@ \n---%zd", sender, sender.view.tag);
    NSInteger section = sender.view.tag;
    
    [self actionSectionClick:section];
}


- (void)actionSectionClick:(NSInteger)section
{
    [self dataSectionOpenReverseOnSection:section];
    [self actionReloadTasksViewSection:section];
}


- (void)actionFinishOnIndexPath:(NSIndexPath*)indexPath andTaskInfo:(TaskInfo*)taskinfo onArrangeName:(NSString*)name onDays:(NSArray*)days
{
    NSLog(@"finish %@, arrange name %@, days %@", taskinfo.sn, name, days);
    if([name isEqualToString:@"今天"] || [name isEqualToString:@"明天"]) {
        if(days.count == 1) {
            BOOL result = [self.taskInfoManager addFinishedAtOnTaskInfo:taskinfo on:days[0] committedAt:[NSString dateTimeStringNow]];
            if(result) {
                [self actionReloadTasksViewOnIndexPath:indexPath];
            }
            else {
                NSLog(@"#error - addFinishedAtOnSn(%@) error.", taskinfo.sn);
                [self showIndicationText:@"设置任务为完成状态不成功." inTime:1];
            }
        }
        else {
            NSLog(@"#error - argument error.");
            [self showIndicationText:@"设置任务为完成状态不成功." inTime:1];
        }
    }

}


- (void)actionRedoOnIndexPath:(NSIndexPath*)indexPath andTaskInfo:(TaskInfo*)taskinfo onArrangeName:(NSString*)name onDays:(NSArray*)days
{
    NSLog(@"finish %@, arrange name %@, days %@", taskinfo.sn, name, days);
    if([name isEqualToString:@"今天"] || [name isEqualToString:@"明天"]) {
        if(days.count == 1) {
            BOOL result = [self.taskInfoManager addRedoAtOnSn:taskinfo.sn on:days[0] committedAt:[NSString dateTimeStringNow]];
            if(result) {
                [self actionReloadTasksViewOnIndexPath:indexPath];
            }
            else {
                NSLog(@"#error - addRedoAtOnSn(%@) error.", taskinfo.sn);
                [self showIndicationText:@"设置任务为重新完成状态不成功." inTime:1];
            }
        }
        else {
            NSLog(@"#error - argument error.");
            [self showIndicationText:@"设置任务为重新完成状态不成功." inTime:1];
        }
    }
    
}


- (void)enterTaskDetail:(TaskInfo*)taskinfo arrange:(TaskInfoArrange*)taskinfoArrange
{
    NSLog(@"%@", taskinfo);
    TaskDetailViewController *vc = [[TaskDetailViewController alloc] initWithArrangeMode:taskinfo arrange:taskinfoArrange];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)enterTaskDetail:(TaskInfo*)taskinfo onDay:(NSString*)day
{
    TaskDetailViewController *vc = [[TaskDetailViewController alloc] initWithDayMode:taskinfo day:day];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)enterTaskDetail:(TaskInfo*)taskinfo
{
    TaskDetailViewController *vc = [[TaskDetailViewController alloc] initWithListMode:taskinfo];
    [self.navigationController pushViewController:vc animated:YES];
}




- (void)actionOnIndexPath:(NSIndexPath*)indexPath byString:(NSString*)actionString
{
    NSLog(@"action on %zd:%zd with string : %@", indexPath.section, indexPath.row, actionString);
    TaskArrangeGroup *taskArrangeGroup = self.taskInfoManager.taskArrangeGroups[indexPath.section];
    TaskInfoArrange *taskInfoArrange = [self dataTaskInfoArrangeOnIndexPath:indexPath];
    if([actionString isEqualToString:@"finish"]) {
        [self actionFinishOnIndexPath:indexPath andTaskInfo:taskInfoArrange.taskinfo onArrangeName:taskArrangeGroup.arrangeName onDays:taskInfoArrange.arrangeDays];
        return ;
    }

    if([actionString isEqualToString:@"redo"]) {
        [self actionRedoOnIndexPath:indexPath andTaskInfo:taskInfoArrange.taskinfo onArrangeName:taskArrangeGroup.arrangeName onDays:taskInfoArrange.arrangeDays];
        return ;
    }
}


- (void)actionReloadTasksViewOnIndexPath:(NSIndexPath*)indexPath
{
    [self.tasksView beginUpdates];
    [self.tasksView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tasksView endUpdates];
}

- (void)actionReloadTasksViewOnIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    [self.tasksView beginUpdates];
    [self.tasksView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tasksView endUpdates];
}


- (void)actionReloadTasksViewSection:(NSInteger)section
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self.tasksView beginUpdates];
    [self.tasksView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [self.tasksView endUpdates];
}


- (void)actionReloadTasksView
{
    [self.tasksView reloadData];
    
    if(self.mode == TASKINFO_MODE_DAY) {
        [self test];
        

    }
}


- (void)test
{
//    CGSize size = self.tasksView.contentSize;
//    [self.tasksView setContentOffset:CGPointMake(0, size.height - self.tasksView.frame.size.height) animated:YES];
    
    
    
    
    static CGFloat y = 0;
    y += 10;
    [self.tasksView setContentOffset:CGPointMake(0, y) animated:YES];
    CGSize size = self.tasksView.contentSize;
    NSLog(@"%f", size.height);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self test];
    });
    
    
    
}


- (void)actionDetectTaskUpdate:(NSNotification*)notification
{
    NSDictionary *diffs = notification.object;
    NSLog(@"%@", diffs);
    
    [self dataTasksReload];
    [self actionReloadTasksView];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}






@end
