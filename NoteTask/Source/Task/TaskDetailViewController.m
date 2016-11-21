//
//  TaskDetailViewController.m
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "TaskModel.h"
#import "TaskCell.h"
#import "TaskRecordViewController.h"



@interface TaskDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *contentTableView;
/*
TaskContent 
TaskProperty
TaskRecordSummary
TaskRecord
 */
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath*,NSNumber*> *optumizeHeights;


@property (nonatomic, strong) NSMutableArray<TaskRecord*> *taskRecords;

@property (nonatomic, strong) NSArray<NSNumber*> *taskRecordTypesSortOrder;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *taskRecordTypes;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *taskRecordTypesEnabled;

@end



@implementation TaskDetailViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self test];
    });
    
    //申请各成员.
    self.optumizeHeights = [[NSMutableDictionary alloc] init];
    
    self.taskRecordTypesSortOrder =
                            @[
                              @(TaskRecordTypeUserRecord),
                              @(TaskRecordTypeFinish),
                              @(TaskRecordTypeSignIn),
                              @(TaskRecordTypeSignOut),
                              @(TaskRecordTypeCreate),
                              @(TaskRecordTypeRedo),
                              ];
    
    self.taskRecordTypes = [self.taskRecordTypesSortOrder  mutableCopy];
    self.taskRecordTypesEnabled = [[NSMutableArray alloc] init];
    
    [self setTaskRecordTypes:@[
                               @(TaskRecordTypeUserRecord),
                               @(TaskRecordTypeFinish),
                               ] triggerOn:YES reload:NO];
    
    [self setTaskRecordTypes:@[
                               @(TaskRecordTypeSignIn),
                               @(TaskRecordTypeSignOut),
                               @(TaskRecordTypeCreate),
                               @(TaskRecordTypeRedo),
                               ] triggerOn:NO reload:NO];
    
    [self updateTaskRecordsData];
    
    self.contentTableView = [[UITableView alloc] init];
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
    [self addSubview:self.contentTableView];
    [self.contentTableView registerClass:[UITableViewCell        class] forCellReuseIdentifier:@"TaskDetailDefaultCell" ];
    [self.contentTableView registerClass:[TaskDetailContentCell  class] forCellReuseIdentifier:@"TaskDetailContentCell" ];
    [self.contentTableView registerClass:[TaskDetailPropertyCell class] forCellReuseIdentifier:@"TaskDetailPropertyCell"];
    [self.contentTableView registerClass:[TaskRecordCell         class] forCellReuseIdentifier:@"TaskRecordCell"        ];
    
    
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
    
    [self.contentTableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = @"";
}


