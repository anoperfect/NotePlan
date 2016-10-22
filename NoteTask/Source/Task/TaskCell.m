//
//  TaskCellTableViewCell.m
//  NoteTask
//
//  Created by Ben on 16/10/18.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskCell.h"
#import "TaskModel.h"





@interface TaskCell ()

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
        self.summayView = [[UILabel alloc] init];
        [self addSubview:self.summayView];
        
        self.actionsMenu = [[UIToolbar alloc] init];
        [self addSubview:self.actionsMenu];
        
        self.actionsContainer = [[UIView alloc] init];
        [self addSubview:self.actionsContainer];
        
    }
    return self;
}


- (void)setTask:(TaskModel*)task
{
    CGRect frameCell = self.frame;
    CGRect frameSummary = CGRectMake(64, 10, self.frame.size.width - 64 - 6, 12);
    CGRect frameActions;
    self.summayView.numberOfLines = 1;
    if(self.detailedMode) {
        self.summayView.numberOfLines = 0;
        frameSummary.size.height = 100;
    }
    
    LOG_VIEW_RECT(self, @"taskcell");
    LOG_VIEW_RECT(self.summayView, @"summay");
    
//    self.summayView.font = [UIFont systemFontOfSize:14.5];
//    self.summayView.text = task.title;
    
//    let attributedText = NSAttributedString(string: "内容", attributes: [NSStrikethroughStyleAttributeName: 1])
//    let contentLabel = UILabel()
//    contentLabel.attributedText = attributedText
    
    NSUInteger length = [task.title length];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:task.title];
    UIColor *textColor = [UIColor blackColor];
    UIColor *textFinishColor = [UIColor grayColor];
    UIFont *textFont = [UIFont systemFontOfSize:14.5];
    UIFont *textFinishFont = [UIFont systemFontOfSize:14.6];
    
    if(task.status == 0) {
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
        [attributedString addAttribute:NSStrikethroughColorAttributeName value:(id)[UIColor blackColor] range:NSMakeRange(0, length)];
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
        frameActions = CGRectMake(0, frameSummary.origin.y + frameSummary.size.height, frameCell.size.width, 36);
        self.actionsMenu.frame = frameActions;
        NSArray<NSString*> *actionsKeyword = @[@"checkin", @"edit", @"subtask", @"finish", @"redo"];
        NSInteger count = actionsKeyword.count;
        NSLog(@"actions count : %zd", count);
        
        CGFloat heightActions = 36;
        CGFloat heightAction = 20;
        CGFloat padding = (frameActions.size.width - actionsKeyword.count * heightAction) / (actionsKeyword.count + 1);
        CGFloat edgeTop = (heightActions - heightAction) / 2 ;
        CGFloat edgeLeft = (frameActions.size.width / actionsKeyword.count - heightActions ) / 2;
        
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
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
        }
        
        self.actionsMenu.items = @[
                                   [[UIBarButtonItem alloc] initWithTitle:@"abc" style:UIBarButtonItemStylePlain target:self action:nil],
                                   
                                   
                                   
                                   
                                   ];
        
        
        frameCell.size.height = frameActions.origin.y + frameActions.size.height;
        NSLog(@"--- cell height : %lf", frameCell.size.height);
        self.frame = frameCell;
        
        self.actionsMenu.backgroundColor = [UIColor whiteColor];
    }
    else {
        self.actionsMenu.hidden = YES;
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