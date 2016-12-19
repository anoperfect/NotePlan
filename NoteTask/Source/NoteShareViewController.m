//
//  NoteShareViewController.m
//  NoteTask
//
//  Created by Ben on 16/11/1.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteShareViewController.h"
#import "NoteModel.h"
#import "NoteDetailViewController.h"
@interface NoteShareViewController () <UIWebViewDelegate>



@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, assign) BOOL htmGenerated;

@property (nonatomic, assign) NSInteger pdfGenerateStatus;//0.waiting. 1.OK. -1.failed.


@property (nonatomic, strong) NSString *noteFolder;
@property (nonatomic, strong) NSString *htmName;
@property (nonatomic, strong) NSString *htmPath;
@property (nonatomic, strong) NSString *pdfName;
@property (nonatomic, strong) NSString *pdfPath;
@property (nonatomic, strong) NSData *pdfData;


@property (nonatomic, assign) NSInteger    selectedIndex;
@property (nonatomic, strong) UISegmentedControl    *fileTypeSelect;

@property (nonatomic, strong) UIView    *viewAirDropContainer;
@property (nonatomic, strong) UIImageView   *labelAirDropIcon;
@property (nonatomic, strong) UILabel   *labelAirDrop;
@property (nonatomic, strong) UILabel   *labelAirDropDetail;
@property (nonatomic, strong) UIButton  *buttonAirDropHtm;
@property (nonatomic, strong) UIButton  *buttonAirDropPdf;
@property (nonatomic, strong) UIButton  *buttonAirDrop;

@property (nonatomic, strong) UIView    *viewLANContainer;
@property (nonatomic, strong) UIImageView   *labelLANIcon;
@property (nonatomic, strong) UILabel   *labelLAN;
@property (nonatomic, strong) UILabel   *labelLANDetail;


@property (nonatomic, strong) UIView    *viewWANContainer;
@property (nonatomic, strong) UIImageView   *labelWANIcon;
@property (nonatomic, strong) UILabel   *labelWAN;
@property (nonatomic, strong) UILabel   *labelWANDetail;
@property (nonatomic, strong) UIButton  *buttonWANUpload;

@property (nonatomic, strong) GCDWebServer* webServer;
@property (nonatomic, strong) NSString *serverURL;
@property (nonatomic, assign) NSInteger serverStatus; //0.正启动.1.启动成功.2.启动失败.

@property (nonatomic, assign) NSInteger uploadHtmStatus; //0.正上传.1.上传成功.2.上传失败.
@property (nonatomic, assign) NSInteger uploadPdfStatus; //0.正上传.1.上传成功.2.上传失败.
@property (nonatomic, strong) NSString *WANServer;

@end

@implementation NoteShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"共享";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.WANServer = @"http://notetask.appben.com";
    
#define NEW_AND_ADD_SUBVIEW(view, class) [self addSubview:(view = [[class alloc] init])];
    
    
    NEW_AND_ADD_SUBVIEW(self.fileTypeSelect, UISegmentedControl);
    
    NEW_AND_ADD_SUBVIEW(self.viewAirDropContainer, UIView);
    NEW_AND_ADD_SUBVIEW(self.labelAirDropIcon, UIImageView);
    NEW_AND_ADD_SUBVIEW(self.labelAirDrop, UILabel);
    NEW_AND_ADD_SUBVIEW(self.labelAirDropDetail, UILabel);
