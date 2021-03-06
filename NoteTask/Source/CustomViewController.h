//
//  CustomViewController.h
//  NoteTask
//
//  Created by Ben on 16/8/20.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomViewController : UIViewController



@property (nonatomic, assign) BOOL      contentViewScrolled;
@property (nonatomic, strong, readonly) UIView    *contentView;


- (void)addSubview:(UIView*)view;
- (void)addSubviews:(NSArray<UIView*>*)views;

- (void)showIndicationTextTime:(NSTimeInterval)secs;
- (void)showIndicationText:(NSString*)text ;
- (void)dismissIndicationText;

- (void)showProgressText:(NSString*)text inTime:(NSTimeInterval)secs;
- (void)dismissProgressText;

- (void)showPopupView:(UIView*)view
           commission:(NSDictionary*)commission
       clickToDismiss:(BOOL)clickToDismiss
              dismiss:(void(^)(void))dismiss;
- (void)dismissPopupView;


- (void)pushViewControllerByName:(NSString*)name;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;


- (void)showMenus:(NSArray<NSDictionary*>*)menus
             text:(id)text
     selectAction:(void(^)(NSInteger idx, NSDictionary* menu))selectAction;

- (void)dismissMenus;

//override.
- (void)customViewWillAppearByPushed;
- (void)customViewWillAppearByPopBack;

////disappear是主动行为, 可以确定是属于push new, pop, 或者其他. 因此不用定义这个.
//- (void)customViewWillDisappearByPushNew;
//- (void)customViewWillDisappearByPoped;








@end











@protocol CustomTableViewDelegate <NSObject>

- (void)customTableViewCellSelected:(NSInteger)idx menuData:(NSDictionary*)menuData;
- (void)customTableViewCellCustomize:(UITableViewCell*)cell;


@end


@interface CustomTableView : UIView

@property (nonatomic, strong) NSString                  *sectionText;
@property (nonatomic, strong) NSAttributedString        *sectionAttributedText;
@property (nonatomic, strong) NSArray<NSDictionary*>    *menus;
@property (nonatomic, strong) void(^selectAction)(NSInteger idx, NSDictionary* menuData);

@end






#define VIEW_WIDTH      self.contentView.bounds.size.width
#define VIEW_HEIGHT     self.contentView.bounds.size.height
#define VIEW_SIZE       self.contentView.bounds.size
#define VIEW_BOUNDS     self.contentView.bounds

#define SCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height
#define SCREEN_SIZE       [UIScreen mainScreen].bounds.size
#define SCREEN_BOUNDS     [UIScreen mainScreen].bounds




//当前未使用.
@protocol ActionMenuDeleage <NSObject>
- (void)actionMenuSelected:(NSInteger)idx data:(NSDictionary*)data;
- (void)actionMenuDismiss;

@end


@interface ActionMenuViewController : UIViewController
@property (nonatomic, weak) id<ActionMenuDeleage> delegate;
+ (ActionMenuViewController*)actionMenuViewControllerWithDatas:(NSArray<NSDictionary*>*)datas;
@end


@interface PopViewController : UIViewController

@property (nonatomic, strong) UIView    *popupView;

@end
