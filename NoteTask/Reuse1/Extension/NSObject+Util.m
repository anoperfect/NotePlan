//
//  NSObject+Util.m
//  NoteTask
//
//  Created by Ben on 16/3/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NSObject+Util.h"

@implementation NSObject(Util)

+ (void)objectClassTest:(NSObject*)obj
{
    if(nil != obj) {
        NSLog(@"%20@ : %d", @"NSDictionary",    [obj isKindOfClass:[NSDictionary class]]);
        NSLog(@"%20@ : %d", @"NSArray",         [obj isKindOfClass:[NSArray class]]);
        NSLog(@"%20@ : %d", @"NSString",        [obj isKindOfClass:[NSString class]]);
        NSLog(@"%20@ : %d", @"NSNumber",        [obj isKindOfClass:[NSNumber class]]);
        NSLog(@"%20@ : %d", @"NSData",          [obj isKindOfClass:[NSData class]]);
        NSLog(@"obj content = [%@]", obj);
    }
    else {
        NSLog(@"obj nil");
    }
}


- (void)performSelectorByString:(NSString*)selString
{
    if(!selString) {
        NSLog(@"#error - not perform %@.", selString);
        return ;
    }
    
    SEL sel = NSSelectorFromString(selString);
    if(sel && [self respondsToSelector:sel]) {
        _Pragma("clang diagnostic push")
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
        [self performSelector:sel];
        _Pragma("clang diagnostic pop")
    }
    else {
        NSLog(@"#error - not perform %@.", selString);
    }
}


- (void)memberObjectCreate
{
    YYClassInfo *c = [YYClassInfo classInfoWithClass:[self class]];
    for(NSString *key in c.ivarInfos.allKeys) {
        YYClassIvarInfo *ivar = c.ivarInfos[key];
        NS0Log(@"key : %@, name : %@, typeEncoding : %@, type : %zd", key, ivar.name, ivar.typeEncoding, ivar.type);
        
        if(ivar.type == YYEncodingTypeObject) {
            NSString *className = nil;
            Class class = nil;
            if([ivar.typeEncoding hasPrefix:@"@\""]
                && [ivar.typeEncoding hasSuffix:@"\""]
                && nil != (className = [ivar.typeEncoding substringWithRange:NSMakeRange(2, ivar.typeEncoding.length - 3)])
                && nil != (class = NSClassFromString(className))
                && ![className isEqualToString:@"UITextView"]) {
                NS0Log(@"%@", class);
                id value = [self valueForKey:key];
                if(!value) {
                    value = [[class alloc] init];
                    [self setValue:value forKey:key];
                    NS0Log(@"set : %@ -> %@", key, value);
                }
                else {
                    NS0Log(@"not set : %@. already valued.", key);
                }
                
                
            }
            else {
                NSLog(@"#error - not set : %@", key);
            }
        }
    }
}


