//
//  TaskDetailViewController.m
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "TaskModel.h"





@interface TaskDetailViewController () {
    UIView *_xxx;
    
}


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



@implementation TaskDetailViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //申请各成员.
    self.container              = [[UIScrollView alloc] init] ;
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
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
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
    self.title = @"";
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
    NSString *s = @"2016-11-07 12:34:56";
    self.taskCommittedAtContent.attributedText = [self attributedStringForPropertyContent:s];
}


- (void)actionUpdateRecordContent
{
    
    
}




@end




























































@interface TaskRecordView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *taskRecordTableView;
@property (nonatomic, strong) NSMutableArray<TaskRecord*> *taskRecords;
@end


@implementation TaskRecordView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self buildSubviews];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubviews];
    }
    return self;
}


- (void)buildData
{
    self.taskRecords = [[[TaskRecordManager taskRecordManager] taskRecordsOnSn:self.taskinfo.sn types:@[@0, @1]] mutableCopy];
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
    return 45.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45.0)];
    return sectionHeaderView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 45.0;
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
    cell.textLabel.text = [NSString stringWithFormat:@"%zd", taskRecord.type];
    cell.detailTextLabel.text = taskRecord.committedAt;
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



@end
