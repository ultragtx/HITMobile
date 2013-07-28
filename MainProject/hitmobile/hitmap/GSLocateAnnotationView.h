//
//  GSLocateAnnotationView.h
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-11.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

@interface GSLocateAnnotationView : GSAnnotationView {
    CGFloat _radius;
    
}

@property (nonatomic, assign) CGFloat radius;


@end
