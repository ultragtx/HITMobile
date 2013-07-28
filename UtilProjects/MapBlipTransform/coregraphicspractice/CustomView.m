//
//  CustomView.m
//  coregraphicspractice
//
//  Created by 鑫容 郭 on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CustomView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomView


CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHeight);

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        /*self.backgroundColor = [UIColor clearColor];
        
        CGPathRef path0 = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, 100, 100), NULL);
        CGPathRef path2 = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, 50, 50), NULL);
        CGPathRef path3 = CGPathCreateWithEllipseInRect(CGRectMake(-50, -50, 100, 100), NULL);
        
        CGPoint centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        //CGRect shape_bounds = CGRectUnion(CGPathGetBoundingBox(path0), CGPathGetBoundingBox(path2));
        CGRect shape_bounds = CGRectMake(-25, -25, 50, 50);
        
        CAShapeLayer *sublayer = [CAShapeLayer layer];
        //sublayer.fillColor = [UIColor blueColor].CGColor;
        sublayer.fillColor = CGColorCreateCopyWithAlpha([UIColor blueColor].CGColor, 0.3);
        sublayer.position = centerPoint;
        sublayer.bounds = shape_bounds;
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
        anim.fromValue = (id)path0;
        anim.toValue = (id)path2;
        
        anim.duration = 3;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VAL;
        
        //[sublayer addAnimation:anim forKey:nil];
        sublayer.path = path3;
        [self.layer addSublayer:sublayer];
        
        CAShapeLayer *sublayer2 = [CAShapeLayer layer];
        sublayer2.strokeColor = CGColorCreateCopyWithAlpha([UIColor blueColor].CGColor, 0.5);
        sublayer2.lineWidth = 2.0;
        sublayer2.fillColor= [UIColor clearColor].CGColor;
        sublayer2.position = centerPoint;
        sublayer2.bounds = shape_bounds;
        //[sublayer2 addAnimation:anim forKey:nil];
        sublayer2.path = path3;
        [self.layer addSublayer:sublayer2];
        
        
        UIImage *image = [UIImage imageNamed:@"MapBlip.png"];
        CALayer *sublayer3 = [CALayer layer];
        sublayer3.contents = (id)image.CGImage;
        sublayer3.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        sublayer3.position = centerPoint;
        [self.layer addSublayer:sublayer3];*/
        
        
        //self.layer.zPosition = 100;
        //self.layer.transform = CATransform3DMakeRotation(1.2, -1, -1, 0);
        
        CGFloat _radius = 120;
        
        self.backgroundColor = [UIColor clearColor];
        
        CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(-_radius / 2, -_radius / 2, _radius, _radius), NULL);
        
        CGPoint centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        CGRect shape_bounds =CGPathGetBoundingBox(path);
        
        // sublayer at index 0
        // the circle filled with alpha blue
        CAShapeLayer *circleFillLayer = [CAShapeLayer layer];
        circleFillLayer.fillColor = CGColorCreateCopyWithAlpha([UIColor blueColor].CGColor, 0.3);
        circleFillLayer.position = centerPoint;
        circleFillLayer.bounds = shape_bounds;
        
        circleFillLayer.path = path;
        [self.layer addSublayer:circleFillLayer];
        
        // sublayer at index 1
        // the circle stroke with alpha blue
        CAShapeLayer *circleStrokeLayer = [CAShapeLayer layer];
        circleStrokeLayer.strokeColor = CGColorCreateCopyWithAlpha([UIColor blueColor].CGColor, 0.5);
        circleStrokeLayer.lineWidth = 2.0;
        circleStrokeLayer.fillColor= [UIColor clearColor].CGColor;
        circleStrokeLayer.position = centerPoint;
        circleStrokeLayer.bounds = shape_bounds;
        circleStrokeLayer.path = path;
        [self.layer addSublayer:circleStrokeLayer];
        
        // sublayer at index 2
        // the blue dot image
        UIImage *image = [UIImage imageNamed:@"MapBlip.png"];
        CALayer *blipImageLayer = [CALayer layer];
        blipImageLayer.contents = (id)image.CGImage;
        blipImageLayer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        blipImageLayer.position = centerPoint;
        [self.layer addSublayer:blipImageLayer];
        
        self.layer.zPosition = 1000;
        //self.layer.transform = CATransform3DMakeRotation(0.9067 * M_PI, 0.233051, 0.5723034, -0.317);
        

        
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    
    /*CGContextSetRGBFillColor(myContext, 1, 0, 0, 1);
    CGContextFillRect(myContext, CGRectMake(0, 0, 100, 50));
    CGContextSetRGBFillColor(myContext, 0, 0, 1, .5);
    CGContextFillRect(myContext, CGRectMake(0, 0, 50, 100));*/
    
    [[UIColor greenColor] set];
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0);
    CGContextStrokeRect(UIGraphicsGetCurrentContext(), self.bounds);
}

- (void)make3DRotationAngle:(CGFloat) angle x:(CGFloat) x y:(CGFloat) y z:(CGFloat) z {
    self.layer.transform = CATransform3DMakeRotation(angle, x, y, z);
}


- (void)treedrorateX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z {
    struct CATransform3D a = {1, 0 ,0, 0, 0, cos(x), sin(x), 0, 0, -sin(x), cos(x), 0, 0, 0, 0, 1};
    struct CATransform3D c = {cos(y), 0, -sin(y), 0, 0, 1, 0, 0, sin(y), 0, cos(y), 0, 0, 0, 0, 1};
    struct CATransform3D b = {cos(z), sin(z), 0, 0, -sin(z), cos(z), 0, 0, 0, 0, 1, 0, 0, 0 ,0 ,1};
    
    struct CATransform3D temp = CATransform3DConcat(a, b);
    struct CATransform3D result = CATransform3DConcat(temp, c);
    
    self.layer.transform = result;
    
}


@end
