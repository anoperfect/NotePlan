//
//  TaskCellTableViewCell.m
//  NoteTask
//
//  Created by Ben on 16/10/18.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskCell.h"
#import "TaskModel.h"





#if 0
static void myCalculateShadingValues (void *info,
                                      const CGFloat *in,
                                      CGFloat *out)
{
    CGFloat v;
    size_t k, components;
    static const CGFloat c[] = {1, 0, .5, 0 };
    
    components = (size_t)info;
    
    v = *in;
    for (k = 0; k < components -1; k++)
        *out++ = c[k] * v;
    *out++ = 1;
}


static CGFunctionRef myGetFunction (CGColorSpaceRef colorspace)
{
    size_t numComponents;
    static const CGFloat input_value_range [2] = { 0, 1 };
    static const CGFloat output_value_ranges [8] = { 0, 1, 0, 1, 0, 1, 0, 1 };
    static const CGFunctionCallbacks callbacks = { 0,
        &myCalculateShadingValues,
        NULL };
    
    numComponents = 1 + CGColorSpaceGetNumberOfComponents (colorspace);
    return CGFunctionCreate ((void *) numComponents,
                             1,
                             input_value_range,
                             numComponents,
                             output_value_ranges,
                             &callbacks);
}
#endif


@interface TaskCell ()

@property (nonatomic, strong) id data;
@property (nonatomic, strong) TaskInfo *taskinfo;

@property (nonatomic, assign) BOOL detailedMode;
@property (nonatomic, strong) void(^actionOn)(NSString*);

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UIView *statusView;
@property (nonatomic, strong) UILabel *summayView;


@property (nonatomic, strong) UIToolbar *actionsMenu;
@property (nonatomic, strong) UIView *actionsContainer;

@end


@implementation TaskCell




- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    NSLog(@"111");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.container = [[UIView alloc] init];
        [self addSubview:self.container];
        
        self.summayView = [[UILabel alloc] init];
        [self.container addSubview:self.summayView];
        
        self.actionsMenu = [[UIToolbar alloc] init];
        [self.container addSubview:self.actionsMenu];
        
        self.actionsContainer = [[UIView alloc] init];
        [self.container addSubview:self.actionsContainer];
        
    }
    return self;
}


