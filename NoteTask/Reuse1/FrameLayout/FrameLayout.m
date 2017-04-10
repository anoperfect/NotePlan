//
//  RootViewController.m
//  Reuse0
//
//  Created by Ben on 16/6/27.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "FrameLayout.h"






@implementation FrameLayoutView

+ (instancetype)viewWithName:(NSString*)name value:(CGFloat)value edge:(UIEdgeInsets)edge
{
    FrameLayoutView *frameLayoutView = [[FrameLayoutView alloc] init];
    frameLayoutView.name = name;
    frameLayoutView.value = value;
    frameLayoutView.percentage = 0.0;
    frameLayoutView.edge = edge;
    
    return frameLayoutView;
}


+ (instancetype)viewWithName:(NSString*)name percentage:(CGFloat)percentage edge:(UIEdgeInsets)edge
{
    FrameLayoutView *frameLayoutView = [[FrameLayoutView alloc] init];
    frameLayoutView.name = name;
    frameLayoutView.value = 0.0;
    frameLayoutView.percentage = percentage;
    frameLayoutView.edge = edge;
    
    return frameLayoutView;
}


+ (instancetype)viewWithName:(NSString*)name value:(CGFloat)value
{
    FrameLayoutView *frameLayoutView = [[FrameLayoutView alloc] init];
    frameLayoutView.name = name;
    frameLayoutView.value = value;
    frameLayoutView.percentage = 0.0;
    frameLayoutView.edge = UIEdgeInsetsZero;
    
    return frameLayoutView;
}


+ (instancetype)viewWithName:(NSString*)name percentage:(CGFloat)percentage
{
    FrameLayoutView *frameLayoutView = [[FrameLayoutView alloc] init];
    frameLayoutView.name = name;
    frameLayoutView.value = 0.0;
    frameLayoutView.percentage = percentage;
    frameLayoutView.edge = UIEdgeInsetsZero;
    
    return frameLayoutView;
}


+ (instancetype)viewWithJson:(id)json
{
    FrameLayoutView *frameLayoutView = [[FrameLayoutView alloc] init];
    frameLayoutView.name = @"nan";
    frameLayoutView.value = 0.0;
    frameLayoutView.percentage = 0;
    frameLayoutView.edge = UIEdgeInsetsZero;
    
    NSDictionary *dict = nil;
    
    if (!json || json == (id)kCFNull) {
        NSLog(@"#error - invalid data.");
        return frameLayoutView;
    }
    
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dict = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        if (![dict isKindOfClass:[NSDictionary class]]) {
            NSLog(@"#error - invalid data.");
            return frameLayoutView;
        }
    }
    
    NSArray *edgeValue = nil;
    if((edgeValue = dict[@"edge"]) != nil
       && [edgeValue isKindOfClass:[NSArray class]]
       && edgeValue.count == 4
       && [edgeValue[0] isKindOfClass:[NSNumber class]]
       && [edgeValue[1] isKindOfClass:[NSNumber class]]
       && [edgeValue[2] isKindOfClass:[NSNumber class]]
       && [edgeValue[3] isKindOfClass:[NSNumber class]]) {
        frameLayoutView.edge = UIEdgeInsetsMake(
                                                [edgeValue[0] floatValue],
                                                [edgeValue[1] floatValue],
                                                [edgeValue[2] floatValue],
                                                [edgeValue[3] floatValue]);
    }
    
    NSMutableArray *allKeys = [NSMutableArray arrayWithArray:dict.allKeys];
    [allKeys removeObject:@"edge"];
    
    if(allKeys.count == 1) {
        if([allKeys[0] isKindOfClass:[NSString class]]) {
            frameLayoutView.name = [allKeys[0] copy];
            
            id value = dict[allKeys[0]];
            if([value isKindOfClass:[NSNumber class]]) {
                frameLayoutView.value = [dict[allKeys[0]] floatValue];
            }
            else if([value isKindOfClass:[NSString class]]) {
                NSString *svalue = value;
                if([svalue hasSuffix:@"%"]) {
                    frameLayoutView.percentage = [svalue floatValue] / 100;
                }
                else {
                    //复杂表达式.
                }
            }
        }
    }
    else {
        NSLog(@"#error - invalid data.");
    }

    return frameLayoutView;
}





@end


@interface FrameLayout ()
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSValue*> *frames;



@end


@implementation FrameLayout


- (instancetype)initWithSize:(CGSize)size
{
    self = [super init];
    if (self) {
        _size = size;
        _frames = [[NSMutableDictionary alloc] init];
        _frames[FRAMELAYOUT_NAME_MAIN] = [NSValue valueWithCGRect:CGRectMake(0, 0, _size.width, _size.height)];
    }
    return self;
}


- (instancetype)initWithRootView:(UIView*)rootView
{
    self = [super init];
    if (self) {
        _size = rootView.bounds.size;
        _frames = [[NSMutableDictionary alloc] init];
        _frames[FRAMELAYOUT_NAME_MAIN] = [NSValue valueWithCGRect:CGRectMake(0, 0, _size.width, _size.height)];
    }
    return self;

}


- (CGRect)frameLayoutGet:(NSString*)name
{
    NSValue *v = _frames[name];
    if([v isKindOfClass:[NSValue class]]) {
        
    }
    else {
        NSLog(@"#error - frameLayoutGet <%@> not found.", name);
    }
    
//    NSLog(@"name %@ : %@", name, v);
    return [v CGRectValue];
}


- (void)frameLayoutSet:(NSString*)name withFrame:(CGRect)frame
{
    _frames[name] = [NSValue valueWithCGRect:frame];
}