//    NEW_AND_ADD_SUBVIEW(self.buttonAirDropHtm, UIButton);
//    NEW_AND_ADD_SUBVIEW(self.buttonAirDropPdf, UIButton);
    NEW_AND_ADD_SUBVIEW(self.buttonAirDrop, UIButton);
    
    NEW_AND_ADD_SUBVIEW(self.viewLANContainer, UIView);
    NEW_AND_ADD_SUBVIEW(self.labelLANIcon, UIImageView);
    NEW_AND_ADD_SUBVIEW(self.labelLAN, UILabel);
    NEW_AND_ADD_SUBVIEW(self.labelLANDetail, UILabel);
    
    NEW_AND_ADD_SUBVIEW(self.viewWANContainer, UIView);
    NEW_AND_ADD_SUBVIEW(self.labelWANIcon, UIImageView);
    NEW_AND_ADD_SUBVIEW(self.labelWAN, UILabel);
    NEW_AND_ADD_SUBVIEW(self.labelWANDetail, UILabel);
    //NEW_AND_ADD_SUBVIEW(self.buttonWANUpload, UIButton);
    
    [self.fileTypeSelect insertSegmentWithTitle:@"网页文件htm" atIndex:0 animated:YES];
    [self.fileTypeSelect insertSegmentWithTitle:@"Pdf文件" atIndex:1 animated:YES];
    [self.fileTypeSelect addTarget:self action:@selector(actionSelectFileType:) forControlEvents:UIControlEventValueChanged];
    self.fileTypeSelect.selectedSegmentIndex = (self.selectedIndex = 1);
    
    self.labelAirDropIcon.image = [UIImage imageNamed:@"ShareAirDrop"];
    self.labelAirDrop.text = @"AirDrop";
    self.labelAirDropDetail.text = @"使用共享方式,使用AirDrop或者其他应用将文件共享或者传输到其他设备.";
    self.labelAirDropDetail.numberOfLines = 0;
    self.labelAirDropDetail.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    
    [self.buttonAirDropHtm setTitle:@"HTM" forState:UIControlStateNormal];
    [self.buttonAirDropHtm setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonAirDropHtm addTarget:self action:@selector(actionShareHtm) forControlEvents:UIControlEventTouchDown];
    self.buttonAirDropHtm.layer.borderColor = [UIColor blackColor].CGColor;
    self.buttonAirDropHtm.layer.borderWidth = 1.;
    self.buttonAirDropHtm.layer.cornerRadius = 2;
    
    [self.buttonAirDropPdf setTitle:@"PDF" forState:UIControlStateNormal];
    [self.buttonAirDropPdf setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonAirDropPdf addTarget:self action:@selector(actionSharePdf) forControlEvents:UIControlEventTouchDown];
    self.buttonAirDropPdf.layer.borderColor = [UIColor blackColor].CGColor;
    self.buttonAirDropPdf.layer.borderWidth = 1.;
    self.buttonAirDropPdf.layer.cornerRadius = 2;
    
    [self.buttonAirDrop setTitle:@"点击分享" forState:UIControlStateNormal];
    [self.buttonAirDrop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonAirDrop addTarget:self action:@selector(actionShare) forControlEvents:UIControlEventTouchDown];
    self.buttonAirDrop.layer.borderColor = [UIColor blackColor].CGColor;
    self.buttonAirDrop.layer.borderWidth = 1.;
    self.buttonAirDrop.layer.cornerRadius = 2;
    
    self.labelLANIcon.image = [UIImage imageNamed:@"ShareLAN"];
    self.labelLANDetail.numberOfLines = 0;
    self.labelLANDetail.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    
    self.labelWANIcon.image = [UIImage imageNamed:@"ShareWAN"];
    self.labelWANDetail.numberOfLines = 0;
    self.labelWANDetail.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    
    [self.buttonWANUpload setTitle:@"上传" forState:UIControlStateNormal];
    [self.buttonWANUpload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.buttonWANUpload.layer.borderColor = [UIColor blackColor].CGColor;
    self.buttonWANUpload.layer.borderWidth = 1.;
    self.buttonWANUpload.layer.cornerRadius = 2;
    self.buttonWANUpload.hidden = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self generateHtm];
        [self actionUploadHtm];
        
        self.webView = [[UIWebView alloc] init];
        [self addSubview:self.webView];
        NSString *s = [self.noteModel generateWWWPage];
        [self.webView loadHTMLString:s baseURL:nil];
        self.webView.delegate = self;
        self.webView.hidden = YES;
        
        [self createLocalServer];
    });
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.webView.frame = VIEW_BOUNDS;
    
    FrameLayout *f = [[FrameLayout alloc] initWithRootView:self.contentView];
    [f frameLayout:FRAMELAYOUT_NAME_MAIN to:@[@"FileTypeMain", @"AirDropMain", @"LANMain", @"WANMain"] withPercentages:@[@0.08,@0.20,@0.36,@0.36]];
    
    [f frameLayoutSet:@"FileTypeSelect" in:@"FileTypeMain" withEdgeInserts:UIEdgeInsetsMake(2, 10, 2, 10)];
    
    [f frameLayoutSet:@"AirDropContainer" in:@"AirDropMain" withEdgeInserts:UIEdgeInsetsMake(10, 10, 10, 10)];
    [f frameLayout:@"AirDropContainer" toVertical:@[@"AirDropDescription", @"AirDropAction"] withPercentages:@[@0.64,@0.36]];
    [f frameLayout:@"AirDropDescription" to:@[@"AirDropTitle", @"AirDropDetail"] withHeights:@[@36,@-1.]];
    [f frameLayoutSquare:@"AirDropTitle" toVertical:@[@"AirDropIcon", @"AirDropLabel"]];
    [f frameLayout:@"AirDropAction" to:@[@"AirDropClick", @""] withHeights:@[@36,@-1.]];
    
    [f frameLayoutSet:@"LANContainer" in:@"LANMain" withEdgeInserts:UIEdgeInsetsMake(10, 10, 10, 10)];
    [f frameLayout:@"LANContainer" to:@[@"LANTitle", @"LANDetail"] withHeights:@[@36, @-1.]];
    [f frameLayoutSquare:@"LANTitle" toVertical:@[@"LANIcon", @"LANLabel"]];
    
    [f frameLayoutSet:@"WANContainer" in:@"WANMain" withEdgeInserts:UIEdgeInsetsMake(10, 10, 10, 10)];
    [f frameLayout:@"WANContainer" to:@[@"WANTitle", @"WANDetail"] withHeights:@[@36, @-1.]];
    [f frameLayoutSquare:@"WANTitle" toVertical:@[@"WANIcon", @"WANLabelAndButton"]];
    [f frameLayout:@"WANLabelAndButton" toVertical:@[@"WANLabel", @"WANButton"] withWidths:@[@180,@-1.]];
    
    FrameAssign(self.fileTypeSelect, @"FileTypeSelect", f)
    
    FrameAssign(self.viewAirDropContainer, @"AirDropContainer", f)
    FrameAssign(self.labelAirDropIcon, @"AirDropIcon", f)
    FrameAssign(self.labelAirDrop, @"AirDropLabel", f)
    FrameAssign(self.labelAirDropDetail, @"AirDropDetail", f)
    FrameAssign(self.buttonAirDropHtm, @"AirDropButtonHtm", f)
    FrameAssign(self.buttonAirDropPdf, @"AirDropButtonPDF", f)
    FrameAssign(self.buttonAirDrop, @"AirDropClick", f)
    
    FrameAssign(self.viewLANContainer, @"LANContainer", f)
    FrameAssign(self.labelLANIcon, @"LANIcon", f)
    FrameAssign(self.labelLAN, @"LANLabel", f)
    FrameAssign(self.labelLANDetail, @"LANDetail", f)
    
    FrameAssign(self.viewWANContainer, @"WANContainer", f)
    FrameAssign(self.labelWANIcon, @"WANIcon", f)
    FrameAssign(self.labelWAN, @"WANLabel", f)
    FrameAssign(self.labelWANDetail, @"WANDetail", f)
    FrameAssign(self.buttonWANUpload, @"WANButton", f)
    
    NSLog(@"%@", f);
    
    
    NSLog(@"---------%zd. %@", self.contentView.subviews, self.contentView);
    for(UIView *view in self.contentView.subviews) {
        NSLog(@"%@", view);
    }
    
    
    
}


