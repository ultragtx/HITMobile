//
//  HIT_MAPViewController.m
//  HIT_MAP
//
//  Created by Hiro on 11-5-28.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TiledMapViewController.h"
#import "TapDetectingView.h"
#import "SearchTableViewController.h"
#import "AppDelegate.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5
#define MAX_SCALE 1.8
#define DEFAULT_SCALE 0.4

@interface TiledMapViewController (ViewHandlingMethods)
- (void)toggleThumbView;
- (void)pickImageNamed:(NSString *)name size:(CGSize)size;
- (void)addItemInNavBar;
- (void)changeItemInToolbar;
- (void)addToolBar;
- (void)chooseCampus1;
- (void)chooseCampus2;
@end

@interface TiledMapViewController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end


@implementation TiledMapViewController
@synthesize segmentControl;
@synthesize locateBarButton;
@synthesize locationManager;
@synthesize bestEffortAtLocation;
@synthesize currentCampus;
@synthesize isLocating;

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
	self.isLocating = NO;
	[super loadView];
	imageScrollView = [[TiledScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 372)];
    [imageScrollView setDataSource:self];
    [[imageScrollView tileContainerView] setDelegate:self];
    [imageScrollView setTileSize:CGSizeMake(256, 256)];
    [imageScrollView setBackgroundColor:[UIColor darkGrayColor]];
	[imageScrollView setShowsVerticalScrollIndicator:NO];
	[imageScrollView setShowsHorizontalScrollIndicator:NO];
	//[imageScrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
    [imageScrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
	[imageScrollView setScrollsToTop:NO];
    [imageScrollView setBouncesZoom:YES];
    [imageScrollView setMaximumResolution:0];
    [imageScrollView setMinimumResolution:-2];
	
    [[self view] addSubview:imageScrollView];
	[self addItemInNavBar];
	[self changeItemInToolbar];
    
    mapCache = [[NSCache alloc] init];
}

- (void)changeItemInToolbar {
	if (isLocating) {
        NSLog(@"YES");
		UIImageView *locatingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BarButtonBackground.png"]];
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10.5, 5.5, 20, 20)];
		[activityIndicator startAnimating];
		[locatingImageView addSubview:activityIndicator];
		[activityIndicator release];
		
		[self.locateBarButton setCustomView:locatingImageView];
		[locatingImageView release];
	}
	else {
        UIButton *locateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 31)];
		[locateButton setImage:[UIImage imageNamed:@"BarButtonBackgroundWithCrossHair.png"] forState:UIControlStateNormal];
		[locateButton addTarget:self 
						 action:@selector(locateBarButtonPressed:)
			   forControlEvents:UIControlEventTouchUpInside];
		[self.locateBarButton setCustomView:locateButton];
		[locateButton release];
	}

	
}