- (NSString*)description
{
    NSMutableString *stringm = [[NSMutableString alloc] init];
    [stringm appendFormat:@"super size : {%f, %f}\n", _size.width, _size.height];
    for(NSString *key in _frames.allKeys) {
        NSValue *v = _frames[key];
        CGRect frame = [v CGRectValue];
        [stringm appendFormat:@"\t %@ : {%.02f, %.02f, %.02f, %.02f}\n", key, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];
    }
    
    return [NSString stringWithString:stringm];
}


- (void)frameLayoutEqual:(NSString*)inName to:(NSArray<NSString*> *)names
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGFloat y = frameIn.origin.y;
    CGFloat height = 0;
    NSInteger nameCount = names.count;
    
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        height = frameIn.size.height / nameCount;
        
        CGRect frame = CGRectMake(frameIn.origin.x, y, frameIn.size.width, height);
        [self frameLayoutSet:names[idx] withFrame:frame];
        
        y += height;
    }
}


- (void)frameLayoutEqual:(NSString*)inName toVertical:(NSArray<NSString*> *)names
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGFloat x = frameIn.origin.x;
    CGFloat width = 0;
    NSInteger nameCount = names.count;
    
    for(NSInteger idx = 0; idx < nameCount; idx ++) {
        width = frameIn.size.width / nameCount;
        
        CGRect frame = CGRectMake(x, frameIn.origin.y, width, frameIn.size.height);
        [self frameLayoutSet:names[idx] withFrame:frame];
        
        x += width;
    }
}


- (void)frameLayoutSet:(NSString*)name in:(NSString *)inName withEdgeInserts:(UIEdgeInsets)edgeInsets
{
    CGRect rect = [self frameLayoutGet:inName];
    rect = UIEdgeInsetsInsetRect(rect, edgeInsets);
    [self frameLayoutSet:name withFrame:rect];
}

//横切第一个为正方形.第二个为剩余部分.
- (void)frameLayoutSquare:(NSString*)inName to:(NSArray<NSString*> *)names
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGRect frame0 = frameIn;
    frame0.size.height = frame0.size.width;
    [self frameLayoutSet:names[0] withFrame:frame0];
    
    CGRect frame1 = frameIn;
    frame1.origin.y += frame0.size.height;
    frame1.size.height -= frame0.size.height;
    [self frameLayoutSet:names[1] withFrame:frame1];
}


//竖切第一个为正方形.第二个为剩余部分.
- (void)frameLayoutSquare:(NSString*)inName toVertical:(NSArray<NSString*> *)names
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGRect frame0 = frameIn;
    frame0.size.width = frame0.size.height;
    [self frameLayoutSet:names[0] withFrame:frame0];
    
    CGRect frame1 = frameIn;
    frame1.origin.x += frame0.size.width;
    frame1.size.width -= frame0.size.width;
    [self frameLayoutSet:names[1] withFrame:frame1];
}


- (NSDictionary<NSString*, NSValue*>*)nameAndFrames
{
    return [NSDictionary dictionaryWithDictionary:self.frames];
}


- (void)frameLayoutHerizon:(NSString*)inName toViews:(NSArray<FrameLayoutView*>*)views
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGFloat y = frameIn.origin.y;
    CGFloat height = 0;
    NSInteger nameCount = views.count ;
    
    CGFloat heightValues = 0;
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        FrameLayoutView *view = views[idx];
        if(![view isKindOfClass:[FrameLayoutView class]]) {
            view = [FrameLayoutView viewWithJson:view];
        }
        
        if(view.value > 0.0) {
            heightValues += view.value;
        }
    }
    
    CGFloat heightValuesLeft = frameIn.size.height - heightValues;
    
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        FrameLayoutView *view = views[idx];
        if(![view isKindOfClass:[FrameLayoutView class]]) {
            view = [FrameLayoutView viewWithJson:view];
        }
        
        if(view.value > 0.0) {
            height = view.value;
        }
        else {
            height = heightValuesLeft * view.percentage;
        }
        
        CGRect frame = CGRectMake(frameIn.origin.x, y, frameIn.size.width, height);
        frame = UIEdgeInsetsInsetRect(frame, view.edge);
        [self frameLayoutSet:view.name withFrame:frame];
        
        y += height;
    }
}


- (void)frameLayoutVertical:(NSString*)inName toViews:(NSArray<FrameLayoutView*>*)views
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGFloat x = frameIn.origin.x;
    CGFloat width = 0;
    NSInteger nameCount = views.count ;
    
    CGFloat widthValues = 0;
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        FrameLayoutView *view = views[idx];
        if(![view isKindOfClass:[FrameLayoutView class]]) {
            view = [FrameLayoutView viewWithJson:view];
        }
        
        if(view.value > 0.0) {
            widthValues += view.value;
        }
    }
    
    CGFloat widthValuesLeft = frameIn.size.width - widthValues;
    
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        FrameLayoutView *view = views[idx];
        if(![view isKindOfClass:[FrameLayoutView class]]) {
            view = [FrameLayoutView viewWithJson:view];
        }
        
        if(view.value > 0.0) {
            width = view.value;
        }
        else {
            width = widthValuesLeft * view.percentage;
        }
        
        CGRect frame = CGRectMake(x, frameIn.origin.y, width, frameIn.size.height);
        frame = UIEdgeInsetsInsetRect(frame, view.edge);
        [self frameLayoutSet:view.name withFrame:frame];
        
        x += width;
    }
}

@end
