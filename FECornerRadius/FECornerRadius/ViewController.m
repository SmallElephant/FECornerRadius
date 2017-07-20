//
//  ViewController.m
//  FECornerRadius
//
//  Created by keso on 2017/7/20.
//  Copyright © 2017年 FlyElephant. All rights reserved.
//

#import "ViewController.h"

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight)
{
    float fw, fh;
    
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;


@property (weak, nonatomic) IBOutlet UIImageView *bottomImgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clipAction:(UIButton *)sender {
    [self setupCornerRadius1];
//    [self setupCornerRadius2];
//    [self setupCornerRadius3];
//    [self setupCornerRadius4];
//    [self setupCornerRadius5];
}

- (void)setupCornerRadius1 {
    self.bottomImgView.image = [UIImage imageNamed:@"girl.jpg"];
    self.bottomImgView.layer.cornerRadius = 50;
    self.bottomImgView.layer.masksToBounds = YES;
}

- (void)setupCornerRadius2 {
    self.bottomImgView.image = [UIImage imageNamed:@"girl.jpg"];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bottomImgView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:self.bottomImgView.bounds.size];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    //设置大小
    maskLayer.frame = self.bottomImgView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.bottomImgView.layer.mask = maskLayer;
}

- (void)setupCornerRadius3 { // 贝塞尔绘制圆角
    self.bottomImgView.image = [UIImage imageNamed:@"girl.jpg"];
    //开始对imageView进行画图
    UIGraphicsBeginImageContextWithOptions(self.bottomImgView.bounds.size, NO, [UIScreen mainScreen].scale);
    //使用贝塞尔曲线画出一个圆形图
    [[UIBezierPath bezierPathWithRoundedRect:self.bottomImgView.bounds cornerRadius:self.bottomImgView.frame.size.width] addClip];
    [self.bottomImgView drawRect:self.bottomImgView.bounds];
    
    self.bottomImgView.image = UIGraphicsGetImageFromCurrentImageContext();
    //结束画图
    UIGraphicsEndImageContext();
}

- (void)setupCornerRadius4 { // Core Graphics 绘图
    
    int width = self.bottomImgView.frame.size.width * 2;
    int height = self.bottomImgView.frame.size.height * 2;
    int radius = width / 2;
    
    UIImage *img = [UIImage imageNamed:@"girl.jpg"];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, radius, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    
    self.bottomImgView.image = img;
    
//    self.bottomImgView.image = [self CGContextClip:[UIImage imageNamed:@"girl.jpg"] cornerRadius:50];
    
//    self.bottomImgView.image = [self createRoundedRectImage:[UIImage imageNamed:@"girl.jpg"] size:CGSizeMake(100, 100) radius:50];
}

- (UIImage *)createRoundedRectImage:(UIImage *)image size:(CGSize)size radius:(int)radius{
    
    size = CGSizeMake(size.width*2, size.height*2);
    radius = radius*2;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 4 * size.width, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, radius, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    return img;
}

// CGContext 裁剪
- (UIImage *)CGContextClip:(UIImage *)img cornerRadius:(CGFloat)c {
    int w = img.size.width * img.scale;
    int h = img.size.height * img.scale;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), false, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, c);
    CGContextAddArcToPoint(context, 0, 0, c, 0, c);
    CGContextAddLineToPoint(context, w-c, 0);
    CGContextAddArcToPoint(context, w, 0, w, c, c);
    CGContextAddLineToPoint(context, w, h-c);
    CGContextAddArcToPoint(context, w, h, w-c, h, c);
    CGContextAddLineToPoint(context, c, h);
    CGContextAddArcToPoint(context, 0, h, 0, h-c, c);
    CGContextAddLineToPoint(context, 0, c);
    CGContextClosePath(context);
    
    CGContextClip(context);     // 先裁剪 context，再画图，就会在裁剪后的 path 中画
    [img drawInRect:CGRectMake(0, 0, w, h)];       // 画图
    CGContextDrawPath(context, kCGPathFill);
    
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ret;
}

- (void)setupCornerRadius5 {
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.bottomImgView.bounds];
    bgImgView.image = [UIImage imageNamed:@"circle_bg"];
    [self.bottomImgView addSubview:bgImgView];
    
    self.bottomImgView.image = [UIImage imageNamed:@"girl.jpg"];
    
}

@end
