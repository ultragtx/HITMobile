//
//  MapAnnotationView.m
//  hitmobile
//
//  Created by 鑫容 郭 on 12-1-19.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import "GSAnnotationView.h"
#import "GSAnnotationCalloutView.h"
#import "GSMapView.h"

@implementation GSAnnotationView

@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize annotation = _annotation;
@synthesize centerOffset = _centerOffset;
@synthesize calloutOffset = _calloutOffset;
@synthesize enabled = _enabled;
@synthesize selected = _selected;
@synthesize canShowCallout = _canShowCallout;

@synthesize leftCalloutAccessoryView = _leftCalloutAccessoryView;
@synthesize rightCalloutAccessoryView = _rightCalloutAccessoryView;

@synthesize image = _image;

@synthesize calloutView = _calloutView;


- (id)initWithAnnotation:(id<GSAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _canShowCallout = YES; // Default to no
        _selected = NO;
        
        self.annotation = annotation;
        //_reuseIdentifier = [[NSString alloc] initWithString:(reuseIdentifier == nil) ? @"" : reuseIdentifier];
        _reuseIdentifier = reuseIdentifier;
        
        UIImage *buttonImage = self.image;
        
        _annotationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
        [_annotationButton setImage:buttonImage forState:UIControlStateNormal];
        [_annotationButton setAdjustsImageWhenHighlighted:YES];// TODO set to NO later
        
        [self addSubview:_annotationButton];
        
        [self setFrame:CGRectMake(0, 0, _annotationButton.frame.size.width, _annotationButton.frame.size.height)];
        
        
        [_annotationButton addTarget:self action:@selector(annotationTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        // FIXME:TEST code below
        //[self setBackgroundColor:[UIColor yellowColor]];
    }
    return self;
}

- (void)removeFromSuperview {
    [_calloutView removeFromSuperview];
    _selected = NO;
    [super removeFromSuperview];
}

#pragma mark - Setter and Getter

- (UIImage *)image {
    if (_image == nil) {
        _image = [UIImage imageNamed:@"MapPin.png"];
        _centerOffset.x = 0;
        _centerOffset.y = 25;
        _calloutOffset.x = 0;
        _calloutOffset.y = -12;
    }
    return _image;
}

#pragma mark - annotation TouchUpInside

- (void)annotationTouchUpInside:(id)sender {
    if (_canShowCallout ) {
        if (_calloutView == nil) {
            _calloutView = [[GSAnnotationCalloutView alloc] initWithParentAnnotationView:self];
        }
        if (_selected) {
            [_calloutView removeFromSuperview];
            _selected = NO;
        }
        else {
            [self.superview addSubview:_calloutView];
            _selected = YES;
        }
        
    }
    if ([[self superview] isKindOfClass:[GSMapView class]] && [[self superview] respondsToSelector:@selector(annotationViewTouchUpInside:)]) {
        
        [[self superview] performSelector:@selector(annotationViewTouchUpInside:) withObject:self];   
    }
}

#pragma mark - Test code Below


@end
