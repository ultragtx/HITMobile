//
//  HIT_MAPViewController.h
//  HIT_MAP
//
//  Created by Hiro on 11-5-28.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "TiledScrollView.h"
#import "TapDetectingView.h"
#define CAMPUS1_WIDTH 4000
#define CAMPUS1_HEIGHT 4220
#define CAMPUS2_WIDTH 3000
#define CAMPUS2_HEIGHT 2411

//@class SearchTableViewController;

@interface TiledMapViewController : UIViewController <TiledScrollViewDataSource, TapDetectingViewDelegate, CLLocationManagerDelegate> {
	TiledScrollView *imageScrollView;
	NSString *currentImageName;
	
	NSTimer *autoscrollTimer; // Timer used for auto-scrolling.
	float autoScrollDistance; // Distance to scroll the thumb view when auto-scroll timer fires;
	
    UISegmentedControl *segmentControl;
    UIBarButtonItem *locateBarButton;
    
	// Loacation Part
	CLLocationManager *locationManager;
	CLLocation *bestEffortAtLocation;
	
	int currentCampus;
	
	BOOL isLocating;
    
    NSCache *mapCache;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, retain) UISegmentedControl *segmentControl;
@property (nonatomic, retain) UIBarButtonItem *locateBarButton;
@property (nonatomic, assign) int currentCampus;
@property (nonatomic, assign) BOOL isLocating;

- (void)stopUpdatingLocation:(NSString *)state;
- (void)locateBarButtonPressed:(id)sender;
- (void)switchCampusButtonPressed:(id)sender;
- (void)chooseCampus1;
- (void)chooseCampus2;
- (void)chooseCampus1WithPointX:(int)x Y:(int)y;
- (void)chooseCampus2WithPointX:(int)x Y:(int)y;
@end

