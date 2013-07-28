//
//  CallOutView.m
//  hitmobile
//
//  Created by 鑫容 郭 on 12-1-22.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import "GSAnnotationCalloutView.h"
#import "GSAnnotationView.h"
#import "GSAnnotationCalloutContentView.h"
#import <QuartzCore/QuartzCore.h>

#define SIDE_WIDTH 12.0f
#define SIDE_HEIGHT 52.0f
#define SIDE_SHADOW_HEIGHT 9.0f
#define MIDDLE_WIDTH 1.0f
#define MIDDLE_HEIGHT 52.0f
#define ARROW_WIDTH 33.0f
#define ARROW_HEIGHT 64.0f
#define ARROW_SHADOW_HEIGHT 5.0f

#define CONTENT_INSECT_X 12.0f
#define CONTENT_INSECT_Y 3.0f

#define CALLOUT_MIN_WIDTH 57.0f

@interface GSAnnotationCalloutView ()

@property (nonatomic, strong) UIImageView *leftSide, *rightSide, *middleLeft, *middleRight, *middleArrow;

@end


@implementation GSAnnotationCalloutView

@synthesize leftSide, rightSide, middleLeft, middleRight, middleArrow;

@synthesize parenAnnotationView = _parenAnnotationView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithParentAnnotationView:(GSAnnotationView *)parenAnnotationView {
    
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _contentView = [[GSAnnotationCalloutContentView alloc] initWithTitle:[parenAnnotationView.annotation title] subTitle:[parenAnnotationView.annotation subtitle] leftCalloutAccessoryView:[parenAnnotationView leftCalloutAccessoryView] rightCalloutAccessoryView:[parenAnnotationView rightCalloutAccessoryView]];
        
        _parenAnnotationView = parenAnnotationView;
        
        [self addSubview:_contentView];
        
        //[self setBackgroundColor:[UIColor yellowColor]];
    }
    return self;
}

- (CATransform3D)layerTransformForScale:(CGFloat)scale targetFrame:(CGRect)targetFrame {
	/*CGFloat horizontalDelta = ARROW_WIDTH / 2;
	CGFloat hotizontalScaleTransform = (horizontalDelta * scale) - horizontalDelta;
	
	CGFloat verticalDelta = roundf(targetFrame.size.height/2);
	CGFloat verticalScaleTransform = verticalDelta - (verticalDelta * scale);*/
	
	//CGAffineTransform affineTransform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, hotizontalScaleTransform, verticalScaleTransform);
    CGAffineTransform affineTransform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, 0, 0);

	return CATransform3DMakeAffineTransform(affineTransform);
}

- (void)resetFrame {
    [_contentView setTitle:_parenAnnotationView.annotation.title];
    [_contentView setSubtitle:_parenAnnotationView.annotation.subtitle];
    
    _contentSize = [_contentView calculateContentSize];
    
    _calloutWidth = _contentSize.width + CONTENT_INSECT_X * 2;
    
    _calloutWidth = _calloutWidth > CALLOUT_MIN_WIDTH ? _calloutWidth : CALLOUT_MIN_WIDTH;
    CGPoint calloutOrigin = CGPointMake(_parenAnnotationView.center.x + _parenAnnotationView.calloutOffset.x - _calloutWidth / 2, _parenAnnotationView.center.y + _parenAnnotationView.calloutOffset.y - ARROW_HEIGHT + ARROW_SHADOW_HEIGHT);
    
    self.frame = CGRectMake(calloutOrigin.x, calloutOrigin.y, _calloutWidth, SIDE_HEIGHT - SIDE_SHADOW_HEIGHT);
}

