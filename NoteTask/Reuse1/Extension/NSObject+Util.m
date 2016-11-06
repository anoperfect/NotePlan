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
    
    //NSDate *dateTomorrow = [date dateByAddingTimeInterval:24*60*60];
    //NSString *dateStringTomorrow = [dateformatter stringFromDate:dateTomorrow];
    
    return dateString;
}


+ (NSString*)dayStringTomorrow
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateString = [dateformatter stringFromDate:date];
    NSLog(@"%@", dateString);
    
    NSDate *dateTomorrow = [date dateByAddingTimeInterval:24*60*60];
    NSString *dateStringTomorrow = [dateformatter stringFromDate:dateTomorrow];
    
    return dateStringTomorrow;
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

