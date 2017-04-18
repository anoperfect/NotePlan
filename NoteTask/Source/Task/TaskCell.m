//
//  TaskCell.m
//  NoteTask
//
//  Created by Ben on 16/10/18.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskCell.h"






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


- (void)buttonClick:(id)sender
{
    PushButton *button = sender;
    NSLog(@"---%@", button.buttonData.actionString);
    
    if(self.actionOn) {
        self.actionOn(button.buttonData.actionString);
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
            isFinished = ([TaskFinishAt checkAllFinishAts:finishedAts].length > 0);
        }
    }
    
    CGRect frameCell = self.frame;
    UIEdgeInsets edgeContainer  = UIEdgeInsetsMake(10, 36, 0, 10);
    UIEdgeInsets edgeSummary    = UIEdgeInsetsMake(10, 10, 10, 10);
    
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

    frameContainer.size.height = frameSummary.size.height + edgeSummary.top + edgeSummary.bottom;
    frameCell.size.height = frameContainer.size.height + edgeContainer.top + edgeContainer.bottom;

    self.frame = frameCell;
    self.container.frame = frameContainer;
    self.container.backgroundColor = [UIColor whiteColor];
    
    //模拟一个立体效果.
    self.container.layer.shadowColor = [UIColor blackColor].CGColor;
    self.container.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    self.container.layer.shadowOpacity = 0.6;
    self.container.layer.shadowRadius = 0.36;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    _taskinfo = taskinfo;
    [self updateDisplay];
}


- (void)updateDisplay
{
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
    else {
        y += 22;
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
    
    NSArray<NSString*> *actionsKeyword = @[
                                           @"TaskActionTicking",
                                           @"TaskActionFinish",
                                           /*@"TaskActionRecord",*/
                                           @"TaskActionUserRecord",
                                           @"TaskActionMore"
                                           ];
    
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
        button.buttonData = pushButtonData;
        [actionsContainer addSubview:button];
        [button setImage:[UIImage imageNamed:s] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(edgeTop, edgeLeft, edgeTop, edgeLeft)];
        button.frame = CGRectMake(idx * frameActions.size.width / actionsKeyword.count, 0, frameActions.size.width / actionsKeyword.count, heightActions);
        
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    }
}


- (void)buttonClick:(id)sender
{
    PushButton *button = sender;
    NSLog(@"---%@", button.buttonData.actionString);
    
    if(self.actionOn) {
        self.actionOn(button.buttonData.actionString);
    }
    
}


- (NSMutableAttributedString*)attributedStringForTaskTitle
{
    NSString *title = @"";
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
    NSMutableAttributedString *attributedContentString;
    attributedContentString = [NSString attributedStringWith:self.taskinfo.content font:[UIFont fontWithName:@"TaskDetailContent"] indent:20 textColor:[UIColor colorWithName:@"TaskDetailText"]];
    
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
@property (nonatomic, strong) UILabel    *contentLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

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
        self.contentLabel = [[UILabel alloc] init];
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
    frameCell.size.height = self.optumizeHeight;
    CGFloat optumizeHeight ;
    
    CGFloat heightTitle = frameCell.size.height * 0.6;
    self.titleLabel.attributedText = self.titleAttributedString;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.frame = CGRectMake(0, 0, frameCell.size.width, heightTitle);
    
    CGFloat heightContent = frameCell.size.height * 0.4;
    self.contentLabel.attributedText = self.contentAttributedString;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.frame = CGRectMake(0, heightTitle, frameCell.size.width, heightContent);
    
    CGSize size = self.contentLabel.frame.size;
    CGSize sizeFit = [self.contentLabel sizeThatFits:CGSizeMake(100000, 100000)];
    
    if(sizeFit.height > heightContent) {
        optumizeHeight = heightTitle + sizeFit.height + 10 ;
        
        self.contentLabel.frame = CGRectMake(0, heightTitle, frameCell.size.width, sizeFit.height + 10);
        [self addSubview:self.contentLabel];
        [self.scrollView removeFromSuperview];
        self.scrollView = nil;
    }
    else {
        optumizeHeight = heightTitle + heightContent;
        if(sizeFit.width > (size.width - 36) || sizeFit.height > size.height) {
            if(!self.scrollView) {
                self.scrollView = [[UIScrollView alloc] init];
            }
            
            self.scrollView.frame = CGRectMake(0, heightTitle, frameCell.size.width - 20, heightContent);
            self.scrollView.contentSize = sizeFit;
            [self.scrollView addSubview:self.contentLabel];
            
            [self addSubview:self.scrollView];
            [self.scrollView addSubview:self.contentLabel];
            
            self.contentLabel.frame = CGRectMake(0, 0, sizeFit.width + 100, size.height);
        }
        else {
            [self addSubview:self.contentLabel];
            [self.scrollView removeFromSuperview];
            self.scrollView = nil;
        }
    }
    
    self.optumizeHeight = optumizeHeight;
    frameCell.size.height = self.optumizeHeight;
    
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
@property (nonatomic, strong) UILabel    *typeLabel;
@property (nonatomic, strong) UILabel    *contentLabel;

@end


@implementation TaskRecordCell




- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    LOG_POSTION
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.container = [[UIView alloc] init];
        self.committedAtLabel = [[UILabel alloc] init];
        self.typeLabel = [[UILabel alloc] init];
        self.contentLabel = [[UILabel alloc] init];
        
        [self.contentView addSubview:self.container];
        [self.container addSubview:self.committedAtLabel];
        [self.container addSubview:self.typeLabel];
        [self.container addSubview:self.contentLabel];
    }
    return self;
}


- (void)logRect
{
//    for(UIView *view in self.subviews) {
//        NSLog(@"\t\t%@", view);
//    }
    
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
    if(self.taskRecord.dayString.length > 0) {
        s = [s stringByAppendingFormat:@"@%@", self.taskRecord.dayString];
    }
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






