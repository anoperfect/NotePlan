//
//  NoteModel.m
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteModel.h"






@implementation NoteParagraphModel






+ (NoteParagraphModel*)noteParagraphFromString:(NSString*)string
{
    NoteParagraphModel *noteParagraph = [[NoteParagraphModel alloc] init];
    
    //没有css标记的时候必须填style="".
    NSRange range0 = [string rangeOfString:@"<p style=\""];
    NSRange range1 = [string rangeOfString:@"\">"];
    NSRange range2 = [string rangeOfString:@"</p>"];
    if(range0.length > 0 && range1.length > 0 && range2.length > 0
       && range0.location == 0 && range2.location == string.length - @"</p>".length
       && range1.location > range0.location && range2.location > range1.location) {
        NS0Log(@"ParagraphString format checked.");
        
        NSString *styleString = [string substringWithRange:NSMakeRange(range0.location + range0.length, range1.location - (range0.location + range0.length))];
        NS0Log(@"ParagraphString style : %@", styleString);
        
        noteParagraph.content = [string substringWithRange:NSMakeRange(range1.location + range1.length, range2.location - (range1.location + range1.length))];
        noteParagraph.content = [NSString htmDecode:noteParagraph.content];
        NS0Log(@"ParagraphString content : %@", noteParagraph.content);
        
        noteParagraph.styleDictionay = [self styleParseFromString:styleString];
        NS0Log(@"ParagraphString style : %@", noteParagraph.styleDictionay);
    }
    else {
        NSLog(@"#error - ParagraphString format checked failed. [%@]", string);
        noteParagraph.content = @"";
    }
    
    return noteParagraph;
}


+ (NSString*)noteParagraphToString:(NoteParagraphModel*)noteParagraph
{
    return [NSString stringWithFormat:
            @"<p style=\"%@\">%@</p>"
            , [NoteParagraphModel styleDictionaryToString:noteParagraph.styleDictionay]
            , [NSString htmEncode:noteParagraph.content]];
}


