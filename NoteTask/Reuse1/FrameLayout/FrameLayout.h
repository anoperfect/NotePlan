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


+ (instancetype)viewWithName:(NSString*)name value:(CGFloat)value;
+ (instancetype)viewWithName:(NSString*)name value:(CGFloat)value edge:(UIEdgeInsets)edge;

+ (instancetype)viewWithName:(NSString*)name percentage:(CGFloat)percentage;
+ (instancetype)viewWithName:(NSString*)name percentage:(CGFloat)percentage edge:(UIEdgeInsets)edge;


@end



#define FRAMELAYOUT_NAME_MAIN @"super"
@interface FrameLayout : NSObject
- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithRootView:(UIView*)rootView;

- (CGRect)frameLayoutGet:(NSString*)name;
- (void)frameLayoutSet:(NSString*)name withFrame:(CGRect)frame;

- (void)frameLayoutEqual:(NSString*)inName to:(NSArray<NSString*> *)names;
- (void)frameLayoutEqual:(NSString*)inName toVertical:(NSArray<NSString*> *)names;










- (void)frameLayoutHerizon:(NSString*)inName toViews:(NSArray<FrameLayoutView*>*)views;
- (void)frameLayoutVertical:(NSString*)inName toViews:(NSArray<FrameLayoutView*>*)views;

- (void)frameLayoutSet:(NSString*)name in:(NSString *)inName withEdgeInserts:(UIEdgeInsets)edgeInsets;

- (NSDictionary<NSString*, NSValue*>*)nameAndFrames;

@end






#define FrameAssign(view, name, frameLayout) view.frame = [frameLayout frameLayoutGet:name];