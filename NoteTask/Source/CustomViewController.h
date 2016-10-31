//
//  CustomViewController.h
//  NoteTask
//
//  Created by Ben on 16/8/20.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomViewController : UIViewController




@property (nonatomic, strong) UIView    *contentView;
@property (nonatomic, assign) BOOL      hiddenByPush;


- (void)addSubview:(UIView*)view;


- (void)showIndicationText:(NSString*)text inTime:(NSTimeInterval)secs;
- (void)dismissIndicationText;

- (void)showProgressText:(NSString*)text inTime:(NSTimeInterval)secs;
- (void)dismissProgressText;

- (void)showPopupView:(UIView*)view;
- (void)showPopupView:(UIView*)view containerAlpha:(CGFloat)alpha dismiss:(void(^)(void))dismiss;
- (void)dismissPopupView;


//override.
- (void)pushBackAction;


@end

























#define VIEW_WIDTH      self.contentView.bounds.size.width
#define VIEW_HEIGHT     self.contentView.bounds.size.height
#define VIEW_SIZE       self.contentView.bounds.size
#define VIEW_BOUNDS     self.contentView.bounds

