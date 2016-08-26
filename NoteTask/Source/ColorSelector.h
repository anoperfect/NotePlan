//
//  ColorSelector.h
//  NoteTask
//
//  Created by Ben on 16/8/22.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorSelector : UIView




- (instancetype)initWithFrame:(CGRect)frame
                   cellHeight:(CGFloat)cellHeight
                 colorPresets:(NSArray<NSString*>*)presetColorStrings
                  isTextColor:(BOOL)isTextColor
                 selectHandle:(void(^)(NSString* selectedColorString, NSString *selectedColorText))handle;

@end
