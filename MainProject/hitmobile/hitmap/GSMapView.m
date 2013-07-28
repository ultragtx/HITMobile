//
//  MapScrollView.m
//  hitmobile
//
//  Created by 鑫容 郭 on 11-12-21.
//  Copyright (c) 2011年 HIT. All rights reserved.
//

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

#import "GSMapView.h"
#import "GSMapTilingView.h"
#import "GSAnnotationView.h"
#import "GSAnnotationCalloutView.h"
#import "GSUserLocation.h"
#import "GSLocateAnnotationView.h"

typedef enum {
    AnnotationSearchType_Insert, //will add to _annotations
    AnnotationSearchType_InsertPlace, // won't add to _annotations
    AnnotationSearchType_Equal
}AnnotationSearchType;

@interface GSMapView (Private)

- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)addReuseableAnntationView:(GSAnnotationView *)annotationView;
- (CGRect)adjustedVisibleBounds;
- (void)adjustAnnotationViewCenter:(GSAnnotationView *)annotationView;
- (void)displayAnnotation:(id)annotation;
- (NSString *)dicKeyFromAnnotation:(id<GSAnnotation>)annotation;
- (void)addCompareMethodToAnnotationClass:(id)annotation;

- (CGPoint)convertToCurrentZoomScaleFromCGPoint:(CGPoint)point;
- (CGPoint)contentOffsetForAnnotation:(id<GSAnnotation>)annotation;

- (void)removeLastCallout;

- (int)indexForSearchingAnnotation:(id<GSAnnotation>)annotation SearchType:(AnnotationSearchType)searchType;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end

@interface GSMapView (AnnotationCompare)

NSComparisonResult compare(id self, SEL _cmd, id obj);

@end

@interface TempAnnotation : NSObject <GSAnnotation> {
    CGPoint _coordinate;
}

@property (nonatomic, assign) CGPoint coordinate;

@end

@implementation TempAnnotation

@synthesize coordinate = _coordinate;

@end

@implementation GSMapView

@synthesize zoomEnabled = _zoomEnabled;
@synthesize mapViewDelegate = _mapViewDelegate;

@synthesize annotations = _annotations;

@synthesize showUserLocation = _showUserLocation;
@synthesize userLocationVisible = _userLocationVisible;
@synthesize userLocation = _userLocation;

NSComparisonResult (^annotationComparisonBlock)(id,id);

- (void)dealloc {
    _mapViewDelegate = nil;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // set default values for ScrollView 
        [self setBackgroundColor:[UIColor lightGrayColor]];
        [self setShowsHorizontalScrollIndicator:YES];
        [self setShowsVerticalScrollIndicator:YES];
        [self setBouncesZoom:NO];
        [super setDelegate:self];
        [self setOpaque:YES];
        // set default values for MapView
        [self setZoomEnabled:YES];
        
        _annotations = [[NSMutableArray alloc] initWithCapacity:0];
        _annotationViews = [[NSMutableDictionary alloc] initWithCapacity:0];
        _reuseableAnnotationViews = [[NSMutableDictionary alloc] initWithCapacity:0];
        _visibleAnnotations = [[NSMutableSet alloc] initWithCapacity:0];
        
        // location tracking
        _userLocationVisible = NO;
        _showUserLocation = NO;
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        
        _userLocation = [[GSUserLocation alloc] init];
        _userLocation.title = @"当前位置";
        
        _locateAnnotationView = [[GSLocateAnnotationView alloc] initWithAnnotation:_userLocation reuseIdentifier:@"$L0cate"];
        
        // FIXME:test code below
        //NSLog(@"%d", [self hash]);
    }
    return self;
}

#pragma mark - Setter Getter

- (void)setShowUserLocation:(BOOL)showUserLocation {
    _showUserLocation = showUserLocation;
    if (_showUserLocation) {
        [self startUpdatingLocation];
    }
    else {
        [self stopUpdatingLocation];
        [_locateAnnotationView removeFromSuperview];
        _userLocationVisible = NO;
    }
}

- (void)setUserLocationVisible:(BOOL)userLocationVisible {
    if (_userLocationVisible == userLocationVisible) {
        return;
    }
    
    if (_userLocationVisible) {
        [self stopUpdatingLocation];
        [_locateAnnotationView removeFromSuperview];
    }
    _userLocationVisible = userLocationVisible;
}

#pragma mark - layout