- (void)addItemInNavBar {
    self.locateBarButton = [[UIBarButtonItem alloc] 
                                        initWithImage:[UIImage imageNamed:@"MOCrossHair.png"] 
                                        style:UIBarButtonItemStyleBordered 
                                        target:self 
                                        action:@selector(locateBarButtonPressed:)];
     
    self.navigationItem.leftBarButtonItem = self.locateBarButton;
    //[locateBarButton release];
    
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@" 一校区 ", @" 二校区 ", nil]];
    self.segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.segmentControl addTarget:self action:@selector(switchCampusButtonPressed:) forControlEvents:UIControlEventValueChanged];
    [self.segmentControl setSelectedSegmentIndex:0];
    [self chooseCampus1];
	self.currentCampus = 1;
	self.navigationItem.titleView = self.segmentControl;
	//[segmentControl release];
    
	UIBarButtonItem *placesBarButton = [[UIBarButtonItem alloc] 
										initWithTitle:@"地点查询" 
										style:UIBarButtonItemStyleBordered 
										target:self 
										action:@selector(placesBarButtonPushed:)];
	self.navigationItem.rightBarButtonItem = placesBarButton;
	[placesBarButton release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillDisappear:(BOOL)animated {
	//[self.navigationController setToolbarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	//[self addToolBar];
}

- (NSString *)iconImageName {
	return @"MapIcon.png";
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
										
#pragma mark -
#pragma mark Location Manager

#define ORIGIANLPOINT_LATITUDE_CAMPUS1 45.753767
#define ORIGIANLPOINT_LONGTITUDE_CAMPUS1 126.634812
#define ORIGIANLPOINT_LATITUDE_CAMPUS2 45.750360
#define ORIGIANLPOINT_LONGTITUDE_CAMPUS2 126.671439

- (void) startUpdateLocation {
    NSLog(@"startUpdatingLocation");
	self.isLocating = YES;
	[self changeItemInToolbar];
	
	if (!locationManager) {
		locationManager = [[CLLocationManager alloc] init];
	}
	else {
		[locationManager stopUpdatingLocation];
		[locationManager init];
	}
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];
	[self performSelector:@selector(stopUpdatingLocation:) withObject:@"Time Out" afterDelay:15.0];
	
}

- (void)stopUpdatingLocation:(NSString *)state {
	NSLog(@"stopUpdatingLocation [%@]", state);
	self.isLocating = NO;
	[self changeItemInToolbar];
	if (NSOrderedSame == [state compare:@"Time Out"]) {
		UIAlertView *timeOutAlert = [[UIAlertView alloc] initWithTitle:@"定位"
															   message:@"定位超时"
															  delegate:self
													 cancelButtonTitle:@"确定"
													 otherButtonTitles:nil];
		[timeOutAlert show];
		[timeOutAlert release];
	}
	
	[locationManager stopUpdatingLocation];
	locationManager.delegate = nil;
}

- (void) showLocationOnMap: (CLLocation *) newLocation  {
	// TODO:test if the point is in the campus and is cross campus move to diffrent campus
	//NSLog("location [%lf] [%lf]", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	switch (self.currentCampus) {
		case 1:
			[imageScrollView showLocationAtLatitude:newLocation.coordinate.latitude
										  lontitude:newLocation.coordinate.longitude
								   originalLatitude:ORIGIANLPOINT_LATITUDE_CAMPUS1
								 originalLongtitude:ORIGIANLPOINT_LONGTITUDE_CAMPUS1
										   AtCampus:1
										SholdMoveTo:YES];
			break;
		case 2:
			[imageScrollView showLocationAtLatitude:newLocation.coordinate.latitude
										  lontitude:newLocation.coordinate.longitude
								   originalLatitude:ORIGIANLPOINT_LATITUDE_CAMPUS2
								 originalLongtitude:ORIGIANLPOINT_LONGTITUDE_CAMPUS2
										   AtCampus:self.currentCampus
										SholdMoveTo:YES];
			break;
		default:
			NSLog(@"something wrong with the currentCampus");
			break;
	}
	
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"didUpdateToLocation");
	// test the age of the location measurement to determine if the measurement is cached
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	if (locationAge > 5.0) return;
	// test that the horizontal accuracy does not indicate an invalid measurement
	if (newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 150) return;

	NSLog(@"latitude[%lf]", newLocation.coordinate.latitude);
	NSLog(@"longitude[%lf]", newLocation.coordinate.longitude);
	
	NSLog(@"new accuracy [%lf]", newLocation.horizontalAccuracy);
	[self stopUpdatingLocation:@"Acquired Location"];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:@"Time Out"];
	[self showLocationOnMap: newLocation];

	
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError");
	if ([error code] != kCLErrorLocationUnknown) {
		[self stopUpdatingLocation:@"Error"];
	}
	UIAlertView *cannotLocateAlert = [[UIAlertView alloc] initWithTitle:@"定位" 
																message:@"您未允许当前应用获取您的位置,要使用定位功能,请启用当前应用的定位服务"
															   delegate:self
													  cancelButtonTitle:@"确定"
													  otherButtonTitles:nil];
	[cannotLocateAlert show];
	[cannotLocateAlert release];
}



#pragma mark -
#pragma mark Button Listener

- (void)placesBarButtonPushed:(id)sender {
	SearchTableViewController *searchViewController = [[SearchTableViewController alloc] initWithNibName:@"SearchTableViewController" bundle:nil];
	searchViewController.parentTiledMapViewController = self;
	//[self presentModalViewController:searchViewController animated:YES];
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController presentModalViewController:searchViewController animated:YES];
	[searchViewController release];
}

- (void)locateBarButtonPressed:(id)sender {
    NSLog(@"locateBarButtonPressed");
	[self startUpdateLocation];
	// for test only
	//CLLocation *location1 = [[CLLocation alloc] initWithLatitude:45.740942 longitude:126.624301];
	//CLLocation *location1 = [[CLLocation alloc] initWithLatitude:45.752878 longitude:126.678298];
	//[self showLocationOnMap:location1];
}

- (void)switchCampusButtonPressed:(id)sender {
    
	[imageScrollView removePinTemporary:NO];
	switch (self.currentCampus) {
		case 1:
			[self chooseCampus2];
            self.currentCampus = 2;
			break;
		case 2:
			[self chooseCampus1];
            self.currentCampus = 1;
			break;
		default:
			NSLog(@"errorr with currentCampus");
			break;
	}
}

#pragma mark -
#pragma mark Memory Management


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
}


- (void)dealloc {
    [locateBarButton release];
    [segmentControl release];
	[imageScrollView release];
	[locationManager release];
	[bestEffortAtLocation release];
    [mapCache release];
    [super dealloc];
}

#pragma mark TiledScrollViewDataSource method

