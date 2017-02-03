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



- (void)frameLayout:(NSString*)inName to:(NSArray<NSString*> *)names withPercentages:(NSArray<NSNumber*> *)percentages
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGFloat y = frameIn.origin.y;
    CGFloat height = 0;
    NSInteger nameCount = names.count;
    NSInteger percentageCount = percentages.count;
    
    for(NSInteger idx = 0; idx < nameCount && idx < percentageCount; idx ++) {
        NSNumber *percentageNumber = percentages[idx];
        height = frameIn.size.height * [percentageNumber floatValue];
        
        CGRect frame = CGRectMake(frameIn.origin.x, y, frameIn.size.width, height);
        [self frameLayoutSet:names[idx] withFrame:frame];
        
        y += height;
    }
}


- (void)frameLayout:(NSString*)inName to:(NSArray<NSString*> *)names withHeights:(NSArray<NSNumber*> *)heights
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGFloat y = frameIn.origin.y;
    CGFloat height = 0;
    NSInteger nameCount = names.count;
    NSInteger heightCount = heights.count;
    
    for(NSInteger idx = 0; idx < nameCount && idx < heightCount; idx ++) {
        NSNumber *heightNumber = heights[idx];
        height = [heightNumber floatValue];
        if(height == -1. && idx == nameCount - 1) {
            height = frameIn.size.height - (y - frameIn.origin.y) ;
            NSLog(@"height left : %lf", height);
        }
        
        CGRect frame = CGRectMake(frameIn.origin.x, y, frameIn.size.width, height);
        [self frameLayoutSet:names[idx] withFrame:frame];
        
        y += height;
    }
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



- (void)frameLayout:(NSString*)inName toVertical:(NSArray<NSString*> *)names withPercentages:(NSArray<NSNumber*> *)percentages
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGFloat x = frameIn.origin.x;
    CGFloat width = 0;
    NSInteger nameCount = names.count;
    NSInteger percentageCount = percentages.count;
    
    for(NSInteger idx = 0; idx < nameCount && idx < percentageCount; idx ++) {
        NSNumber *percentageNumber = percentages[idx];
        width = frameIn.size.width * [percentageNumber floatValue];
        
        CGRect frame = CGRectMake(x, frameIn.origin.y, width, frameIn.size.height);
        [self frameLayoutSet:names[idx] withFrame:frame];
        
        x += width;
    }
}


- (void)frameLayout:(NSString*)inName toVertical:(NSArray<NSString*> *)names withWidths:(NSArray<NSNumber*> *)widths
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGFloat x = frameIn.origin.x;
    CGFloat width = 0;
    NSInteger nameCount = names.count;
    NSInteger widthCount = widths.count;
    
    for(NSInteger idx = 0; idx < nameCount && idx < widthCount; idx ++) {
        NSNumber *widthNumber = widths[idx];
        width = [widthNumber floatValue];
        if(width == -1. && idx == nameCount - 1) {
            width = frameIn.size.width - (x - frameIn.origin.x) ;
            NSLog(@"width left : %lf", width);
        }
        
        CGRect frame = CGRectMake(x, frameIn.origin.y, width, frameIn.size.height);
        [self frameLayoutSet:names[idx] withFrame:frame];
        
        x += width;
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


- (void)frameLayoutHerizon:(NSString*)inName toNameAndHeights:(NSArray*)nameAndHeights
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGFloat y = frameIn.origin.y;
    CGFloat height = 0;
    NSInteger nameCount = nameAndHeights.count / 2;
    
    //height格式为v:100(高度为100)
    //           p:0.9(高度为减去固定分配值后,百分比分配范围的90%)
    
    CGFloat heightValues = 0;
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        NSString *name = nameAndHeights[idx * 2];
        if(![name isKindOfClass:[NSString class]]) {
            NSLog(@"#error - [%s] input value error.", __FUNCTION__);
            return ;
        }
        
        NSString *heightNumberString = nameAndHeights[idx * 2 + 1];
        if(![heightNumberString isKindOfClass:[NSString class]]) {
            NSLog(@"#error - [%s] input value error.", __FUNCTION__);
            return ;
        }
        
        if([heightNumberString hasPrefix:@"v:"]) {
            height = [[heightNumberString substringFromIndex:2] floatValue];
            heightValues += height;
        }
        else if([heightNumberString hasPrefix:@"p:"]) {
            
        }
        else {
            NSLog(@"#error - [%s] input value error.", __FUNCTION__);
            return ;
        }
    }
    
    CGFloat heightValuesLeft = frameIn.size.height - heightValues;
    
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        NSString *name = nameAndHeights[idx * 2];
        NSString *heightNumberString = nameAndHeights[idx * 2 + 1];
        if([heightNumberString hasPrefix:@"v:"]) {
            height = [[heightNumberString substringFromIndex:2] floatValue];
        }
        else if([heightNumberString hasPrefix:@"p:"]) {
            height = heightValuesLeft * [[heightNumberString substringFromIndex:2] floatValue];
        }
        
        CGRect frame = CGRectMake(frameIn.origin.x, y, frameIn.size.width, height);
        [self frameLayoutSet:name withFrame:frame];
        
        y += height;
    }
}