- (void)layoutAnnotations {
    CGRect visibleBounds = [self adjustedVisibleBounds];
    
    float minX = CGRectGetMinX(visibleBounds) / self.zoomScale;
    float minY = CGRectGetMinY(visibleBounds) / self.zoomScale;
    float maxX = CGRectGetMaxX(visibleBounds) / self.zoomScale;
    float maxY = CGRectGetMaxY(visibleBounds) / self.zoomScale;
    
    // remove annotationView that are no longer visible
    NSMutableArray *annotationsToBeRemoved = [[NSMutableArray alloc] initWithCapacity:0];
    for (id<GSAnnotation> annotation in _visibleAnnotations) {
        GSAnnotationView *annotationView = [_annotationViews objectForKey:[self dicKeyFromAnnotation:annotation]];
        if (!CGRectIntersectsRect(annotationView.frame, visibleBounds) && !annotationView.selected) {
            [self addReuseableAnntationView:annotationView];
            [annotationView removeFromSuperview];
            [_annotationViews removeObjectForKey:[self dicKeyFromAnnotation:annotation]];
            //[_visibleAnnotations removeObject:annotation]; // CAUSE ERROR:set was muted while being enumerated
            [annotationsToBeRemoved addObject:annotation];
        }
        else {
            // rePosition the annotationView
            [self adjustAnnotationViewCenter:annotationView];
        }
    }
    for (id annotation in annotationsToBeRemoved) {
        [_visibleAnnotations removeObject:annotation];
    }
    
    // get the annotations that should be visible
    
    TempAnnotation *minAnnotation = [[TempAnnotation alloc] init];
    CGPoint minPoint = CGPointMake(minX, minY);
    [minAnnotation setCoordinate:minPoint];
    
    int firstIndex = [self indexForSearchingAnnotation:minAnnotation SearchType:AnnotationSearchType_InsertPlace];
    
    id<GSAnnotation> annotation;
    for (int i = firstIndex; i < [_annotations count]; i++) {
        annotation = [_annotations objectAtIndex:i];
        if ([annotation coordinate].x > maxX) {
            break; // stop when annotation not visible
        }
        if (![_visibleAnnotations containsObject:annotation]) {
            if (annotation.coordinate.y >= minY && annotation.coordinate.y <= maxY) {
                [self displayAnnotation:annotation];
            }
        }
    }
    
    
}

- (void)layoutUserLocation {
    if (_showUserLocation && _userLocation.location != nil) {
        // layout userLocationView
        if (![_mapViewDelegate respondsToSelector:@selector(convertToCGPointFromCoordinate:)]) {
            return;
        }
        CGPoint coordinateInCGPoint = [_mapViewDelegate convertToCGPointFromCoordinate:_userLocation.location.coordinate];
        CGPoint adjustedCoordinateInCGPoint = [self convertToCurrentZoomScaleFromCGPoint:coordinateInCGPoint];
        
        // !!!:if _mapViewDelegate return a (-1,-1) point, then the coordinate is invalid, not display
        if (adjustedCoordinateInCGPoint.x < 0 || adjustedCoordinateInCGPoint.y < 0) {
            return;
        }
        
        if ([_mapViewDelegate respondsToSelector:@selector(convertToCGFloatFromAccuracy:)]) {
            CGFloat radius = [_mapViewDelegate convertToCGFloatFromAccuracy:_userLocation.location.horizontalAccuracy];
            CGFloat adjustedRadius = radius * self.zoomScale;
            
            [_locateAnnotationView setRadius:adjustedRadius];
        }
        
        
        if (!_userLocationVisible) {
            [self addSubview:_locateAnnotationView];
            [self sendSubviewToBack:_locateAnnotationView];
            [self sendSubviewToBack:_imageView];
            _userLocationVisible = YES;
        }
        else {
            if (_locateAnnotationView.selected) {
                CGFloat offsetX = adjustedCoordinateInCGPoint.x - _locateAnnotationView.center.x;
                CGFloat offsetY = adjustedCoordinateInCGPoint.y - _locateAnnotationView.center.y;
                [_locateAnnotationView.calloutView setFrame:CGRectOffset(_locateAnnotationView.calloutView.frame, offsetX, offsetY)];
            }
        }
        [_locateAnnotationView setCenter:adjustedCoordinateInCGPoint];
        
    }
    else {
        [_locateAnnotationView removeFromSuperview];
        _userLocationVisible = NO;
    }
}