- (void)setTaskInfoArrange:(TaskInfoArrange*)taskInfoArrange
{
    _data = taskInfoArrange;
    _taskinfo = taskInfoArrange.taskinfo;
    
    CGRect frameCell = self.frame;
    UIEdgeInsets edgeContainer = UIEdgeInsetsMake(10, 10, 0, 10);
    UIEdgeInsets edgeSummary = UIEdgeInsetsMake(10, 64, 10, 10);

    CGRect frameContainer = self.bounds;
    frameContainer = UIEdgeInsetsInsetRect(frameContainer, edgeContainer);
    CGRect frameSummary = UIEdgeInsetsInsetRect(CGRectMake(0, 0, frameContainer.size.width, frameContainer.size.height), edgeSummary);
    
    CGRect frameActions;
    self.summayView.numberOfLines = 0;
    if(self.detailedMode) {
        self.summayView.numberOfLines = 0;
        frameSummary.size.height = 100;
    }
    
    NSUInteger length = [_taskinfo.content length];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_taskinfo.content];
    UIColor *textColor = [UIColor blackColor];
    UIColor *textFinishColor = [UIColor grayColor];
    UIFont *textFont = [UIFont systemFontOfSize:14.5];
    UIFont *textFinishFont = [UIFont systemFontOfSize:14.6];
    
    if(_taskinfo.finishedAt.length == 0) {
        [attributedString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)textColor.CGColor range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, attributedString.length)];
    }
    else {
        [attributedString addAttribute:NSFontAttributeName value:textFinishFont range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)textFinishColor.CGColor range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:textFinishColor range:NSMakeRange(0, attributedString.length)];
        
        //删除线.
        [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, length)];
        [attributedString addAttribute:NSStrikethroughColorAttributeName value:(id)textFinishColor range:NSMakeRange(0, length)];
    }
    
    self.summayView.attributedText = attributedString;
    
    
    CGSize size = [self.summayView sizeThatFits:frameSummary.size];
    frameSummary.size.height = size.height;
    self.summayView.frame = frameSummary;
    
    NSLog(@"fit --- %lf, %lf", size.width, size.height);
    self.actionsMenu.hidden = YES;
    self.actionsContainer.hidden = YES;
    
    if(self.detailedMode) {
//        self.actionsMenu.hidden = NO;
        frameActions = CGRectMake(0, frameSummary.origin.y + frameSummary.size.height + 10, frameContainer.size.width, 36);
        self.actionsMenu.frame = frameActions;
        NSArray<NSString*> *actionsKeyword = @[@"TaskActionSignIn", @"TaskActionTicking", @"TaskActionEdit", @"TaskActionFinish", @"TaskActionRedo", @"TaskActionMore"];
        NSInteger count = actionsKeyword.count;
        NSLog(@"actions count : %zd", count);
        
        CGFloat heightActions = 36;
        CGFloat heightAction = 18;
        CGFloat padding = (frameActions.size.width - actionsKeyword.count * heightAction) / (actionsKeyword.count + 1);
        CGFloat edgeTop = (heightActions - heightAction) / 2 ;
        CGFloat edgeLeft = (frameActions.size.width / actionsKeyword.count - heightAction ) / 2;
        
        frameActions.size.height = 0;
        self.actionsContainer.frame = frameActions;
        self.actionsContainer.hidden = NO;
        
        [self.actionsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for(NSInteger idx = 0; idx < count; idx++) {
            NSString *s = actionsKeyword[idx];
            
            PushButtonData *pushButtonData = [[PushButtonData alloc] init];
            pushButtonData.actionString = s;
            
            PushButton *button = [[PushButton alloc] init];
            button.actionData = pushButtonData;
            [self.actionsContainer addSubview:button];
            [button setImage:[UIImage imageNamed:s] forState:UIControlStateNormal];
            button.frame = CGRectMake(padding + idx * (padding + heightAction), (heightActions - heightAction) / 2, heightAction, heightAction);
            [button setImageEdgeInsets:UIEdgeInsetsMake(edgeTop, edgeLeft, edgeTop, edgeLeft)];
            button.frame = CGRectMake(idx * frameActions.size.width / actionsKeyword.count, 0, frameActions.size.width / actionsKeyword.count, heightActions);
            LOG_RECT(button.frame, @"button")
            NSLog(@"%lf, %lf", edgeTop, edgeLeft);
            
            
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
        }
        
        frameContainer.size.height = frameActions.origin.y + frameActions.size.height;
        
        self.actionsMenu.backgroundColor = [UIColor whiteColor];
    }
    else {
        self.actionsMenu.hidden = YES;
        frameContainer.size.height = frameSummary.size.height + edgeSummary.top + edgeSummary.bottom;
        frameCell.size.height = frameContainer.size.height + edgeContainer.top + edgeContainer.bottom;
    }
    
#if 0
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
    CGRect newShadowFrame =   CGRectMake(0, 0, frameContainer.size.width, frameContainer.size.height);
    newShadow.frame = newShadowFrame;
    CGColorRef darkColor = [UIColor blackColor].CGColor;
    CGColorRef lightColor =    [UIColor whiteColor].CGColor;
    newShadow.colors = [NSArray arrayWithObjects:(__bridge id _Nonnull)(lightColor),darkColor,nil];
    [self.container.layer insertSublayer:newShadow atIndex:0];
#endif
    
    
    frameCell.size.height = frameContainer.size.height + edgeContainer.top + edgeContainer.bottom;
    NSLog(@"--- cell height : %lf", frameCell.size.height);
    self.frame = frameCell;
    self.container.frame = frameContainer;
    self.container.backgroundColor = [UIColor whiteColor];
    
    //模拟一个立体效果.
    self.container.layer.shadowColor = [UIColor blackColor].CGColor;
    self.container.layer.shadowOffset = CGSizeMake(1, 1);
    self.container.layer.shadowOpacity = 0.8;
    self.container.layer.shadowRadius = 1;
}


- (void)buttonClick:(id)sender
{
    PushButton *button = sender;
    NSLog(@"---%@", button.actionData.actionString);
    
    if(self.actionOn) {
        self.actionOn(button.actionData.actionString);
    }
    
}


