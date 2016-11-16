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
        return [self attributedStringForPropertyContent:self.taskDay.taskinfo.committedAt];
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
    self.taskRecords = [[[TaskRecordManager taskRecordManager] taskRecordsOnSn:self.taskDay.taskinfo.sn types:self.taskRecordTypesEnabled] mutableCopy];
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
        [tagText yy_insertString:@"     " atIndex:0];
//        [tagText yy_appendString:((idx+1)%4 == 0)?@"    \n":@"     "];
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
    YYLabel *label;
    if(!labelContainer) {
        labelContainer = [[UIScrollView alloc] init];
        labelContainer.tag = 1000;
        [sectionHeaderView addSubview:labelContainer];
        
        label = [[YYLabel alloc] init];
        [labelContainer addSubview:label];
    }
    
    labelContainer.frame = CGRectMake(0, heightOptions, sectionHeaderView.frame.size.width, heightOptions);
    label.frame = CGRectMake(0, 0, 1000, heightOptions);
    label.attributedText = text;
    CGSize size = [label sizeThatFits:label.frame.size];
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
        contentCell.taskinfo = self.taskDay.taskinfo;
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
}


- (void)actionFinish
{
    if(self.taskDay.finishedAt.length > 0) {
        NSLog(@"Already finished.");
        return ;
    }
    
    self.taskDay.finishedAt = [NSString stringDateTimeNow];
    [self actionReloadTaskContent];
    [[TaskRecordManager taskRecordManager] taskRecordAddFinish:self.taskDay.taskinfo.sn on:self.taskDay.dayString committedAt:self.taskDay.finishedAt];
}


- (void)actionReloadTaskContent
{
    
    
}


- (void)actionRedo
{
    if(self.taskDay.finishedAt == 0) {
        NSLog(@"Already finished.");
        return ;
    }
    
    if(self.taskDay.finishedAt.length > 0) {
        self.taskDay.finishedAt = @"";
        [self actionReloadTaskContent];
        [[TaskRecordManager taskRecordManager] taskRecordAddRedo:self.taskDay.taskinfo.sn on:self.taskDay.dayString committedAt:[NSString stringDateTimeNow]];
    }
    else {
        [self showIndicationText:@"任务未完成, 无需执行重做." inTime:1.0];
    }
}



@end





























































#if 0
@interface TaskRecordView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *taskRecordTableView;
@property (nonatomic, strong) NSMutableArray<TaskRecord*> *taskRecords;

@property (nonatomic, strong) NSMutableArray<NSNumber*> *taskRecordTypes;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *taskRecordTypesEnabled;

@end


@implementation TaskRecordView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self buildSubviews];
        [self initDataMember];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubviews];
        [self initDataMember];
    }
    return self;
}


- (void)initDataMember
{
    self.taskRecordTypes = [[NSMutableArray alloc] init];
    self.taskRecordTypesEnabled = [[NSMutableArray alloc] init];
}


- (void)buildData
{
    LOG_POSTION
    self.taskRecords = [[[TaskRecordManager taskRecordManager] taskRecordsOnSn:self.taskinfo.sn types:self.taskRecordTypesEnabled] mutableCopy];
}


