//
//  GSLocateAnnotationView.m
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-11.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import "GSLocateAnnotationView.h"
#import "GSUserLocation.h"


@implementation GSLocateAnnotationView

@dynamic radius;

+ (Class)layerClass {
	return [CALayer class];
}

#pragma mark - Custom Setter & Getter

- (CGFloat)radius {
    return _radius;
}

- (void)setRadius:(CGFloat)radius {
    // TODO: there is no animation now possibly because the view was not added to the superview yet. Maybe set an _oldRadius and _newRadius to solve the problem
    /*CGFloat scale = 129.0f / 76.0f;
    CGPathRef oldPath = CGPathCreateWithEllipseInRect(CGRectMake(-_radius * scale / 2, -_radius / 2, _radius * scale, _radius), NULL);
    
    _radius = radius;
    
    CGPathRef newPath = CGPathCreateWithEllipseInRect(CGRectMake(-_radius * scale / 2, -_radius / 2, _radius * scale, _radius), NULL);
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.fromValue = (id)oldPath;
    anim.toValue = (id)newPath;
    
    anim.duration = 3;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            [layer addAnimation:anim forKey:@"anim"];
            [(CAShapeLayer *)layer setPath:newPath];
        }
    }*/
    
    CGFloat scale = 129.0f / 76.0f;
    _radius = radius;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-_radius * scale / 2, -_radius / 2, _radius * scale, _radius)];
    CGPathRef newPath = [bezierPath CGPath];
    //CGPathRef newPath = CGPathCreateWithEllipseInRect(CGRectMake(-_radius * scale / 2, -_radius / 2, _radius * scale, _radius), NULL);
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            [(CAShapeLayer *)layer setPath:newPath];
        }
    }
    
    //CGPathRelease(newPath);
}


- (id)initWithAnnotation:(GSUserLocation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        _radius = 0;
        
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat scale = 129.0f / 76.0f;
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-_radius * scale / 2, -_radius / 2, _radius * scale, _radius)];
        CGPathRef path = [bezierPath CGPath];
        //CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(-_radius * scale / 2, -_radius / 2, _radius * scale, _radius), NULL);
        
        CGPoint centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        CGRect shape_bounds =CGPathGetBoundingBox(path);
        
        // sublayer at index 0
        // the circle filled with alpha blue
        CAShapeLayer *circleFillLayer = [CAShapeLayer layer];
        CGColorRef circleFillColor = CGColorCreateCopyWithAlpha([UIColor blueColor].CGColor, 0.3);
        circleFillLayer.fillColor = circleFillColor;
        CGColorRelease(circleFillColor);
        circleFillLayer.position = centerPoint;
        circleFillLayer.bounds = shape_bounds;
        circleFillLayer.path = path;
        [self.layer addSublayer:circleFillLayer];
        
        // sublayer at index 1
        // the circle stroke with alpha blue
        CAShapeLayer *circleStrokeLayer = [CAShapeLayer layer];
        CGColorRef circleStrokeColor = CGColorCreateCopyWithAlpha([UIColor whiteColor].CGColor, 0.5);
        circleStrokeLayer.strokeColor = circleStrokeColor;
        CGColorRelease(circleStrokeColor);
        circleStrokeLayer.lineWidth = 2.0;
        circleStrokeLayer.fillColor= [UIColor clearColor].CGColor;
        circleStrokeLayer.position = centerPoint;
        circleStrokeLayer.bounds = shape_bounds;
        circleStrokeLayer.path = path;
        [self.layer addSublayer:circleStrokeLayer];
        
        //CGPathRelease(path);
        
        // sublayer at index 2
        // the blue dot image
        UIImage *image = [UIImage imageNamed:@"MapBlip.png"];
        CALayer *blipImageLayer = [CALayer layer];
        blipImageLayer.contents = (id)image.CGImage;
        blipImageLayer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        blipImageLayer.position = centerPoint;
        CATransform3D transform = CATransform3DConcat(CATransform3DMakeScale(1.5, 1.5, 1), CATransform3DMakeRotation(1.1440 * M_PI, 1.207627, 2.351695, 1.207627));
        //blipImageLayer.affineTransform = CGAffineTransformMakeScale(1.5, 1.5);
        //blipImageLayer.transform = CATransform3DMakeRotation(1.1440 * M_PI, 1.207627, 2.351695, 1.207627);
        blipImageLayer.transform = transform;
        blipImageLayer.zPosition = 200;
        [self.layer addSublayer:blipImageLayer];
        
        //self.layer.zPosition = 0;
        //self.layer.transform = CATransform3DMakeRotation(0.9067 * M_PI, 0.233051, 0.5723034, -0.317);
        
        // FIXME:test code below
        //[self setBackgroundColor:[UIColor yellowColor]];
        //annotation.title = @"当前位置";
        
        //_radius = annotation.radius;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor greenColor] set];
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokeRect(context, self.bounds);
}*/

- (UIImage *)image {
    if (_image == nil) {
        
        //_image = [[UIImage imageNamed:@"MapBlip.png"] retain];
        // create a blank image for the GSAnnotationView
        UIGraphicsBeginImageContext(CGSizeMake(23.0f, 23.0f));
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _image = [[UIImage alloc] initWithCGImage:image.CGImage];
        _centerOffset.x = 0;
        _centerOffset.y = 0;
        _calloutOffset.x = 0;
        _calloutOffset.y = -5;
    }
    return _image;
}

#pragma mark - Code for Testing

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    //[self testAnimation];
}

/*- (void)testAnimation {
    CGFloat scale = 129.0f / 76.0f;
    CGPathRef path0 = CGPathCreateWithEllipseInRect(CGRectMake(-_radius * scale / 4 / 2, -_radius / 4 / 2, _radius * scale / 4, _radius / 4), NULL);
    CGPathRef path2 = CGPathCreateWithEllipseInRect(CGRectMake(-_radius * scale * 2 / 2, -_radius * 2 / 2, _radius * scale * 2, _radius * 2), NULL);
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.fromValue = (id)path0;
    anim.toValue = (id)path2;
    
    anim.duration = 3;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VAL;

    //[self.layer.sublayers performSelector:@selector(addAnimation:forKey:) withObject:anim withObject:@"anim"];
    
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            [layer addAnimation:anim forKey:@"anim"];
        }
    }
    
    CGPathRelease(path0);
    CGPathRelease(path2);
    
}*/


@end
