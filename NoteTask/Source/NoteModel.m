//
//  NoteModel.m
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteModel.h"








@implementation NoteModel

- (NSString*)description
{
    NSMutableString *strm = [[NSMutableString alloc] init];
    [strm appendFormat:@"======NoteModel description : %p, [%@],  title:%@, content:%@", self, self.sn, self.title, self.content];
    
    return strm;
}


- (BOOL)isEqualToNoteModel:(NoteModel*)note
{
    return YES
            && [self.title      isEqualToString:note.title]
            && [self.content    isEqualToString:note.content]
            && [self.summary    isEqualToString:note.summary]
            && [self.source     isEqualToString:note.source]
            && [self.createdAt  isEqualToString:note.createdAt]
            && [self.modifiedAt isEqualToString:note.modifiedAt]
    ;
}


+ (NSArray<NSString*>*)classificationPreset
{
    return @[@"个人笔记", @"使用简介"];
}


+ (NSArray<NSString*> *)colorFilterDisplayStrings
{
    return @[@"所有", @"◉红色", @"未标记", @"◉黄色", @"已标记", @"◉蓝色"];
}


+ (NSArray<NSString*> *)colorAssignDisplayStrings
{
    return @[@"未标记", @"◉红色", @"◉黄色", @"◉蓝色"];
}


+ (NSArray<NSString *> *)colorStrings
{
    return @[@"red", @"yellow", @"blue"];
}




/*
 colorString             -           colorDisplayString
 red
 yellow
 blue
 -          -------------------------   已标记
 *          -------------------------   所有
 ""         -------------------------   未标记
 */


+ (NSDictionary*)colorDisplayDictionary
{
    return @{
             @"red"     : @"◉红色",
             @"yellow"  : @"◉黄色",
             @"blue"    : @"◉蓝色",
             @"-"       : @"已标记",
             @"*"       : @"所有",
             @""        : @"未标记"
             };
}


+ (NSString*)colorStringToColorDisplayString:(NSString*)colorString
{
    NSDictionary *dict = [self colorDisplayDictionary];
    NSString * colorDisplayString = dict[colorString];
    if(!colorDisplayString) {
        NSLog(@"#error - colorString (%@) invalid.", colorString);
        colorDisplayString = @"未标记";
    }
    
    return colorDisplayString;
}

+ (NSString*)colorDisplayStringToColorString:(NSString*)colorDisplayString
{
    NSString *colorString = nil;
    
    NSDictionary *dict = [self colorDisplayDictionary];
    for(NSString *colorStringKey in dict.allKeys) {
        if([colorDisplayString isEqualToString:dict[colorStringKey]]) {
            colorString = colorStringKey;
        }
    }
    
    if(!colorString) {
        NSLog(@"#error - colorDisplayString (%@) invalid.", colorDisplayString);
        colorString = @"";
    }
    
    return colorString;
}


//<h1 style="color:blue; text-align:center">This is a header</h1>
//<p style="FONT-SIZE: 15pt; COLOR: #ffffff; FONT-FAMILY: 黑体">
//font-family: Verdana, sans-serif;


+ (NoteModel*)noteFromDictionary:(NSDictionary*)dict
{
    NS0Log(@"noteFromDictionary : %@", dict);
    NoteModel *note = [[NoteModel alloc] init];
    note = [NoteModel mj_objectWithKeyValues:dict];

    return note;
}


- (NSString*)stringMemberCheck:(id)member
{
    if([member isKindOfClass:[NSString class]]) {
        return member;
    }
    
    if([member isKindOfClass:[NSNumber class]]) {
        NSLog(@"#error - member should be NSString.");
        return [NSString stringWithFormat:@"%@", member];
    }
    
    NSLog(@"#error - member should be NSString.");
    return @"";
}


