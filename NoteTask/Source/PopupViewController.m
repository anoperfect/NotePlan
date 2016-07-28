//
//  PopupViewController.m
//  NoteTask
//
//  Created by Ben on 16/7/22.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "PopupViewController.h"

@interface PopupViewController ()

@end

@implementation PopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.view.backgroundColor = [UIColor colorFromString:@"#abcdee@60"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CALayer *layer = [CALayer layer];
    
    layer.contents = (__bridge id _Nullable)(self.imageBackground.CGImage);
    NSLog(@"%@", layer.contents);
    NSLog(@"%f, %f", self.imageBackground.size.width, self.imageBackground.size.height);
    //[self.view.layer addSublayer:layer];
    
    
    

    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.imageBackground];
    [self.view addSubview:imageView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    [self.view addSubview:blurView];

//    let blurEffect: UIBlurEffect = UIBlurEffect(style: .Light)
//    let blurView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
//    blurView.frame = CGRectMake(50.0, 50.0, self.view.frame.width - 100.0, 200.0)
//    self.view.addSubview(blurView)
    
    
    self.navigationController.navigationBarHidden = YES;
    
    
    
}


- (UIImage*)filterImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    //    CIImage *image = [CIImage imageWithContentsOfURL:imageURL];
    CIImage *image = [[CIImage alloc] initWithImage:self.imageBackground];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:@2.0f forKey: @"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage = [context createCGImage: result fromRect:[result extent]];
    UIImage * blurImage = [UIImage imageWithCGImage:outImage];
    
    return blurImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
