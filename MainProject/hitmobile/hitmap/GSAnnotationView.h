//
//  MapAnnotationView.h
//  hitmobile
//
//  Created by 鑫容 郭 on 12-1-19.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSAnnotation.h"
@class GSAnnotationCalloutView;

@interface GSAnnotationView : UIView {
    UIButton *_annotationButton;
    
    UIImage *_image;
    
    NSString *_reuseIdentifier;
    
    id<GSAnnotation> _annotation;
    
    CGPoint _centerOffset;
    
    CGPoint _calloutOffset;
    
    BOOL _enabled;
    
    BOOL _selected;
    
    BOOL _canShowCallout;
    
    UIView *_leftCalloutAccessoryView;
    UIView *_rightCalloutAccessoryView;
    
    //@private
    GSAnnotationCalloutView *_calloutView;
    
}

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, readonly) NSString *reuseIdentifier;

@property (nonatomic, strong) id<GSAnnotation> annotation;

@property (nonatomic, assign) CGPoint centerOffset;
@property (nonatomic, assign) CGPoint calloutOffset;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL canShowCallout;

@property (nonatomic, strong) UIView *leftCalloutAccessoryView;
@property (nonatomic, strong) UIView *rightCalloutAccessoryView;

@property (nonatomic, readonly) GSAnnotationCalloutView *calloutView;

- (id)initWithAnnotation:(id<GSAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end
