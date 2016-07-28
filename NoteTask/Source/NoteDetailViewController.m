//
//  NoteDetailViewController.m
//  NoteTask
//
//  Created by Ben on 16/7/19.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteDetailViewController.h"
#import "NotePropertyView.h"
#import "YYText.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "PopupViewController.h"
#import "TextButtonLine.h"
















@interface NoteDetailViewController () <UITableViewDataSource, UITableViewDelegate, YYTextViewDelegate>

@property (nonatomic, strong) NoteModel* noteModel;
@property (nonatomic, strong) NSMutableArray<NoteParagraphModel*> *noteParagraphs;
@property (nonatomic, strong) NSMutableDictionary *optumizeHeights;

@property (nonatomic, strong) NSIndexPath *indexPathOnEditing;
@property (nonatomic, strong) NSString *dueEditing;


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableNoteParagraphs;




@end

@implementation NoteDetailViewController





- (instancetype)initWithNoteModel:(NoteModel*)noteModel
{
    self = [super init];
    if (self) {
        self.noteModel = noteModel;
        self.noteParagraphs = [[NSMutableArray alloc] init];
        [self parseNoteParagraphs];
        
        self.optumizeHeights = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}


- (instancetype)initWithCreateNoteModel
{
    self = [super init];
    if (self) {
        
        NoteModel* noteModel = [[NoteModel alloc] init];
        noteModel.title = @"点击输入题目";
        noteModel.content = @"";
        
        self.noteModel = noteModel;
        self.noteParagraphs = [[NSMutableArray alloc] init];
        [self parseNoteParagraphs];
        
        self.optumizeHeights = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"笔记详情";
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.noteModel.title;
    self.titleLabel.numberOfLines = 0;
    //[self.view addSubview:self.titleLabel];
    
    self.tableNoteParagraphs = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableNoteParagraphs.dataSource = self;
    self.tableNoteParagraphs.delegate = self;
    [self.view addSubview:self.tableNoteParagraphs];
    
    
}

#define YBLOW 64
- (void)viewWillLayoutSubviews
{
    CGRect frameTitleLabel = CGRectMake(0, YBLOW, self.view.bounds.size.width, 100);
    CGSize size = [self.titleLabel sizeThatFits:frameTitleLabel.size];
    frameTitleLabel.size.height = size.height;
    self.titleLabel.frame = frameTitleLabel;
    
    frameTitleLabel.size.height = 0;
    
    CGRect frameNoteParagraphs = CGRectMake(0,
                                            0, /*frameTitleLabel.origin.y + frameTitleLabel.size.height,*/
                                            self.view.bounds.size.width,
                                            self.view.bounds.size.height - (frameTitleLabel.origin.y + frameTitleLabel.size.height));
    frameNoteParagraphs = self.view.bounds;
    self.tableNoteParagraphs.frame = frameNoteParagraphs;
    
    
    
    
    
    
    
}


- (void)parseNoteParagraphs
{
    self.noteParagraphs = [[NSMutableArray alloc] init];
    
    NoteParagraphModel *noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"设计师心情最平静的时候是熬夜做完案子准备睡觉时，看见天色有些发白，听见一两声鸟。为了更加形象地描述（嘲讽）这个脑细胞平均每天死一万次的职业，《Lean Branding》的作者Laura Busche画了10张图，长这样：";

    [self.noteParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"1、设计师听到最幸福的情话就是：挺好的，用这稿！如果改到山穷水尽疑无路，设计师真的会想说“kill me，kill me now”。fs fsdfsdkfjs dfsdklfdskjf sdkfjds fsldkflsdfk sdfk sd;lkf s;ldfkdslkfsdl";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"2.直播优化层面";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"其实最难的难点是提高首播时间、服务质量即Qos（Quality of Service，服务质量），如何在丢包率20%的情况下还能保障稳定、流畅的直播体验，需要考虑以下方案：";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"1）为加快首播时间，收流服务器主动推送 GOP :（Group of Pictures:策略影响编码质量)所谓GOP，意思是画面组，一个GOP就是一组连续的画面至边缘节点，边缘节点缓存 GOP，播放端则可以快速加载，减少回源延迟";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"2）GOP丢帧，为解决延时，为什么会有延时，网络抖动、网络拥塞导致的数据发送不出去，丢完之后所有的时间戳都要修改，切记，要不客户端就会卡一个 GOP的时间，是由于 PTS（Presentation Time Stamp，PTS主要用于度量解码后的视频帧什么时候被显示出来） 和 DTS 的原因，或者播放器修正 DTS 和 PTS 也行（推流端丢GOD更复杂，丢 p 帧之前的 i 帧会花屏）";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"3）纯音频丢帧，要解决音视频不同步的问题，要让视频的 delta增量到你丢掉音频的delta之后，再发音频，要不就会音视频不同步";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"4）源站主备切换和断线重连";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"5）根据TCP拥塞窗口做智能调度，当拥塞窗口过大说明节点服务质量不佳，需要切换节点和故障排查";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"6）增加上行、下行带宽探测接口，当带宽不满足时降低视频质量，即降低码率";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"7）定时获取最优的推流、拉流链路IP，尽可能保证提供最好的服务";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"8)监控必须要，监控各个节点的Qos状态，来做整个平台的资源配置优化和调度";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"9）如果产品从推流端、CDN、播放器都是自家的，保障 Qos 优势非常大";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"10）当直播量非常大时，要加入集群管理和调度，保障 Qos";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"11）播放端通过增加延时来减少网络抖动，通过快播来减少延时。（出自知乎宋少东）。";
    [self.noteParagraphs addObject:noteParagraph];
    
    
    
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"7、你不知道排版最难的地方就是一点一点的间距和文字，真的会瞎掉我的狗眼，别说5分钟给我排个版，你以为是ppt？";
    [self.noteParagraphs addObject:noteParagraph];
    
    [self.noteParagraphs addObjectsFromArray:self.noteParagraphs];
}


- (NSMutableAttributedString*)noteParagraphAttrbutedString:(NoteParagraphModel*)noteParagraphModel
{

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:noteParagraphModel.content];
    UIFont *font = [UIFont systemFontOfSize:16];
    UIColor *color = [UIColor blackColor];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}
                                                            

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 100.0;
    
    if([indexPath isEqual:self.indexPathOnEditing]) {
        
    }
    else {
        NSNumber *heightNumber = self.optumizeHeights[indexPath];
        if([heightNumber isKindOfClass:[NSNumber class]]) {
            height = [heightNumber floatValue];
        }
    }
    
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 1;
    return sections;
}


#define ROW_NUMBER_TITLE    2
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = self.noteParagraphs.count;
    return rows + ROW_NUMBER_TITLE; /*title一栏, 信息一栏.*/
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define TAG_noteParagraphLabel          1000000 + 10
#define TAG_noteParagraphTextView       1000000 + 11
#define TAG_notePropertyView            1000000 + 12
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteParagraph"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        CGRect frame = cell.frame;
        frame.size.width = tableView.frame.size.width;
        [cell setFrame:frame];

    }
    else {

    }
    
    if(indexPath.row == 0) {
        cell.textLabel.text = self.noteModel.title;
        cell.textLabel.font = [UIFont systemFontOfSize:20 weight:1];
        cell.textLabel.numberOfLines = 0;
        
        NSLog(@"%f", cell.textLabel.frame.size.width);
        NSLog(@"%f", cell.frame.size.width);
        
        CGSize sizeOptumize = CGSizeMake(cell.frame.size.width - 80, 200);
        sizeOptumize = [cell.textLabel sizeThatFits:sizeOptumize];
        CGFloat heightOptumize = sizeOptumize.height;
        self.optumizeHeights[indexPath] = [NSNumber numberWithFloat:heightOptumize];
        
        CGRect frame = cell.textLabel.frame;
        frame.size.height = heightOptumize;
        cell.textLabel.frame = frame;
    }
    else if(indexPath.row == 1) {
        //cell.textLabel.text = @"附加信息";
        CGFloat height = 36.0;
        
        self.optumizeHeights[indexPath] = [NSNumber numberWithFloat:height];
        
        NotePropertyView *notePropertyView = [cell viewWithTag:TAG_notePropertyView];
        if(!notePropertyView) {
            notePropertyView = [[NotePropertyView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, height)];
            
            [cell addSubview:notePropertyView];
            [notePropertyView setTag:TAG_notePropertyView];
        }
        
        [notePropertyView setClassification:self.noteModel.classification color:nil];
        

        
    }
    else {

        YYLabel *noteParagraphLabel = [cell viewWithTag:TAG_noteParagraphLabel];
        if(!noteParagraphLabel) {
            noteParagraphLabel = [[YYLabel alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width - 10 * 2, 100)];
            noteParagraphLabel.numberOfLines = 0;
            
            [cell addSubview:noteParagraphLabel];
            [noteParagraphLabel setTag:TAG_noteParagraphLabel];
        }
        
        //内容设置.
        NoteParagraphModel *noteParagraph = self.noteParagraphs[indexPath.row - ROW_NUMBER_TITLE];
        noteParagraphLabel.attributedText = [self noteParagraphAttrbutedString:noteParagraph];
        //noteParagraphLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        //计算可变高度. 同时保存给UITableviewCell的高度计算.
        CGSize sizeOptumize = CGSizeMake(noteParagraphLabel.frame.size.width, 1000);
        sizeOptumize = [noteParagraphLabel sizeThatFits:sizeOptumize];
        CGFloat heightOptumize = sizeOptumize.height + 20 ;
        self.optumizeHeights[indexPath] = [NSNumber numberWithFloat:heightOptumize];
        
        //设置高度.
        CGRect frame = noteParagraphLabel.frame;
        frame.size.height = heightOptumize;
        noteParagraphLabel.frame = frame;
    }
    
    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"row : %zd", indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if(indexPath.row == 0) {
        
    }
    else if(indexPath.row == 1) {

    }
    else {
//        //[self snapshot];
//        
//        PopupViewController *vc = [[PopupViewController alloc] init];
//        UIImage *image = [self screenImageWithSize:[UIScreen mainScreen].bounds.size];
//        /*
//        CALayer *layer = [CALayer layer];
//        
//        layer.contents = (__bridge id _Nullable)(image.CGImage);
//        NSLog(@"%@", layer.contents);
//        //[vc.view.layer addSublayer:layer];
//        
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//        [self.view addSubview:imageView];
//        */
//        vc.imageBackground = image;
//        [self.navigationController pushViewController:vc animated:NO];
        
        CGFloat width = 45;
        TextButtonLine *v = [[TextButtonLine alloc] initWithFrame:CGRectMake(self.view.frame.size.width - width - 10, 64 + 10, width, self.view.frame.size.height - 10 * 2)];
        v.layoutMode = TextButtonLineLayoutModeVertical;
        NSArray<NSString*> *actionStrings = @[@"复制", @"编辑", @"插入", @"增加"];
        
        [v setTexts:actionStrings];
        __weak typeof(self) weakSelf = self;
        [v setButtonActionByText:^(NSString* actionText) {
            [weakSelf dismissPopupView];
            [weakSelf action:actionText OnIndexPath:indexPath];
        }];
        
        [self showPopupView:v];
    }

    
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.indexPathOnEditing) {
        if([indexPath isEqual:self.indexPathOnEditing]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return YES;
    }
}


