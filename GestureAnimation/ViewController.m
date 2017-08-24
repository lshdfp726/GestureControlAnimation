//
//  ViewController.m
//  GestureAnimation
//
//  Created by fns on 2017/8/24.
//  Copyright © 2017年 lsh726. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *doorImageView;
@property (nonatomic, strong) CALayer *doorLayer;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self  createDoorAnimation];
}


- (void)createDoorAnimation {
    
    self.doorLayer = [CALayer layer];
    self.doorLayer.frame = self.containerView.bounds;
    self.doorLayer.position = CGPointMake(self.doorLayer.position.x - 256/4, self.doorLayer.position.y);
    self.doorLayer.anchorPoint = CGPointMake(0, 0.5);
    self.doorLayer.contents = (__bridge id)[UIImage imageNamed:@"door.jpeg"].CGImage;
    [self.containerView.layer addSublayer:self.doorLayer];
    //apply perspective transform
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 500.0;
    self.containerView.layer.sublayerTransform = perspective;
    //add pan gesture recognizer to handle swipes
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(panGestureRecognizer:)];
    [self.view addGestureRecognizer:pan];
    //pause all layer animations
    self.doorLayer.speed = 0.0;
    //apply swinging animation (which won't play because layer is paused)
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation.y";
    animation.toValue = @(-M_PI_2);
    animation.duration = 1.0;
    [self.doorLayer addAnimation:animation forKey:nil];
}


- (void)panGestureRecognizer:(UIPanGestureRecognizer *)reg {
    CGFloat x = [reg translationInView:self.view].x;//理解为获取手指平移的程度（拖拽的力度）
    x /=200.0f;
    NSLog(@"translationInView==%f",x);
    CFTimeInterval timeOffset = self.doorLayer.timeOffset;
    NSLog(@"视图的动画时间偏移量%f",timeOffset);
    timeOffset = MIN(0.999, MAX(0.0, timeOffset - x));
    
    self.doorLayer.timeOffset = timeOffset;
    [reg setTranslation:CGPointZero inView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
