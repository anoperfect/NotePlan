//
//  RootViewController.h
//  Reuse0
//
//  Created by Ben on 16/6/27.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>






@interface FrameLayoutView : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat percentage;
@property (nonatomic, assign) UIEdgeInsets edge;


+ (instancetype)viewWithName:(NSString*)name value:(CGFloat)value edge:(UIEdgeInsets)edge;
+ (instancetype)viewWithName:(NSString*)name percentage:(CGFloat)percentage edge:(UIEdgeInsets)edge;

@end



#define FRAMELAYOUT_NAME_MAIN @"super"
@interface FrameLayout : NSObject
- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithRootView:(UIView*)rootView;

- (CGRect)frameLayoutGet:(NSString*)name;

- (void)frameLayoutSet:(NSString*)name withFrame:(CGRect)frame;
- (void)frameLayoutSet:(NSString*)name in:(NSString *)inName withEdgeInserts:(UIEdgeInsets)edgeInsets;

- (void)frameLayout:(NSString*)inName to:(NSArray<NSString*> *)names withPercentages:(NSArray<NSNumber*> *)percentages;
- (void)frameLayout:(NSString*)inName to:(NSArray<NSString*> *)names withHeights:(NSArray<NSNumber*> *)heights;
- (void)frameLayoutEqual:(NSString*)inName to:(NSArray<NSString*> *)names;

- (void)frameLayout:(NSString*)inName toVertical:(NSArray<NSString*> *)names withPercentages:(NSArray<NSNumber*> *)percentages;
- (void)frameLayout:(NSString*)inName toVertical:(NSArray<NSString*> *)names withWidths:(NSArray<NSNumber*> *)widths;
- (void)frameLayoutEqual:(NSString*)inName toVertical:(NSArray<NSString*> *)names;




//横切第一个为正方形.第二个为剩余部分.
- (void)frameLayoutSquare:(NSString*)inName to:(NSArray<NSString*> *)names;

//竖切第一个为正方形.第二个为剩余部分.
- (void)frameLayoutSquare:(NSString*)inName toVertical:(NSArray<NSString*> *)names;

- (void)frameLayoutHerizon:(NSString*)inName toNameAndHeights:(NSArray*)nameAndHeights;
- (void)frameLayoutVertical:(NSString*)inName toNameAndWidths:(NSArray*)nameAndWidths;
- (void)frameLayoutSet:(NSString*)name containNames:(NSArray<NSString*>*)containNames;

- (NSDictionary<NSString*, NSValue*>*)nameAndFrames;

- (void)frameLayoutHerizon:(NSString*)inName toViews:(NSArray<FrameLayoutView*>*)views;
- (void)frameLayoutVertical:(NSString*)inName toViews:(NSArray<FrameLayoutView*>*)views;

@end






#define FrameAssign(view, name, frameLayout) view.frame = [frameLayout frameLayoutGet:name];