- (NSDictionary*)toDictionary
{
    NSMutableDictionary *noteDict = [[NSMutableDictionary alloc] init];
    
    noteDict[@"sn"]               = [self stringMemberCheck:self.sn];
    noteDict[@"title"]            = [self stringMemberCheck:self.title];
    noteDict[@"content"]          = [self stringMemberCheck:self.content];
    noteDict[@"summary"]          = [self stringMemberCheck:self.summary];
    noteDict[@"summaryGenerated"] = [self stringMemberCheck:self.summaryGenerated];
    noteDict[@"classification"]   = [self stringMemberCheck:self.classification];
    noteDict[@"color"]            = [self stringMemberCheck:self.color];
    noteDict[@"thumb"]            = [self stringMemberCheck:self.thumb];
    noteDict[@"audio"]            = [self stringMemberCheck:self.audio];
    noteDict[@"location"]         = [self stringMemberCheck:self.location];
    noteDict[@"createdAt"]        = [self stringMemberCheck:self.createdAt];
    noteDict[@"modifiedAt"]       = [self stringMemberCheck:self.modifiedAt];
    noteDict[@"browseredAt"]      = [self stringMemberCheck:self.browseredAt];
    noteDict[@"deletedAt"]        = [self stringMemberCheck:self.deletedAt];
    noteDict[@"source"]           = [self stringMemberCheck:self.source];
    noteDict[@"synchronize"]      = self.synchronize;
    noteDict[@"countCollect"]     = @(self.countCollect);
    noteDict[@"countLike"]        = @(self.countLike);
    noteDict[@"countDislike"]     = @(self.countDislike);
    noteDict[@"countBrowser"]     = @(self.countBrowser);
    noteDict[@"countEdit"]        = @(self.countEdit);
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:noteDict];
    
    dict = [NSDictionary dictionaryWithDictionary:[self mj_keyValues]];
    return dict;
}


- (NSString*)previewTitle
{
    NSString *title = @"";
    NoteParagraphModel *titleNoteParagraph = [NoteParagraphModel noteParagraphFromString:self.title];
    title = titleNoteParagraph.content;
    if(title.length == 0) {
        title = @"无标题";
    }
    else {
        title = [NSString stringWithFormat:@"%@", titleNoteParagraph.content];
    }

    return title;
}


- (NSString*)previewSummary
{
    if(self.summary.length > 0) {
        return self.summary;
    }
    
    if(self.summaryGenerated.length > 0) {
        return self.summaryGenerated;
    }
    
    NSArray<NoteParagraphModel *> *contentNoteParagraphs = [NoteParagraphModel noteParagraphsFromString:self.content];
    
    self.summaryGenerated = [self summaryGenerateFromNoteParagraphs:contentNoteParagraphs];
    return self.summaryGenerated;
}