- (void)layoutSubviews {
    //NSLog(@"scrollview layoutSubviews");
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    _imageView.frame = frameToCenter;
    
    if ([_imageView isKindOfClass:[GSMapTilingView class]]) {
        // to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
        // tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
        // which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
        _imageView.contentScaleFactor = 1.0;
    }
    
    [self layoutAnnotations];
    
    if (_userLocationVisible) {
        [self layoutUserLocation];
    }
    
    if ([_mapViewDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [_mapViewDelegate mapView:self regionDidChangeAnimated:NO];
    }
}

- (void)displayTiledImageNamed:(NSString *)imageName size:(CGSize)imageSize
{
    // clear the annotations
    [self removeAllAnnotations];
    
    // remove _userLocation
    [self setShowUserLocation:NO];
    
    // clear the previous imageView
    [_imageView removeFromSuperview];
    _imageView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new TilingView for the new image
    _imageView = [[GSMapTilingView alloc] initWithImageName:imageName size:imageSize];
    //[(TilingView *)_imageView setAnnotates:YES]; // ** remove this line to remove the white tile grid **
    [self addSubview:_imageView];
    
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
    
    [self setNeedsLayout];
}

#pragma mark - Private Methods

- (CGRect)adjustedVisibleBounds {
    return [self bounds];
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _imageView.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MAX(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 1.0;// / [[UIScreen mainScreen] scale];
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
    //self.maximumZoomScale = 1.5;
    //self.minimumZoomScale = 0.08;
    
    //NSLog(@"max zoom [%f], min zoom [%f]", maxScale, minScale);
}

- (void)addReuseableAnntationView:(GSAnnotationView *)annotationView {
    NSString *reuseIdentifier = annotationView.reuseIdentifier;
    if (reuseIdentifier == nil) {
        return;
    }
    NSMutableSet *annotationViewsSet = [_reuseableAnnotationViews objectForKey:annotationView.reuseIdentifier];
    if (!annotationViewsSet) {
        annotationViewsSet = [[NSMutableSet alloc] initWithCapacity:0];
        [_reuseableAnnotationViews setObject:annotationViewsSet forKey:annotationView.reuseIdentifier];
    }
    [annotationViewsSet addObject:annotationView];
}

- (void)adjustAnnotationViewCenter:(GSAnnotationView *)annotationView {
    id<GSAnnotation> annotation = annotationView.annotation;
    CGPoint centerPoint;
    centerPoint.x = annotation.coordinate.x * self.zoomScale - annotationView.centerOffset.x;
    centerPoint.y = annotation.coordinate.y * self.zoomScale - annotationView.centerOffset.y;
    
    if (annotationView.selected) {
        CGFloat offsetX = centerPoint.x - annotationView.center.x;
        CGFloat offsetY = centerPoint.y - annotationView.center.y;
        [annotationView.calloutView setFrame:CGRectOffset(annotationView.calloutView.frame, offsetX, offsetY)];
    }
    annotationView.center = centerPoint;
}

- (void)displayAnnotation:(id<GSAnnotation>)annotation {
    GSAnnotationView *annotationView = [_mapViewDelegate mapView:self viewForAnnotation:annotation];
    [annotationView setAnnotation:annotation];
    // TODO:if _mapViewDelegate not response to mapView:viewForAnnotation then init GSAnnotationView with the default GSPinAnnotationView
    [self adjustAnnotationViewCenter:annotationView];
    
    [self addSubview:annotationView];
    [_annotationViews setObject:annotationView forKey:[self dicKeyFromAnnotation:annotation]];
    [_visibleAnnotations addObject:annotation];
    
    if (_lastAnnotationShowCallout.selected) {
        [self bringSubviewToFront:_lastAnnotationShowCallout];
        [self bringSubviewToFront:_lastAnnotationShowCallout.calloutView];
    }
    [self sendSubviewToBack:_locateAnnotationView];
    [self sendSubviewToBack:_imageView];
}

- (NSString *)dicKeyFromAnnotation:(id<GSAnnotation>)annotation {
    return [NSString stringWithFormat:@"%ud", [annotation hash]];
}

- (CGPoint)convertToCurrentZoomScaleFromCGPoint:(CGPoint)point {
    CGPoint newPoint;
    newPoint.x = point.x * self.zoomScale;
    newPoint.y = point.y * self.zoomScale;
    return newPoint;
}

- (CGPoint)contentOffsetForAnnotation:(id<GSAnnotation>)annotation {
    CGPoint positionOnCurrentZoomScale = [self convertToCurrentZoomScaleFromCGPoint:annotation.coordinate];
    
    CGPoint maxContentOffset;
    maxContentOffset.x = fmaxf(0.0f, self.contentSize.width - self.bounds.size.width);
    maxContentOffset.y = fmaxf(0.0f, self.contentSize.height - self.bounds.size.height);
    
    CGRect safeRect = CGRectMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f, maxContentOffset.x, maxContentOffset.x);
    
    CGPoint offset;
    
    if (positionOnCurrentZoomScale.x <= CGRectGetMinX(safeRect)) {
        offset.x = 0;
    }
    else if (positionOnCurrentZoomScale.x < CGRectGetMaxX(safeRect)) {
        offset.x = positionOnCurrentZoomScale.x - self.bounds.size.width / 2.0;
    }
    else {
        offset.x = maxContentOffset.x;
    }
    
    if (positionOnCurrentZoomScale.y <= CGRectGetMinY(safeRect)) {
        offset.y = 0;
    }
    else if (positionOnCurrentZoomScale.y < CGRectGetMaxY(safeRect)) {
        offset.y = positionOnCurrentZoomScale.y - self.bounds.size.height / 2.0;
    }
    else {
        offset.y = maxContentOffset.y;
    }
    return offset;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([self zoomEnabled]) {
        return _imageView;
    }
    else {
        return nil;
    }
}

#pragma mark - Compare and serch Method for GSAnnotation

/*NSComparisonResult compare(id self, SEL _cmd, id obj) {
    if ([(id<GSAnnotation>)self coordinate].x > [(id<GSAnnotation>)obj coordinate].x) {
        return NSOrderedDescending;
    }
    else if ([(id<GSAnnotation>)self coordinate].x < [(id<GSAnnotation>)obj coordinate].x) {
        return NSOrderedAscending;
    }
    else if ([(id<GSAnnotation>)self coordinate].y > [(id<GSAnnotation>)obj coordinate].y) {
        return NSOrderedDescending;
    }
    else if ([(id<GSAnnotation>)self coordinate].y < [(id<GSAnnotation>)obj coordinate].y) {
        return NSOrderedAscending;
    }
    else if (![self isEqual:obj]) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (void)addCompareMethodToAnnotationClass:(id)annotation {
    if (![annotation respondsToSelector:@selector(compare:)]) {
        class_addMethod([annotation class], @selector(compare:), (IMP)compare, "i@:@");
    }
}*/

BOOL annotationAlreadyExist; // set to yes when annotationComparisonBlock return NSOrderedSame

NSComparisonResult (^annotationComparisonBlock)(id,id) = ^(id<GSAnnotation> anno1, id<GSAnnotation> anno2) {
    
    // WARNING: There should be no neccessary to compare coordinate.y but when using the default
    // FIXME:   brinary search of NSArray, seems that there are problems when searching.
    // TODO:    so compare coordinate.y now. But when x==x and y==y there maybe still problems.
    
    if ([anno1 coordinate].x > [anno2 coordinate].x) {
        return NSOrderedDescending;
    }
    else if ([anno1 coordinate].x < [anno2 coordinate].x) {
        return NSOrderedAscending;
    }
    else if ([anno1 coordinate].y > [anno2 coordinate].y) {
        return NSOrderedDescending;
    }
    else if ([anno1 coordinate].y < [anno2 coordinate].y) {
        return NSOrderedAscending;
    }
    else if (![anno1 isEqual:anno2]) {
        return NSOrderedAscending;
    }
    else {
        annotationAlreadyExist = YES;
        return NSOrderedSame;
    }
};

- (int)indexForSearchingAnnotation:(id<GSAnnotation>)annotation SearchType:(AnnotationSearchType)searchType {
    int index;
    switch (searchType) {
        case AnnotationSearchType_Insert:
            index = [_annotations indexOfObject:annotation
                                  inSortedRange:NSMakeRange(0, [_annotations count])
                                        options:NSBinarySearchingInsertionIndex
                                usingComparator:annotationComparisonBlock];
            break;
        case AnnotationSearchType_InsertPlace:
            index = [_annotations indexOfObject:annotation
                          inSortedRange:NSMakeRange(0, [_annotations count])
                                options:NSBinarySearchingInsertionIndex
                        usingComparator:annotationComparisonBlock];
            annotationAlreadyExist = NO; // useless for AnnotationSearchType_Equal so set it back to NO
            break;
        case AnnotationSearchType_Equal:
            index = [_annotations indexOfObject:annotation
                                  inSortedRange:NSMakeRange(0, [_annotations count])
                                        options:0
                                usingComparator:annotationComparisonBlock];
            annotationAlreadyExist = NO; // useless for AnnotationSearchType_Equal so set it back to NO
            break;
            
        default:
            index = NSNotFound;
            break;
    }
    return index;
}

#pragma mark - Public Method and Related

- (void)addAnnotation:(id<GSAnnotation>)annotation {
    int index = [self indexForSearchingAnnotation:annotation SearchType:AnnotationSearchType_Insert];
    if (annotationAlreadyExist) {
        //NSLog(@"annotationAlreadyExist.%@", annotation.title);
        annotationAlreadyExist = NO;
        return;
    }
    [_annotations insertObject:annotation atIndex:index];
    
    CGRect visibleBounds = [self adjustedVisibleBounds];
    CGPoint zoomScaledPoint = [self convertToCurrentZoomScaleFromCGPoint:annotation.coordinate];
    if (CGRectContainsPoint(visibleBounds, zoomScaledPoint)) {
        [self displayAnnotation:annotation];
    }
    
}

- (void)addAnnotations:(NSArray *)annotations {
    for (id annotation in annotations) {
        [self addAnnotation:annotation];
    }
}

- (void)removeAnnotationViewForAnnotation:(id<GSAnnotation>)annotation {
    GSAnnotationView *annotationView = [_annotationViews objectForKey:[self dicKeyFromAnnotation:annotation]];
    // set _lastAnnotationShowCallout To nil if it is being removed
    if ([annotationView isEqual:_lastAnnotationShowCallout]) {
        _lastAnnotationShowCallout = nil;
    }
    
    [_annotationViews removeObjectForKey:[self dicKeyFromAnnotation:annotation]];
    
    [annotationView removeFromSuperview];
}

- (void)removeAnnotation:(id<GSAnnotation>)annotation {
    if ([_visibleAnnotations containsObject:annotation]) {
        [self removeAnnotationViewForAnnotation:annotation];
        [_visibleAnnotations removeObject:annotation];
    }
    
    int index = [self indexForSearchingAnnotation:annotation SearchType:AnnotationSearchType_Equal];
    if (index != NSNotFound) {
        // These log remains until the bug about indexOfObject:inSortedRange:... been finished
        // Seems that the problem is from the implementation of indexOfObject:inSortedRange:...
        /*CGPoint a = [(id<GSAnnotation>)[_annotations objectAtIndex:index] coordinate];
        CGPoint b = [annotation coordinate];
        if (a.x != b.x || a.y != b.y) {
            NSLog(@"error equal [%@],[%@]", NSStringFromCGPoint(a), NSStringFromCGPoint(b));
            NSLog(@"object at index - 1[%@]", NSStringFromCGPoint([(id<GSAnnotation>)[_annotations objectAtIndex:(index - 1)] coordinate]));
            NSLog(@"object at index + 1[%@]", NSStringFromCGPoint([(id<GSAnnotation>)[_annotations objectAtIndex:(index + 1)] coordinate]));
            NSLog(@"hash [%ud],[%ud]", [[_annotations objectAtIndex:index] hash], [annotation hash]);
            if ([[_annotations objectAtIndex:index] isEqual:annotation]) {
                NSLog(@"is Equal");
            }
        }*/
        [_annotations removeObjectAtIndex:index];
    }
    /*else {
        NSLog(@"annotation:[%@]", annotation.title);
    }*/

    // ???:really need to remove one view from _reuseableAnnotationViews?
    //NSLog(@"count [%d]", [_annotations count]);
}

- (void)removeAnnotations:(NSArray *)annotations {
    for (id annotation in annotations) {
        [self removeAnnotation:annotation];
    }
}

- (void)removeAllAnnotations {
    for (id<GSAnnotation> annotation in _visibleAnnotations) {
        [self removeAnnotationViewForAnnotation:annotation];
    }
    [_visibleAnnotations removeAllObjects];
    
    [_annotations removeAllObjects];
}

- (GSAnnotationView *)viewForAnnotation:(id<GSAnnotation>)annotation {
    return [_annotationViews objectForKey:[self dicKeyFromAnnotation:annotation]];
}

- (GSAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier {
    NSMutableSet *annotationViewsSet = (NSMutableSet *)[_reuseableAnnotationViews objectForKey:identifier];
    GSAnnotationView *annotationView = [annotationViewsSet anyObject];
    if (annotationView) {
        //[[annotationView retain] autorelease];
        [annotationViewsSet removeObject:annotationView];
    }
    return annotationView;
}

- (void)selectAnnotation:(id<GSAnnotation>)annotation animated:(BOOL)animated {
    int index = [self indexForSearchingAnnotation:annotation SearchType:AnnotationSearchType_Equal];
    if (index != NSNotFound) {
        if (![_visibleAnnotations containsObject:annotation]) {
            [self displayAnnotation:annotation];
        }
        GSAnnotationView *annotationView = [_annotationViews objectForKey:[self dicKeyFromAnnotation:annotation]];
        if (!annotationView.selected) {
            [annotationView performSelector:@selector(annotationTouchUpInside:) withObject:nil];
        }
        CGPoint contentOffset = [self contentOffsetForAnnotation:annotation];
        [self setContentOffset:contentOffset animated:animated];
    }
}

- (void)deselectAnnotation:(id<GSAnnotation>)annotation animated:(BOOL)animated {
    GSAnnotationView *annotationView = [_annotationViews objectForKey:[self dicKeyFromAnnotation:annotation]];
    
    if ([annotationView isEqual:_lastAnnotationShowCallout]) {
        [self removeLastCallout];
    }
}

#pragma mark - ShowAnnotationCallout

- (void)didSelectAnnotationView:(GSAnnotationView *)annotationView {
    if ([_mapViewDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [_mapViewDelegate mapView:self didSelectAnnotationView:annotationView];
    }
}

- (void)didDeselectAnnotationView:(GSAnnotationView *)annotationView {
    if ([_mapViewDelegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [_mapViewDelegate mapView:self didDeselectAnnotationView:annotationView];
    }
}

- (void)removeLastCallout {
    if (_lastAnnotationShowCallout.selected) {
        [_lastAnnotationShowCallout performSelector:@selector(annotationTouchUpInside:) withObject:nil];
    }
    _lastAnnotationShowCallout = nil;
}

- (void)annotationViewTouchUpInside:(GSAnnotationView *)annotationView {
    if (_lastAnnotationShowCallout != annotationView) {
        if (annotationView.selected) {
            [self removeLastCallout];
            _lastAnnotationShowCallout = annotationView;
        }
    }
    else {
        if (!_lastAnnotationShowCallout.selected) {
            _lastAnnotationShowCallout = nil;
        }
    }
    
    if (annotationView.canShowCallout) {
        if (annotationView.selected) {
            [self didSelectAnnotationView:annotationView];
        }
        else {
            [self didDeselectAnnotationView:annotationView];
        }
    }
}

#pragma mark - Location Tracking

- (void)startUpdatingLocation {
    [_userLocation setUpdating:YES];
    [_userLocation setLocation:nil];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager setDelegate:self];
    [_locationManager startUpdatingLocation];
    
    if ([_mapViewDelegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)]) {
        [_mapViewDelegate mapViewWillStartLocatingUser:self];
    }
}

- (void)stopUpdatingLocation {
    [_userLocation setUpdating:NO];
    [_locationManager stopUpdatingLocation];
    [_locationManager setDelegate:nil];
    
    if ([_mapViewDelegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)]) {
        [_mapViewDelegate mapViewDidStopLocatingUser:self];
    }
}


#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	if (locationAge > 5.0) return;
	// test that the horizontal accuracy does not indicate an invalid measurement
	if (newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 150) return;
    
    NSLog(@"latitude[%lf]", newLocation.coordinate.latitude);
	NSLog(@"longitude[%lf]", newLocation.coordinate.longitude);
	
	NSLog(@"new accuracy [%lf]", newLocation.horizontalAccuracy);
    
    [_userLocation setLocation:newLocation];
    
	[self stopUpdatingLocation];
    
    // show user location
    [self layoutUserLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    if ([error code] != kCLErrorLocationUnknown) {
		[self stopUpdatingLocation];
	}
	UIAlertView *cannotLocateAlert = [[UIAlertView alloc] initWithTitle:@"定位" 
																message:@"您未允许当前应用获取您的位置,要使用定位功能,请启用当前应用的定位服务"
															   delegate:self
													  cancelButtonTitle:@"确定"
													  otherButtonTitles:nil];
	[cannotLocateAlert show];
}

#pragma mark - Code for Testing

@end
