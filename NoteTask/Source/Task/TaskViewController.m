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



@interface TaskViewController () <UITableViewDelegate, UITableViewDataSource
                                    >

@property (nonatomic, strong) UITableView *tasksView;



@property (nonatomic, assign) BOOL dayMode;

@property (nonatomic, strong) TaskInfoManager *taskInfoManager;

@property (nonatomic, strong) NSIndexPath *indexPathDetaied; //只有一个可以点击后展开状态. 展开前需关闭前一个.
@property (nonatomic, assign) CGFloat heightDetailedCell; //纪录下展开的cell的fit高度.


@property (nonatomic, strong) NSMutableArray *sectionsWrap;

@end





@implementation TaskViewController
#pragma mark - Custom override view.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithName:@"CustomBackground"];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"任务";
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithName:@"NavigationBackText"]];
    
    //返回只有一个箭头.
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.sectionsWrap = [[NSMutableArray alloc] init];
    
    [self dataTasksReload];
    
    [self subviewBuild];
    
    NSLog(@"-%zd", [@"1" compare:@"2"]);
    NSLog(@"-%zd", [@"1" compare:@"1"]);
    NSLog(@"-%zd", [@"2" compare:@"1"]);
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.tasksView.frame = VIEW_BOUNDS;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark - View build and customize.
- (void)subviewBuild
{
    [self navigationItemRightInit];
    [self tasksViewBuild];
}


- (void)navigationItemRightInit
{
    UIImage *rightItemImage = [UIImage imageNamed:@"more"];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:rightItemImage style:UIBarButtonItemStyleDone target:self action:@selector(actionMore)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}


- (void)tasksViewBuild
{
    self.tasksView = [[UITableView alloc] initWithFrame:VIEW_BOUNDS style:UITableViewStylePlain];
    [self.contentView addSubview:self.tasksView];
    self.tasksView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tasksView.dataSource   = self;
    self.tasksView.delegate     = self;
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45.0)];
    sectionHeaderView.backgroundColor = [UIColor colorFromString:@"#faf0e6@60"];
    sectionHeaderView.tag = section;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, sectionHeaderView.frame.size.width - 10, 41)];
    label.text = [self.taskInfoManager dayNameOnSection:section];
    [sectionHeaderView addSubview:label];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionSectionTap:)];
    tap.numberOfTapsRequired = 1;
    [sectionHeaderView addGestureRecognizer:tap];
    
    return sectionHeaderView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 80.0;
    if([self.indexPathDetaied isEqual:indexPath]) {
        height = self.heightDetailedCell;
    }
    
    NSLog(@"---tableview height row : %lf", height);
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections ;
    sections = 3;
    return sections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    rows = 6;
    
    TaskDayList *taskDayList = [self.taskInfoManager taskDayListOnSection:section];
    rows = taskDayList.taskDays.count;
    
    if([self.sectionsWrap indexOfObject:@(section)] != NSNotFound) {
        rows = 0;
    }
    return rows;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_POSTION
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.layer.cornerRadius = 6;
    
    cell.detailedMode = [self.indexPathDetaied isEqual:indexPath];
    TaskDay *taskDay = [self dataTaskDayOnIndexPath:indexPath];
    cell.taskDay = taskDay;
    __weak typeof(self) _self = self;
    cell.actionOn = ^(NSString* actionString){
        [_self actionOnIndexPath:indexPath byString:actionString];
    };
    
    self.heightDetailedCell = cell.frame.size.height + 10;
    
    NSLog(@"--- heightDetailedCell : %lf", self.heightDetailedCell);
    
    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if(0) {
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([indexPath isEqual:self.indexPathDetaied]) {
        [self actionCloseDetailedOnIndexPath:indexPath];
    }
    else {
        [self actionOpenDetailedOnIndexPath:indexPath];
    }
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if(0) {
        
    }
    
    
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}



- (void)dataTasksReload
{
    self.taskInfoManager = [TaskInfoManager taskInfoManager];
    [self.taskInfoManager reloadTaskInfos];
    
    NSLog(@"%@", self.taskInfoManager);
}


- (TaskDay*)dataTaskDayOnIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
        case 0:
            return self.taskInfoManager.taskDayListToday.taskDays[indexPath.row];
            break;
            
        case 1:
            return self.taskInfoManager.taskDayListTomorrow.taskDays[indexPath.row];
            break;
            
        case 2:
            return self.taskInfoManager.taskDayListComming.taskDays[indexPath.row];
            break;
            
        default:
            break;
    }
    
    return nil;
}