- (void)createLocalServer
{
    __weak typeof(self) _self = self;
    
    // Create server
    
    _webServer = [[GCDWebServer alloc] init];
    
    // Add a handler to respond to GET requests on any URL
    [_webServer addDefaultHandlerForMethod:@"GET"
                              requestClass:[GCDWebServerRequest class]
                              processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                  NSArray<NSString*> *paths = [request.path componentsSeparatedByString:@"/"];
                                  NSString* filename = [paths lastObject];
                                  NSString* noteSn = nil;
                                  NSString *sNotFound = @"<html><body><p>未找到所需文件</p></body></html>";
                                  if([filename hasSuffix:@".htm"]) {
                                      noteSn = [filename substringWithRange:NSMakeRange(5, filename.length - 5 - 4)];
                                      NoteModel *note = [[AppConfig sharedAppConfig] configNoteGetBySn:noteSn];
                                      if(note) {
                                          return [GCDWebServerDataResponse responseWithHTML:[note generateWWWPage]];
                                      }
                                      else {
                                          return [GCDWebServerDataResponse responseWithHTML:sNotFound];
                                      }
                                  }
                                  else if([filename hasSuffix:@".pdf"]) {
                                      noteSn = [filename substringWithRange:NSMakeRange(5, filename.length - 5 - 4)];
                                      NSString *pdfPath = [NSString stringWithFormat:@"%@/%@", _self.noteFolder, filename];
                                      NSData *pdfData = [NSData dataWithContentsOfFile:pdfPath];
                                      if(pdfData.length > 0) {
                                          return [GCDWebServerDataResponse responseWithData:pdfData contentType:@"application/pdf"];
                                      }
                                      else {
                                          return [GCDWebServerDataResponse responseWithHTML:sNotFound];
                                      }
                                  }
                                  else {
                                      return [GCDWebServerDataResponse responseWithHTML:sNotFound];
                                  }
                                  
                                  //                                  return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>未找到所需文件</p></body></html>"];
                              }];
    
    // Start server on port 8080
    [_webServer startWithPort:8081 bonjourName:nil];
    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
    if(_webServer.serverURL) {
        self.serverStatus = 1;
        self.serverURL = [_webServer.serverURL copy];
        NSString *htmURLString = [NSString stringWithFormat:@"%@Note-%@.htm", self.serverURL, self.noteModel.sn];
        self.labelLANDetail.text = [self.labelLANDetail.text stringByReplacingOccurrencesOfString:@"htm地址获取中..." withString:htmURLString];
        NSString *pdfURLString = [NSString stringWithFormat:@"%@Note-%@.pdf", self.serverURL, self.noteModel.sn];
        self.labelLANDetail.text = [self.labelLANDetail.text stringByReplacingOccurrencesOfString:@"pdf地址获取中..." withString:pdfURLString];
    }
    else {
        self.serverStatus = -1;
        self.labelLAN.text = @"局域网获取(当前不可用)";
        NSString *htmURLString = @"未能获取到htm地址.";
        self.labelLANDetail.text = [self.labelLANDetail.text stringByReplacingOccurrencesOfString:@"htm地址获取中..." withString:htmURLString];
        NSString *pdfURLString = @"未能获取到pdf地址.";
        self.labelLANDetail.text = [self.labelLANDetail.text stringByReplacingOccurrencesOfString:@"pdf地址获取中..." withString:pdfURLString];
    }
    
    [self actionUpdateDisplayText];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"stop webserver.");
    [self.webServer stop];
}


