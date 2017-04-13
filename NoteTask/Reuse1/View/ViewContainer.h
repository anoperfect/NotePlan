//
//  ViewContainer.h
//  Reuse0
//
//  Created by Ben on 16/3/31.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>






@interface ViewContainer : UIView

- (void)horizonLayoutViews:(NSArray<UIView*>*) subviews
                      edge:(UIEdgeInsets)edge
               subViewEdge:(UIEdgeInsets)subviewEdge;

- (void)verticalLayoutViews:(NSArray<UIView*>*) subviews
                       edge:(UIEdgeInsets)edge
                subViewEdge:(UIEdgeInsets)subviewEdge;



@end
