//
//  NoteDetailViewController.m
//  NoteTask
//
//  Created by Ben on 16/7/19.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteDetailViewController.h"






@interface NoteDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NoteModel* noteModel;
@property (nonatomic, strong) NSMutableArray<NoteParagraphModel*> *noteParagraphs;
@property (nonatomic, strong) NSMutableDictionary *optumizeHeights;

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
    noteParagraph.content = @"7、你不知道排版最难的地方就是一点一点的间距和文字，真的会瞎掉我的狗眼，别说5分钟给我排个版，你以为是ppt？";
    [self.noteParagraphs addObject:noteParagraph];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 100.0;
    
    NSNumber *heightNumber = self.optumizeHeights[indexPath];
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


#define ROW_NUMBER_TITLE    2
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = self.noteParagraphs.count;
    return rows + ROW_NUMBER_TITLE; /*title一栏, 信息一栏.*/
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        cell.textLabel.text = @"附加信息";
        self.optumizeHeights[indexPath] = [NSNumber numberWithFloat:36.0];
    }
    else {
        #define TAG_noteParagraphLabel 1000000+45
        UILabel *noteParagraphLabel = [cell viewWithTag:TAG_noteParagraphLabel];
        if(!noteParagraphLabel) {
            noteParagraphLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width - 10 * 2, 100)];
            noteParagraphLabel.numberOfLines = 0;
            
            [cell addSubview:noteParagraphLabel];
            [noteParagraphLabel setTag:TAG_noteParagraphLabel];
        }
        
        //内容设置.
        
        
        noteParagraphLabel.text = self.noteParagraphs[indexPath.row - ROW_NUMBER_TITLE].content;
        noteParagraphLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        //计算可变高度. 同时保存给UITableviewCell的高度计算.
        CGSize sizeOptumize = CGSizeMake(noteParagraphLabel.frame.size.width, 1000);
        sizeOptumize = [noteParagraphLabel sizeThatFits:sizeOptumize];
        CGFloat heightOptumize = sizeOptumize.height + 20;
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
