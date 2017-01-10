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
//@property (nonatomic, strong) NSData *pdfData;


@property (nonatomic, strong) NSMutableArray<NSData*> *pdfDatas;
@property (nonatomic, assign) NSInteger pdfDatasSections;
@property (nonatomic, assign) NSInteger pdfDatasSectionsUploaded;

@property (nonatomic, assign) uint64_t totalUnitCount;
@property (nonatomic, assign) uint64_t completedUnitCount;
@property (nonatomic, assign) uint64_t sectionUnitCount; //一次上传几M的文件,容易出错, 分片为100K一次.


@property (nonatomic, assign) NSInteger    selectedIndex;
@property (nonatomic, strong) UISegmentedControl    *fileTypeSelect;

@property (nonatomic, strong) UIView    *viewAirDropContainer;
@property (nonatomic, strong) UIImageView   *labelAirDropIcon;
@property (nonatomic, strong) UILabel   *labelAirDrop;
@property (nonatomic, strong) UILabel   *labelAirDropDetail;
@property (nonatomic, strong) UIButton  *buttonAirDrop;

@property (nonatomic, strong) UIView    *viewLANContainer;
@property (nonatomic, strong) UIImageView   *labelLANIcon;
@property (nonatomic, strong) UILabel   *labelLAN;
@property (nonatomic, strong) UILabel   *labelLANAddress;
@property (nonatomic, strong) UILabel   *labelLANDetail;
@property (nonatomic, strong) UIButton  *buttonLANAddressShare;


@property (nonatomic, strong) UIView    *viewWANContainer;
@property (nonatomic, strong) UIImageView   *labelWANIcon;
@property (nonatomic, strong) UILabel   *labelWAN;
@property (nonatomic, strong) UILabel   *labelWANAddress;
@property (nonatomic, strong) UILabel   *labelWANDetail;
@property (nonatomic, strong) UIButton  *buttonWANUpload;
@property (nonatomic, strong) UIButton  *buttonWANAddressShare;


@property (nonatomic, strong) GCDWebServer* webServer;
@property (nonatomic, strong) NSString *serverURL;
@property (nonatomic, assign) NSInteger serverStatus; //0.正启动.1.启动成功.2.启动失败.

@property (nonatomic, assign) NSInteger uploadHtmStatus; //0.正上传.1.上传成功.2.上传失败.
@property (nonatomic, assign) NSInteger uploadPdfStatus; //0.正上传.1.上传成功.2.上传失败.
@property (nonatomic, strong) NSString *WANServer;

@property (nonatomic, strong) NSArray<NoteParagraphModel *> *contentNoteParagraphs;
@property (nonatomic, strong) NSMutableArray *uploadTasks;
@end

@implementation NoteShareViewController