- (void)buildSubviews
{
    self.taskRecordTableView = [[UITableView alloc] init];
    self.taskRecordTableView.dataSource = self;
    self.taskRecordTableView.delegate = self;
    [self.taskRecordTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TaskRecordCell"];
    [self addSubview:self.taskRecordTableView];
}



- (void)layoutSubviews
{
    LOG_POSTION
    self.taskRecordTableView.frame = self.bounds;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45.0)];
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    NSArray *tags = @[@"red", @"orange", @"yellow", @"green", @"blue", @"purple", @"gray"];
    NSArray *tagStrokeColors = @[
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 ];
    NSArray *tagFillColors = @[
                                 [UIColor colorFromString:@"#fb6560"],
                                 [UIColor colorFromString:@"#fb6560"],
                                 [UIColor colorFromString:@"#fb6560"],
                                 [UIColor colorFromString:@"#fb6560"],
                                 [UIColor colorFromString:@"#fb6560"],
                                 [UIColor colorFromString:@"#fb6560"],
                                 [UIColor colorFromString:@"#fb6560"],
                               ];
    
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    for (int idx = 0; idx < self.taskRecordTypes.count; idx ++) {
        NSString *tag = [TaskRecord stringOfType:[self.taskRecordTypes[idx] integerValue]];
        BOOL enabled = (NSNotFound != [self.taskRecordTypesEnabled indexOfObject:self.taskRecordTypes[idx]]);
        UIColor *tagStrokeColor = tagStrokeColors[idx];
        UIColor *tagFillColor = enabled ? tagFillColors[idx] : [UIColor grayColor];
        NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:tag];
        [tagText yy_insertString:@"     " atIndex:0];
        [tagText yy_appendString:((idx+1)%4 == 0)?@"    \n":@"     "];
        [tagText yy_setFont:font range:NSMakeRange(0, tagText.length)];
        [tagText yy_setColor:[UIColor whiteColor] range:NSMakeRange(0, tagText.length)];
        [tagText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:[tagText yy_rangeOfAll]];
        
        YYTextBorder *border = [YYTextBorder new];
        border.strokeWidth = 1.5;
        border.strokeColor = tagStrokeColor;
        border.fillColor = tagFillColor;
        border.cornerRadius = 100; // a huge value
        border.insets = UIEdgeInsetsMake(-2, -5.5, -2, -8);
        [tagText yy_setTextBackgroundBorder:border range:[tagText.string rangeOfString:tag]];
        
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setColor:[UIColor whiteColor]];
//        [highlight setBackgroundBorder:highlightBorder];
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            NSLog(@"Tap - %@", [NSString stringWithFormat:@"Tap: %@",[text.string substringWithRange:range]]);
            NSInteger type = [TaskRecord typeOfString:[text.string substringWithRange:range]];
            if(NSNotFound != type) {
                if(NSNotFound == [self.taskRecordTypesEnabled indexOfObject:@(type)]) {
                    [self setTaskRecordTypes:@[@(type)] triggerOn:YES];
                }
                else {
                    [self setTaskRecordTypes:@[@(type)] triggerOn:NO];
                }
            }
        };
        [tagText yy_setTextHighlight:highlight range:tagText.yy_rangeOfAll];
        
        [text appendAttributedString:tagText];
    }
    [text yy_setLineSpacing:10 range:[text yy_rangeOfAll]];
    [text yy_setLineBreakMode:NSLineBreakByCharWrapping range:[text yy_rangeOfAll]];
    
    [text yy_appendString:@"\n"];
    
    YYTextView *textView = [sectionHeaderView viewWithTag:1000];
    if(!textView) {
        textView = [[YYTextView alloc] init];
        textView.tag = 1000;
        [sectionHeaderView addSubview:textView];
    }
    textView.attributedText = text;
    textView.allowsCopyAttributedString = YES;
    textView.allowsPasteAttributedString = YES;
   // textView.delegate = self;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    textView.scrollIndicatorInsets = textView.contentInset;
    textView.selectedRange = NSMakeRange(text.length, 0);
    textView.frame = CGRectMake(0, 0, VIEW_WIDTH, 60);
    textView.editable = NO;
    
    return sectionHeaderView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 100.0;
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections ;
    sections = 1;
    return sections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    rows = self.taskRecords.count;
    NSLog(@"taskrecord count : %zd", rows);
    return rows;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskRecordCell" forIndexPath:indexPath];
    TaskRecord *taskRecord = self.taskRecords[indexPath.row];
    cell.textLabel.attributedText = [taskRecord generateAttributedString];
    cell.textLabel.numberOfLines = 0;
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


- (void)setTaskinfo:(TaskInfo *)taskinfo
{
    NSLog(@"--- %@", taskinfo.sn);
    _taskinfo = taskinfo;
    [self buildData];
    [self.taskRecordTableView reloadData];
    
}