- (void)generateHtm
{
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [docPath objectAtIndex:0];
    self.noteFolder = [NSString stringWithFormat:@"%@/Note", documentsPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.noteFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    self.htmName = [NSString stringWithFormat:@"Note-%@.htm", self.noteModel.sn];
    self.htmPath = [NSString stringWithFormat:@"%@/%@", self.noteFolder, self.htmName];
    
    NSData *htmData = [[self.noteModel generateWWWPage] dataUsingEncoding:NSUTF8StringEncoding];
    [htmData writeToFile:self.htmPath atomically:YES];
    self.htmGenerated = YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self generatePdf];
}


- (void)generatePdf
{
    KYPrintPageRenderer *ppRenderer = [[KYPrintPageRenderer alloc] init];
    UIViewPrintFormatter *viewFormatter = [self.webView viewPrintFormatter];
    [ppRenderer addPrintFormatter:viewFormatter startingAtPageAtIndex:0];
    NSData *pdfData = [ppRenderer printToPDF];
    NSLog(@"data length : %zd", pdfData.length);
    
    self.pdfName = [NSString stringWithFormat:@"Note-%@.pdf", self.noteModel.sn];
    self.pdfPath = [NSString stringWithFormat:@"%@/%@", self.noteFolder, self.pdfName];
    NSLog(@"%@", self.pdfPath);
    
    if(pdfData.length > 0) {
        [self showIndicationText:@"已生成网页文件和PDF文件." inTime:1.];
        [pdfData writeToFile:self.pdfPath atomically:YES];
        self.pdfGenerateStatus = 1;
        self.pdfData = pdfData;
        [self actionUploadPdf];
    }
    else {
        [self showIndicationText:@"生成PDF文件出错" inTime:1.];
        self.pdfGenerateStatus = -1;
    }
    
    [self actionUpdateDisplayText];
}