- (void)viewDidLoad {
    self.contentViewScrolled = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"共享";
    self.view.backgroundColor = [UIColor whiteColor];
    self.contentNoteParagraphs = [NoteParagraphModel noteParagraphsFromString:self.noteModel.content];
    self.uploadTasks = [[NSMutableArray alloc] init];
    
    self.WANServer = @"http://notetask.appben.com";
    
#define NEW_AND_ADD_SUBVIEW(view, class) [self addSubview:(view = [[class alloc] init])];
    
    
    NEW_AND_ADD_SUBVIEW(self.fileTypeSelect, UISegmentedControl);
    
    NEW_AND_ADD_SUBVIEW(self.viewAirDropContainer, UIView);
    NEW_AND_ADD_SUBVIEW(self.labelAirDropIcon, UIImageView);
    NEW_AND_ADD_SUBVIEW(self.labelAirDrop, UILabel);
    NEW_AND_ADD_SUBVIEW(self.labelAirDropDetail, UILabel);
    NEW_AND_ADD_SUBVIEW(self.buttonAirDrop, UIButton);
    
    NEW_AND_ADD_SUBVIEW(self.viewLANContainer, UIView);
    NEW_AND_ADD_SUBVIEW(self.labelLANIcon, UIImageView);
    NEW_AND_ADD_SUBVIEW(self.labelLAN, UILabel);
    NEW_AND_ADD_SUBVIEW(self.labelLANAddress, UILabel);
    NEW_AND_ADD_SUBVIEW(self.labelLANDetail, UILabel);
    NEW_AND_ADD_SUBVIEW(self.buttonLANAddressShare, UIButton);
    
    NEW_AND_ADD_SUBVIEW(self.viewWANContainer, UIView);
    NEW_AND_ADD_SUBVIEW(self.labelWANIcon, UIImageView);
    NEW_AND_ADD_SUBVIEW(self.labelWAN, UILabel);
    NEW_AND_ADD_SUBVIEW(self.labelWANAddress, UILabel);
    NEW_AND_ADD_SUBVIEW(self.labelWANDetail, UILabel);
    NEW_AND_ADD_SUBVIEW(self.buttonWANAddressShare, UIButton);
    //NEW_AND_ADD_SUBVIEW(self.buttonWANUpload, UIButton);
    
    [self.fileTypeSelect insertSegmentWithTitle:@"网页文件htm" atIndex:0 animated:YES];
    [self.fileTypeSelect insertSegmentWithTitle:@"Pdf文件" atIndex:1 animated:YES];
    [self.fileTypeSelect addTarget:self action:@selector(actionSelectFileType:) forControlEvents:UIControlEventValueChanged];
    self.fileTypeSelect.selectedSegmentIndex = (self.selectedIndex = 1);
    
    self.labelAirDropIcon.image = [UIImage imageNamed:@"ShareAirDrop"];
    self.labelAirDrop.text = @"AirDrop";
    self.labelAirDropDetail.text = @"使用共享方式,使用AirDrop或者其他应用将文件共享或者传输到其他设备.";
    self.labelAirDropDetail.numberOfLines = 0;
    self.labelAirDropDetail.font = FONT_SMALL;
    
    [self.buttonAirDrop setTitle:@"点击分享" forState:UIControlStateNormal];
    [self.buttonAirDrop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonAirDrop addTarget:self action:@selector(actionShareAirDrop) forControlEvents:UIControlEventTouchDown];
    self.buttonAirDrop.layer.borderColor = [UIColor blackColor].CGColor;
    self.buttonAirDrop.layer.borderWidth = 1.;
    self.buttonAirDrop.layer.cornerRadius = 2;
    self.buttonAirDrop.titleLabel.font = FONT_SMALL;
    self.buttonAirDrop.titleLabel.numberOfLines = 0;
    self.buttonAirDrop.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    
    self.labelLANIcon.image = [UIImage imageNamed:@"ShareLAN"];
    self.labelLANAddress.font = FONT_SMALL;
    self.labelLANDetail.numberOfLines = 0;
    self.labelLANDetail.font = FONT_SMALL;
    [self.buttonLANAddressShare setTitle:@"分享地址" forState:UIControlStateNormal];
    [self.buttonLANAddressShare setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonLANAddressShare addTarget:self action:@selector(actionShareLANAddress) forControlEvents:UIControlEventTouchDown];
    self.buttonLANAddressShare.layer.borderColor = [UIColor blackColor].CGColor;
    self.buttonLANAddressShare.layer.borderWidth = 1.;
    self.buttonLANAddressShare.layer.cornerRadius = 2;
    self.buttonLANAddressShare.titleLabel.font = FONT_SMALL;
    self.buttonLANAddressShare.titleLabel.numberOfLines = 0;
    self.buttonLANAddressShare.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    
    self.labelWANIcon.image = [UIImage imageNamed:@"ShareWAN"];
    self.labelWANAddress.font = FONT_SMALL;
    self.labelWANDetail.numberOfLines = 0;
    self.labelWANDetail.font = FONT_SMALL;
    
    [self.buttonWANUpload setTitle:@"上传" forState:UIControlStateNormal];
    [self.buttonWANUpload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.buttonWANUpload.layer.borderColor = [UIColor blackColor].CGColor;
    self.buttonWANUpload.layer.borderWidth = 1.;
    self.buttonWANUpload.layer.cornerRadius = 2;
    self.buttonWANUpload.hidden = YES;
    [self.buttonWANAddressShare setTitle:@"分享地址" forState:UIControlStateNormal];
    [self.buttonWANAddressShare setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonWANAddressShare addTarget:self action:@selector(actionShareWANAddress) forControlEvents:UIControlEventTouchDown];
    self.buttonWANAddressShare.layer.borderColor = [UIColor blackColor].CGColor;
    self.buttonWANAddressShare.layer.borderWidth = 1.;
    self.buttonWANAddressShare.layer.cornerRadius = 2;
    self.buttonWANAddressShare.titleLabel.font = FONT_SMALL;
    self.buttonWANAddressShare.titleLabel.numberOfLines = 0;
    self.buttonWANAddressShare.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createLocalServer];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self generateHtm];
        [self actionUploadHtm];
        
        self.webView = [[UIWebView alloc] init];
        [self addSubview:self.webView];
        NSString *s = [self.noteModel generateWWWPage];
        NSURL *url = _webServer.serverURL;
        url = [url URLByAppendingPathComponent:@"note" isDirectory:YES];
        [self.webView loadHTMLString:s baseURL:url];
        self.webView.delegate = self;
        self.webView.hidden = YES;
    });
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.webView.frame = VIEW_BOUNDS;
    
    UIScrollView *scrollView = (UIScrollView*)self.contentView;
    if([scrollView isKindOfClass:[UIScrollView class]]) {
        scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 1000);
    }
    
    FrameLayout *f = [[FrameLayout alloc] initWithRootView:self.contentView];
    [f frameLayoutHerizon:FRAMELAYOUT_NAME_MAIN
                  toViews:@[
                            [FrameLayoutView viewWithName:@"_fileTypeSelect" value:45 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            [FrameLayoutView viewWithName:@"AirDropLine" value:45 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            [FrameLayoutView viewWithName:@"_labelAirDropDetail" value:45 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            [FrameLayoutView viewWithName:@"PaddingLANLine" value:20 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            [FrameLayoutView viewWithName:@"LANLine" value:45 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            [FrameLayoutView viewWithName:@"_labelLANAddress" value:36 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            [FrameLayoutView viewWithName:@"_labelLANDetail" value:100 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            [FrameLayoutView viewWithName:@"PaddingWANLine" value:20 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            [FrameLayoutView viewWithName:@"WANLine" value:45 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            [FrameLayoutView viewWithName:@"_labelWANAddress" value:36 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            [FrameLayoutView viewWithName:@"_labelWANDetail" value:100 edge:UIEdgeInsetsMake(2, 10, 2, 10)],
                            ]
     ];
    
    [f frameLayoutVertical:@"AirDropLine"
                   toViews:@[
                             [FrameLayoutView viewWithName:@"_labelAirDropIcon" value:41 edge:UIEdgeInsetsZero],
                             [FrameLayoutView viewWithName:@"_labelAirDrop" percentage:1 edge:UIEdgeInsetsZero],
                             [FrameLayoutView viewWithName:@"_buttonAirDrop" value:41 edge:UIEdgeInsetsZero],
                             ]
     ];
    
    [f frameLayoutVertical:@"LANLine"
                   toViews:@[
                             [FrameLayoutView viewWithName:@"_labelLANIcon" value:41 edge:UIEdgeInsetsZero],
                             [FrameLayoutView viewWithName:@"_labelLAN" percentage:1 edge:UIEdgeInsetsZero],
                             [FrameLayoutView viewWithName:@"_buttonLANAddressShare" value:41 edge:UIEdgeInsetsZero],
                             ]
     ];
    
    [f frameLayoutVertical:@"WANLine"
                   toViews:@[
                             [FrameLayoutView viewWithName:@"_labelWANIcon" value:41 edge:UIEdgeInsetsZero],
                             [FrameLayoutView viewWithName:@"_labelWAN" percentage:1 edge:UIEdgeInsetsZero],
                             [FrameLayoutView viewWithName:@"_buttonWANAddressShare" value:41 edge:UIEdgeInsetsZero],
                             ]
     ];
    
    [self memberViewSetFrameWith:[f nameAndFrames]];
    NSLog(@"%@", [f nameAndFrames]);
    
    self.buttonAirDrop.layer.cornerRadius = self.buttonAirDrop.frame.size.width / 2;
    self.buttonLANAddressShare.layer.cornerRadius = self.buttonLANAddressShare.frame.size.width / 2;
    self.buttonWANAddressShare.layer.cornerRadius = self.buttonWANAddressShare.frame.size.width / 2;
    
    
    
    
    
    
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
                                  NSLog(@"------ request [%@]", request.path);
                                  NSArray<NSString*> *paths = [request.path componentsSeparatedByString:@"/"];
                                  NSString* filename = [paths lastObject];
                                  NSString *sNotFound = @"<html><body><p>未找到所需文件</p></body></html>";
                                  if([request.path hasPrefix:@"/note"]) {
                                      NSString *noteSn = [[filename componentsSeparatedByString:@"."] firstObject];
                                      NSLog(@"sn [%@]", noteSn);
                                      if([filename hasSuffix:@".htm"]) {
                                          NoteModel *note = [[AppConfig sharedAppConfig] configNoteGetBySn:noteSn];
                                          if(note) {
                                              return [GCDWebServerDataResponse responseWithHTML:[note generateWWWPage]];
                                          }
                                          else {
                                              NSLog(@"#error - note sn %@ not found.", noteSn);
                                              return [GCDWebServerDataResponse responseWithHTML:sNotFound];
                                          }
                                      }
                                      else if([filename hasSuffix:@".pdf"]) {
                                          NSString *pdfPath = [NSString stringWithFormat:@"%@/%@", _self.noteFolder, filename];
                                          NSData *pdfData = [NSData dataWithContentsOfFile:pdfPath];
                                          if(pdfData.length > 0) {
                                              return [GCDWebServerDataResponse responseWithData:pdfData contentType:@"application/pdf"];
                                          }
                                          else {
                                              NSLog(@"#error - note sn %@ pdf note found [%@].", noteSn, pdfPath);
                                              return [GCDWebServerDataResponse responseWithHTML:sNotFound];
                                          }
                                      }
                                      else if([filename hasSuffix:@".jpg"] || [filename hasSuffix:@".png"]) {
                                          NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
                                          NSString *imageLocalFolder = [NSString stringWithFormat:@"%@/NoteImageLocal", cachePath];
                                          NSString *imageFileName = [NSString stringWithFormat:@"%@/%@", imageLocalFolder, filename];
                                          NSLog(@"imageFileName : %@", imageFileName);
                                          if([[NSFileManager defaultManager] fileExistsAtPath:imageFileName isDirectory:nil]) {
                                              LOG_POSTION
                                              NSData *data = [NSData dataWithContentsOfFile:imageFileName];
                                              if(data.length > 0) {
                                                  LOG_POSTION
                                                  return [GCDWebServerDataResponse responseWithData:data contentType:@"application/image"];
                                              }
                                              else {
                                                  LOG_POSTION
                                                  return [GCDWebServerDataResponse responseWithHTML:sNotFound];
                                              }
                                          }
                                          else {
                                              LOG_POSTION
                                              return [GCDWebServerDataResponse responseWithHTML:sNotFound];
                                          }
                                      }
                                      else {
                                          NSLog(@"#error - request [%@] not treated.", request.path);
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
        NSString *htmURLString = [NSString stringWithFormat:@"%@note/%@.htm", self.serverURL, self.noteModel.sn];
        self.labelLANDetail.text = [self.labelLANDetail.text stringByReplacingOccurrencesOfString:@"htm地址获取中..." withString:htmURLString];
        NSString *pdfURLString = [NSString stringWithFormat:@"%@note/%@.pdf", self.serverURL, self.noteModel.sn];
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
    for(NSURLSessionDataTask *task in self.uploadTasks) {
        if(task.state == NSURLSessionTaskStateRunning) {
            [task cancel];
        }
    }
}


- (void)generateHtm
{
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [docPath objectAtIndex:0];
    self.noteFolder = [NSString stringWithFormat:@"%@/Note", documentsPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.noteFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    self.htmName = [NSString stringWithFormat:@"%@.htm", self.noteModel.sn];
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
    
    self.pdfName = [NSString stringWithFormat:@"%@.pdf", self.noteModel.sn];
    self.pdfPath = [NSString stringWithFormat:@"%@/%@", self.noteFolder, self.pdfName];
    NSLog(@"%@", self.pdfPath);
    
    if(pdfData.length > 0) {
        [self showIndicationText:@"已生成网页文件和PDF文件." inTime:1.];
        [pdfData writeToFile:self.pdfPath atomically:YES];
        self.pdfGenerateStatus = 1;
        //一次上传文件太大可能容易导致程序出错. 分割成1M的组.
        
        NSLog(@"pdfData length : %zd", pdfData.length);
        self.totalUnitCount = pdfData.length;
        self.sectionUnitCount = 100 * 1024;
        
        self.pdfDatas = [[NSMutableArray alloc] init];
        self.pdfDatasSections = (pdfData.length + (NSInteger)(self.sectionUnitCount - 1)) / (NSInteger)self.sectionUnitCount;
        self.pdfDatasSectionsUploaded = 0;
        const void *bytes = pdfData.bytes;
        NSInteger offset = 0;
        for(NSInteger idx = 0; idx < self.pdfDatasSections; idx ++) {
            NSInteger length = idx < self.pdfDatasSections - 1 ? (NSInteger)self.sectionUnitCount : pdfData.length % self.sectionUnitCount;
            [self.pdfDatas addObject:[NSData dataWithBytes:bytes+offset length:length]];
            offset += length;
        }
        
        [self actionUploadPdf];
    }
    else {
        [self showIndicationText:@"生成PDF文件出错" inTime:1.];
        self.pdfGenerateStatus = -1;
    }
    
    [self.webView removeFromSuperview];
    self.webView = nil;
    
    [self actionUpdateDisplayText];
}


- (void)actionShareAirDrop
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


- (void)actionShareLANAddress
{
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.labelLANAddress.text] applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}


- (void)actionShareWANAddress
{
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.labelWANAddress.text] applicationActivities:nil];
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
        for(NoteParagraphModel *paragraph in self.contentNoteParagraphs) {
            if(paragraph.image.length > 0 && ![paragraph.image hasPrefix:@"http://"] && ![paragraph.image hasPrefix:@"https://"]) {
                NSString *imageFileName = [NoteModel imageLocalFileNameOfImageName:paragraph.image];
                NSData *data = [NSData dataWithContentsOfFile:imageFileName];
                if(data.length > 0) {
                    [formData appendPartWithFileData:data name:@"uploadfile" fileName:paragraph.image mimeType:@"image/jpeg"];
                }
                else {
                    NSLog(@"#error - image name file not found (%@).", paragraph.image);
                }
            }
        }
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
    __weak typeof(self) _self = self;
    AFHTTPSessionManager *manager = HTTPMANAGE;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    // 参数
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"token"] = @"param....";
    // 访问路径
    NSString *stringURL = [NSString stringWithFormat:@"%@/upload", self.WANServer];
    NSURLSessionDataTask *task = [manager POST:stringURL parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 上传文件
        NSData *data = _self.pdfDatas[_self.pdfDatasSectionsUploaded];
        NSString *fileName = [NSString stringWithFormat:@"%@_%03zd_%03zd", _self.pdfName, _self.pdfDatasSectionsUploaded+1, _self.pdfDatasSections];
        NSLog(@"---[%zd:%zd] length : %zd", _self.pdfDatasSectionsUploaded, _self.pdfDatasSections, data.length);
        [formData appendPartWithFileData:data
                                    name:@"uploadfile"
                                fileName:fileName
                                mimeType:@"application/pdf"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"---[%zd:%zd]%@", _self.pdfDatasSectionsUploaded, _self.pdfDatasSections, uploadProgress);
        
        NSLog(@"%lld", uploadProgress.totalUnitCount);
        NSLog(@"%lld", uploadProgress.completedUnitCount);
        
        _self.completedUnitCount = uploadProgress.completedUnitCount + _self.pdfDatasSectionsUploaded * _self.sectionUnitCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self actionUpdateDisplayText];
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"---[%zd:%zd]upload pdf success.", _self.pdfDatasSectionsUploaded, _self.pdfDatasSections);
//        NSString * s = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", s);
        _self.pdfDatasSectionsUploaded ++;
        if(_self.pdfDatasSectionsUploaded < _self.pdfDatasSections) {
            NSLog(@"---[%zd:%zd]continue to", _self.pdfDatasSectionsUploaded, _self.pdfDatasSections);
            _self.completedUnitCount = _self.pdfDatasSectionsUploaded * _self.sectionUnitCount;
            [_self actionUpdateDisplayText];
            
            //继续下一片的上传.
            [_self actionUploadPdf];
        }
        else {
            NSLog(@"---[%zd:%zd]finish", _self.pdfDatasSectionsUploaded, _self.pdfDatasSections);
            _self.uploadPdfStatus = 1;
            [_self actionUpdateDisplayText];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"---[%zd:%zd]upload pdf failure.(%@)", _self.pdfDatasSectionsUploaded, _self.pdfDatasSections, error);
        _self.uploadPdfStatus = -1;
        [_self actionUpdateDisplayText];
    }];

    [self.uploadTasks addObject:task];
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
        self.labelLANDetail.text = @"WIFI连接状态下,可通过局域网内电脑浏览器登入指定http地址,\n查看网页版本笔记内容,以及使用浏览器功能保存网页内容或导出pdf文件.\n(局域网访问地址可能因为局域网内具体环境出现访问出错情况,请联系本局域网网络管理员,或者使用互联网访问方式.)";
        self.labelWANDetail.text = @"能正常连接互联网时,上传笔记信息到互联网服务器成功后.\n可通过电脑浏览器登入指定http地址,\n查看网页版本笔记内容,以及使用浏览器功能保存网页内容或导出pdf文件.";
        
        for(UIView *view in self.contentView.subviews) {
            view.hidden = NO;
        }
        
        self.labelLAN.text = @"局域网获取";
        self.buttonLANAddressShare.hidden = YES;
        if(self.serverStatus == 0) {
            self.labelLAN.text = @"局域网获取(创建服务中)";
            self.labelLANAddress.text = @"1";
        }
        else if(self.serverStatus == 1) {
            self.labelLAN.text = @"局域网获取";
            NSString *urlString = [NSString stringWithFormat:@"%@/note/%@", self.serverURL, self.htmName];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"://" withString:@"###"];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"###" withString:@"://"];
            self.labelLANAddress.text = urlString;
            self.buttonLANAddressShare.hidden = NO;
        }
        else {
            self.labelLAN.text = @"局域网获取(当前不可用)";
        }
        
        self.buttonWANAddressShare.hidden = YES;
        if(self.uploadHtmStatus == 0) {
            self.labelWAN.text = @"互联网获取(等待上传中)";
        }
        else if(self.uploadHtmStatus == 1) {
            self.labelWAN.text = @"互联网获取";
            NSString *urlString = [NSString stringWithFormat:@"%@/note/%@", self.WANServer, self.htmName];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"://" withString:@"###"];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"###" withString:@"://"];
            self.labelWANAddress.text = urlString;
            self.buttonWANAddressShare.hidden = NO;
        }
        else {
            self.labelWAN.text = @"互联网获取(连接失败)";
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
        
        self.labelLANDetail.text = @"WIFI连接状态下, 可通过局域网内电脑浏览器登入或下载软件下载指定http地址, 查看或者下载Pdf版本笔记内容. \n(局域网访问地址可能因为局域网内具体环境出现访问出错情况, 请联系本局域网网络管理员, 或者使用互联网访问方式. )";
        self.labelWANDetail.text = @"能正常连接互联网时, 上传笔记信息到互联网服务器成功后. \n可通过电脑浏览器登入指定http地址, 查看或者下载Pdf版本笔记内容. ";
        
        for(UIView *view in self.contentView.subviews) {
            view.hidden = NO;
        }
        
        self.labelAirDrop.text = @"AirDrop";
        self.buttonLANAddressShare.hidden = YES;
        
        self.labelLAN.text = @"局域网获取";
        if(self.serverStatus == 0) {
            self.labelLAN.text = @"局域网获取(创建服务中)";
            self.labelLANAddress.text = @"0";
        }
        else if(self.serverStatus == 1) {
            self.labelLAN.text = @"局域网获取";
            NSString *urlString = [NSString stringWithFormat:@"%@/note/%@", self.serverURL, self.pdfName];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"://" withString:@"###"];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"###" withString:@"://"];
            self.labelLANAddress.text = urlString;
            self.buttonLANAddressShare.hidden = NO;
        }
        else {
            self.labelLAN.text = @"局域网获取(当前不可用)";
        }
        
        self.buttonWANAddressShare.hidden = YES;
        if(self.uploadPdfStatus == 0) {
            self.labelWAN.text = @"互联网获取(等待上传中)";
            LOG_POSTION
            if(self.pdfDatasSections > 0) {
                double percentage = (double)(self.completedUnitCount * 100) / (double)self.totalUnitCount ;
                self.labelWANAddress.text = [NSString stringWithFormat:@"等待获取地址(上传进度%.1f%%)", percentage];
                NSLog(@"percentage : %lf, [%lld/%lld]", percentage, self.completedUnitCount, self.totalUnitCount);
            }
        }
        else if(self.uploadPdfStatus == 1) {
            self.labelWAN.text = @"互联网获取";
            NSString *urlString = [NSString stringWithFormat:@"%@/note/%@", self.WANServer, self.pdfName];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"://" withString:@"###"];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"###" withString:@"://"];
            self.labelWANAddress.text = urlString;
            self.buttonWANAddressShare.hidden = NO;
        }
        else {
            self.labelWAN.text = @"互联网获取(连接失败)";
            self.labelWANAddress.text = @"-1";
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