- (void)editNoteParagraphAtIndexPath:(NSIndexPath*)indexPath due:(NSString*)dueEditing
{
    self.indexPathOnEditing = indexPath;
    self.dueEditing         = dueEditing;
    
    [self.tableNoteParagraphs beginUpdates];
    [self.tableNoteParagraphs reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableNoteParagraphs endUpdates];
    
    UITableViewCell *cell = [self.tableNoteParagraphs cellForRowAtIndexPath:indexPath];
    YYLabel *noteParagraphLabel = [cell viewWithTag:TAG_noteParagraphLabel];
    noteParagraphLabel.hidden = YES;
    
    NSLog(@"%@", noteParagraphLabel);
    NSLog(@"%@", noteParagraphLabel.attributedText);
    NSLog(@"%@", noteParagraphLabel.text);
    
    YYTextView *noteParagraphTextView = [[YYTextView alloc] init];
    noteParagraphTextView.tag = TAG_noteParagraphTextView;
    noteParagraphTextView.frame = cell.bounds;
    noteParagraphTextView.attributedText = noteParagraphLabel.attributedText;
    
    UIToolbar *keyboardAccessory = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 36)];
    keyboardAccessory.backgroundColor = [UIColor whiteColor];
    
    [keyboardAccessory setItems:@[
                                  [[UIBarButtonItem alloc] initWithTitle:@"撤销" style:UIBarButtonItemStylePlain target:self action:@selector(removeUpdate:)],
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  [[UIBarButtonItem alloc] initWithTitle:@"输入完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneUpdate:)]
                                  ]
                       animated:YES];
    
    noteParagraphTextView.inputAccessoryView = keyboardAccessory;
    
    [cell addSubview:noteParagraphTextView];
    
    cell.backgroundColor = [UIColor blueColor];
    
    [self.tableNoteParagraphs scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [noteParagraphTextView becomeFirstResponder];
}


- (void)withdrawEditingNoteParagraphAtIndexPath:(NSIndexPath*)indexPath
{
    //取消编辑状态.
    [[self textViewOnEditing] endEditing:YES];
    
    if([self.dueEditing isEqualToString:@"编辑"]) {
        //数据源不更新,直接刷新显示.
        [self.tableNoteParagraphs reloadData];
    }
    else if([self.dueEditing isEqualToString:@"插入"] || [self.dueEditing isEqualToString:@"增加"]) {
        //删除新增加的NoteParagraph.
        NSInteger idxNoteParagraph = [self noteParagraphIndexOn:indexPath];
        [self.noteParagraphs removeObjectAtIndex:idxNoteParagraph];
        
        [self.tableNoteParagraphs reloadData];
    }
    else {
        NSLog(@"#error - dueEditing nil.");
        [self.tableNoteParagraphs reloadData];
    }
    
    self.indexPathOnEditing = nil;
}


- (void)finishEditingNoteParagraphAtIndexPath:(NSIndexPath*)indexPath
{
    YYTextView *noteParagraphTextView = [self textViewOnEditing];
    if(!noteParagraphTextView) {
        NSLog(@"#error - textViewOnEditing nil.");
        return ;
    }
    
    NSString *content = [noteParagraphTextView.attributedText string];
    [self updateNoteParagraphOnIndex:[self noteParagraphIndexOn:indexPath] withContent:content];
    
    //输入框移除.
    [noteParagraphTextView removeFromSuperview];
    
    //刷新显示.
    [self.tableNoteParagraphs reloadData];
    
    //标记indexPathOnEditing.
    self.indexPathOnEditing = nil;
}


- (void)action:(NSString*)string OnIndexPath:(NSIndexPath*)indexPath
{
    if([string isEqualToString:@"编辑"]) {
        
        if(self.indexPathOnEditing) {
            [self action:@"编辑完成" OnIndexPath:self.indexPathOnEditing];
            self.indexPathOnEditing = nil;
        }
        
        [self editNoteParagraphAtIndexPath:indexPath due:@"编辑"];

        return ;
    }

    
    if([string isEqualToString:@"插入"]) {
        NSInteger idxInsert = [self noteParagraphIndexOn:indexPath];
        NoteParagraphModel *noteParagraph = [[NoteParagraphModel alloc] init];
        noteParagraph.content = @"111";
        [self.noteParagraphs insertObject:noteParagraph atIndex:idxInsert];
        
        [self.tableNoteParagraphs beginUpdates];
        [self.tableNoteParagraphs insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableNoteParagraphs endUpdates];
        
        [self.tableNoteParagraphs reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self editNoteParagraphAtIndexPath:indexPath due:@"插入"];
        });
        
        return;
        
    }
    
    if([string isEqualToString:@"增加"]) {
    
        NSInteger idxAppend = [self noteParagraphIndexOn:indexPath];
        if(idxAppend == self.noteParagraphs.count - 1) {
            [self.noteParagraphs addObject:[self newNoteParagraph]];
        }
        else {
            [self.noteParagraphs insertObject:[self newNoteParagraph] atIndex:idxAppend + 1];
        }
        
        NSIndexPath *indexPathAppend = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        
        [self.tableNoteParagraphs beginUpdates];
        [self.tableNoteParagraphs insertRowsAtIndexPaths:@[indexPathAppend] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableNoteParagraphs endUpdates];
        
        [self.tableNoteParagraphs reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self editNoteParagraphAtIndexPath:indexPathAppend due:@"增加"];
        });
        
        return;
        
    }
    
    
    
    
    
    

    
    
    NSLog(@"action not implemented.");
}