- (void)didMoveToSuperview {

    [self resetFrame];
    
    CGRect targetFrame = self.bounds;
    self.layer.transform = [self layerTransformForScale:0.001f targetFrame:targetFrame];
    [UIView animateWithDuration:0.1 
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionLayoutSubviews
					 animations:^{
                         //NSLog(@"animation1");
						 self.layer.transform = [self layerTransformForScale:1.1f targetFrame:targetFrame];
					 } 
					 completion:^ (BOOL finished) {
                         //NSLog(@"animation finished1");
						 [UIView animateWithDuration:0.1
											   delay:0
											 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionLayoutSubviews
										  animations:^{
                                              //NSLog(@"animation2");
											  self.layer.transform = [self layerTransformForScale:0.95f targetFrame:targetFrame];
										  } 
										  completion:^ (BOOL finished) {
                                              //NSLog(@"animation finished2");
											  [UIView animateWithDuration:0.1
																	delay:0
																  options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionLayoutSubviews
															   animations:^{
                                                                   //NSLog(@"animation3");
																   self.layer.transform = [self layerTransformForScale:1.0f targetFrame:targetFrame];
															   } 
															   completion:^ (BOOL finished) {
                                                                   //NSLog(@"animation finished3");
																   self.layer.transform = CATransform3DIdentity;
															   }
											   ];
										  }];
					 }
	 ];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    //NSLog(@"calloutView layoutSubviews");
    
    CGRect leftSideRect = CGRectMake(0, 0, SIDE_WIDTH, SIDE_HEIGHT);
    
    _middleLeftWidth = (_calloutWidth - SIDE_WIDTH * 2 - ARROW_WIDTH) / 2;
    CGRect middleLeftRect = CGRectMake(SIDE_WIDTH, 0, _middleLeftWidth, MIDDLE_HEIGHT);
    
    CGRect middleArrowRect = CGRectMake(SIDE_WIDTH + _middleLeftWidth, 0, ARROW_WIDTH, ARROW_HEIGHT);
    
    _middleRightWidth = (_calloutWidth - SIDE_WIDTH * 2 - ARROW_WIDTH) / 2;
    CGRect middleRightRect = CGRectMake(SIDE_WIDTH + _middleLeftWidth + ARROW_WIDTH, 0, _middleRightWidth, MIDDLE_HEIGHT);
    
    CGRect rightSideRect = CGRectMake(SIDE_WIDTH + _middleLeftWidth + ARROW_WIDTH + _middleRightWidth, 0, SIDE_WIDTH, SIDE_HEIGHT);
    
    [self.leftSide setFrame:leftSideRect];
    [self.middleLeft setFrame:middleLeftRect];
    [self.middleArrow setFrame:middleArrowRect];
    [self.middleRight setFrame:middleRightRect];
    [self.rightSide setFrame:rightSideRect];
    
    _contentView.frame = CGRectMake(CONTENT_INSECT_X, CONTENT_INSECT_Y, _contentSize.width, _contentView.frame.size.height);

    //NSLog(@"calloutView frame:%@", NSStringFromCGRect(self.frame));

}

#pragma mark - Setters 

/*- (void)setParenAnnotationView:(GSAnnotationView *)parenAnnotationView {
    if (_parenAnnotationView == parenAnnotationView) {
        return;
    }
    
}*/

#pragma mark - Lazy Getters

- (UIImageView *)leftSide {
    if (leftSide == nil) {
        leftSide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapannotation_left.png"]];
        [self insertSubview:leftSide atIndex:0];
    }
    return leftSide;
}

- (UIImageView *)rightSide {
    if (rightSide == nil) {
        rightSide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapannotation_right.png"]];
        [self insertSubview:rightSide atIndex:0];

    }
    return rightSide;
}

- (UIImageView *)middleLeft {
    if (middleLeft == nil) {
        middleLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapannotation_middle.png"]];
        [self insertSubview:middleLeft atIndex:0];
    }
    return middleLeft;
}

- (UIImageView *)middleRight {
    if (middleRight == nil) {
        middleRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapannotation_middle.png"]];
        [self insertSubview:middleRight atIndex:0];
    }
    return middleRight;
}

- (UIImageView *)middleArrow {
    if (middleArrow == nil) {
        middleArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapannotation_arrow2.png"]];
        [self insertSubview:middleArrow atIndex:0];
    }
    return middleArrow;
}

@end