- (void)actionMore
{
    
    
    
    
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
    NSLog(@"---%@ \n---%zd", sender, sender.view.tag);
    NSInteger section = sender.view.tag;
    
    [self actionSectionClick:section];
}


- (void)actionSectionClick:(NSInteger)section
{
    NSInteger idx = [self.sectionsWrap indexOfObject:@(section)];
    if(idx == NSNotFound) {
        [self.sectionsWrap addObject:@(section)];
    }
    else {
        [self.sectionsWrap removeObject:@(section)];
    }
    
    [self actionReloadTasksViewSection:section];
}


- (void)actionFinishOnIndexPath:(NSIndexPath*)indexPath andTaskDay:(TaskDay*)taskDay
{
    if(taskDay.finishedAt.length > 0) {
        NSLog(@"Already finished.");
        return ;
    }
    
    taskDay.finishedAt = [NSString stringDateTimeNow];
    self.indexPathDetaied = nil;
    [self actionReloadTasksViewOnIndexPath:indexPath];
    [[TaskRecordManager taskRecordManager] taskRecordAddFinish:taskDay.taskinfo.sn on:taskDay.dayString committedAt:taskDay.finishedAt];
}


- (void)actionRedoOnIndexPath:(NSIndexPath*)indexPath andTaskDay:(TaskDay*)taskDay
{
    if(taskDay.finishedAt == 0) {
        NSLog(@"Already finished.");
        return ;
    }
    
    if(taskDay.finishedAt.length > 0) {
        taskDay.finishedAt = @"";
        [self actionReloadTasksViewOnIndexPath:indexPath];
        [[TaskRecordManager taskRecordManager] taskRecordAddRedo:taskDay.taskinfo.sn on:taskDay.dayString committedAt:[NSString stringDateTimeNow]];
    }
    else {
        [self showIndicationText:@"任务未完成, 无需执行重做." inTime:1.0];
    }
}


- (void)actionOnIndexPath:(NSIndexPath*)indexPath byString:(NSString*)actionString
{
    NSLog(@"action on %zd:%zd with string : %@", indexPath.section, indexPath.row, actionString);
    TaskDay *taskDay = [self dataTaskDayOnIndexPath:indexPath];
    if([actionString isEqualToString:@"finish"]) {
        [self actionFinishOnIndexPath:indexPath andTaskDay:taskDay];
        return ;
    }
    
    if([actionString isEqualToString:@"redo"]) {
        [self actionRedoOnIndexPath:indexPath andTaskDay:taskDay];
        return ;
    }
    
    if([actionString isEqualToString:@"edit"]) {
        //编辑时效果. row=0的滚动到row0. row>=1的滚动到row1. 然后计算frame弹出输入框控件.
        //编辑行滚动到最上行.
//        [self.tasksView moveRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        [self.tasksView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        TaskCell *cell = [self.tasksView cellForRowAtIndexPath:indexPath];
        CGRect tmp = [cell.summayView convertRect:cell.summayView.bounds toView:[UIApplication sharedApplication].keyWindow];
        LOG_RECT(tmp, @"---")
        
        UIView *v0 = self.view;
        while(v0) {
            NSLog(@"v0 : %@", v0);
            v0 = [v0 superview];
        }
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 64, VIEW_WIDTH, 100)];
        textView.text = taskDay.taskinfo.content;
        textView.font = [UIFont systemFontOfSize:14.5];
        textView.backgroundColor = [UIColor whiteColor];
        __weak typeof(self) _self = self;
        __weak typeof(textView) _textView = textView;
        [self showPopupView:textView containerAlpha:0.3 dismiss:^{
            [_self actionUpdateTaskContentOn:indexPath to:_textView.text];
        }];
        
        return ;
    }
    
    if([actionString isEqualToString:@"edit"]) {
        TaskCellActionMenu *menu = [[TaskCellActionMenu alloc] initWithFrame:CGRectMake(VIEW_WIDTH * 0.2, 0, VIEW_WIDTH * 0.8, VIEW_HEIGHT)];
        [self.contentView addSubview:menu];
        
        menu.backgroundColor = [UIColor blueColor];
        LOG_VIEW_RECT(menu, @"menu")
        
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
}


- (void)actionUpdateTaskContentOn:(NSIndexPath*)indexPath to:(NSString*)text
{
    //检查内容是否有更改.
    TaskDay *taskDay = [self dataTaskDayOnIndexPath:indexPath];
    if([taskDay.taskinfo.content isEqualToString:text]) {
        
        
        return ;
    }
    
    //根据sn更新数据库存储.
    
    
    //根据sn更新self.tasks数据源.
    
    
    //更新tasksView.
}







@end
