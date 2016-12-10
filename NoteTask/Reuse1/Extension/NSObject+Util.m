//
//  NSObject+Util.m
//  Reuse0
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
