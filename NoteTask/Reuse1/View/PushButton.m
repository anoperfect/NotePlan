//
//  PushButton.m
//  Reuse0
//
//  Created by Ben on 16/3/31.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "PushButton.h"
#import "UIpConfig.h"





@implementation PushButtonData


@end







@implementation PushButton




- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showsTouchWhenHighlighted = YES;
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsTouchWhenHighlighted = YES;
    }
    return self;
}


- (void)setActionData:(PushButtonData*)data
{
    _actionData = data;
#if 0
    //[self setTitle:@"收藏" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
    
    //[self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, widthButton - heightButton)];
    //[self setTitleEdgeInsets:UIEdgeInsetsMake(0, heightButton, 0, 0)];
    
    CGRect frame = button.imageView.frame;
    LOG_RECT(frame, @"button-image");
    frame = button.titleLabel.frame;
    LOG_RECT(frame, @"button-title");
#endif
}


#if 0
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat btnCornerRedius = 1;
    CGFloat titleW = contentRect.size.width - btnCornerRedius;
    CGFloat titleH = self.frame.size.height;
    CGFloat titleX = self.frame.size.height + btnCornerRedius;
    CGFloat titleY = 0;
    contentRect = (CGRect){{titleX,titleY},{titleW,titleH}};
    return contentRect;
    
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
//    CGFloat btnCornerRedius = 1;
    CGFloat imageW = self.frame.size.height -10;
    CGFloat imageH = self.frame.size.height -10;
    CGFloat imageX = 5;
    CGFloat imageY = 5;
    contentRect = (CGRect){{imageX,imageY},{imageW,imageH}};
    return contentRect;
    
}
#endif



//- (CGRect)titleRectForContentRect:(CGRect)contentRect
//{
//    return contentRect;
//
//    
//}
//
//- (CGRect)imageRectForContentRect:(CGRect)contentRect
//{
////    return UIEdgeInsetsInsetRect(contentRect, UIEdgeInsetsMake(6, 6, 6, 6));
////    return contentRect;
//    return CGRectMake(0, 0, 0, 0);
//
//}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end






























































@implementation ViewContainer





- (void)horizonLayoutViews:(NSArray<UIView *> *)subviews
                      edge:(UIEdgeInsets)edge
               subViewEdge:(UIEdgeInsets)subviewEdge
{
    
    
    
    
}



- (void)verticalLayoutViews:(NSArray<UIView*>*) subviews
                       edge:(UIEdgeInsets)edge
                subViewEdge:(UIEdgeInsets)subviewEdge
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    height += edge.top;
    
    CGFloat xSubview = 0.0;
    CGFloat ySubview = 0.0;
    CGFloat ySubviewSum = edge.top;
    
    for(UIView *view in subviews) {
        width = MAX(view.bounds.size.width + subviewEdge.left + subviewEdge.right + edge.left + edge.right, width);
        height += subviewEdge.top + subviewEdge.bottom + view.bounds.size.height;
        
        xSubview = edge.left + subviewEdge.left;
        ySubview = ySubviewSum + subviewEdge.top;
        ySubviewSum += subviewEdge.top + subviewEdge.bottom + view.bounds.size.height;
        
        view.frame = CGRectMake(xSubview, ySubview, view.bounds.size.width, view.bounds.size.height);
        [self addSubview:view];
    }
    
    height += edge.bottom;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
}


#if 0
- (void)drawRect:(CGRect)rect
{

    NSLog(@"---drawRect");
    
#if 0
    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path addArcWithCenter:CGPointMake(20, 20) radius:10.0 startAngle:0.0 endAngle:M_PI*1 clockwise:YES];
    [path addArcWithCenter:CGPointMake(20, 20) radius:10.0 startAngle:M_PI endAngle:M_PI * 1.5 clockwise:YES];
    [[UIColor blueColor] setStroke];
    [[UIColor whiteColor] setFill];
    [path stroke];
    [path fill];
    
#else
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UIEdgeInsets edge = UIEdgeInsetsMake(2, 2, 2, 4);
    CGFloat heightForArrow = 6;
    CGFloat widthToArrow = 0.8;
    CGFloat arrowWidthPercentage = 0.6;
    CGFloat cornerRadius = 6.0;
    
    //创建path
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //左圆角
    [path addArcWithCenter:CGPointMake(edge.left + cornerRadius, edge.top + heightForArrow + cornerRadius) radius:cornerRadius startAngle:M_PI endAngle:M_PI*1.5 clockwise:YES];

    //上边左点.
    //[path moveToPoint:   CGPointMake(edge.left+cornerRadius, edge.top + heightForArrow)];
    
    //箭头左点.
    [path addLineToPoint:CGPointMake((width - edge.left - edge.right) * widthToArrow, edge.top + heightForArrow)];
    
    //箭头顶点.
    [path addLineToPoint:CGPointMake((width - edge.left - edge.right) * widthToArrow + arrowWidthPercentage * heightForArrow, edge.top)];
    
    //箭头右点.
    [path addLineToPoint:CGPointMake((width - edge.left - edge.right) * widthToArrow + arrowWidthPercentage * heightForArrow * 2, edge.top + heightForArrow)];
    
    //上边右点.
    [path addLineToPoint:CGPointMake((width - edge.right - cornerRadius), edge.top + heightForArrow)];
    
    //右圆角.
    [path addArcWithCenter:CGPointMake((width - edge.right - cornerRadius), edge.top + heightForArrow + cornerRadius) radius:cornerRadius startAngle:M_PI * 1.5 endAngle:M_PI*2 clockwise:YES];
    
    
    //右边下.
    [path addLineToPoint:CGPointMake((width - edge.right), height - edge.bottom - cornerRadius)];
    
    //右下圆角
    [path addArcWithCenter:CGPointMake((width - edge.right - cornerRadius), height - edge.bottom - cornerRadius) radius:cornerRadius startAngle:0 endAngle:M_PI*0.5 clockwise:YES];
    
    //下边左.
    [path addLineToPoint:CGPointMake(edge.left+cornerRadius, height - edge.bottom)];
    
    //左下圆角.
    [path addArcWithCenter:CGPointMake(edge.left+cornerRadius, height - edge.bottom - cornerRadius) radius:cornerRadius startAngle:M_PI*0.5 endAngle:M_PI clockwise:YES];
    
    //左边.
    [path addLineToPoint:CGPointMake(edge.left, edge.top + heightForArrow + cornerRadius)];

    
    // 设置描边宽度（为了让描边看上去更清楚）
    [path setLineWidth:1.0];
    //设置颜色（颜色设置也可以放在最上面，只要在绘制前都可以）
    [[UIColor blueColor] setStroke];
    [[UIColor whiteColor] setFill];
    // 描边和填充
    [path stroke];
    [path fill];
#endif
}
#endif




@end




@implementation UIButton (UIButtonImageWithLable)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title titleFont:(UIFont*)font forState:(UIControlState)stateType {
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
    CGSize titleSize ;
    NSAttributedString * s = [NSString attributedStringWith:title font:font indent:0 textColor:nil];
    
    NSRange range = NSMakeRange(0, title.length);
    titleSize = [title sizeWithAttributes:[s attributesAtIndex:0 effectiveRange:&range]];
    [self.imageView setContentMode:UIViewContentModeCenter];
//    [self setImageEdgeInsets:UIEdgeInsetsMake(-8.0,
//                                              0.0,
//                                              0.0,
//                                              -titleSize.width)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:font];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(30.0,
                                              -20,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
}

@end