- (void)setTaskInfo:(TaskInfo*)taskinfo finishedAts:(NSArray<TaskFinishAt*>*)finishedAts
{
    _taskinfo = taskinfo;
    BOOL isFinished = NO;
    
    //任务全局设置为完成的话, 则标记为完成. 否则需要检测对应的TaskFinishAt.
    if(_taskinfo.finishedAt.length > 0) {
        isFinished = YES;
    }
    else {
        if(finishedAts.count > 0) {
            BOOL allDayFinished = YES;
            for(TaskFinishAt *taskFinishAt in finishedAts) {
                if(taskFinishAt.finishedAt.length > 0) {
                    NSLog(@"%@ %@ : %@", taskFinishAt.snTaskInfo, taskFinishAt.dayString, taskFinishAt.finishedAt);
                }
                else {
                    allDayFinished = NO;
                    break;
                }
            }
            
            isFinished = allDayFinished;
        }
    }
    
    CGRect frameCell = self.frame;
    UIEdgeInsets edgeContainer  = UIEdgeInsetsMake(10, 10, 0, 10);
    UIEdgeInsets edgeSummary    = UIEdgeInsetsMake(10, 64, 10, 10);
    
    CGRect frameContainer   = UIEdgeInsetsInsetRect(self.bounds, edgeContainer);
    CGRect frameSummary     = UIEdgeInsetsInsetRect(CGRectMake(0, 0, frameContainer.size.width, frameContainer.size.height), edgeSummary);
    
    self.summayView.numberOfLines = 0;
    frameSummary.size.height = 100;
    
    NSUInteger length = [_taskinfo.content length];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_taskinfo.content];
    UIColor *textColor = [UIColor blackColor];
    UIColor *textFinishColor = [UIColor grayColor];
    UIFont *textFont = [UIFont systemFontOfSize:14.5];
    UIFont *textFinishFont = [UIFont systemFontOfSize:14.6];
    
    if(!isFinished) {
        [attributedString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)textColor.CGColor range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, attributedString.length)];
    }
    else {
        [attributedString addAttribute:NSFontAttributeName value:textFinishFont range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)textFinishColor.CGColor range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:textFinishColor range:NSMakeRange(0, attributedString.length)];
        
        //删除线.
        [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, length)];
        [attributedString addAttribute:NSStrikethroughColorAttributeName value:(id)textFinishColor range:NSMakeRange(0, length)];
    }
    
    self.summayView.attributedText = attributedString;
    
    
    CGSize size = [self.summayView sizeThatFits:frameSummary.size];
    frameSummary.size.height = size.height;
    self.summayView.frame = frameSummary;
    NSLog(@"fit --- %lf, %lf", size.width, size.height);

    frameContainer.size.height = frameSummary.size.height + edgeSummary.top + edgeSummary.bottom;
    frameCell.size.height = frameContainer.size.height + edgeContainer.top + edgeContainer.bottom;

    NSLog(@"--- cell height : %lf", frameCell.size.height);
    self.frame = frameCell;
    self.container.frame = frameContainer;
    self.container.backgroundColor = [UIColor whiteColor];
    
    //模拟一个立体效果.
    self.container.layer.shadowColor = [UIColor blackColor].CGColor;
    self.container.layer.shadowOffset = CGSizeMake(1, 1);
    self.container.layer.shadowOpacity = 0.8;
    self.container.layer.shadowRadius = 1;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end















@interface TaskCellActionMenu () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) id data;

@end



@implementation TaskCellActionMenu

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //image title content, keyword.
        
        self.data = @[
                      @[@"checkin", @"签到", @"", @"checkin"],
                      @[@"edit", @"修改任务标题", @"", @"edit"],
                      @[@"subtask", @"子任务", @"", @"subtask"],
                      @[@"finish", @"标记任务完成", @"可在任务标题上右划执行", @"finish"],
                      @[@"redo", @"标记为未完成", @"可在任务标题上左划执行", @"redo"]
                      ];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        [self addSubview:tableView];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.data;
    return array.count;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"111"];
    NSArray<NSArray*> *array = self.data;
    NSArray<NSString*> *rowData = array[indexPath.row];
    
    [cell.imageView setImage:[UIImage imageNamed:rowData[0]]];
    
    UIImage *image = [UIImage imageNamed:rowData[0]];
    //NSLog(@"image : %@", image);
    cell.imageView.image = image;
    
    //缩小显示图片.
    
    CGSize itemSize = CGSizeMake(20, 20);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    cell.textLabel.text = rowData[1];
    cell.detailTextLabel.text = rowData[2];
    
    return cell;
}






@end






@interface TaskDetailContentCell ()

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UIView    *taskTitleHeader;
@property (nonatomic, strong) UILabel   *taskTitleLabel;
@property (nonatomic, strong) UIButton  *editButton;
@property (nonatomic, strong) UILabel   *taskContentLabel;
@property (nonatomic, strong) UIView    *taskStatus;
@property (nonatomic, strong) UIView    *taskAdditional;

@end


@implementation TaskDetailContentCell




- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    LOG_POSTION
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.container = [[UIView alloc] init];
        [self addSubview:self.container];
        
        self.taskTitleHeader        = [[UIView alloc] init] ;
        self.taskTitleLabel         = [[UILabel alloc] init] ;
        self.editButton             = [[UIButton alloc] init] ;
        self.taskContentLabel       = [[UILabel alloc] init] ;
        self.taskStatus             = [[UIView alloc] init] ;
        self.taskAdditional         = [[UIView alloc] init] ;
        
        [self.container addSubview:self.taskTitleHeader];
        [self.container addSubview:self.taskTitleLabel];
        [self.container addSubview:self.editButton];
        [self.container addSubview:self.taskContentLabel];
        [self.container addSubview:self.taskStatus];
        [self.container addSubview:self.taskAdditional];
        
        self.taskTitleLabel.numberOfLines = 0;
        self.taskContentLabel.numberOfLines = 0;
    }
    return self;
}


- (void)setTaskinfo:(TaskInfo*)taskinfo
{
    LOG_POSTION
    _taskinfo = taskinfo;
    [self updateDisplay];
}