- (NSInteger)noteParagraphIndexOn:(NSIndexPath*)indexPath
{
    return indexPath.row - ROW_NUMBER_TITLE;
}


- (NoteParagraphModel*)newNoteParagraph
{
    NoteParagraphModel *noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"111";
    
    return noteParagraph;
}


- (void)updateNoteParagraphOnIndex:(NSInteger)noteParagraphIndex withContent:(NSString*)content
{
    NoteParagraphModel *noteParagraph = self.noteParagraphs[noteParagraphIndex];
    noteParagraph.content = content;
    
    //更新本地存储.
    
    
}


- (YYTextView*)textViewOnEditing
{
    YYTextView *noteParagraphTextView = nil;
    
    if(self.indexPathOnEditing
       && [self.tableNoteParagraphs visibleCells].count > 0
       ) {
        
        UITableViewCell *cell = [self.tableNoteParagraphs cellForRowAtIndexPath:self.indexPathOnEditing];
        if(cell) {
            noteParagraphTextView = [cell viewWithTag:TAG_noteParagraphTextView];
        }
    }
    
    return noteParagraphTextView;
}


- (void)removeUpdate:(id)sender
{
    [self withdrawEditingNoteParagraphAtIndexPath:self.indexPathOnEditing];
}


- (void)doneUpdate:(id)sender
{
    [self finishEditingNoteParagraphAtIndexPath:self.indexPathOnEditing];
}







