//
//  TaskViewController.m
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskViewController.h"
#import "TaskModel.h"
#import "TaskCell.h"




@interface TaskViewController () <UITableViewDelegate, UITableViewDataSource
                                    >

@property (nonatomic, strong) UITableView *tasksView;



@property (nonatomic, assign) BOOL dayMode;

@property (nonatomic, strong) NSMutableArray<TaskListModel*> *tasks;

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
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.tasksView.frame = self.contentView.bounds;
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
    self.tasksView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
    [self.contentView addSubview:self.tasksView];
    self.tasksView.dataSource   = self;
    self.tasksView.delegate     = self;
    //注册UITableViewCell重用.
    [self.tasksView registerClass:[TaskCell class] forCellReuseIdentifier:@"TaskCell"];
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
    label.text = self.tasks[section].detail;
    [sectionHeaderView addSubview:label];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionSectionTap:)];
    tap.numberOfTapsRequired = 1;
    [sectionHeaderView addGestureRecognizer:tap];
    
    return sectionHeaderView;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 60.0;
    if([self.indexPathDetaied isEqual:indexPath]) {
        height = self.heightDetailedCell;
    }
    
    NSLog(@"---tableview height row : %lf", height);
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = self.tasks.count;
    sections = 4;
    return sections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = self.tasks[section].tasklist.count;
    rows = 6;
    
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
    TaskModel *task = [self dataTaskModeOnIndexPath:indexPath];
    cell.task = task;
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
    self.tasks = [[NSMutableArray alloc] init];
    TaskListModel *list ;
    TaskModel *task ;
    
    for(NSInteger idxList = 0; idxList < 4 ; idxList ++ ) {
        list = [[TaskListModel alloc] init];
        list.detail = [NSString stringWithFormat:@"abc-%zd", idxList];
        list.tasklist = [[NSMutableArray alloc] init];
        for(NSInteger idxTask = 0; idxTask < 6; idxTask ++) {
            task = [[TaskModel alloc] init];
            task.title = [NSString stringWithFormat:@"%zd:%zd-111分十分艰苦的技术开发技术开发设计款发动机风扇肯德基风扇会计法深刻的风景哦日福建省开发经费可是对方离开", idxList, idxTask+1];
            [list.tasklist addObject:task];
        }
        
        [self.tasks addObject:list];
    }
}



- (TaskModel*)dataTaskModeOnIndexPath:(NSIndexPath*)indexPath
{
    TaskListModel *list = self.tasks[indexPath.section];
    TaskModel *task = list.tasklist[indexPath.row];
    return task;
}






- (void)actionMore
{
    
    
    
    
}


- (void)actionOpenDetailedOnIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath *prevIndexPath = self.indexPathDetaied;
    self.indexPathDetaied = indexPath;
    
    [self.tasksView beginUpdates];
    if(prevIndexPath) {
        [self.tasksView reloadRowsAtIndexPaths:@[prevIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tasksView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tasksView endUpdates];
}


- (void)actionCloseDetailedOnIndexPath:(NSIndexPath*)indexPath
{
    self.indexPathDetaied = nil;
    [self.tasksView beginUpdates];
    [self.tasksView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tasksView endUpdates];
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
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self.tasksView beginUpdates];
    [self.tasksView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [self.tasksView endUpdates];
}





- (void)actionOnIndexPath:(NSIndexPath*)indexPath byString:(NSString*)actionString
{
    NSLog(@"action on %zd:%zd with string : %@", indexPath.section, indexPath.row, actionString);
    TaskModel *task = [self dataTaskModeOnIndexPath:indexPath];
    if([actionString isEqualToString:@"finish"]) {
        task.status = 1;
        self.indexPathDetaied = nil;
        [self actionReloadOnIndexPath:indexPath];
        return ;
    }
    
    if([actionString isEqualToString:@"redo"]) {
        if(task.status == 1) {
            task.status = 0;
            [self actionReloadOnIndexPath:indexPath];
        }
        else {
            [self showIndicationText:@"任务未完成, 无需执行重做." inTime:1.0];
        }
        return ;
    }
    
    if([actionString isEqualToString:@"edit"]) {
        TaskCellActionMenu *menu = [[TaskCellActionMenu alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width * 0.2, 0, self.contentView.frame.size.width * 0.8, self.contentView.frame.size.height)];
        [self.contentView addSubview:menu];
        
        menu.backgroundColor = [UIColor blueColor];
        LOG_VIEW_RECT(menu, @"menu")
        
        return ;
    }
    
    
    
}


- (void)actionReloadOnIndexPath:(NSIndexPath*)indexPath
{
    [self.tasksView beginUpdates];
    [self.tasksView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tasksView endUpdates];
}




@end