- (void)updateDisplay
{
    LOG_POSTION
    if(!self.taskinfo) {
        return ;
    }
    
    CGRect frameCell = self.frame;
    UIEdgeInsets edgeContainer = UIEdgeInsetsMake(10, 10, 10, 10);
    CGRect frameContainer = self.bounds;
    frameContainer = UIEdgeInsetsInsetRect(frameContainer, edgeContainer);
    
    CGFloat y = 0;
    CGFloat widthContainer = frameContainer.size.width;
    CGFloat heightHeader = 9.51;
    CGFloat heightTitle = 60;
    CGFloat heightContent = 60;
    CGFloat heightStatus = 18;
    CGFloat heightTaskAdditional = 45;
    
    y += heightHeader;
    
    self.taskTitleLabel.attributedText = [self attributedStringForTaskTitle];
        if(self.taskTitleLabel.attributedText.length > 0) {
            self.taskTitleLabel.numberOfLines = 2;
            self.taskTitleLabel.frame = CGRectMake(0, y, widthContainer, heightTitle);
            y += heightTitle;
    }
    
    self.taskContentLabel.attributedText = [self attributedStringForTaskContent];
    self.taskContentLabel.numberOfLines = 0;
    self.taskContentLabel.frame = CGRectMake(0, y, widthContainer, heightContent);
    CGSize sizeFit = [self.taskContentLabel sizeThatFits:self.taskContentLabel.frame.size];
    heightContent = sizeFit.height;
    self.taskContentLabel.frame = CGRectMake(0, y, widthContainer, heightContent);
    y += heightContent;
    
    self.taskStatus.frame = CGRectMake(0, y, widthContainer, heightStatus);
    y += heightStatus;
    
    self.taskAdditional.frame = CGRectMake(0, y, widthContainer, heightTaskAdditional);
    [self addActionMenu];
    y += heightTaskAdditional;
    
    frameContainer.size.height = y;
    self.container.frame = frameContainer;
    
    frameCell.size.height = y + edgeContainer.top + edgeContainer.bottom;
    self.frame = frameCell;
    
    for(UIView *v in self.container.subviews) {
        NSLog(@"---%@", v);
    }
    
}


- (void)addActionMenu
{
    UIEdgeInsets edgeInserts = UIEdgeInsetsMake(10, 10, 10, 10);
    edgeInserts = UIEdgeInsetsZero;
    CGRect frameActions = UIEdgeInsetsInsetRect(self.taskAdditional.bounds, edgeInserts);
    [self.taskAdditional.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *actionsContainer = [[UIView alloc] init];
    [self.taskAdditional addSubview:actionsContainer];
    actionsContainer.frame = frameActions;
    actionsContainer.hidden = NO;
    
    NSArray<NSString*> *actionsKeyword = @[@"TaskActionSignIn", @"TaskActionTicking", @"TaskActionEdit", @"TaskActionFinish", @"TaskActionRedo", @"TaskActionMore"];
    NSInteger count = actionsKeyword.count;
    NSLog(@"actions count : %zd", count);
    
    CGFloat heightActions = frameActions.size.height;
    CGFloat heightAction = 18;
    CGFloat edgeTop = (heightActions - heightAction) / 2 ;
    CGFloat edgeLeft = (frameActions.size.width / actionsKeyword.count - heightAction ) / 2;
    
    for(NSInteger idx = 0; idx < count; idx++) {
        NSString *s = actionsKeyword[idx];
        
        PushButtonData *pushButtonData = [[PushButtonData alloc] init];
        pushButtonData.actionString = s;
        
        PushButton *button = [[PushButton alloc] init];
        button.actionData = pushButtonData;
        [actionsContainer addSubview:button];
        [button setImage:[UIImage imageNamed:s] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(edgeTop, edgeLeft, edgeTop, edgeLeft)];
        button.frame = CGRectMake(idx * frameActions.size.width / actionsKeyword.count, 0, frameActions.size.width / actionsKeyword.count, heightActions);
        LOG_RECT(button.frame, @"button")
        NSLog(@"%lf, %lf", edgeTop, edgeLeft);
        
        
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    }
}


- (void)buttonClick:(id)sender
{
    PushButton *button = sender;
    NSLog(@"---%@", button.actionData.actionString);
    
    if(self.actionOn) {
        self.actionOn(button.actionData.actionString);
    }
    
}



- (NSMutableAttributedString*)attributedStringForTaskTitle
{
    NSString *title = @"Task";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedString addAttribute:NSExpansionAttributeName value:@0 range:NSMakeRange(0, title.length)];
    NSMutableParagraphStyle * paragraphStyleContent = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleContent setHeadIndent:20];
    [paragraphStyleContent setFirstLineHeadIndent:20];
    [paragraphStyleContent setTailIndent:-20];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleContent range:NSMakeRange(0, title.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"TaskDetailTitle"] range:NSMakeRange(0, title.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithName:@"TaskDetailText"] range:NSMakeRange(0, title.length)];
    
    return attributedString;
}


- (NSMutableAttributedString*)attributedStringForTaskContent
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
    
    return attributedContentString;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end