- (NSArray*)taskPropertyTitles
{
    NSArray *titles = @[
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
    if([title isEqualToString:@"任务时间"]) {
        return [self attributedStringForPropertyContent:@"2016-11-01"];
    }
    
    if([title isEqualToString:@"提交时间"]) {
        return [self attributedStringForPropertyContent:self.taskinfo.committedAt];
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
    [attributedString addAttribute:NSExpansionAttributeName value:@0 range:NSMakeRange(0, title.length)];
    NSMutableParagraphStyle * paragraphStyleContent = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleContent setHeadIndent:20];
    [paragraphStyleContent setFirstLineHeadIndent:20];
    [paragraphStyleContent setTailIndent:-20];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleContent range:NSMakeRange(0, title.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TaskPropertyTitleLabel"] range:NSMakeRange(0, title.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithName:@"TaskDetailText"] range:NSMakeRange(0, title.length)];
    
    return attributedString;
}


- (NSMutableAttributedString*)attributedStringForPropertyContent:(NSString*)content
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedString addAttribute:NSExpansionAttributeName value:@0 range:NSMakeRange(0, content.length)];
    NSMutableParagraphStyle * paragraphStyleContent = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleContent setHeadIndent:20];
    [paragraphStyleContent setFirstLineHeadIndent:20];
    [paragraphStyleContent setTailIndent:-20];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleContent range:NSMakeRange(0, content.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TaskPropertyContentLabel"] range:NSMakeRange(0, content.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithName:@"TaskDetailText"] range:NSMakeRange(0, content.length)];
    
    return attributedString;
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


- (void)setTaskRecordTypes:(NSArray<NSNumber*>*)taskRecordTypes triggerOn:(BOOL)on reload:(BOOL)reload
{
    NSLog(@"all : %@. enabled : %@", self.taskRecordTypes, self.taskRecordTypesEnabled);
    NSLog(@"set %@ to %zd", taskRecordTypes, on);
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
    
    
    NSLog(@"all : %@. enabled : %@", self.taskRecordTypes, self.taskRecordTypesEnabled);
    
    [self updateTaskRecordsData];
    
    if(reload) {
        [self.contentTableView reloadData];
    }
}


- (void)updateTaskRecordsData
{
    self.taskRecords = [[[TaskRecordManager taskRecordManager] taskRecordsOnSn:self.taskinfo.sn types:self.taskRecordTypesEnabled] mutableCopy];
    [[TaskRecordManager taskRecordManager] taskRecordSort:self.taskRecords byModifiedAtAscend:NO];
    NSLog(@"rrrrrr : %zd", self.taskRecords.count);
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return 0;
    }
    return 72.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 72.0)];
    sectionHeaderView.backgroundColor = [UIColor colorWithName:@"TaskDetailRecordHeaderBackground"];
    
    //标题.
    CGFloat heightTitle = 36;
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sectionHeaderView.frame.size.width, heightTitle)];
    [sectionHeaderView addSubview:labelTitle];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [attributedString appendAttributedString:[self attributedStringForPropertyTitle:@"任务记录"]];
    [attributedString appendAttributedString:[NSString attributedStringWith:[NSString stringWithFormat:@" (共%zd条) ", self.taskRecords.count]
                                                                       font:[UIFont fontWithName:@"CustomTextColor"]
                                                                  textColor:[UIColor colorWithName:@"CustomTextColor"]
                                                            backgroundColor:nil
                                                                     indent:20]];
    labelTitle.attributedText = attributedString;
    
    
    
    
    
    
    //类型筛选. 使用YYLabel+Link的方式. 应该用一排button或者横向tableview可以.
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    UIColor *colorEnabled = [UIColor colorWithName:@"TaskDetailRecordTypeEnabledBackground"];
    UIColor *colorDisabled = [UIColor colorWithName:@"TaskDetailRecordTypeDisabledBackground"];
    for (int idx = 0; idx < self.taskRecordTypes.count; idx ++) {
        NSString *tag = [TaskRecord stringOfType:[self.taskRecordTypes[idx] integerValue]];
        BOOL enabled = (NSNotFound != [self.taskRecordTypesEnabled indexOfObject:self.taskRecordTypes[idx]]);
        UIColor *tagStrokeColor = colorEnabled;
        UIColor *tagFillColor = enabled ? colorEnabled : colorDisabled;
        NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:tag];
        [tagText yy_insertString:@"  " atIndex:0];
        [tagText yy_appendString:@"  "];
        [tagText yy_setFont:font range:NSMakeRange(0, tagText.length)];
        [tagText yy_setColor:[UIColor colorWithName:@"TaskRecordTimeLine"] range:NSMakeRange(0, tagText.length)];
        [tagText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:[tagText yy_rangeOfAll]];
        
        YYTextBorder *border = [YYTextBorder new];
        border.strokeWidth = 2;
        border.strokeColor = tagStrokeColor;
        border.strokeColor = [UIColor clearColor];
        border.fillColor = tagFillColor;
        border.strokeColor = tagFillColor;
        border.fillColor = [UIColor clearColor];
        border.cornerRadius = 1; // a huge value
        border.insets = UIEdgeInsetsMake(-2, -2, -2, -2);
        [tagText yy_setTextBackgroundBorder:border range:[tagText.string rangeOfString:tag]];
        
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setColor:[UIColor whiteColor]];
        //        [highlight setBackgroundBorder:highlightBorder];
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            NSLog(@"Tap - %@", [NSString stringWithFormat:@"Tap: %@",[text.string substringWithRange:range]]);
            NSInteger type = [TaskRecord typeOfString:[text.string substringWithRange:range]];
            if(NSNotFound != type) {
                if(NSNotFound == [self.taskRecordTypesEnabled indexOfObject:@(type)]) {
                    [self setTaskRecordTypes:@[@(type)] triggerOn:YES reload:YES];
                }
                else {
                    [self setTaskRecordTypes:@[@(type)] triggerOn:NO reload:YES];
                }
            }
        };
        [tagText yy_setTextHighlight:highlight range:tagText.yy_rangeOfAll];
        
        [text appendAttributedString:tagText];
    }
    [text yy_setLineSpacing:10 range:[text yy_rangeOfAll]];
    [text yy_setLineBreakMode:NSLineBreakByCharWrapping range:[text yy_rangeOfAll]];
    