- (void)actionShare
{
    if(self.selectedIndex == 0) {
        [self actionShareHtm];
    }
    else if(self.selectedIndex == 1) {
        [self actionSharePdf];
    }
    else {
        [self showIndicationText:@"Error" inTime:1.0];
    }
}

- (void)actionShareHtm
{
    NSURL *url = [NSURL fileURLWithPath:self.htmPath];
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}


- (void)actionSharePdf
{
    NSURL *url = [NSURL fileURLWithPath:self.pdfPath];
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}


- (void)actionUploadHtm
{
    AFHTTPSessionManager *manager = HTTPMANAGE;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    // 参数
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"token"] = @"param....";
    // 访问路径
    NSString *stringURL = [NSString stringWithFormat:@"%@/upload", self.WANServer];
    [manager POST:stringURL parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 上传文件
        [formData appendPartWithFileData:[NSData dataWithContentsOfFile:self.htmPath] name:@"uploadfile" fileName:self.htmName mimeType:@"text/html"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"---%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"---upload htm success.%@", responseObject);
        NSString * s = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@", s);
        self.uploadHtmStatus = 1;
        [self actionUpdateDisplayText];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"---upload htm failure.(%@)", error);
        self.uploadHtmStatus = -1;
        [self actionUpdateDisplayText];
    }];
}


- (void)actionUploadPdf
{
    AFHTTPSessionManager *manager = HTTPMANAGE;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    // 参数
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"token"] = @"param....";
    // 访问路径
    NSString *stringURL = [NSString stringWithFormat:@"%@/upload", self.WANServer];
    [manager POST:stringURL parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 上传文件
        [formData appendPartWithFileData:[NSData dataWithContentsOfFile:self.pdfPath] name:@"uploadfile" fileName:self.pdfName mimeType:@"application/pdf"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"---%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"---upload pdf success.");
        NSString * s = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@", s);
        self.uploadPdfStatus = 1;
        [self actionUpdateDisplayText];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"---upload pdf failure.(%@)", error);
        self.uploadPdfStatus = -1;
        [self actionUpdateDisplayText];
    }];
}


- (void)actionSelectFileType:(UISegmentedControl*)sender
{
    self.selectedIndex = sender.selectedSegmentIndex;
    [self actionUpdateDisplayText];
}


