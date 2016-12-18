//
//  MenuButton.h
//  NoteTask
//
//  Created by Ben on 16/6/28.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MenuButtonData : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageName;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end








@interface MenuButton : UIButton

- (void)setMenuButtonData:(MenuButtonData*)data;
//- (void)setMenuButtonData:(MenuButtonData*)data;

@end