- (UIView *)tiledScrollView:(TiledScrollView *)tiledScrollView tileForRow:(int)row column:(int)column resolution:(int)resolution {
	
	// re-use a tile rather than creating a new one, if possible
	UIImageView *tile = (UIImageView *)[tiledScrollView dequeueReusableTile];
	
	if (!tile) {
		// the scroll view will handle setting the tile's frame, so we don't have to worry about if
		tile = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
		
		// Setting the content mode to "top left" ensures that the images around the edge are
        // positioned properly in their tiles. 
		[tile setContentMode:UIViewContentModeTopLeft];
	}
	
	// The resolution is stored as a power of 2, so -1 means 50%, -2 means 25%, and 0 means 100%.
    // We've named the tiles things like BlackLagoon_50_0_2.png, where the 50 represents 50% resolution.
	int resolutionPercentage = 100 * pow(2, resolution);
	//NSString *tempString = [NSString stringWithFormat:@"%@_%d_%d_%d.png", currentImageName, resolutionPercentage, row, column];
	//NSLog(@"tempSting is [%@]", tempString);
	[tile setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%d_%d_%d.png", currentImageName, resolutionPercentage, row, column]]];
	return tile;
}

- (void)decompressImage:(UIImage *)image
{
	UIGraphicsBeginImageContext(CGSizeMake(1, 1));
	[image drawAtPoint:CGPointZero];
	UIGraphicsEndImageContext();
}

- (UIImage *)imageWithRow:(int)row column:(int)column resolution:(int)resolution {
	int resolutionPercentage = 100 * pow(2, resolution);
    
    UIImage *tileImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%d_%d_%d.jpg", currentImageName, resolutionPercentage, row, column]];
	return tileImage;
    
    // saved in cache maybe no use at all because UIImage imageWithName already have a cache
    /*UIImage *tiledImage = [mapCache objectForKey:[NSString stringWithFormat:@"%@_%d_%d_%d.png", currentImageName, resolutionPercentage, row, column]];
    if (!tiledImage) {
        tiledImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%d_%d_%d.png", currentImageName, resolutionPercentage, row, column]];
        [mapCache setObject:tiledImage forKey:[NSString stringWithFormat:@"%@_%d_%d_%d.png", currentImageName, resolutionPercentage, row, column]];
        //[self decompressImage:tiledImage];
    }*/
    UIImage *tiledImage = [mapCache objectForKey:[NSString stringWithFormat:@"%@_%d_%d_%d.jpg", currentImageName, resolutionPercentage, row, column]];
    if (!tiledImage) {
        tiledImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%d_%d_%d.jpg", currentImageName, resolutionPercentage, row, column]];
        [mapCache setObject:tiledImage forKey:[NSString stringWithFormat:@"%@_%d_%d_%d.jpg", currentImageName, resolutionPercentage, row, column]];
        //[self decompressImage:tiledImage];
    }
	
    return tiledImage;
}


#pragma mark TapDetectingViewDelegate 

- (void)tapDetectingView:(TapDetectingView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
    // Do nothing
}

- (void)tapDetectingView:(TapDetectingView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    // double tap zooms in
    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapDetectingView:(TapDetectingView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    // two-finger tap zooms out
    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark View handling methods

- (void)chooseCampus1WithPointX:(int)x Y:(int)y {
	
	if (self.currentCampus != 1) {
		self.currentCampus = 1;
		//self.title = @"一校区";
		// we now have to pass the size of the image, because we're not loading the entire image at once
		[self pickImageNamed:@"HIT_MAP_CAMP1" size:CGSizeMake(CAMPUS1_WIDTH, CAMPUS1_HEIGHT)];
	}
	
	if (x != 0 || y != 0) {
		[imageScrollView showPinAtPointX:x Y:y PinType:PINTYPE_PIN SholdMoveTo:YES];
	}
	
}

- (void)chooseCampus2WithPointX:(int)x Y:(int)y {
	
	if (self.currentCampus != 2) {
		self.currentCampus = 2;
		//self.title = @"二校区";
		// we now have to pass the size of the image, because we're not loading the entire image at once
		[self pickImageNamed:@"HIT_MAP_CAMP2" size:CGSizeMake(CAMPUS2_WIDTH, CAMPUS2_HEIGHT)];
	}
	
	if (x != 0 || y != 0) {
		[imageScrollView showPinAtPointX:x Y:y PinType:PINTYPE_PIN SholdMoveTo:YES];
	}
	
}

- (void)chooseCampus1 {
	[self chooseCampus1WithPointX:0 Y:0];
}

- (void)chooseCampus2 {
	[self chooseCampus2WithPointX:0 Y:0];
}

- (void)pickImageNamed:(NSString *)name size:(CGSize)size {
    
    [currentImageName release];
    currentImageName = [name retain];
    
    // change the content size and reset the state of the scroll view
    // to avoid interactions with different zoom scales and resolutions. 
    [imageScrollView reloadDataWithNewContentSize:size];
	CGPoint centerPoint = CGPointMake(size.width / 2, size.height / 2);
    [imageScrollView setContentOffset:centerPoint];
    imageScrollView.originalX = size.width;
	imageScrollView.originalY = size.height;
	
    // choose minimum scale so image width fills screen
	float minScale = [imageScrollView frame].size.height  / size.height;
	[imageScrollView setMinimumZoomScale:minScale];
	[imageScrollView setMaximumZoomScale:MAX_SCALE];
    [imageScrollView setZoomScale:DEFAULT_SCALE];   
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
