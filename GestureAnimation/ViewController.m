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
    
    self.doorLayer.speed = 0.0;//设置为零 表示禁止动画自动播放
    //apply swinging animation (which won't play because layer is paused)
    
    [self createDoorAnimation:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createDoorAnimation:) name:UIApplicationWillEnterForegroundNotification object:nil];
}


- (void)createDoorAnimation:(NSNotification *)noti {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation.y";
    animation.toValue = @(-M_PI_2);
    animation.duration = 1.0;
    [self.doorLayer addAnimation:animation forKey:nil];
    if (noti) {
        /**程序从前台切换到后台之后，视图控制器上的所有视图的layer 层动画都被系统自动remove掉了，所以监听系统从后台进入前台时 在加一遍动画，但是此时layer层其实还是上次的，有关动画参数的值其实没变
         就需要进行相应的reset 重新设置
         */
        self.doorLayer.timeOffset = 0.0;
    }
}


- (void)panGestureRecognizer:(UIPanGestureRecognizer *)reg {
 
    CGFloat x = [reg translationInView:self.view].x;//理解为获取手指平移的程度（拖拽的力度）
    x /=200.0f;
    NSLog(@"translationInView==%f",x);
    CFTimeInterval timeOffset = self.doorLayer.timeOffset;//利用前后平移程度值差值来调整动画便宜时间！
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