-(UIImage *)screenImageWithSize:(CGSize )imgSize{
    UIGraphicsBeginImageContext(imgSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    AppDelegate * app = (AppDelegate *)([UIApplication sharedApplication].delegate); //获取app的appdelegate，便于取到当前的window用来截屏
    [app.window.layer renderInContext:context];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


- (void)snapshot
{
    UIGraphicsBeginImageContext(self.view.frame.size);

    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //将截屏保存到相册
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(newImage,self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    UIGraphicsEndImageContext();
    
    UIImage *image = [self screenImageWithSize:[UIScreen mainScreen].bounds.size];
    UIImageWriteToSavedPhotosAlbum(image,self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    

}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"保存失败，请检查是否拥有相关的权限");
    }
    else {
        NSLog(@"保存成功！");
    }
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#define TAG_popupView_container     1000000002
- (void)showPopupView:(UIView*)view
{
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    containerView.backgroundColor = [UIColor colorWithName:@"PopupContainerBackground"];
    containerView.alpha = 0.9;
    containerView.tag = TAG_popupView_container;
    [self.view addSubview:containerView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopupView)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [containerView addGestureRecognizer:tapGestureRecognizer];
    
    [containerView addSubview:view];
    

    
    
}


- (void)dismissPopupView
{
    UIView *containerView = [self.view viewWithTag:TAG_popupView_container];
    for(id obj in containerView.subviews) {
        NSLog(@"%@", obj);
        //        [obj removeObserver:self forKeyPath:@"frame"];
        [obj removeFromSuperview];
    }
    
    [containerView removeFromSuperview];
    containerView = nil;
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
