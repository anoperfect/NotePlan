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
    [[AppConfig sharedAppConfig] configNoteUpdate:self];
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


+ (void)imageDataLocalRemoveWithName:(NSString *)imageName
{
    NSString *fileName = [self imageLocalFileNameOfImageName:imageName];
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    }
    else {
        NSLog(@"#error - remove failed at [%@]", fileName);
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

















@interface NoteClassification ()

@end


@implementation NoteClassification



@end