- (void)memberViewSetFrameWith:(NSDictionary*)nameAndFrames
{
    YYClassInfo *c = [YYClassInfo classInfoWithClass:[self class]];
    for(NSString *key in c.ivarInfos.allKeys) {
        YYClassIvarInfo *ivar = c.ivarInfos[key];
        NS0Log(@"key : %@, name : %@, typeEncoding : %@, type : %zd", key, ivar.name, ivar.typeEncoding, ivar.type);
        
        if(ivar.type == YYEncodingTypeObject) {
            id obj = [self valueForKey:key];
            if([obj respondsToSelector:@selector(setFrame:)]) {
                NSValue *frameValue = nameAndFrames[key];
                if([frameValue isKindOfClass:[NSValue class]]) {
                    CGRect frame = [frameValue CGRectValue];
                    [obj setFrame:frame];
                    NS0Log(@"===%@ set to [%.2f,%.2f,%.2f,%.2f]", key, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
                }
                else {
                    NS0Log(@"[%@] not set. no value", key);
                }
            }
            else {
                NS0Log(@"[%@] not set. not belong to UIView.", key)
            }
        }
    }
}


@end



@implementation NSString (DateString)



+ (BOOL)stringIsAllDigtal:(NSString*)string
{
    NSInteger length = string.length;
    for(NSInteger idx = 0; idx < length; idx ++) {
        unichar ch = [string characterAtIndex:idx];
        if(ch >= '0' && ch <= '9') {
        }
        else {
            return NO;
        }
    }
    
    return YES;
}


+ (BOOL)stringIsValidDayString:(NSString*)dayString
{
    if(dayString.length != 10) {
        return NO;
    }
    
    NSString *yyyyString = [dayString substringToIndex:3];
    NSString *c1 = [dayString substringWithRange:NSMakeRange(4, 1)];
    NSString *mmString = [dayString substringWithRange:NSMakeRange(5, 2)];
    NSString *c2 = [dayString substringWithRange:NSMakeRange(7, 1)];
    NSString *ddString = [dayString substringWithRange:NSMakeRange(8, 2)];
    
    if(![c1 isEqualToString:@"-"] && [c2 isEqualToString:@"-"]) {
        return NO;
    }
    
    NSInteger yyyy = [yyyyString integerValue];
    NSInteger mm = [mmString integerValue];
    NSInteger dd = [ddString integerValue];
    
    static NSInteger numberOfDayArray[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    static NSInteger numberOfDayLeepArray[12] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    
    if(!(mm >= 1 && mm <= 12)) {
        return NO;
    }
    
    if((yyyy % 4 == 0 && yyyy % 100 != 0) || yyyy % 400 == 0) {
        if(!(dd >=1 && dd <= numberOfDayLeepArray[mm-1])) {
            return NO;
        }
    }
    else {
        if(!(dd >=1 && dd <= numberOfDayArray[mm-1])) {
            return NO;
        }
    }
    
    return YES;
}


+ (NSString*)dayStringToday
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateString = [dateformatter stringFromDate:date];
    NSLog(@"%@", dateString);
    
    return dateString;
}


+ (NSString*)dayStringTomorrow
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *dateTomorrow = [date dateByAddingTimeInterval:24*60*60];
    NSString *dateStringTomorrow = [dateformatter stringFromDate:dateTomorrow];
    
    return dateStringTomorrow;
}


+ (NSString*)stringDateTimeNow
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateString = [dateformatter stringFromDate:date];
    
    NSTimeInterval t = [date timeIntervalSince1970];
    long long lt = t;
    double dot = t - lt;
    dateString = [dateString stringByAppendingFormat:@" %.6lf",dot];
    
    return dateString;
}


+ (NSString*)stringDateTimeOfDate:(NSDate*)date
{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateString = [dateformatter stringFromDate:date];
    
    NSTimeInterval t = [date timeIntervalSince1970];
    long long lt = t;
    double dot = t - lt;
    dateString = [dateString stringByAppendingFormat:@" %.6lf",dot];
    
    return dateString;
}


+ (NSDate*)stringToDate:(NSString*)s
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateTime = [formatter dateFromString:s];
    return dateTime;
}


+ (NSString*)dateStringOfDate:(NSDate*)date
{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateString = [dateformatter stringFromDate:date];
    return dateString;
}


+ (BOOL)date:(NSDate*)date isSameDayOfDate:(NSDate*)date0
{
    NSString *dateString = [NSString dateStringOfDate:date];
    NSString *dateString0 = [NSString dateStringOfDate:date0];
    
    return [dateString isEqualToString:dateString0];
}


+ (BOOL)date:(NSDate*)date isYestodayOfDate:(NSDate*)date0
{
    date = [date dateByAddingTimeInterval:86400];
    return [self date:date isSameDayOfDate:date0];
}


+ (BOOL)date:(NSDate*)date isTomorrowOfDate:(NSDate*)date0
{
    date0 = [date0 dateByAddingTimeInterval:86400];
    return [self date:date isSameDayOfDate:date0];
}




























@end





//编辑的正文内容替换.
#if 0
不断行的空白格	&nbsp;
<	小于	&lt;	<
>	大于	&gt;	>
&	&符号	&amp;	&
"	双引号	&quot;	"
#endif
@implementation NSString (Htm)