+ (NSMutableDictionary*)styleParseFromString:(NSString*)styleString
{
    NSMutableDictionary *styleDictionary = [[NSMutableDictionary alloc] init];
    NSArray<NSString*> *styles = [styleString componentsSeparatedByString:@";"];
    for(NSString *style1String in styles) {
        NSArray<NSString*> *style1pv = [style1String componentsSeparatedByString:@":"];
        if(style1pv.count == 2) {
            NSString *styleProperty = [style1pv[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            styleProperty = [styleProperty lowercaseString];
            NSString *styleValue = [style1pv[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            styleValue = [styleValue lowercaseString];
            styleDictionary[styleProperty] = styleValue;
        }
    }
    
    return styleDictionary;
}


+ (NSString*)styleDictionaryToString:(NSDictionary*)styleDictionary
{
    if(styleDictionary.count == 0) {
        return @"";
    }
    
    NSMutableString *styleString = [[NSMutableString alloc] init];
    for(NSInteger idx = 0; idx < styleDictionary.count ; idx ++) {
        [styleString appendFormat:@"%@: %@", styleDictionary.allKeys[idx], styleDictionary.allValues[idx]];
        if(idx != styleDictionary.count - 1) {
            [styleString appendString:@";"];
        }
    }
    
    return [NSString stringWithString:styleString];
}


//暂时style的value都用字符串表示. 不转换为具体的颜色, 大小值.
+ (NSString*)styleGenerateToString:(NSDictionary*)style
{
    NSMutableString *styleString = [[NSMutableString alloc] init];
    
    NSString *property;
    NSString *value;
    
    property = @"color";
    value = style[property];
    if(!value) {
        value = style[[property uppercaseString]];
    }
    if(value) {
        [styleString appendFormat:@"%@: %@;", property, value];
    }
    
    property = @"font-size";
    value = style[property];
    if(!value) {
        value = style[[property uppercaseString]];
    }
    if(value) {
        [styleString appendFormat:@"%@: %@;", property, value];
    }
    
    property = @"font-style";
    value = style[property];
    if([value isEqualToString:@"italic"]) {
        [styleString appendFormat:@"%@: %@;", property, value];
    }
    
    property = @"text-decoration";
    value = style[property];
    if([value isEqualToString:@"underline"]) {
        [styleString appendFormat:@"%@: %@;", property, value];
    }
    
    property = @"border";
    value = style[property];
    if([value isEqualToString:@"underline"]) {
        [styleString appendFormat:@"%@: %@ %@;", property, value, @"solid"];
    }
    
    return [NSString stringWithString:styleString];
}


+ (NSArray<NoteParagraphModel*> *)noteParagraphsFromString:(NSString*)string
{
    NSMutableArray *noteParagraphs = [[NSMutableArray alloc] init];
    
    NSArray<NSString *> *paragraphStrings = [string componentsSeparatedByString:@"</p>"];
    for(NSString *paragraphString0 in paragraphStrings) {
        if(paragraphString0.length < 3) {
            continue;
        }
        
        NSString *paragraphString = [paragraphString0 stringByAppendingString:@"</p>"];
        paragraphString = [paragraphString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NoteParagraphModel *noteParagraph = [NoteParagraphModel noteParagraphFromString:paragraphString];
        
        [noteParagraphs addObject:noteParagraph];
    }
    
    return [NSArray arrayWithArray:noteParagraphs];
}


+ (NSString*)noteParagraphsToString:(NSArray<NoteParagraphModel*> *)noteParagraphs
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    for(NoteParagraphModel *noteParagraph in noteParagraphs) {
        [string appendString:[NoteParagraphModel noteParagraphToString:noteParagraph]];
    }
    
    return [NSString stringWithString:string];
}


- (UIFont*)textFont
{
    NS0Log(@"xxx : %@", self.styleDictionay);
    CGFloat fontSize = self.isTitle?18:16;
    NSString *fontString = self.styleDictionay[@"font-size"];
    CGFloat ptSize;
    if([fontString hasSuffix:@"pt"] && (ptSize = [fontString floatValue]) >= 1.0 && ptSize < 100.0) {
        fontSize = ptSize;
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    if([self.styleDictionay[@"font-weight"] isEqualToString:@"bold"]) {
        NSLog(@"---set to bold");
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    else {
        NSLog(@"--- not set to bold");
        
    }
    
    //斜体.测试中发现对中文不支持.使用obliq方法.
    //font = [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize];
    
    return font;
}


- (UIColor*)textColor
{
    UIColor *textColor = [UIColor blackColor];
    NSString *fontString = self.styleDictionay[@"color"];
    if(fontString.length > 0 && nil != (textColor = [UIColor colorFromString:fontString])) {
        
    }
    else {
        textColor = [UIColor blackColor];
    }
    
    return textColor;
}


- (UIColor*)backgroundColor
{
    return [UIColor whiteColor];
}


- (NSMutableAttributedString*)attributedTextGenerated
{
    if(!self.content) {
        self.content = @"";
    }
    
    NS0Log(@"NoteParagraph content : %@, style : %@", self.content, self.styleDictionay);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.content];
    NSRange rangeAll = NSMakeRange(0, attributedString.length);
    
    //字体,颜色.
    UIFont *font    = [self textFont];
    UIColor *color  = [self textColor];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:rangeAll];
    
    //对齐方式.
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.headIndent = 0.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 2.0;
    NSDictionary * attributes = @{NSParagraphStyleAttributeName:paragraphStyle};
    [attributedString addAttributes:attributes range:rangeAll];
    
    //斜体.
    if([self.styleDictionay[@"font-style"] isEqualToString:@"italic"]) {
        NSLog(@"attributedString add : italic");
        [attributedString addAttribute:NSObliquenessAttributeName value:@0.5 range:rangeAll];
    }
    
    //下划线.
    if([self.styleDictionay[@"text-decoration"] isEqualToString:@"underline"]) {
        NSLog(@"attributedString add : underline");
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:rangeAll];
    }
    
    //边框.
    NSString *borderPx = self.styleDictionay[@"border"];
    NSInteger px = 0;
    if(borderPx.length > 0 && [borderPx hasSuffix:@"px"] && (px = [borderPx integerValue]) > 0) {
        NSLog(@"attributedString add : border");
        //[attributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:rangeAll];
        
        YYTextBorder *border = [YYTextBorder new];
        border.strokeColor = color;//[UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000];
        border.strokeWidth = 1;
        border.lineStyle = YYTextLineStyleSingle;
        border.cornerRadius = 0;
        border.insets = UIEdgeInsetsMake(1, 1, 1, 1);
        attributedString.yy_textBackgroundBorder = border;
    }
    
    NS0Log(@"%@", attributedString);
    
    return attributedString;
}


- (NSString*)description
{
    return [NoteParagraphModel noteParagraphToString:self];
}


- (NoteParagraphModel*)copy
{
    NSLog(@"copy");
    NoteParagraphModel *noteParagraphCopy = [[NoteParagraphModel alloc] init];
    noteParagraphCopy.content = self.content;
    noteParagraphCopy.image = self.image;
    noteParagraphCopy.styleDictionay = [[NSMutableDictionary alloc] initWithDictionary:self.styleDictionay];
    
    return noteParagraphCopy;
}



@end

@implementation NoteModel

static NSInteger kno = 0;

- (instancetype)initWithJsonData:(NSData*)jsonData
{
    kno ++;
    
    self.title = [NSString stringWithFormat:@"title%zd中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁", kno];
    self.content = [NSString stringWithFormat:@"内容%zd中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁", kno];
    
    //NSString *jsonString = @"";
    
    
    
    
    
    
    
    return self;
}


- (NSData*)toJsonData
{
    return nil;
}


- (NSString*)contents
{
    return [NSString stringWithFormat:@"content%zd中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁", kno];
    
}


- (NSString*)description
{
    NSMutableString *strm = [[NSMutableString alloc] init];
    [strm appendFormat:@"======NoteModel description : %p, [%@],  title:%@, content:%@", self, self.identifier, self.title, self.content];
    
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
    
    ;
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
    
    note.sn
    = [dict[@"rowid"] integerValue];
    
    note.identifier
    = dict[@"identifier"];
    
    note.title
    = dict[@"title"];
    note.content
    = dict[@"content"];
    
    note.summary
    = dict[@"summary"];
    note.classification
    = dict[@"classification"];
    note.color
    = dict[@"color"];
    note.thumb
    = dict[@"thumb"];
    note.audio
    = dict[@"audio"];
    
    
    note.location
    = dict[@"location"];
    note.createdAt
    = dict[@"createdAt"];
    note.modifiedAt
    = dict[@"modifiedAt"];
    note.browseredAt
    = dict[@"browseredAt"];
    note.deletedAt
    = dict[@"deletedAt"];
    note.source
    = dict[@"source"];
    
    note.synchronize
    = dict[@"synchronize"];
    
    
    note.countCollect
    = [dict[@"countCollect"] integerValue];
    note.countLike
    = [dict[@"countLike"] integerValue];
    note.countDislike
    = [dict[@"countDislike"] integerValue];
    note.countBrowser
    = [dict[@"countBrowser"] integerValue];
    note.countEdit
    = [dict[@"countEdit"] integerValue];
    
#if 0
    
    [NoteParagraphModel fromParagraphString:note.title];
#endif
    
    return note;
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
        title = [NSString stringWithFormat:@"%@"/*, self.identifier*/, titleNoteParagraph.content];
    }

    return title;
}


- (NSString*)previewSummary
{
    if(self.summary.length > 0) {
        return self.summary;
    }
    
    NSMutableString *summary = [[NSMutableString alloc] init];
    
    NSArray<NoteParagraphModel *> *contentNoteParagraphs = [NoteParagraphModel noteParagraphsFromString:self.content];
    for(NoteParagraphModel *noteParagraph in contentNoteParagraphs) {
        [summary appendFormat:@"%@ ", [noteParagraph.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
    summary = [NSMutableString stringWithString:[summary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if(summary.length == 0) {
        return @"无内容";
    }
    
    return [NSString stringWithString:summary];
}


- (NSString*)generateWWWPage
{
    NSString *resPath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"NoteTemplate.htm"];
    NSData *data = [NSData dataWithContentsOfFile:resPath];
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    s = [s stringByReplacingOccurrencesOfString:@"@@note.identifier" withString:self.identifier?self.identifier:@""];
    s = [s stringByReplacingOccurrencesOfString:@"@@note.title" withString:self.title?self.title:@""];
    s = [s stringByReplacingOccurrencesOfString:@"@@note.content" withString:self.content?self.content:@""];
    s = [s stringByReplacingOccurrencesOfString:@"@@note.classification" withString:self.classification?self.classification:@""];
    s = [s stringByReplacingOccurrencesOfString:@"@@note.createdAt" withString:self.createdAt?self.createdAt:@""];
    
    NSLog(@"-=-=-=\n\n\n%@\n\n\n", s);
    return s;
}


+ (NSString*)randonIdentifierStringWithLength:(NSInteger)length
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