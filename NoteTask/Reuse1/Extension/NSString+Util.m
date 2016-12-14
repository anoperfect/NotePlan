//
//  NSString+Util.m
//  Reuse0 
//
//  Created by Ben on 16/2/24.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NSString+Util.h"

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


+ (BOOL)dateStringIsValid:(NSString*)dayString
{
    if(dayString.length != 10) {
        return NO;
    }
    
    NSString *yyyyString = [dayString substringToIndex:4];
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


+ (NSString*)dateStringToday
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateString = [dateformatter stringFromDate:date];
    
    return dateString;
}


+ (NSString*)dateStringTomorrow
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *dateTomorrow = [date dateByAddingTimeInterval:24*60*60];
    NSString *dateStringTomorrow = [dateformatter stringFromDate:dateTomorrow];
    
    return dateStringTomorrow;
}


+ (NSString*)dateTimeStringNow
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


+ (NSString*)dateTimeStringOfDate:(NSDate*)date
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


+ (NSDate*)dateFromString:(NSString*)s
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    if(s.length == 19) {
        [formatter setDateFormat : @"yyyy-MM-dd HH:mm:ss"];
    }
    else if(s.length == 10) {
        [formatter setDateFormat : @"yyyy-MM-dd"];
    }
    
    NSDate *dateTime = [formatter dateFromString:s];
    
    if(!dateTime) {
        NSLog(@"#error - not valid date string : [%@]", s);
    }
    
    return dateTime;
}


+ (NSString*)dateStringOfDate:(NSDate*)date
{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateString = [dateformatter stringFromDate:date];
    return dateString;
}


+ (NSInteger)dateStringCountCompareToday:(NSString*)dayString
{
    //直接取since1970的话可能有时区的问题.
    NSDate *dateToday = [NSDate date];
    NSString *dateTodayString = [self dateStringOfDate:dateToday];
    dateToday = [self dateFromString:dateTodayString];
    NSDate *dateCompare = [self dateFromString:dayString];
    
    NSLog(@"%@", dayString);
    
    NSTimeInterval t = [dateCompare timeIntervalSinceDate:dateToday];
    
    NSLog(@"%@", dateCompare);
    NSLog(@"%@", dateToday);
    
    NSLog(@"%f", t);
    NSInteger secs = t;
    NSLog(@"%zd", secs);
    return secs / (3600 * 24);
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


+ (NSString*)dateNextDayTo:(NSString*)dateString
{
    NSString *yyyyString = [dateString substringToIndex:4];
    NSString *mmString = [dateString substringWithRange:NSMakeRange(5, 2)];
    NSString *ddString = [dateString substringWithRange:NSMakeRange(8, 2)];
    
    NSInteger yyyy = [yyyyString integerValue];
    NSInteger mm = [mmString integerValue];
    NSInteger dd = [ddString integerValue];
    

    
    if(mm == 12 && dd == 31) {
        yyyy += 1;
        mm = 1;
        dd = 1;
    }
    else {
        static NSInteger numberOfDayArray[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
        static NSInteger numberOfDayLeepArray[12] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
        NSInteger *numberOfDays;
        if((yyyy % 4 == 0 && yyyy % 100 != 0) || yyyy % 400 == 0) {
            numberOfDays = numberOfDayLeepArray;
        }
        else {
            numberOfDays = numberOfDayArray;
        }
        
        if(dd == numberOfDays[mm-1]) {
            mm += 1;
            dd = 1;
        }
        else {
            dd += 1;
        }
    }
    
    return [NSString stringWithFormat:@"%04zd-%02zd-%02zd", yyyy, mm, dd];
}


+ (NSArray<NSString*>*)dateFrom:(NSString*)dateStringFrom to:(NSString*)dateStringTo
{
    if(!([self dateStringIsValid:dateStringFrom] && [NSString dateStringIsValid:dateStringTo])) {
        NSLog(@"#error - dateString invalid [%@][%@]", dateStringFrom, dateStringTo);
        return nil;
    }
    
    NSMutableArray *dateStrings = [[NSMutableArray alloc] init];
    
    NSComparisonResult comparisonResult = [dateStringFrom compare:dateStringTo];
    if(comparisonResult == NSOrderedAscending) {
        [dateStrings addObject:dateStringFrom];
        NSString *nextDay = dateStringFrom;
        while(1) {
            nextDay = [self dateNextDayTo:nextDay];
            [dateStrings addObject:nextDay];
            if([nextDay isEqualToString:dateStringTo]) {
                break;
            }
        }
    }
    else if(comparisonResult == NSOrderedSame) {
        [dateStrings addObject:dateStringFrom];
    }
    else {
        NSLog(@"#error - sequence sames not expected.[%@][%@]", dateStringFrom, dateStringTo);
        return nil;
    }
    
    return [NSArray arrayWithArray:dateStrings];
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
                                    textAlignment:(NSTextAlignment)textAlignment

{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:s];
    NSInteger length = attributedString.length;
    NSRange range = NSMakeRange(0, length);
    
    if(indent > 0) {
        NSMutableParagraphStyle * paragraphStyleContent = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyleContent setHeadIndent:indent];
        [paragraphStyleContent setFirstLineHeadIndent:indent];
        [paragraphStyleContent setTailIndent:-indent];
        [paragraphStyleContent setAlignment:textAlignment];
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
        if(idx == 0) {
            [s appendFormat:@"%@", obj];
        }
        else {
            [s appendFormat:@"%@%@", seprator, obj];
        }
        
        idx ++;
    }
    
    return [NSString stringWithString:s];
}


@end
