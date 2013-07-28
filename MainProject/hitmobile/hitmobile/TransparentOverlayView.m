//
//  TransparentOverlayView.m
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-20.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import "TransparentOverlayView.h"
#import "AppDelegate.h"

@implementation TransparentOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)handleTapGestureRecognizer:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate toggleRightView];
    }
}

@end