- (NSString*)summaryGenerateFromNoteParagraphs:(NSArray<NoteParagraphModel *> *)contentNoteParagraphs
{
    NSMutableString *summary = [[NSMutableString alloc] init];
    for(NoteParagraphModel *noteParagraph in contentNoteParagraphs) {
        [summary appendFormat:@"%@ ", [noteParagraph.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
    summary = [NSMutableString stringWithString:[summary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if(summary.length == 0) {
        summary = [NSMutableString stringWithString:@"无内容"];
    }
    
    return [NSString stringWithString:summary];
}


- (NSString*)generateWWWPage
{
    NSString *resPath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"NoteTemplate.htm"];
    NSData *data = [NSData dataWithContentsOfFile:resPath];
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    s = [s stringByReplacingOccurrencesOfString:@"@@note.sn" withString:self.sn?self.sn:@""];
    s = [s stringByReplacingOccurrencesOfString:@"@@note.title" withString:self.title?self.title:@""];
    s = [s stringByReplacingOccurrencesOfString:@"@@note.content" withString:self.content?self.content:@""];
    s = [s stringByReplacingOccurrencesOfString:@"@@note.classification" withString:self.classification?self.classification:@""];
    s = [s stringByReplacingOccurrencesOfString:@"@@note.createdAt" withString:self.createdAt?self.createdAt:@""];
    
    //NSLog(@"-=-=-=\n\n\n%@\n\n\n", s);
    return s;
}


+ (NSString*)randomSnsStringWithLength:(NSInteger)length
{
    char s[100];
    
    NSInteger idx;
    for(idx = 0; idx < length && idx < 100 - 1; idx ++) {
        NSInteger snNum = arc4random() % 36;
        s[idx] = snNum <= 9 ? '0' + snNum : 'a' + snNum - 10;
    }
    s[idx] = '\0';
    
    return [NSString stringWithUTF8String:s];
}


+ (void)sortNotes:(NSMutableArray<NoteModel*>*)notes By:(NSString*)by ascend:(BOOL)ascend
{
    if([by isEqualToString:@"createdAt"]) {
        [notes sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NoteModel *note1 = obj1;
            NoteModel *note2 = obj2;
            return ascend?[note1.createdAt compare:note2.createdAt]:[note2.createdAt compare:note1.createdAt];
        }];
    }
    
    if([by isEqualToString:@"modifiedAt"]) {
        [notes sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NoteModel *note1 = obj1;
            NoteModel *note2 = obj2;
            return ascend?[note1.modifiedAt compare:note2.modifiedAt]:[note2.modifiedAt compare:note1.modifiedAt];
        }];
    }
    
    if([by isEqualToString:@"browseredAt"]) {
        [notes sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NoteModel *note1 = obj1;
            NoteModel *note2 = obj2;
            return ascend?[note1.browseredAt compare:note2.browseredAt]:[note2.browseredAt compare:note1.browseredAt];
        }];
    }
}


+ (NSString*)imageCacheFileNameOfHttpAddrString:(NSString*)httpAddrString
{
//    NSRange range;
//    NSInteger location = 0;
//    
//    NSLog(@"%@", httpAddrString);
//    NSLog(@"%@", [NSCharacterSet symbolCharacterSet]);
//    
//    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
//    
//    while(1) {
//        range = [httpAddrString rangeOfCharacterFromSet:characterSet options:0 range:NSMakeRange(location, httpAddrString.length - location)];
//        
//        if(range.length > 0) {
//            location = range.location + range.length;
//            NSLog(@"%@", [httpAddrString substringWithRange:range]);
//            httpAddrString = [httpAddrString stringbyre]
//        }
//        else {
//            break;
//        }
//    }
    
    httpAddrString = [httpAddrString stringByReplacingOccurrencesOfString:@"/" withString:@"#"];
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *imageCacheFolder = [NSString stringWithFormat:@"%@/NoteImageCache", cachePath];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:imageCacheFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageCacheFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", imageCacheFolder, httpAddrString];
    return fileName;
}


+ (NSData*)imageDataCacheGetWithName:(NSString*)httpAddrString
{
    NSData *data = nil;
    
    NSString *fileName = [self imageCacheFileNameOfHttpAddrString:httpAddrString];
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        data = [NSData dataWithContentsOfFile:fileName];
    }
    
    return data;
}


+ (void)imageDataCacheSet:(NSData*)data withName:(NSString*)httpAddrString
{
    NSString *fileName = [self imageCacheFileNameOfHttpAddrString:httpAddrString];
    BOOL result = [data writeToFile:fileName atomically:YES];
    if(!result) {
        NSLog(@"#error - data write error.");
    }
}


+ (NSString*)imageLocalFileNameOfImageName:(NSString*)imageName
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *imageLocalFolder = [NSString stringWithFormat:@"%@/NoteImageLocal", cachePath];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:imageLocalFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageLocalFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", imageLocalFolder, imageName];
//    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
//    fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@""];
//    fileName = [fileName stringByReplacingOccurrencesOfString:@"0." withString:@"_"];
    return fileName;
}


+ (NSData*)imageDataLocalWithName:(NSString*)imageName
{
    NSData *data = nil;
    
    NSString *fileName = [self imageLocalFileNameOfImageName:imageName];
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        data = [NSData dataWithContentsOfFile:fileName];
    }
    
    return data;
}