//    [text yy_appendString:@"\n"];
    
    CGFloat heightOptions = 36;
    
    UIScrollView *labelContainer = [sectionHeaderView viewWithTag:1000];
    YYTextView *label;
    if(!labelContainer) {
        labelContainer = [[UIScrollView alloc] init];
        labelContainer.tag = 1000;
        [sectionHeaderView addSubview:labelContainer];
        
        label = [[YYTextView alloc] init];
        [labelContainer addSubview:label];
    }
    
    [labelContainer setShowsHorizontalScrollIndicator:NO];
    labelContainer.frame = CGRectMake(0, heightOptions, sectionHeaderView.frame.size.width, heightOptions);
    label.frame = CGRectMake(0, 0, 1000, heightOptions);
    label.attributedText = text;
    label.editable = NO;
    CGSize size = [label sizeThatFits:label.frame.size];
    NSLog(@"---%f", size.width);
    //填充的边框会超过几个像素.
    label.frame = CGRectMake(0, 0, size.width + 6, heightOptions);
    labelContainer.contentSize = label.frame.size;
    
    return sectionHeaderView;
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
    sections = 2;
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
        rows = 10;
    }
    else if(section == 1) {
        rows = self.taskRecords.count;
    }
    return rows;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        return contentCell;
    }
    
    NSInteger idx = 0;
    if(NSNotFound != (idx=[self tableViewCellIndexOfTaskPropertyAtIndexPath:indexPath])) {
        TaskDetailPropertyCell *propertyCell = [tableView dequeueReusableCellWithIdentifier:@"TaskDetailPropertyCell" forIndexPath:indexPath];
        NSString *title = [self taskPropertyTitles][idx];
        [propertyCell setTitle:[self attributedStringForPropertyTitle:title]
                       content:[self attributedStringForPropertyContentOfTitle:title]
         ];
        self.optumizeHeights[indexPath] = @(propertyCell.frame.size.height);
        return propertyCell;
    }
    
    if(NSNotFound != (idx=[self tableViewCellIndexOfTaskRecordAtIndexPath:indexPath])) {
        TaskRecordCell *recordCell = [tableView dequeueReusableCellWithIdentifier:@"TaskRecordCell" forIndexPath:indexPath];
        TaskRecord *taskRecord = [self taskRecordOnIndexPath:indexPath];
        recordCell.taskRecord = taskRecord;
        self.optumizeHeights[indexPath] = @(recordCell.frame.size.height);
        return recordCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskDetailDefaultCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%zd:%zd", indexPath.section, indexPath.row];
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


- (TaskRecord*)taskRecordOnIndexPath:(NSIndexPath*)indexPath
{
    NSInteger idx = [self tableViewCellIndexOfTaskRecordAtIndexPath:indexPath];
    if(NSNotFound != idx && idx < self.taskRecords.count) {
        return self.taskRecords[idx];
    }
    else {
        return nil;
    }
}


- (void)actionStringOnTaskContent:(NSString*)actionString
{
    NSLog(@"action string : %@", actionString);
    [self transitionToTaskRecordViewController];
}


- (void)transitionToTaskRecordViewController
{
    TaskRecordViewController *vc = [[TaskRecordViewController alloc] init];
    vc.taskinfo = self.taskinfo;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)actionFinish
{
//    if(self.taskDay.finishedAt.length > 0) {
//        NSLog(@"Already finished.");
//        return ;
//    }
//    
//    self.taskDay.finishedAt = [NSString stringDateTimeNow];
//    [self actionReloadTaskContent];
//    [[TaskRecordManager taskRecordManager] taskRecordAddFinish:self.taskinfo.sn on:self.taskDay.dayString committedAt:self.taskDay.finishedAt];
}


- (void)actionReloadTaskContent
{
    
    
}


- (void)actionRedo
{
//    if(self.taskDay.finishedAt == 0) {
//        NSLog(@"Already finished.");
//        return ;
//    }
//    
//    if(self.taskDay.finishedAt.length > 0) {
//        self.taskDay.finishedAt = @"";
//        [self actionReloadTaskContent];
//        [[TaskRecordManager taskRecordManager] taskRecordAddRedo:self.taskinfo.sn on:self.taskDay.dayString committedAt:[NSString stringDateTimeNow]];
//    }
//    else {
//        [self showIndicationText:@"任务未完成, 无需执行重做." inTime:1.0];
//    }
}


- (void)test
{return ;
    LOG_POSTION
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    
    if(1) {
        NSString *tag = @"完成";
        UIColor *tagStrokeColor = [UIColor blueColor];
        UIColor *tagFillColor = [UIColor clearColor];
        NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:tag];
        [tagText yy_insertString:@"   " atIndex:0];
        [tagText yy_appendString:@"   "];
        [tagText yy_setFont:font range:[tagText yy_rangeOfAll]];
        [tagText yy_setColor:[UIColor whiteColor] range:[tagText yy_rangeOfAll]];
        [tagText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:tagText.yy_rangeOfAll];
        
        YYTextBorder *border = [YYTextBorder new];
        border.strokeWidth = 1.5;
        border.strokeColor = tagStrokeColor;
        border.fillColor = tagFillColor;
        border.cornerRadius = 100; // a huge value
        border.insets = UIEdgeInsetsMake(-2, -5.5, -2, -8);
        [tagText yy_setTextBackgroundBorder:border range:[tagText.string rangeOfString:tag]];
        [text appendAttributedString:tagText];
    }
    
    //YYTextView *v = [[YYTextView alloc] initWithFrame:self.contentView.bounds];
    //[self addSubview:v];
    //v.attributedText = text;
    
    YYLabel *v = [[YYLabel alloc] initWithFrame:self.contentView.bounds];
    [self addSubview:v];
    v.attributedText = text;
    
}




@end