- (void)setTaskRecordTypes:(NSArray<NSNumber*>*)taskRecordTypes triggerOn:(BOOL)on
{
    NSLog(@"all : %@. enabled : %@", self.taskRecordTypes, self.taskRecordTypesEnabled);
    NSLog(@"set %@ to %zd", taskRecordTypes, on);
    for(NSNumber *taskRecordType in taskRecordTypes) {
        if(NSNotFound == [self.taskRecordTypes indexOfObject:taskRecordType]) {
            [self.taskRecordTypes addObject:taskRecordType];
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
    
    [self buildData];
    [self.taskRecordTableView reloadData];
}



@end

#endif


















#if 0

@interface TaskDetailViewController () <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, strong) UIScrollView *container;

@property (nonatomic, strong) UIView    *taskContentContainer;
@property (nonatomic, strong) UIView    *taskTitleHeader;
@property (nonatomic, strong) UILabel   *taskTitleLabel;
@property (nonatomic, strong) UIButton  *editButton;
@property (nonatomic, strong) UILabel   *taskContentLabel;
@property (nonatomic, strong) UIView    *taskStatus;
@property (nonatomic, strong) UIView    *taskAdditional;


@property (nonatomic, strong) UIButton  *taskScheduleDaysContainer;
@property (nonatomic, strong) UILabel   *taskScheduleDaysLabel;
@property (nonatomic, strong) UIView    *taskScheduleDayStringDisplay;

@property (nonatomic, strong) UIButton  *taskCommittedAtContainer;
@property (nonatomic, strong) UILabel   *taskCommittedAtTitle;
@property (nonatomic, strong) UILabel   *taskCommittedAtContent;

@property (nonatomic, strong) UIButton  *taskRecordContainer;
@property (nonatomic, strong) UILabel   *taskRecordTitle;
@property (nonatomic, strong) UILabel   *taskRecordContent;



@property (nonatomic, strong) TaskRecordView *taskRecordView;



@end



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //申请各成员.
    self.container              = [[UIScrollView alloc] init] ;
    self.container.hidden = YES;
    self.taskContentContainer   = [[UIView alloc] init] ;
    
    self.taskTitleHeader        = [[UIView alloc] init] ;
    self.taskTitleLabel         = [[UILabel alloc] init] ;
    self.editButton             = [[UIButton alloc] init] ;
    self.taskContentLabel       = [[UILabel alloc] init] ;
    self.taskStatus             = [[UIView alloc] init] ;
    self.taskAdditional         = [[UIView alloc] init] ;
    
    self.taskScheduleDaysContainer      = [[UIButton alloc] init] ;
    self.taskScheduleDaysLabel          = [[UILabel alloc] init];
    self.taskScheduleDayStringDisplay   = [[UIView alloc] init];
    
    self.taskCommittedAtContainer   = [[UIButton alloc] init];
    self.taskCommittedAtTitle       = [[UILabel alloc] init];
    self.taskCommittedAtContent     = [[UILabel alloc] init];
    
    self.taskRecordContainer    = [[UIButton alloc] init];
    self.taskRecordTitle        = [[UILabel alloc] init];
    self.taskRecordContent      = [[UILabel alloc] init];
    
    self.taskRecordView         = [[TaskRecordView alloc] init];
    self.taskRecordView.taskinfo = self.taskinfo;
    [self.taskRecordView setTaskRecordTypes:@[@0, @1, @2, @3, @4, @5, @6 ] triggerOn:YES];
    
    [self addSubview:self.container];
    [self.container addSubview:self.taskContentContainer];
    [self.container addSubview:self.taskTitleHeader];
    [self.container addSubview:self.taskTitleLabel];
    [self.container addSubview:self.editButton];
    [self.container addSubview:self.taskContentLabel];
    [self.container addSubview:self.taskStatus];
    [self.container addSubview:self.taskAdditional];
    
    [self.container addSubview:self.taskScheduleDaysContainer];
    [self.container addSubview:self.taskScheduleDaysLabel];
    [self.container addSubview:self.taskScheduleDayStringDisplay];
    
    [self.container addSubview:self.taskCommittedAtContainer];
    [self.container addSubview:self.taskCommittedAtTitle];
    [self.container addSubview:self.taskCommittedAtContent];
    
    [self.container addSubview:self.taskRecordContainer];
    [self.container addSubview:self.taskRecordTitle];
    [self.container addSubview:self.taskRecordContent];
    
    [self.container addSubview:self.taskRecordView];
    
    self.taskContentContainer.backgroundColor = [UIColor colorWithName:@"TaskDetailContentContainerBackground"];
    
    self.taskScheduleDaysContainer.backgroundColor  = [UIColor colorWithName:@"TaskDetailPropertyContainerBackground"];
    self.taskCommittedAtContainer.backgroundColor   = [UIColor colorWithName:@"TaskDetailPropertyContainerBackground"];
    self.taskRecordContainer.backgroundColor        = [UIColor colorWithName:@"TaskDetailPropertyContainerBackground"];
    
    self.taskScheduleDayStringDisplay.userInteractionEnabled =  NO;
    [self.taskScheduleDaysContainer addTarget:self action:@selector(actionClickScheduleDays) forControlEvents:UIControlEventTouchDown];
    
    
    {
        NSString *taskTitleString = @"Task";
        NSMutableAttributedString *attributedTitleString = [[NSMutableAttributedString alloc] initWithString:taskTitleString];
        [attributedTitleString addAttribute:NSExpansionAttributeName value:@0 range:NSMakeRange(0, taskTitleString.length)];
        NSMutableParagraphStyle * paragraphStyleTitle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyleTitle setHeadIndent:20];
        [paragraphStyleTitle setFirstLineHeadIndent:20];
        [paragraphStyleTitle setTailIndent:-20];
        [attributedTitleString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleTitle range:NSMakeRange(0, taskTitleString.length)];
        [attributedTitleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TaskDetailTitle"] range:NSMakeRange(0, taskTitleString.length)];
        [attributedTitleString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithName:@"TaskDetailText"] range:NSMakeRange(0, taskTitleString.length)];
        self.taskTitleLabel.attributedText = attributedTitleString;
    }
    
    {
        NSString *taskContentString = self.taskinfo.content;
        NSMutableAttributedString *attributedContentString = [[NSMutableAttributedString alloc] initWithString:taskContentString];
        [attributedContentString addAttribute:NSExpansionAttributeName value:@0 range:NSMakeRange(0, taskContentString.length)];
        NSMutableParagraphStyle * paragraphStyleContent = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyleContent setHeadIndent:20];
        [paragraphStyleContent setFirstLineHeadIndent:20];
        [paragraphStyleContent setTailIndent:-20];
        [attributedContentString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleContent range:NSMakeRange(0, taskContentString.length)];
        [attributedContentString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TaskDetailContent"] range:NSMakeRange(0, taskContentString.length)];
        [attributedContentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithName:@"TaskDetailText"] range:NSMakeRange(0, taskContentString.length)];
        self.taskContentLabel.attributedText = attributedContentString;
        self.taskContentLabel.numberOfLines = 0;
    }
    
    NSDictionary *dictTitles = @{
                                 @"任务时间" : self.taskScheduleDaysLabel,
                                 @"提交时间" : self.taskCommittedAtTitle,
                                 @"任务纪录" : self.taskRecordTitle,
                                 };
    for(NSString *title in dictTitles.allKeys)
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
        UILabel *label = dictTitles[title];
        label.attributedText = attributedString;
        label.numberOfLines = 0;
    }
    
    [self actionUpdateTaskScheduleDaysContent];
    [self actionUpdateCommittedAtContent];
    [self actionUpdateRecordContent];
    
    self.contentTableView = [[UITableView alloc] init];
    
    self.contentTableView = [[UITableView alloc] init];
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
    [self addSubview:self.contentTableView];
    [self.contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TaskRecordCell0"];
    [self.contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TaskRecordCell1"];
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.contentTableView.frame = self.contentView.bounds;
    
    self.container.frame = VIEW_BOUNDS;
    self.container.contentSize = CGSizeMake(VIEW_WIDTH, 1000);
    
    self.taskContentLabel.frame = CGRectMake(0, 0, VIEW_WIDTH, 1000);
    CGSize sizeFitContentLabel = [self.taskContentLabel sizeThatFits:VIEW_SIZE];
    NSLog(@"opt height : %lf", sizeFitContentLabel.height);
    
    FrameLayout *f = [[FrameLayout alloc] initWithRootView:self.container];
    [f frameLayoutHerizon:FRAMELAYOUT_NAME_MAIN
         toNameAndHeights:@[
                            @"HeaderPadding",@"v:51",
                            @"TitleLine", @"v:60",
                            @"ContentLabel", [NSString stringWithFormat:@"v:%f", sizeFitContentLabel.height],
                            @"Status",@"v:45",
                            @"Additonal",@"v:45",
                            @"",@"v:1",
                            @"ScheduleDaysLabel", @"v:36",
                            @"ScheduleDaysDisplayView", @"v:36",
                            @"",@"v:1",
                            @"TaskCommittedAtTitle", @"v:36",
                            @"TaskCommittedAtContent", @"v:36",
                            @"",@"v:1",
                            @"TaskRecordTitle", @"v:36",
                            @"TaskRecordContent", @"v:36",
                            @"",@"v:1",
                            @"TaskRecordView", @"v:200"
                            ]
     ];
    
    [f frameLayout:@"TitleLine" toVertical:@[@"Title", @"EditButton", @""] withPercentages:@[@0.72, @0.28]];
    [f frameLayoutSet:@"ContentContainer" containNames:@[@"HeaderPadding", @"Title", @"ContentLabel", @"Status", @"Additonal"]];
    [f frameLayoutSet:@"ScheduleDaysContainer" containNames:@[@"ScheduleDaysLabel", @"ScheduleDaysDisplayView"]];
    [f frameLayoutSet:@"CommittedAtContainer" containNames:@[@"TaskCommittedAtTitle", @"TaskCommittedAtContent"]];
    [f frameLayoutSet:@"TaskRecordContainer" containNames:@[@"TaskRecordTitle", @"TaskRecordContent"]];
    
    FrameAssign(self.taskContentContainer, @"ContentContainer", f)
    FrameAssign(self.taskTitleHeader, @"HeaderPadding", f)
    FrameAssign(self.taskTitleLabel, @"Title", f)
    FrameAssign(self.taskContentLabel, @"ContentLabel", f)
    FrameAssign(self.taskStatus, @"Status", f)
    FrameAssign(self.taskAdditional, @"Additonal", f)
    
    FrameAssign(self.taskScheduleDaysContainer, @"ScheduleDaysContainer", f)
    FrameAssign(self.taskScheduleDaysLabel, @"ScheduleDaysLabel", f)
    FrameAssign(self.taskScheduleDayStringDisplay, @"ScheduleDaysDisplayView", f)
    
    FrameAssign(self.taskCommittedAtContainer, @"CommittedAtContainer", f)
    FrameAssign(self.taskCommittedAtTitle, @"TaskCommittedAtTitle", f)
    FrameAssign(self.taskCommittedAtContent, @"TaskCommittedAtContent", f)
    
    FrameAssign(self.taskRecordContainer, @"TaskRecordContainer", f)
    FrameAssign(self.taskRecordTitle, @"TaskRecordTitle", f)
    FrameAssign(self.taskRecordContent, @"TaskRecordContent", f)
    
    FrameAssign(self.taskRecordView, @"TaskRecordView", f)
    
    
    
    NSLog(@"%@", f);
    
    NSLog(@"%@", self.taskCommittedAtTitle);
    NSLog(@"%@", self.taskCommittedAtTitle.attributedText);
    
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45.0)];
#if 0
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    NSArray *tags = @[@"red", @"orange", @"yellow", @"green", @"blue", @"purple", @"gray"];
    NSArray *tagStrokeColors = @[
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 [UIColor colorFromString:@"#fa3f39"],
                                 ];
    NSArray *tagFillColors = @[
                               [UIColor colorFromString:@"#fb6560"],
                               [UIColor colorFromString:@"#fb6560"],
                               [UIColor colorFromString:@"#fb6560"],
                               [UIColor colorFromString:@"#fb6560"],
                               [UIColor colorFromString:@"#fb6560"],
                               [UIColor colorFromString:@"#fb6560"],
                               [UIColor colorFromString:@"#fb6560"],
                               ];
    
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    for (int idx = 0; idx < self.taskRecordTypes.count; idx ++) {
        NSString *tag = [TaskRecord stringOfType:[self.taskRecordTypes[idx] integerValue]];
        BOOL enabled = (NSNotFound != [self.taskRecordTypesEnabled indexOfObject:self.taskRecordTypes[idx]]);
        UIColor *tagStrokeColor = tagStrokeColors[idx];
        UIColor *tagFillColor = enabled ? tagFillColors[idx] : [UIColor grayColor];
        NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:tag];
        [tagText yy_insertString:@"     " atIndex:0];
        [tagText yy_appendString:((idx+1)%4 == 0)?@"    \n":@"     "];
        [tagText yy_setFont:font range:NSMakeRange(0, tagText.length)];
        [tagText yy_setColor:[UIColor whiteColor] range:NSMakeRange(0, tagText.length)];
        [tagText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:[tagText yy_rangeOfAll]];
        
        YYTextBorder *border = [YYTextBorder new];
        border.strokeWidth = 1.5;
        border.strokeColor = tagStrokeColor;
        border.fillColor = tagFillColor;
        border.cornerRadius = 100; // a huge value
        border.insets = UIEdgeInsetsMake(-2, -5.5, -2, -8);
        [tagText yy_setTextBackgroundBorder:border range:[tagText.string rangeOfString:tag]];
        
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setColor:[UIColor whiteColor]];
        //        [highlight setBackgroundBorder:highlightBorder];
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            NSLog(@"Tap - %@", [NSString stringWithFormat:@"Tap: %@",[text.string substringWithRange:range]]);
            NSInteger type = [TaskRecord typeOfString:[text.string substringWithRange:range]];
            if(NSNotFound != type) {
                if(NSNotFound == [self.taskRecordTypesEnabled indexOfObject:@(type)]) {
                    [self setTaskRecordTypes:@[@(type)] triggerOn:YES];
                }
                else {
                    [self setTaskRecordTypes:@[@(type)] triggerOn:NO];
                }
            }
        };
        [tagText yy_setTextHighlight:highlight range:tagText.yy_rangeOfAll];
        
        [text appendAttributedString:tagText];
    }
    [text yy_setLineSpacing:10 range:[text yy_rangeOfAll]];
    [text yy_setLineBreakMode:NSLineBreakByCharWrapping range:[text yy_rangeOfAll]];
    
    [text yy_appendString:@"\n"];
    
    YYTextView *textView = [sectionHeaderView viewWithTag:1000];
    if(!textView) {
        textView = [[YYTextView alloc] init];
        textView.tag = 1000;
        [sectionHeaderView addSubview:textView];
    }
    textView.attributedText = text;
    textView.allowsCopyAttributedString = YES;
    textView.allowsPasteAttributedString = YES;
    // textView.delegate = self;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    textView.scrollIndicatorInsets = textView.contentInset;
    textView.selectedRange = NSMakeRange(text.length, 0);
    textView.frame = CGRectMake(0, 0, VIEW_WIDTH, 60);
    textView.editable = NO;
#endif
    return sectionHeaderView;
}





#endif