+ (void)imageDataLocalSet:(NSData*)data withName:(NSString*)imageName
{
    NSString *fileName = [self imageLocalFileNameOfImageName:imageName];
    NSLog(@"fileName : %@", fileName);
    BOOL result = [data writeToFile:fileName atomically:YES];
    if(!result) {
        NSLog(@"#error - data write error.");
    }
}


+ (NSString*)imageNameNewOnSn:(NSString*)sn format:(NSString*)format
{
    NSString *imageName = [NSString stringWithFormat:@"NoteImage%@_%@", [NSString dateTimeStringNow], sn];
    
    imageName = [imageName stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    imageName = [imageName stringByReplacingOccurrencesOfString:@"-" withString:@""];
    imageName = [imageName stringByReplacingOccurrencesOfString:@":" withString:@""];
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    imageName = [imageName stringByAppendingFormat:@".%@", format];
    
    return imageName;
}


@end

#if 0
NoteParagraphModel *noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"设计师心情最平静的时候是熬夜做完案子准备睡觉时，看见天色有些发白，听见一两声鸟。为了更加形象地描述（嘲讽）这个脑细胞平均每天死一万次的职业，《Lean Branding》的作者Laura Busche画了10张图，长这样：";

[self.contentParagraphs addObject:noteParagraph];

noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"1、设计师听到最幸福的情话就是：挺好的，用这稿！如果改到山穷水尽疑无路，设计师真的会想说“kill me，kill me now”。fs fsdfsdkfjs dfsdklfdskjf sdkfjds fsldkflsdfk sdfk sd;lkf s;ldfkdslkfsdl";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"2.直播优化层面";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"其实最难的难点是提高首播时间、服务质量即Qos（Quality of Service，服务质量），如何在丢包率20%的情况下还能保障稳定、流畅的直播体验，需要考虑以下方案：";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"1）为加快首播时间，收流服务器主动推送 GOP :（Group of Pictures:策略影响编码质量)所谓GOP，意思是画面组，一个GOP就是一组连续的画面至边缘节点，边缘节点缓存 GOP，播放端则可以快速加载，减少回源延迟";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"2）GOP丢帧，为解决延时，为什么会有延时，网络抖动、网络拥塞导致的数据发送不出去，丢完之后所有的时间戳都要修改，切记，要不客户端就会卡一个 GOP的时间，是由于 PTS（Presentation Time Stamp，PTS主要用于度量解码后的视频帧什么时候被显示出来） 和 DTS 的原因，或者播放器修正 DTS 和 PTS 也行（推流端丢GOD更复杂，丢 p 帧之前的 i 帧会花屏）";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"3）纯音频丢帧，要解决音视频不同步的问题，要让视频的 delta增量到你丢掉音频的delta之后，再发音频，要不就会音视频不同步";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"4）源站主备切换和断线重连";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"5）根据TCP拥塞窗口做智能调度，当拥塞窗口过大说明节点服务质量不佳，需要切换节点和故障排查";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"6）增加上行、下行带宽探测接口，当带宽不满足时降低视频质量，即降低码率";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"7）定时获取最优的推流、拉流链路IP，尽可能保证提供最好的服务";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"8)监控必须要，监控各个节点的Qos状态，来做整个平台的资源配置优化和调度";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"9）如果产品从推流端、CDN、播放器都是自家的，保障 Qos 优势非常大";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"10）当直播量非常大时，要加入集群管理和调度，保障 Qos";
[self.contentParagraphs addObject:noteParagraph];


noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"11）播放端通过增加延时来减少网络抖动，通过快播来减少延时。（出自知乎宋少东）。";
[self.contentParagraphs addObject:noteParagraph];




noteParagraph = [[NoteParagraphModel alloc] init];
noteParagraph.content = @"7、你不知道排版最难的地方就是一点一点的间距和文字，真的会瞎掉我的狗眼，别说5分钟给我排个版，你以为是ppt？";
[self.contentParagraphs addObject:noteParagraph];

[self.contentParagraphs addObjectsFromArray:self.contentParagraphs];
#endif















@interface NoteClassification ()

@end


@implementation NoteClassification



@end