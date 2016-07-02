//
//  RemoteViewController.m
//  NoteTask
//
//  Created by Ben on 16/2/20.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import "RemoteViewController.h"
#import "UIColor+Util.h"
#import "TableViewLastCell.h"




#import "AFNetworking.h"
#import "TTTAttributedLabel.h"
#import "YYText.h"
@interface RemoteViewController () <TTTAttributedLabelDelegate>

@property (nonatomic, strong) TableViewLastCell *lastCell;



@end



@implementation RemoteViewController


- (instancetype)init {
    self = [super init];
    
    if(self) {
        self.objects = [[NSMutableArray alloc] init];
        
        
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor themeColor];
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.backgroundColor = [UIColor themeColor];
    
    _lastCell = [[TableViewLastCell alloc] init];
    [_lastCell setStatus1:TableViewLastCellStatusNotVisible];
    self.tableView.tableFooterView = _lastCell;
    
    [self performSelector:@selector(refresh) withObject:nil afterDelay:1.f];
    
    
    NSString *s = @"<a href=\"123\">测试1231111111111fdsdfsdfs附近是开发建设地方开始就大方送到房间是对方说的风刀霜剑看风景的是开发技术的开发建设贷款纠纷时的咖啡机深刻的风景时的咖啡机看电视附近的身份时的咖啡机都是咖啡就是对方123 <br>123</a>";
    NSMutableAttributedString *attstring =
    [[NSMutableAttributedString alloc] initWithData:[s dataUsingEncoding:NSUnicodeStringEncoding]
                                            options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                                                                                              documentAttributes:nil error:nil];
    
    
    YYLabel *label = [[YYLabel alloc] initWithFrame:CGRectMake(0, 360, self.view.frame.size.width, self.view.frame.size.height-360-200)];
    label.attributedText = attstring;
    label.textAlignment = NSTextAlignmentCenter;
    label.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    CGSize size = [label sizeThatFits:label.frame.size];
    size = [label systemLayoutSizeFittingSize:label.frame.size];
    NSLog(@"yyyyyyyyyyyyyyyyy %f %f", size.width, size.height);
}


- (void)viewWillLayoutSubviews {
    [_lastCell setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    [_lastCell setBackgroundColor:[UIColor yellowColor]];
    
    
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    //remove notification.
}










- (NSString*)generateURL:(NSInteger)page {
    NSLog(@"Need override.");
    return @"www";
}


//public.
- (void)parseRemoteContent:(NSData*)data
{
    NSLog(@"Need override.");
    return ;
}


- (void)loadMore {
    //获取网络请求地址. 具体实现由继承类重载.
    NSString *URLString = [self generateURL:self.page];
    NSLog(@"URLString1 : %@", URLString);
    
    [self startReload1];
    
    //网络请求.
#if 0
    NSURL *url = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:0 timeoutInterval:10.f];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
                               if(!connectionError) {
                                   [self parseRemoteContent:data];
                                   [self.tableView reloadData];
                               }
                               else {
                                   
                               }
    }];
    
#endif
    
    
    
    
 
    
    
    
    
}


- (void)startReload1
{
    NSLog(@"111x");
    NSString *urlString = @"http://www.cnblogs.com";
    NSInteger page = 1;
    
    NSLog(@"URLString : %@", urlString);
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [session GET:urlString parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
            
        }
     
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"%@", [responseObject class]);
             [self parseData:responseObject onPage:page];
             
             if([responseObject isKindOfClass:[NSData class]]) {
                 NSLog(@"NSData --- ");
                 
             }
         }
     
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@", error);
         }
     ];
}


- (void)parseData:(NSData*)data onPage:(NSInteger)page
{
    NSLog(@"-----\n");
    
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(100, 120, 120, 60)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.numberOfLines = 0;
    
    //设置高亮颜色
    label.highlightedTextColor = [UIColor greenColor];
    //检测url
    label.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    //对齐方式
    label.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
    //行间距
    label.lineSpacing = 8;
    //设置阴影
    label.shadowColor = [UIColor grayColor];
    label.delegate = self; // Delegate
    
    //NO 不显示下划线
    
    label.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    
    NSString *text = @"冷清风 赞了 王战 的说说";
    
    [label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString)
     
     {
         
         //设置可点击文字的范围
         
         NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"冷清风" options:NSCaseInsensitiveSearch];
         
         
         
         //设定可点击文字的的大小
         
         UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:16];
         
         CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
         
         if (font) {
             
             //设置可点击文本的大小
             
             [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
             
             
             
             //设置可点击文本的颜色
             
             [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor blueColor] CGColor] range:boldRange];
             
             
             CFRelease(font);
             
         }
         
         return mutableAttributedString;
         
     }];
    NSLog(@"-----");
    
    //[self.view addSubview:label];
    
    NSLog(@"-----");
    
    NSString *s1 = @"<a href=\"http://123\">无正文</a>";
    data = [s1 dataUsingEncoding:NSUTF8StringEncoding];
   
    NSLog(@"-----");
    TTTAttributedLabel *attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
documentAttributes:nil error:nil];
    
    NSLog(@"attString : %@", attString);
    
    NSLog(@"-----");
    attributedLabel.text = attString;
    attributedLabel.frame = CGRectMake(0, 360, 200, 200);
    //[self.view addSubview:attributedLabel];
    attributedLabel.delegate = self;
    
    
    NSLog(@"-----");
    
    
}


- (void)attributedLabel:(__unused TTTAttributedLabel *)label

   didSelectLinkWithURL:(NSURL *)url

{
    NSLog(@"CLICK : %@", url);
    
    NSLog(@"CLICK : %@", [url relativeString]);
    
}


- (void)refresh {
    self.page = 1;
    [self loadMore];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.separatorColor = [UIColor separatorColor];
    return [self.objects count];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height))) {
        [self loadMore];
    }
}



@end
