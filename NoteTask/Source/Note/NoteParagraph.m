//
//  NoteParagraph.m
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteParagraph.h"











@implementation NoteParagraphModel




+ (NoteParagraphModel*)noteParagraphFromString:(NSString*)string
{
    NoteParagraphModel *noteParagraph = [[NoteParagraphModel alloc] init];
    
    NSString *contentString = @"";
    NSString *propertyString = @"";
    NSString *styleString = @"";
    
    NSRange rangeP;
    NSRange rangePWithProperty;
    //skip to <p> / <p .
    rangeP = [string rangeOfString:@"<p>"];
    if(rangeP.length > 0) {
        if(rangeP.location != 0) {
            NSLog(@"#error - skip string (%@) on parsing (%@)", [string substringWithRange:NSMakeRange(0, rangeP.location)], string)
            string = [string substringFromIndex:rangeP.location];
        }
    }
    else {
        rangePWithProperty = [string rangeOfString:@"<p "];
        if(rangePWithProperty.length > 0) {
            if(rangePWithProperty.location != 0) {
                NSLog(@"#error - skip string (%@) on parsing (%@)", [string substringWithRange:NSMakeRange(0, rangePWithProperty.location)], string)
                string = [string substringFromIndex:rangePWithProperty.location];
            }
        }
        else {
            NSLog(@"#error - ParagraphString format checked failed. [%@]", string);
            return nil;
        }
    }
    
    if(rangeP.length > 0) {
        contentString = [string substringWithRange:NSMakeRange(3, string.length - 7)];
    }
    else {
        NSRange range0 = [string rangeOfString:@">"];
        if(range0.length != 1 || range0.location == string.length - 1) {
            NSLog(@"#error - ParagraphString format checked failed. [%@]", string);
            return nil;
        }
        
        propertyString = [string substringWithRange:NSMakeRange(3, range0.location - 3)];
        contentString = [string substringWithRange:NSMakeRange(range0.location+1, string.length - 4 - (range0.location+1))];
        styleString = propertyString;
    }
    
    NSString *imageTab0 = @"<img src=\"";
    NSString *imageTab1 = @"\"/>";
    
    NSRange rangeImage0 = [contentString rangeOfString:imageTab0];
    NSRange rangeImage1 = [contentString rangeOfString:imageTab1];
    if(rangeImage1.length == 0) {
        imageTab1 = @"\">";
        rangeImage1 = [contentString rangeOfString:imageTab1];
    }
    NS0Log(@"contentString : (%zd)[%@]", contentString.length, contentString);
    NS0Log(@"rangeImage0 : %zd , %zd", rangeImage0.location, rangeImage0.length);
    NS0Log(@"rangeImage1 : %zd , %zd", rangeImage1.location, rangeImage1.length);
    if(rangeImage0.length > 0 && rangeImage1.length > 0 && rangeImage0.location < rangeImage1.location) {
        noteParagraph.image = [contentString substringWithRange:NSMakeRange(rangeImage0.location + rangeImage0.length, rangeImage1.location - (rangeImage0.location + rangeImage0.length))];
        NSLog(@"image : %@", noteParagraph.image);
        
        if(rangeImage1.location + rangeImage1.length != contentString.length) {
            contentString = [contentString substringWithRange:NSMakeRange(rangeImage1.location + rangeImage1.length, contentString.length - (rangeImage1.location + rangeImage1.length))];
            noteParagraph.content = [NSString htmDecode:contentString];
            NSLog(@"xxx : %@", contentString);
            NSLog(@"xxx : %@", noteParagraph.content);
        }
        else {
            noteParagraph.content = @"";
        }
    }
    else {
        noteParagraph.content = [NSString htmDecode:contentString];
        noteParagraph.styleDictionay = [self styleParseFromString:styleString];
    }
    
    return noteParagraph;
}


+ (NSString*)noteParagraphToString:(NoteParagraphModel*)noteParagraph
{
    if(noteParagraph.image.length == 0) {
        return [NSString stringWithFormat:
                @"<p style=\"%@\">%@</p>"
                , [NoteParagraphModel styleDictionaryToString:noteParagraph.styleDictionay]
                , [NSString htmEncode:noteParagraph.content]];
    }
    else {
        return [NSString stringWithFormat:
                @"<p style=\"%@\"><img src=\"%@\"/>%@</p>"
                , [NoteParagraphModel styleDictionaryToString:noteParagraph.styleDictionay]
                , noteParagraph.image
                , [NSString htmEncode:noteParagraph.content]];
    }
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
    
    string = [string stringByReplacingOccurrencesOfString:@"<p><br></p>" withString:@""];
    NSArray<NSString *> *paragraphStrings = [string componentsSeparatedByString:@"</p>"];
    for(NSString *paragraphString0 in paragraphStrings) {
        if(paragraphString0.length < 3) {
            LOG_POSTION
            continue;
        }
        
        NSString *paragraphString = [paragraphString0 stringByAppendingString:@"</p>"];
        paragraphString = [paragraphString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NoteParagraphModel *noteParagraph = [NoteParagraphModel noteParagraphFromString:paragraphString];
        if(noteParagraph) {
            [noteParagraphs addObject:noteParagraph];
        }
    }
    
    return [NSArray arrayWithArray:noteParagraphs];
}


+ (NSString*)noteParagraphsToString:(NSArray<NoteParagraphModel*> *)noteParagraphs
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    for(NoteParagraphModel *noteParagraph in noteParagraphs) {
        [string appendString:[NoteParagraphModel noteParagraphToString:noteParagraph]];
        [string appendString:@"<p><br></p>"];
    }
    
    return [NSString stringWithString:string];
}


- (UIFont*)textFont
{
    CGFloat fontSize = self.isTitle?18:16;
    NSString *fontString = self.styleDictionay[@"font-size"];
    CGFloat ptSize;
    if([fontString hasSuffix:@"px"] && (ptSize = [fontString floatValue]) >= 1.0 && ptSize < 100.0) {
        fontSize = ptSize;
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    if([self.styleDictionay[@"font-weight"] isEqualToString:@"bold"]) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    else {
        
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


- (NSMutableAttributedString*)attributedTextGeneratedOnSn:(NSInteger)sn andEditMode:(BOOL)editMode
{
    NSString *content = @"";
    BOOL textLight = NO;
    if(self.content.length == 0) {
        if(editMode) {
            textLight = YES;
            if(self.isTitle) {
                content = @"请输入标题.";
            }
            else {
                content = [NSString stringWithFormat:@"第 %zd 段.", sn];
            }
        }
        else {
            if(sn == 0) {
                content = @"无标题";
            }
            else {
                content = @"";
            }
        }
    }
    else {
        content = self.content;
    }
    
    if(self.content.length == 0) {
        NSLog(@"sn: %zd, editMode: %zd, self.content: %@, content: %@", sn, editMode, self.content, content);
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    NSRange rangeAll = NSMakeRange(0, attributedString.length);
    
    //字体,颜色.
    UIFont *font    = [self textFont];
    UIColor *color  = textLight ? [UIColor lightGrayColor] : [self textColor];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:rangeAll];
    
    //对齐方式.
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.headIndent = 0.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 6.0;
    if([self.styleDictionay[@"text-align"] isEqualToString:@"center"] ||  sn == 0) {
        paragraphStyle.alignment = NSTextAlignmentCenter;
    }
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