- (void)actionUpdateDisplayText
{
    NSLog(@"-=-=-=%zd | serverStatus:%zd, pdfGenerateStatus:%zd, uploadHtmStatus:%zd, uploadPdfStatus:%zd", self.selectedIndex, self.serverStatus, self.pdfGenerateStatus, self.uploadHtmStatus, self.uploadPdfStatus);
    
    if(self.selectedIndex == 0) {
        for(UIView *view in self.contentView.subviews) {
            view.hidden = NO;
        }
        self.labelLAN.text = @"局域网获取";
        if(self.serverStatus == 0) {
            self.labelLAN.text = @"局域网获取(创建服务中)";
            self.labelLANDetail.text = @"WIFI连接状态下,可通过局域网内电脑浏览器登入指定http地址,\n查看网页版本笔记内容,以及使用浏览器功能保存网页内容或导出pdf文件.\n(局域网访问地址可能因为局域网内具体环境出现访问出错情况,请联系本局域网网络管理员,或者使用互联网访问方式.)";
        }
        else if(self.serverStatus == 1) {
            self.labelLAN.text = @"局域网获取";
            self.labelLANDetail.text = [NSString stringWithFormat:@"%@%@\n\nWIFI连接状态下,可通过局域网内电脑浏览器登入上述http地址,\n查看网页版本笔记内容,以及使用浏览器功能保存网页内容或导出pdf文件.\n(局域网访问地址可能因为局域网内具体环境出现访问出错情况,请联系本局域网网络管理员,或者使用互联网访问方式.)", self.serverURL, self.htmName];
            self.buttonAirDropHtm.hidden = NO;
        }
        else {
            self.labelLAN.text = @"局域网获取(当前不可用)";
            self.labelLANDetail.text = @"WIFI连接状态下,可通过局域网内电脑浏览器登入指定http地址,\n查看网页版本笔记内容,以及使用浏览器功能保存网页内容或导出pdf文件.\n(局域网访问地址可能因为局域网内具体环境出现访问出错情况,请联系本局域网网络管理员,或者使用互联网访问方式.)";
        }
        
        if(self.uploadHtmStatus == 0) {
            self.labelWAN.text = @"互联网获取(等待上传中)";
            self.labelWANDetail.text = @"能正常连接互联网时,上传笔记信息到互联网服务器成功后.\n可通过电脑浏览器登入指定http地址,\n查看网页版本笔记内容,以及使用浏览器功能保存网页内容或导出pdf文件.";
        }
        else if(self.uploadHtmStatus == 1) {
            self.labelWAN.text = @"互联网获取";
            self.labelWANDetail.text = [NSString stringWithFormat:@"%@/%@\n\n能正常连接互联网时,上传笔记信息到互联网服务器成功后.\n可通过电脑浏览器登入上述http地址,\n查看网页版本笔记内容,以及使用浏览器功能保存网页内容或导出pdf文件.", self.WANServer, self.htmName];
        }
        else {
            self.labelWAN.text = @"互联网获取(连接失败)";
            self.labelWANDetail.text = @"能正常连接互联网时,上传笔记信息到互联网服务器成功后.\n可通过电脑浏览器登入指定http地址,\n查看网页版本笔记内容,以及使用浏览器功能保存网页内容或导出pdf文件.";
        }
    }
    else if(self.selectedIndex == 1) {
        if(self.pdfGenerateStatus == 0 || self.pdfGenerateStatus == -1) {
            for(UIView *view in self.contentView.subviews) {
                view.hidden = YES;
            }
            
            self.fileTypeSelect.hidden = NO;
            self.labelAirDrop.hidden = NO;
            self.labelAirDrop.text = self.pdfGenerateStatus==0?@"正渲染Pdf文件...":@"渲染Pdf文件出错";
            return ;
        }
        
        for(UIView *view in self.contentView.subviews) {
            view.hidden = NO;
        }
        
        self.labelAirDrop.text = @"AirDrop";
        
        self.labelLAN.text = @"局域网获取";
        if(self.serverStatus == 0) {
            self.labelLAN.text = @"局域网获取(创建服务中)";
            self.labelLANDetail.text = @"WIFI连接状态下,可通过局域网内电脑浏览器登入或下载软件下载指定http地址,\n查看/下载Pdf版本笔记内容.\n(局域网访问地址可能因为局域网内具体环境出现访问出错情况,请联系本局域网网络管理员,或者使用互联网访问方式.)";;
        }
        else if(self.serverStatus == 1) {
            self.labelLAN.text = @"局域网获取";
            self.labelLANDetail.text = [NSString stringWithFormat:@"%@%@\n\nWIFI连接状态下,可通过局域网内电脑浏览器登入或下载软件下载上述http地址,\n查看/下载Pdf版本笔记内容.\n(局域网访问地址可能因为局域网内具体环境出现访问出错情况,请联系本局域网网络管理员,或者使用互联网访问方式.)", self.serverURL, self.pdfName];
        }
        else {
            self.labelLAN.text = @"局域网获取(当前不可用)";
            self.labelLANDetail.text = @"WIFI连接状态下,可通过局域网内电脑浏览器登入或下载软件下载指定http地址,\n查看或者下载Pdf版本笔记内容.\n(局域网访问地址可能因为局域网内具体环境出现访问出错情况,请联系本局域网网络管理员,或者使用互联网访问方式.)";;
        }
        
        if(self.uploadPdfStatus == 0) {
            self.labelWAN.text = @"互联网获取(等待上传中)";
            self.labelWANDetail.text = @"能正常连接互联网时,上传笔记信息到互联网服务器成功后.\n可通过电脑浏览器登入指定http地址,查看或者下载Pdf版本笔记内容.";
        }
        else if(self.uploadPdfStatus == 1) {
            self.labelWAN.text = @"互联网获取";
            self.labelWANDetail.text = [NSString stringWithFormat:@"%@/%@\n\n能正常连接互联网时,上传笔记信息到互联网服务器成功后.\n可通过电脑浏览器登入上述http地址,查看或者下载Pdf版本笔记内容.", self.WANServer, self.htmName];
        }
        else {
            self.labelWAN.text = @"互联网获取(连接失败)";
            self.labelWANDetail.text = @"能正常连接互联网时,上传笔记信息到互联网服务器成功后.\n可通过电脑浏览器登入指定http地址,查看或者下载Pdf版本笔记内容.";
        }
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
