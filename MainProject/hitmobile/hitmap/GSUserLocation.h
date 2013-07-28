//
//  GSUserLocation.h
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-3.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GSAnnotation.h"

@interface GSUserLocation  : NSObject <GSAnnotation> {
    CGPoint _coordinate;
    
    CGFloat _radius;
    
    CLLocation *_location;
    
    BOOL _updating;
}

@property (nonatomic, assign) CGPoint coordinate;
@property (nonatomic, assign) CGFloat radius;

// TODO:location and updating in MapKit are readonly
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) BOOL updating;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