@interface TaskDetailPropertyCell ()

@property (nonatomic, strong) UILabel    *titleLabel;
@property (nonatomic, strong) YYLabel    *contentLabel;

@property (nonatomic, strong) NSAttributedString *titleAttributedString;
@property (nonatomic, strong) NSAttributedString *contentAttributedString;

@end


@implementation TaskDetailPropertyCell




- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    LOG_POSTION
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.contentLabel = [[YYLabel alloc] init];
        [self addSubview:self.titleLabel];
        [self addSubview:self.contentLabel];
    }
    return self;
}


- (void)setTitle:(NSAttributedString*)titleAttributedString content:(NSAttributedString*)contentAttributedString
{
    _titleAttributedString = titleAttributedString;
    _contentAttributedString = contentAttributedString;
    [self updateDisplay];
}


- (void)updateDisplay
{
    LOG_POSTION
    
    CGRect frameCell = self.frame;
    
    CGFloat heightTitle = frameCell.size.height * 0.6;
    self.titleLabel.attributedText = self.titleAttributedString;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.frame = CGRectMake(0, 0, frameCell.size.width, heightTitle);
    
    CGFloat heightContent = frameCell.size.height * 0.4;
    self.contentLabel.attributedText = self.contentAttributedString;
    self.contentLabel.numberOfLines = 1;
    self.contentLabel.frame = CGRectMake(0, heightTitle, frameCell.size.width, heightContent);
    
    self.frame = frameCell;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end




@interface TaskRecordCell ()

@property (nonatomic, strong) UIView     *container;
@property (nonatomic, strong) UILabel    *committedAtLabel;
@property (nonatomic, strong) YYLabel    *typeLabel;
@property (nonatomic, strong) YYLabel    *contentLabel;

@end


@implementation TaskRecordCell




- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    LOG_POSTION
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.container = [[UIView alloc] init];
        self.committedAtLabel = [[UILabel alloc] init];
        self.typeLabel = [[YYLabel alloc] init];
        self.contentLabel = [[YYLabel alloc] init];
        
        [self.contentView addSubview:self.container];
        [self.container addSubview:self.committedAtLabel];
        [self.container addSubview:self.typeLabel];
        [self.container addSubview:self.contentLabel];
    }
    return self;
}


- (void)logRect
{
    for(UIView *view in self.subviews) {
        NSLog(@"\t\t%@", view);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self logRect];
    });
}


- (void)setTaskRecord:(TaskRecord *)taskRecord
{
    _taskRecord = taskRecord;
    [self updateDisplay];
    
    
}


- (void)updateDisplay
{
    CGRect frameCell = self.frame;
    CGRect frameContentView = self.contentView.frame;
    UIEdgeInsets edgeContainer = UIEdgeInsetsMake(10, 0, 10, 0);
    CGRect frameContainer = UIEdgeInsetsInsetRect(frameContentView, edgeContainer);
    CGFloat y = 0;
    CGFloat heightCommittedAt = 20;
    CGFloat heightType = 30;
    CGFloat heightContent = 60;
    
    NSString *s;
    NSMutableAttributedString *attributedString;
    
    s = [TaskInfo dateTimeStringForDisplay:self.taskRecord.committedAt];
    attributedString = [NSString attributedStringWith:s
                                                 font:[UIFont fontWithName:@"NoteRecordCommittedAt"]
                                               indent:20
                                            textColor:[UIColor colorWithName:@"NoteRecordCommittedAt"]
                        ];
    self.committedAtLabel.attributedText = attributedString;
    self.committedAtLabel.frame = CGRectMake(0, y, frameContainer.size.width, heightCommittedAt);
    y += heightCommittedAt;
    
    s = [TaskRecord stringOfType:self.taskRecord.type];
    attributedString = [NSString attributedStringWith:s
                                                 font:[UIFont fontWithName:@"NoteRecordType"]
                                               indent:20
                                            textColor:[UIColor colorWithName:@"NoteRecordType"]
                        ];
    
    self.typeLabel.attributedText = attributedString;
    self.typeLabel.frame = CGRectMake(0, y, frameContainer.size.width, heightType);
    y += heightType;
    
    if(self.taskRecord.record.length > 0) {
        self.contentLabel.hidden = NO;
        s = self.taskRecord.record;
        attributedString = [NSString attributedStringWith:s
                                                     font:[UIFont fontWithName:@"NoteRecordContent"]
                                                   indent:20
                                                textColor:[UIColor colorWithName:@"NoteRecordContent"]
                            ];
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.attributedText = attributedString;
        self.contentLabel.frame = CGRectMake(0, y, frameContainer.size.width, heightContent);
        CGSize sizeOptumize = [self.contentLabel sizeThatFits:self.contentLabel.frame.size];
        heightContent = sizeOptumize.height + 10;
        self.contentLabel.frame = CGRectMake(0, y, frameContainer.size.width, heightContent);
        y += heightContent;
    }
    else {
        self.contentLabel.hidden = YES;
    }
    
    CGFloat heightContainer = y;
    CGFloat heightContentView = y + edgeContainer.top + edgeContainer.bottom;
    CGFloat heightCell = heightContentView;
    
    frameContainer.size.height = heightContainer;
    self.container.frame = frameContainer;
    
    frameContentView.size.height = heightContentView;
    self.contentView.frame = frameContentView;
    
    frameCell.size.height = heightCell;
    self.frame = frameCell;
}






- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0xE2/255.0f green:0xE2/255.0f blue:0xE2/255.0f alpha:1].CGColor);
//    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 1, rect.size.width, 1));
    
    //设置属性
    [[UIColor colorWithName:@"TaskRecordTimeLine"] set];
    CGContextSetLineWidth(context, 0.5);
    
    //添加对象,绘制椭圆（圆形）的过程也是先创建一个矩形
    CGRect rectCircle = CGRectMake(2, 16, 10, 10);
    CGContextAddEllipseInRect(context, rectCircle);
    //绘制
    
    CGRect rectTopLine = CGRectMake(6, 2, 2, 12);
    CGContextAddRect(context, rectTopLine);
    
    CGRect rectBottomLine = CGRectMake(6, 28, 2, rect.size.height - 28 - 2);
    CGContextAddRect(context, rectBottomLine);

    CGContextDrawPath(context, kCGPathFillStroke);
    
    
}


@end





@interface TaskDaySelector ()

@property (nonatomic, strong) UIView     *container;



@property (nonatomic, strong) UILabel    *label1;
@property (nonatomic, strong) UILabel    *label2;
@property (nonatomic, strong) UITextField    *textInput1;
@property (nonatomic, strong) UITextField    *textInput2;
@property (nonatomic, strong) UILabel    *labelDays;


@property (nonatomic, strong) UISegmentedControl *daysTypeSelector;
@property (nonatomic, strong) NSArray<NSString*> *daysTypes;


@property (nonatomic, strong) NSString *daysType;
@property (nonatomic, strong) NSString *dayString;
@property (nonatomic, strong) NSArray<NSString*> *mutilDays;
@property (nonatomic, strong) NSString *dayStringFrom;
@property (nonatomic, strong) NSString *dayStringTo;

@end


@implementation TaskDaySelector




- (instancetype)init
{
    LOG_POSTION
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.container = [[UIView alloc] init];
        [self addSubview:self.container];
        
        self.label1 = [[UILabel alloc] init];
        self.label2 = [[UILabel alloc] init];
        self.textInput1 = [[UITextField alloc] init];
        self.textInput2 = [[UITextField alloc] init];
        
        self.labelDays = [[UILabel alloc] init];
        self.mutilDays = [[NSMutableArray alloc] init];
        
        self.daysTypes = @[kStringSelectorDay, kStringSelectorDays, kStringSelectorContinuous];
        self.daysTypeSelector = [[UISegmentedControl alloc] init];
        for(NSInteger idx = 0; idx < self.daysTypes.count; idx ++) {
            [self.daysTypeSelector insertSegmentWithTitle:self.daysTypes[idx] atIndex:idx animated:YES];
        }
        [self.daysTypeSelector addTarget:self action:@selector(actionDaysTypeSelector:) forControlEvents:UIControlEventValueChanged];
        
        [self.container addSubview:self.label1];
        [self.container addSubview:self.label2];
        [self.container addSubview:self.textInput1];
        [self.container addSubview:self.textInput2];
        [self.container addSubview:self.labelDays];
        [self.container addSubview:self.daysTypeSelector];
        

        
    }
    return self;
}


- (void)layoutSubviews
{
    CGRect frame = self.bounds;
    NSLog(@"%lf %lf", frame.size.width, frame.size.height);
    self.container.frame = frame;
    [self updateDisplay];
}