+ (NSString*)htmEncode:(NSString*)s
{
    NSArray *a0 = @[@"&",     @" ",      @"<",    @">",    @"\"",     @"\n"];
    NSArray *a1 = @[@"&amp;", @"&nbsp;", @"&lt;", @"&gt;", @"&quot;", @"<br />"];
    
    NSInteger count = a0.count;
    for(NSInteger idx = 0; idx < count; idx ++) {
        s = [s stringByReplacingOccurrencesOfString:a0[idx] withString:a1[idx]];
    }
    
    return s;
}


+ (NSString*)htmDecode:(NSString*)s
{
    NSArray *a0 = @[@"&",     @" ",      @"<",    @">",    @"\"",     @"\n"];
    NSArray *a1 = @[@"&amp;", @"&nbsp;", @"&lt;", @"&gt;", @"&quot;", @"<br />"];
    
    NSInteger count = a0.count;
    for(NSInteger idx = 0; idx < count; idx ++) {
        s = [s stringByReplacingOccurrencesOfString:a1[idx] withString:a0[idx]];
    }
    
    return s;
}

@end



@implementation NSString (Random)



+ (NSString*)randomStringWithLength:(NSInteger)length andType:(NSInteger)type
{
    //暂不实现多种type. 仅仅支持0-9, a-z.
    NSMutableString *s = [[NSMutableString alloc] init];
    for(NSInteger idx = 0; idx < length; idx ++) {
        u_int32_t num = arc4random();
        NSUInteger snNum = num % 36;
        char ch = snNum <= 9 ? '0' + snNum : 'a' + snNum - 10;
        [s appendFormat:@"%c", ch];
    }
    
    return [NSString stringWithString:s];
}




@end


@implementation NSString (NSAttributedString)


+(NSMutableAttributedString*)attributedStringWith:(NSString*)s
                                             font:(UIFont*)font
                                           indent:(NSInteger)indent
                                        textColor:(UIColor*)textColor
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:s];
    NSInteger length = attributedString.length;
    NSRange range = NSMakeRange(0, length);
    
    if(font) {
        [attributedString addAttribute:NSFontAttributeName value:font range:range];
    }
    
    if(indent > 0) {
        NSMutableParagraphStyle * paragraphStyleContent = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyleContent setHeadIndent:indent];
        [paragraphStyleContent setFirstLineHeadIndent:indent];
        [paragraphStyleContent setTailIndent:-indent];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleContent range:range];
    }
    
    if(textColor) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:range];
    }
    
    
    return attributedString;
}


+(NSMutableAttributedString*)attributedStringWith:(NSString*)s
                                             font:(UIFont*)font
                                           indent:(NSInteger)indent
                                        textColor:(UIColor*)textColor
                                  backgroundColor:(UIColor*)backgroundColor
                                   underlineColor:(UIColor*)underlineColor
                                     throughColor:(UIColor*)throughColor

{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:s];
    NSInteger length = attributedString.length;
    NSRange range = NSMakeRange(0, length);
    
    if(indent > 0) {
        NSMutableParagraphStyle * paragraphStyleContent = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyleContent setHeadIndent:indent];
        [paragraphStyleContent setFirstLineHeadIndent:indent];
        [paragraphStyleContent setTailIndent:-indent];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleContent range:range];
    }
    
    if(font) {
        [attributedString addAttribute:NSFontAttributeName value:font range:range];
    }
    
    if(textColor) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:range];
    }
    
    if(backgroundColor) {
        [attributedString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
    }
    
    if(underlineColor) {
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:range];
        [attributedString addAttribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    }
    
    if(throughColor) {
        [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:range];
        [attributedString addAttribute:NSStrikethroughColorAttributeName value:throughColor range:range];
    }
    
    return attributedString;
}








@end

@implementation NSString (NSArrayCombine)


+ (NSString*)arrayDescriptionConbine:(NSArray*)array seprator:(NSString*)seprator
{
    NSMutableString *s = [[NSMutableString alloc] init];
    NSInteger idx = 0;
    for(id obj in array) {
        if(idx != 0) {
            [s appendString:seprator];
        }
        [s appendFormat:@"%@", obj];
    }
    
    return [NSString stringWithString:s];
}


@end
