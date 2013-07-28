//
//  MapScrollView.h
//  hitmobile
//
//  Created by 鑫容 郭 on 11-12-21.
//  Copyright (c) 2011年 HIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GSAnnotation.h"
@class GSAnnotationView;
@class HITPlaceCollection;
@class GSAnnotationCalloutView;
@class GSUserLocation;
@class GSLocateAnnotationView;

@protocol GSMapViewDelegate;

@interface GSMapView : UIScrollView <UIScrollViewDelegate, CLLocationManagerDelegate> {
    // Map Properties
    BOOL _zoomEnabled;
    
    // Accessing the Delegate
    id<GSMapViewDelegate> __unsafe_unretained _mapViewDelegate;
    
    // Accessing the Devices's Current Location
    BOOL _showUserLocation;
    BOOL _userLocationVisible;
    GSUserLocation *_userLocation;
    
    // Annotating the Map
    NSMutableArray *_annotations;
    
    // Tracking the User Location
    
    
@private    
    UIView *_imageView;
    NSMutableDictionary *_annotationViews;
    NSMutableDictionary *_reuseableAnnotationViews;
    NSMutableSet *_visibleAnnotations;
    GSAnnotationView *_lastAnnotationShowCallout;
    
    CLLocationManager *_locationManager;
    
    GSLocateAnnotationView *_locateAnnotationView;
    
    // Test fields:
    
}

@property (nonatomic, assign) BOOL zoomEnabled;
@property (nonatomic, unsafe_unretained) id<GSMapViewDelegate> mapViewDelegate;

@property (nonatomic, assign) BOOL showUserLocation;
@property (nonatomic, assign) BOOL userLocationVisible;
@property (nonatomic, readonly) GSUserLocation *userLocation;

@property (nonatomic, readonly) NSArray *annotations;

- (void)addAnnotation:(id<GSAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)annotations;
- (void)removeAnnotation:(id<GSAnnotation>)annotation;
- (void)removeAnnotations:(NSArray *)annotations;
- (void)removeAllAnnotations;
- (GSAnnotationView *)viewForAnnotation:(id<GSAnnotation>)annotation;

- (GSAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier;

- (void)selectAnnotation:(id<GSAnnotation>)annotation animated:(BOOL)animated;
- (void)deselectAnnotation:(id<GSAnnotation>)annotation animated:(BOOL)animated;

- (void)displayTiledImageNamed:(NSString *)imageName size:(CGSize)imageSize;

@end

@protocol GSMapViewDelegate <NSObject>

@optional

// Managing Annotation Views

- (GSAnnotationView *)mapView:(GSMapView *)mapView viewForAnnotation:(id<GSAnnotation>)annotation;

- (void)mapView:(GSMapView *)mapView annotationView:(GSAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

- (void)mapView:(GSMapView *)mapView regionDidChangeAnimated:(BOOL)animated;

- (void)mapView:(GSMapView *)mapView didSelectAnnotationView:(GSAnnotationView *)view;
- (void)mapView:(GSMapView *)mapView didDeselectAnnotationView:(GSAnnotationView *)view;

- (void)mapViewWillStartLocatingUser:(GSMapView *)mapView;
- (void)mapViewDidStopLocatingUser:(GSMapView *)mapView;
- (void)mapView:(GSMapView *)mapView didUpdateUserLocation:(GSUserLocation *)userLocation;
- (void)mapView:(GSMapView *)mapView didFailToLocateUserWithError:(NSError *)error;


- (CGPoint)convertToCGPointFromCoordinate:(CLLocationCoordinate2D)coordinate;

- (CGFloat)convertToCGFloatFromAccuracy:(CLLocationAccuracy)accuracy;

@end
