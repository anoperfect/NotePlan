//
//  TaskRecordViewController.m
//  NoteTask
//
//  Created by Ben on 16/11/1.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskRecordViewController.h"
#import "TaskCell.h"





@interface TaskRecordViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray<TaskRecord*> *taskRecords;

@property (nonatomic, strong) NSArray<NSNumber*> *taskRecordTypesSortOrder;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *taskRecordTypes;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *taskRecordTypesEnabled;

@property (nonatomic, strong) NSMutableDictionary<NSIndexPath*,NSNumber*> *optumizeHeights;

@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, assign) BOOL moveToBottom; //直接执行一次移动到底部, 可能不能执行到.
@end

@implementation TaskRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //申请各成员.
    self.optumizeHeights = [[NSMutableDictionary alloc] init];
    
    self.taskRecordTypesSortOrder =
    @[
      @(TaskRecordTypeCreate) ,
      @(TaskRecordTypeSignIn),
      @(TaskRecordTypeSignOut),
      @(TaskRecordTypeUserModify),
      @(TaskRecordTypeUserDelete),
      @(TaskRecordTypeUserRecord),
      @(TaskRecordTypeLocalReminder),
      @(TaskRecordTypeRemoteReminder),
      @(TaskRecordTypeFinish),
      @(TaskRecordTypeRedo),
      ];
    
    self.taskRecordTypes = [self.taskRecordTypesSortOrder  mutableCopy];
    self.taskRecordTypesEnabled = [[NSMutableArray alloc] init];
    
    [self setTaskRecordTypes:@[
                               @(TaskRecordTypeCreate) ,
                               @(TaskRecordTypeSignIn),
                               @(TaskRecordTypeSignOut),
                               @(TaskRecordTypeUserModify),
                               @(TaskRecordTypeUserDelete),
                               @(TaskRecordTypeUserRecord),
                               @(TaskRecordTypeLocalReminder),
                               @(TaskRecordTypeRemoteReminder),
                               @(TaskRecordTypeFinish),
                               @(TaskRecordTypeRedo),
                               ] triggerOn:YES reload:NO];
    
    
    
    
#if 0
    [self setTaskRecordTypes:@[
                               @(TaskRecordTypeSignIn),
                               @(TaskRecordTypeSignOut),
                               @(TaskRecordTypeCreate),
                               @(TaskRecordTypeRedo),
                               ] triggerOn:NO reload:NO];
#endif
    
    [self updateTaskRecordsData];
    
    self.contentTableView = [[UITableView alloc] init];
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
//    self.contentTableView.bounces = NO;
    [self addSubview:self.contentTableView];
    [self.contentTableView registerClass:[TaskRecordCell         class] forCellReuseIdentifier:@"TaskRecordCell"        ];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.taskRecords.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.contentTableView.frame = VIEW_BOUNDS;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"记录";
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}


- (void)setTaskRecordTypes:(NSArray<NSNumber*>*)taskRecordTypes triggerOn:(BOOL)on reload:(BOOL)reload
{
    for(NSNumber *taskRecordType in taskRecordTypes) {
        if(NSNotFound == [self.taskRecordTypes indexOfObject:taskRecordType]) {
            continue;
        }
        
        if(on && NSNotFound == [self.taskRecordTypesEnabled indexOfObject:taskRecordType]) {
            [self.taskRecordTypesEnabled addObject:taskRecordType];
        }
        else if(!on && NSNotFound != [self.taskRecordTypesEnabled indexOfObject:taskRecordType]) {
            [self.taskRecordTypesEnabled removeObject:taskRecordType];
        }
        else {
            NSLog(@"#error - ");
        }
    }
    
    [self updateTaskRecordsData];
    
    if(reload) {
        [self.contentTableView reloadData];
    }
}


- (void)updateTaskRecordsData
{
    self.taskRecords = [[[TaskRecordManager taskRecordManager] taskRecordsOnSn:self.taskinfo.sn types:self.taskRecordTypesEnabled] mutableCopy];
    [[TaskRecordManager taskRecordManager] taskRecordSort:self.taskRecords byModifiedAtAscend:YES];
    NSLog(@"rrrrrr : %zd", self.taskRecords.count);
}


- (TaskRecord*)taskRecordOnIndexPath:(NSIndexPath*)indexPath
{
    NSInteger idx = indexPath.row;
    if(NSNotFound != idx && idx < self.taskRecords.count) {
        return self.taskRecords[idx];
    }
    else {
        return nil;
    }
}




- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 72.0)];
    sectionHeaderView.backgroundColor = [UIColor colorWithName:@"TaskDetailRecordHeaderBackground"];
    
    return sectionHeaderView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 200.0;
    NSNumber *heightNumber = [self.optumizeHeights objectForKey:indexPath];
    if([heightNumber isKindOfClass:[NSNumber class]]) {
        height = [heightNumber floatValue];
    }
    
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 1;
    return sections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    rows = self.taskRecords.count;
    NSLog(@"rows : %zd", rows);
    return rows;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskRecordCell *recordCell = [tableView dequeueReusableCellWithIdentifier:@"TaskRecordCell" forIndexPath:indexPath];
    TaskRecord *taskRecord = [self taskRecordOnIndexPath:indexPath];
    recordCell.taskRecord = taskRecord;
    self.optumizeHeights[indexPath] = @(recordCell.frame.size.height);
    return recordCell;
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


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.taskRecords.count - 1 && !self.moveToBottom) {
        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.taskRecords.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        self.moveToBottom = YES;
    }
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