- (void)updateDisplay
{
    LOG_POSTION
    
    CGFloat widthTotal = self.container.frame.size.width;
    CGFloat widthDaysTypeSelector = 200;
    self.daysTypeSelector.frame = CGRectMake((widthTotal-widthDaysTypeSelector) / 2 , 10, widthDaysTypeSelector, 28);
    
    
    
    CGFloat y = 50;
    
    self.label1.frame = CGRectMake(10, y, 100, 36);
    self.label1.text = @"任务执行日期 : ";
    self.label1.font = FONT_SMALL;
    self.label1.textAlignment = NSTextAlignmentRight;
    self.textInput1.frame = CGRectMake(121, y, 100, 36);
    self.textInput1.font = FONT_SMALL;
    
    
    
    
    self.daysType = kStringSelectorDays;
    
    if([self.daysType isEqualToString:kStringSelectorDay]) {
        self.label1.text = @"任务执行日期 : ";
        
        self.label2.hidden = YES;
        self.textInput2.hidden = YES;
        self.labelDays.hidden = YES;
        
        UIToolbar *keyboardAccessory = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
        keyboardAccessory.backgroundColor = [UIColor whiteColor];
        [keyboardAccessory setItems:@[
                                      [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStylePlain target:self action:@selector(inputStringToday:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"明天" style:UIBarButtonItemStylePlain target:self action:@selector(inputStringTomorrow:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"日历" style:UIBarButtonItemStylePlain target:self action:@selector(openCalendar:)]
                                      ]
                           animated:YES];
        self.textInput1.inputAccessoryView = keyboardAccessory;
        
        CALayer *underlineLayer = nil;
        for(CALayer *layer in self.textInput1.layer.sublayers) {
            if([layer.name isEqualToString:@"underline"]) {
                underlineLayer = layer;
                break;
            }
        }
        if(!underlineLayer) {
            underlineLayer = [CALayer layer];
            [self.textInput1.layer addSublayer:underlineLayer];
        }
        underlineLayer.position = CGPointMake(self.textInput1.frame.size.width / 2, self.textInput1.frame.size.height - 10);
        underlineLayer.bounds = CGRectMake(0, 0, self.textInput1.frame.size.width, 1);
        underlineLayer.backgroundColor = [UIColor blueColor].CGColor;
        self.optumizeHeight = 56;
    }
    else if([self.daysType isEqualToString:kStringSelectorDays]) {
        self.label1.text = @"任务执行日期 : ";
        
        self.label2.hidden = YES;
        self.textInput2.hidden = YES;
        self.labelDays.hidden = NO;
        self.labelDays.frame = CGRectMake(121, 96, self.container.frame.size.width - 121, 36);
        self.labelDays.font = FONT_SMALL;
        if(self.mutilDays.count == 0) {
            self.labelDays.text = @"选定的执行日期在此显示";
        }
        else {
            
        }
        
        UIToolbar *keyboardAccessory = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
        keyboardAccessory.backgroundColor = [UIColor whiteColor];
        [keyboardAccessory setItems:@[
                                      [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStylePlain target:self action:@selector(inputStringToday:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"明天" style:UIBarButtonItemStylePlain target:self action:@selector(inputStringTomorrow:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"增加" style:UIBarButtonItemStylePlain target:self action:@selector(daysModeAddDay:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"日历" style:UIBarButtonItemStylePlain target:self action:@selector(openCalendar:)]
                                      ]
                           animated:YES];
        self.textInput1.inputAccessoryView = keyboardAccessory;
        
        CALayer *underlineLayer = nil;
        for(CALayer *layer in self.textInput1.layer.sublayers) {
            if([layer.name isEqualToString:@"underline"]) {
                underlineLayer = layer;
                break;
            }
        }
        if(!underlineLayer) {
            underlineLayer = [CALayer layer];
            [self.textInput1.layer addSublayer:underlineLayer];
        }
        underlineLayer.position = CGPointMake(self.textInput1.frame.size.width / 2, self.textInput1.frame.size.height - 10);
        underlineLayer.bounds = CGRectMake(0, 0, self.textInput1.frame.size.width, 1);
        underlineLayer.backgroundColor = [UIColor blueColor].CGColor;
        self.optumizeHeight = SCREEN_HEIGHT;
        
        
        
        
        
    }
    
    
    
}


- (void)actionDaysTypeSelector:(UISegmentedControl*)segmentedControl
{
    LOG_POSTION
    NSInteger idx = segmentedControl.selectedSegmentIndex;
    if(idx >= 0 && idx < self.daysTypes.count) {
        LOG_POSTION
        self.daysType = self.daysTypes[idx];
        [self updateDisplay];
    }
}


- (void)inputStringToday:(id)sender
{
    if([self.daysType isEqualToString:kStringSelectorDay]) {
        self.textInput1.text = [NSString dayStringToday];
        [self.textInput1 resignFirstResponder];
    }
    else if([self.daysType isEqualToString:kStringSelectorDays]) {
        self.textInput1.text = [NSString dayStringToday];
    }
    else if([self.daysType isEqualToString:kStringSelectorContinuous]) {
        if(self.textInput1.editing) {
            self.textInput1.text = [NSString dayStringToday];
            [self.textInput1 resignFirstResponder];
            [self.textInput2 becomeFirstResponder];
        }
        else if(self.textInput2.editing) {
            self.textInput2.text = [NSString dayStringToday];
            [self.textInput2 resignFirstResponder];
        }
    }
}


- (void)inputStringTomorrow:(id)sender
{
    if(self.textInput1.editing) {
        self.textInput1.text = [NSString dayStringTomorrow];
        [self.textInput1 resignFirstResponder];
    }
    
    if(self.textInput2.editing) {
        self.textInput2.text = [NSString dayStringTomorrow];
        [self.textInput2 resignFirstResponder];
    }
}


- (void)openCalendar:(id)sender
{
    
    
}


- (void)daysModeAddDay:(id)sender
{
    LOG_POSTION
    
    
    
}


- (void)drawRect:(CGRect)rect
{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    //设置属性
//    [[UIColor colorWithName:@"TaskRecordTimeLine"] set];
//    
//
//    
//    CGFloat yBorder = 6;
//    CGFloat y1 = yBorder;
//    CGFloat y2 = rect.size.height - yBorder;
//    
//    CGFloat widthPercentage = 0.6;
//    CGFloat xBorder = 6;
//    CGPoint point0 = CGPointMake(xBorder + xBorder, y1);
//    CGPoint point1 = CGPointMake(rect.size.width * widthPercentage, y1);
//    CGPoint point2 = CGPointMake(rect.size.width * widthPercentage - xBorder, y2);
//    CGPoint point3 = CGPointMake(xBorder, y2);
//    
//    CGContextMoveToPoint(context, point0.x, point1.y);
//    CGContextAddLineToPoint(context, point1.x,point1.y);
//    CGContextAddLineToPoint(context, point2.x,point2.y);
//    CGContextAddLineToPoint(context, point3.x,point3.y);
//    CGContextAddLineToPoint(context, point0.x,point0.y);
//    CGContextStrokePath(context);
    
    

    
    
    
    
}





@end








@interface TaskCalendar () <JTCalendarDelegate>
{
    NSMutableDictionary *_eventsByDate;
    NSDate *_dateSelected;
    UITextField *_textInput;
}

@property (nonatomic, strong) JTCalendarManager *calendarManager;
@property (nonatomic, strong) JTCalendarMenuView *calendarMenuView;
@property (nonatomic, strong) JTHorizontalCalendarView *calendarContentView;

@property (nonatomic, strong) NSString *dayString;
@property (nonatomic, strong) NSArray<NSString*> *dayStrings;

@end



@implementation TaskCalendar


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        
        CGFloat xTextInput = 60;
        CGFloat yTextInput = 60;
        CGFloat heightTextInput = 36;
        _textInput = [[UITextField alloc] initWithFrame:CGRectMake(xTextInput, yTextInput, width - xTextInput * 2, heightTextInput)];
        _textInput.textAlignment = NSTextAlignmentCenter;
        _textInput.layer.borderColor = [UIColor colorWithName:@"TaskEditText"].CGColor;
        _textInput.layer.borderWidth = 1;
        _textInput.layer.cornerRadius = _textInput.frame.size.height / 2;
        
        _calendarMenuView = [[JTCalendarMenuView alloc] initWithFrame:CGRectMake(0, height - width - 50, width, 36)];
        _calendarContentView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectMake(0, height - width, width, width)];
        _calendarManager = [[JTCalendarManager alloc] init];
        _calendarManager.delegate = self;
        
        _calendarMenuView.contentRatio = .75;
        _calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatSingle;
        _calendarManager.dateHelper.calendar.locale = [NSLocale currentLocale];
        
        [_calendarManager setMenuView:_calendarMenuView];
        [_calendarManager setContentView:_calendarContentView];
        [_calendarManager setDate:[NSDate date]];
        
        [self addSubview:_textInput];
        [self addSubview:_calendarMenuView];
        [self addSubview:_calendarContentView];
    }
    return self;
}


#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    dayView.hidden = NO;
    
    // Other month
    if([dayView isFromAnotherMonth]){
        dayView.hidden = YES;
    }
    // Today
    else if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}


- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    
    NSString *dateString = [NSString dateStringOfDate:dayView.date];
    NSLog(@"%@", dateString);
    _textInput.text = dateString;
    self.dayString = dateString;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Don't change page in week mode because block the selection of days in first and last weeks of the month
    if(_calendarManager.settings.weekModeEnabled){
        return;
    }
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
}

#pragma mark - Views customization

- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    
    return label;
}

- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UILabel *)menuItemView date:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MMMM yyyy";
        
        dateFormatter.locale = _calendarManager.dateHelper.calendar.locale;
        dateFormatter.timeZone = _calendarManager.dateHelper.calendar.timeZone;
    }
    
    menuItemView.text = [dateFormatter stringFromDate:date];
}

- (UIView<JTCalendarWeekDay> *)calendarBuildWeekDayView:(JTCalendarManager *)calendar
{
    JTCalendarWeekDayView *view = [JTCalendarWeekDayView new];
    
    for(UILabel *label in view.dayViews){
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@"Avenir-Light" size:14];
    }
    
    return view;
}

- (UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar
{
    JTCalendarDayView *view = [JTCalendarDayView new];
    
    view.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:13];
    
    view.circleRatio = .8;
    view.dotRatio = 1. / .9;
    
    return view;
}

#pragma mark - Fake data

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)createRandomEvents
{
    _eventsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!_eventsByDate[key]){
            _eventsByDate[key] = [NSMutableArray new];
        }
        
        [_eventsByDate[key] addObject:randomDate];
    }
}

@end