- (void)frameLayoutVertical:(NSString*)inName toNameAndWidths:(NSArray*)nameAndWidths
{
    CGRect frameIn = [self frameLayoutGet:inName];
    
    CGFloat x = frameIn.origin.x;
    CGFloat width = 0;
    NSInteger nameCount = nameAndWidths.count / 2;
    
    //width格式为v:100(高度为100)
    //           p:0.9(高度为减去固定分配值后,百分比分配范围的90%)
    
    CGFloat widthValues = 0;
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        NSString *name = nameAndWidths[idx * 2];
        if(![name isKindOfClass:[NSString class]]) {
            NSLog(@"#error - [%s] input value error.", __FUNCTION__);
            return ;
        }
        
        NSString *widthNumberString = nameAndWidths[idx * 2 + 1];
        if(![widthNumberString isKindOfClass:[NSString class]]) {
            NSLog(@"#error - [%s] input value error.", __FUNCTION__);
            return ;
        }
        
        if([widthNumberString hasPrefix:@"v:"]) {
            width = [[widthNumberString substringFromIndex:2] floatValue];
            widthValues += width;
        }
        else if([widthNumberString hasPrefix:@"p:"]) {
            
        }
        else {
            NSLog(@"#error - [%s] input value error.", __FUNCTION__);
            return ;
        }
    }
    
    CGFloat widthValuesLeft = frameIn.size.width - widthValues;
    
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        NSString *name = nameAndWidths[idx * 2];
        NSString *widthNumberString = nameAndWidths[idx * 2 + 1];
        if([widthNumberString hasPrefix:@"v:"]) {
            width = [[widthNumberString substringFromIndex:2] floatValue];
        }
        else if([widthNumberString hasPrefix:@"p:"]) {
            width = widthValuesLeft * [[widthNumberString substringFromIndex:2] floatValue];
        }
        
        CGRect frame = CGRectMake(x, frameIn.origin.y, width, frameIn.size.height);
        [self frameLayoutSet:name withFrame:frame];
        
        x += width;
    }
}


- (void)frameLayoutSet:(NSString*)name containNames:(NSArray<NSString*>*)containNames
{
    CGRect frame = [self frameLayoutGet:containNames[0]];
    for(NSString *containName in containNames) {
        CGRect frame0 = [self frameLayoutGet:containName];
        if(frame.origin.x > frame0.origin.x) {
            frame.origin.x = frame0.origin.x;
        }
        
        if(frame.origin.y > frame0.origin.y) {
            frame.origin.y = frame0.origin.y;
        }
        
        if((frame.origin.x + frame.size.width) < (frame0.origin.x + frame0.size.width)) {
            frame.size.width = frame0.origin.x + frame0.size.width - frame.origin.x;
        }
        
        if((frame.origin.y + frame.size.height) < (frame0.origin.y + frame0.size.height)) {
            frame.size.height = frame0.origin.y + frame0.size.height - frame.origin.y;
        }
    }
    
    [self frameLayoutSet:name withFrame:frame];
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
        if(view.value > 0.0) {
            heightValues += view.value;
        }
    }
    
    CGFloat heightValuesLeft = frameIn.size.height - heightValues;
    
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        FrameLayoutView *view = views[idx];
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
        if(view.value > 0.0) {
            widthValues += view.value;
        }
    }
    
    CGFloat widthValuesLeft = frameIn.size.width - widthValues;
    
    for(NSInteger idx = 0; idx < nameCount ; idx ++) {
        FrameLayoutView *view = views[idx];
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
