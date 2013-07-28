//
//  HITPlaceAnnotationView.m
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-13.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import "HITPlaceAnnotationView.h"

@implementation HITPlaceAnnotationView

- (UIImage *)image {
    if (_image == nil) {
        _image = [UIImage imageNamed:@"map-pin.png"];
        _centerOffset.x = 0;
        _centerOffset.y = 51 / 2;
        _calloutOffset.x = 0;
        _calloutOffset.y = -51 / 2;
    }
    return _image;
}

@end
