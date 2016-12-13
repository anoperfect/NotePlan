//
//  NSString+Util.h
//  Reuse0
//
//  Created by Ben on 16/2/24.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DateString)

+ (BOOL)stringIsAllDigtal:(NSString*)string;

+ (BOOL)dateStringIsValid:(NSString*)dayString;

+ (NSString*)dateStringToday;
+ (NSString*)dateStringTomorrow;

+ (NSString*)dateTimeStringNow;
+ (NSDate*)dateFromString:(NSString*)s;

+ (NSString*)dateStringOfDate:(NSDate*)date;
+ (NSString*)dateTimeStringOfDate:(NSDate*)date;

+ (NSInteger)dateStringCountCompareToday:(NSString*)dayString;

+ (BOOL)date:(NSDate*)date isSameDayOfDate:(NSDate*)date0;
+ (BOOL)date:(NSDate*)date isYestodayOfDate:(NSDate*)date0;
+ (BOOL)date:(NSDate*)date isTomorrowOfDate:(NSDate*)date0;

+ (NSArray<NSString*>*)dateFrom:(NSString*)dateStringFrom to:(NSString*)dateStringTo;

@end


@interface NSString (Htm)

+ (NSString*)htmEncode:(NSString*)s;
+ (NSString*)htmDecode:(NSString*)s;
@end







@interface NSString (Random)
+ (NSString*)randomStringWithLength:(NSInteger)length andType:(NSInteger)type;
@end



@interface NSString (NSAttributedString)
+(NSMutableAttributedString*)attributedStringWith:(NSString*)s
                                             font:(UIFont*)font
                                           indent:(NSInteger)indent
                                        textColor:(UIColor*)textColor;


+(NSMutableAttributedString*)attributedStringWith:(NSString*)s
                                             font:(UIFont*)font
                                           indent:(NSInteger)indent
                                        textColor:(UIColor*)textColor
                                  backgroundColor:(UIColor*)backgroundColor
                                   underlineColor:(UIColor*)underlineColor
                                     throughColor:(UIColor*)throughColor
                                    textAlignment:(NSTextAlignment)textAlignment;
                                    



@end


@interface NSString (NSArrayCombine)

+ (NSString*)arrayDescriptionConbine:(NSArray*)array seprator:(NSString*)seprator;

@end
