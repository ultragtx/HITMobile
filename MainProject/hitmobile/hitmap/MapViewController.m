//
//  MasterViewController.m
//  hitmap
//
//  Created by 鑫容 郭 on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "GSAnnotationView.h"

#import "GSLocateAnnotationView.h"
#import "GSUserLocation.h"

#import "HITPlaceAnnotationView.h"


#define CAMPUS1_WIDTH 4000
#define CAMPUS1_HEIGHT 4220
#define CAMPUS2_WIDTH 3000
#define CAMPUS2_HEIGHT 2411

#define ORIGIANLPOINT_LATITUDE_CAMPUS1 45.753767
#define ORIGIANLPOINT_LONGTITUDE_CAMPUS1 126.634812
#define ORIGIANLPOINT_LATITUDE_CAMPUS2 45.750360
#define ORIGIANLPOINT_LONGTITUDE_CAMPUS2 126.671439

#define OFFSET1_ORIGINALPOINT_X 800
#define OFFSET1_ORIGINALPOINT_Y 400
#define OFFSET2_ORIGINALPOINT_X 1180
#define OFFSET2_ORIGINALPOINT_Y 388//366

@implementation MapViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        _currentDisplayLevel = 0;
        //NSLog(@"LocalizedString: %@", NSLocalizedString(@"Test", @"default"));
        //NSLog(@"frame [%f][%f][%f][%f]", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        //[self.view setBounds:CGRectMake(0, 0, 320, 480 - 44 - 20)];
        //[self.view setFrame:CGRectMake(0, 0, 320, 480 - 44 -20)];
        //NSLog(@"frame [%f][%f][%f][%f]", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
    // Release any cached data, images, etc that aren't in use.
}

- (void)initPlaces {
    // Campus1
    NSString *bundlePathofPlist = [[NSBundle mainBundle]pathForResource:@"newLocation" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
    NSArray *Region1places = [dict valueForKey:@"Region1place"];
    NSArray *Region1CoordinatesXs = [dict valueForKey:@"Region1CoordinatesX"];
    NSArray *Region1CoordinatesYs = [dict valueForKey:@"Region1CoordinatesY"];
    NSArray *Region1Levels = [dict valueForKey:@"Region1Level"];
    
    _campus1Places = [[NSMutableArray alloc] initWithCapacity:[Region1places count]];
    
    for (int i = 0; i < [Region1places count]; i++) {
        HITPlaceAnotation *annotation = [[HITPlaceAnotation alloc] init];
        annotation.title = [Region1places objectAtIndex:i];
        
        annotation.coordinate = CGPointMake([(NSNumber *)[Region1CoordinatesXs objectAtIndex:i] floatValue], [(NSNumber *)[Region1CoordinatesYs objectAtIndex:i] floatValue]);
        
        annotation.displayLevel = [(NSNumber *)[Region1Levels objectAtIndex:i] intValue];
        
        // TODO: init other fieds
        
        [_campus1Places addObject:annotation];
    }
    
    NSArray *Region2places = [dict valueForKey:@"Region2place"];
    NSArray *Region2CoordinatesXs = [dict valueForKey:@"Region2CoordinatesX"];
    NSArray *Region2CoordinatesYs = [dict valueForKey:@"Region2CoordinatesY"];
    NSArray *Region2Levels = [dict valueForKey:@"Region2Level"];
    
    _campus2Places = [[NSMutableArray alloc] initWithCapacity:[Region2places count]];
    
    for (int i = 0; i < [Region2places count]; i++) {
        HITPlaceAnotation *annotation = [[HITPlaceAnotation alloc] init];
        annotation.title = [Region2places objectAtIndex:i];
        
        annotation.coordinate = CGPointMake([(NSNumber *)[Region2CoordinatesXs objectAtIndex:i] floatValue], [(NSNumber *)[Region2CoordinatesYs objectAtIndex:i] floatValue]);
        
        annotation.displayLevel = [(NSNumber *)[Region2Levels objectAtIndex:i] intValue];
        
        // TODO: init other fieds
        
        [_campus2Places addObject:annotation];
    }

}

- (void)addAnnotations {
    for (HITPlaceAnotation *annotation in _currentCampusPlaces) {
        if (annotation.displayLevel <= _currentDisplayLevel) {
            [_mapScrollView addAnnotation:annotation];
        }
    }
}

- (void)selectCampus:(HITCampus)campus {
    switch (campus) {
        case HITCAMPUS1:
            [_mapScrollView displayTiledImageNamed:@"HIT_MAP_CAMP1" size:CGSizeMake(CAMPUS1_WIDTH, CAMPUS1_HEIGHT)];
            _currentCampusPlaces = _campus1Places;
            [self setTitle:@"一校区"];
            break;
        case HITCAMPUS2:
            [_mapScrollView displayTiledImageNamed:@"HIT_MAP_CAMP2" size:CGSizeMake(CAMPUS2_WIDTH, CAMPUS2_WIDTH)];
            _currentCampusPlaces = _campus2Places;
            [self setTitle:@"二校区"];
        default:
            break;
    }
    if (_showAnnotations) {
        [self addAnnotations];
    }
}

#pragma mark - View lifecycle

- (void)initSearBarAndTableView
{
    
    // MenuButton
    UIButton *menueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menueButton setImage:[UIImage imageNamed:@"BarButtonLikeUIButton.png"] forState:UIControlStateNormal];
    [menueButton setImage:[UIImage imageNamed:@"BarButtonLikeUIButtonHighlighted.png"] forState:UIControlStateHighlighted];
    [menueButton setFrame:CGRectMake(0, 0, 44 + 5, 44)];
    [menueButton addTarget:[UIApplication sharedApplication].delegate action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menueButton];
    
    // SearchBar
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(44 + 5, 0, 320 - 44 - 5, 44)];
    [_searchBar setBarStyle:UIBarStyleBlack];
    [_searchBar setDelegate:self];
    // set Keyboard type
    /*for(UIView *subView in searchBar.subviews) {
     if([subView isKindOfClass: [UITextField class]]) {
     [(UITextField *)subView setKeyboardAppearance: UIKeyboardAppearanceAlert];
     }
     }*/
    //[self.navigationItem setTitleView:_searchBar];
    [self.view addSubview:_searchBar];
    
    UIBarButtonItem *cancleBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancleBarButtonClicked:)];
    [self.navigationItem setRightBarButtonItem:cancleBarButtonItem animated:NO];
    
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"] style:UIBarButtonItemStyleBordered target:[UIApplication sharedApplication].delegate action:@selector(toggleLeftView)];
    [self.navigationItem setLeftBarButtonItem:menuBarButtonItem];
    
    // tableView
    _placesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 480 -20 - 44 - 44) style:UITableViewStylePlain];
    [_placesTableView setDelegate:self];
    [_placesTableView setDataSource:self];
    [_placesTableView setAlpha:0.0f]; // For the animatoin
    _searchAnnotationResults = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initSettingsView
{
    // settingsView 
    _settingsView = [[MapSettingsView alloc] initWithFrame:CGRectMake(0, 44, 320, 480 - 44 - 20 - 44)];
    [_settingsView setDelegate:self];
    [self.view addSubview:_settingsView];
}

- (void)initMapView
{
    // mapview
    _mapScrollView = [[GSMapView alloc] initWithFrame:CGRectMake(0, 44, 320, 480 - 44 -20 - 44)];
    [_mapScrollView setContentSize:CGSizeMake(CAMPUS1_WIDTH, CAMPUS1_HEIGHT)];
    //[_mapScrollView displayTiledImageNamed:@"HIT_MAP_CAMP1" size:CGSizeMake(CAMPUS1_WIDTH, CAMPUS1_HEIGHT)];
    [self selectCampus:_currentCampus];
    [self.view addSubview:_mapScrollView];
    [_mapScrollView setMapViewDelegate:self];
}

- (void)initToolBar
{
    // _activityIndicator for _locateBarButton
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    // BarButtonItems
    _locateBarButtonInnerButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:[UIImage imageNamed:@"MOCrossHair.png"]]];
    [_locateBarButtonInnerButton setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_locateBarButtonInnerButton setTintColor:[UIColor darkGrayColor]];
    [_locateBarButtonInnerButton setMomentary:YES];
    [_locateBarButtonInnerButton addTarget:self action:@selector(locateBarButtonPressed:) forControlEvents:UIControlEventValueChanged];
    
    for (UIView *view in _locateBarButtonInnerButton.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [_activityIndicator setFrame:CGRectMake(7, 5, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height)];
            [view addSubview:_activityIndicator];
        }
    }
    
    UIBarButtonItem *locateBarButton = [[UIBarButtonItem alloc] initWithCustomView:_locateBarButtonInnerButton];
    UIBarButtonItem *flexibleBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl target:self action:@selector(settingsBarButtonPressed:)];
    
    NSArray *toolBarItems = [NSArray arrayWithObjects:locateBarButton, flexibleBarButton, settingsButton, nil];
    
    // ToolBar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 480 - 44 - 20, 320, 44)];
    [toolbar setBarStyle:UIBarStyleBlack];
    [self.view addSubview:toolbar];
    [toolbar setItems:toolBarItems];
    
    // _blankImage for _locateBarButton
    UIGraphicsBeginImageContext(CGSizeMake(20.0f, 20.0f));
    _blankImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)initFDCurlViewControl
{
    // init the FDCurlViewControl
    // This is designd as a toolbar button but we can use the curl control but not show it on the screen
    _curlViewControl = [[FDCurlViewControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
	[_curlViewControl setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[_curlViewControl setHidesWhenAnimating:NO];
    [_curlViewControl setTargetView:_mapScrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _viewCurlUp = NO;
    _showAnnotations = YES;
    _currentCampus = HITCAMPUS1;
    _currentLocatingStatus = LocatingStatus_standBy;
    
    [self initSettingsView];
    
    [self initPlaces];

    [self initMapView];
    
    [self initToolBar];
    
    [self initSearBarAndTableView];
    
    [self initFDCurlViewControl];
    
    // FIXME:test Code Below    
    //[self performSelector:@selector(testSelectAnnotation) withObject:nil afterDelay:3];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}

/*- (void)testSelectAnnotation {
    HITPlaceAnotation *annotation = [_campus1Places objectAtIndex:48];
    [_mapScrollView addAnnotation:annotation];
    [_mapScrollView selectAnnotation:annotation animated:YES];
    _annotaionShouldStay = annotation;
}*/

- (void)showAndSelectAnnotation:(HITPlaceAnotation *)annotation {
    [_mapScrollView addAnnotation:annotation];
    [_mapScrollView selectAnnotation:annotation animated:YES];
    _annotaionShouldStay = annotation;
}

#pragma mark - Bar Button Listener

- (void)locateBarButtonPressed:(id)sender {
    switch (_currentLocatingStatus) {
        case LocatingStatus_standBy:
            [_mapScrollView setShowUserLocation:YES];
            break;
        case LocatingStatus_locating:
            [_mapScrollView setShowUserLocation:NO];
            _currentLocatingStatus = LocatingStatus_standBy;
        default:
            break;
    }
}

- (void)settingsBarButtonPressed:(id)sender {
    //[UIView transitionFromView:_mapScrollView toView:_settingsView duration:3.0 options:UIViewAnimationOptionTransitionCurlUp completion:NULL];
    if (_viewCurlUp) {
        [_curlViewControl curlViewDown];
        _viewCurlUp = NO;
    }
    else {
        [_curlViewControl curlViewUp];
        _viewCurlUp = YES;
    }
    
}

#pragma mark - GSMapViewDelegate

- (GSAnnotationView *)mapView:(GSMapView *)mapView viewForAnnotation:(id<GSAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[HITPlaceAnotation class]]) {
        static NSString *identifier = @"test";
        HITPlaceAnnotationView *annotationView = (HITPlaceAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
         if (annotationView == nil) {
             annotationView = [[HITPlaceAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
         }
        //[annotationView setLeftCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        //[annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        return annotationView;
    }
    return nil;
}

- (void)mapView:(GSMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //NSLog(@"zoomScale [%f]", mapView.zoomScale);
    int targetDisplayLevel;
    if (mapView.zoomScale <= 0.17) {
        targetDisplayLevel = 1;
    }
    else if (mapView.zoomScale <= 0.29) {
        targetDisplayLevel = 2;
    }
    else if (mapView.zoomScale <= 0.54) {
        targetDisplayLevel = 3;
    }
    else if (mapView.zoomScale <= 1) {
        targetDisplayLevel = 4;
    }
    else {
        targetDisplayLevel = 4;
    }
    if (_showAnnotations) {
        if (_currentDisplayLevel > targetDisplayLevel) {
            // remove
            for (HITPlaceAnotation *annotation in _currentCampusPlaces) {
                if (annotation.displayLevel > targetDisplayLevel && annotation.displayLevel <= _currentDisplayLevel && ![annotation isEqual:_annotaionShouldStay]) {
                    [_mapScrollView removeAnnotation:annotation];
                }
            }
        }
        else if (_currentDisplayLevel < targetDisplayLevel) {
            // add
            for (HITPlaceAnotation *annotation in _currentCampusPlaces) {
                if (annotation.displayLevel <= targetDisplayLevel && annotation.displayLevel > _currentDisplayLevel) {
                    [_mapScrollView addAnnotation:annotation];
                }
            }
        }
        
    }
    _currentDisplayLevel = targetDisplayLevel;
    //NSLog(@"enter level %d", _currentDisplayLevel);
}

- (void)mapViewWillStartLocatingUser:(GSMapView *)mapView {
    _currentLocatingStatus = LocatingStatus_locating;
    [_locateBarButtonInnerButton setImage:_blankImage forSegmentAtIndex:0];
    [_activityIndicator startAnimating];
}

- (void)mapViewDidStopLocatingUser:(GSMapView *)mapView {
    _currentLocatingStatus = LocatingStatus_standBy;
    [_locateBarButtonInnerButton setImage:[UIImage imageNamed:@"MOCrossHair.png"] forSegmentAtIndex:0];
    [_activityIndicator stopAnimating];
}

- (void)mapView:(GSMapView *)mapView didSelectAnnotationView:(GSAnnotationView *)view {
    //id<GSAnnotation> annotation = view.annotation;
    
}

- (void)mapView:(GSMapView *)mapView didDeselectAnnotationView:(GSAnnotationView *)view {
    id<GSAnnotation> annotation = view.annotation;
    if ([annotation isEqual:_annotaionShouldStay]) {
        _annotaionShouldStay = nil;
    }
}

- (void)outOfCampusAlert {
	UIAlertView *outOfCampusAlert = [[UIAlertView alloc] initWithTitle:@"定位"
															   message:@"您所在的位置超出了当前地图的显示范围，您可尝试切换校区并重新定位。"
															  delegate:self
													 cancelButtonTitle:@"确认"
													 otherButtonTitles:nil];
	[outOfCampusAlert show];
}

- (CGPoint)convertToCGPointFromCoordinate:(CLLocationCoordinate2D)coordinate {
    
    CLLocationDegrees oriLatitude = _currentCampus == HITCAMPUS1 ? ORIGIANLPOINT_LATITUDE_CAMPUS1 : ORIGIANLPOINT_LATITUDE_CAMPUS2;
    CLLocationDegrees oriLongitude = _currentCampus == HITCAMPUS1 ? ORIGIANLPOINT_LONGTITUDE_CAMPUS1 : ORIGIANLPOINT_LONGTITUDE_CAMPUS2;
	// calculate x y on gMap
	CLLocation *location1 = [[CLLocation alloc] initWithLatitude:oriLatitude longitude:oriLongitude];
	CLLocation *locationX = [[CLLocation alloc] initWithLatitude:oriLatitude longitude:coordinate.longitude];
	CLLocation *locationY = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:oriLongitude];
	double x = [location1 distanceFromLocation:locationX];
	double y = [location1 distanceFromLocation:locationY];
    //	NSLog(@"x [%lf] y [%lf]", x, y);
	
	// change g to g_rotateas
	double gMapAngle1 = (_currentCampus == HITCAMPUS1) ? (51.68 / 360.0 * 2 * M_PI) : (10.5 / 360.0 * 2 * M_PI);  // 参数: 角度
	double gMapPointX = x;	//120;//5;//12.5;					  // 数据
	double gMapPointY = y;	//5;//120;//0;						  // 数据
    
	double tempGAngle = atan(gMapPointY / gMapPointX) - gMapAngle1;
    //	NSLog(@"gtA[%lf]", tempGAngle / (2*M_PI) * 360);
	double tempGLength = sqrt(pow(gMapPointX, 2.0) + pow(gMapPointY, 2.0));
    //	NSLog(@"gC[%lf]", tempGLength);
	double gMapPointRotateX = tempGLength * cos(tempGAngle);
	double gMapPointRotateY = tempGLength * sin(tempGAngle);
    //	NSLog(@"gRX[%lf]", gMapPointRotateX);
    //	NSLog(@"gRY[%lf]", gMapPointRotateY);
	
	// change g_rotate to h_rotate
	double hRotateXScaleToGRotateX = (_currentCampus == HITCAMPUS1) ? 1.545000 : 1.664836009;//878.38 / 550.8;	//1.09; //2.69 / 2.40; // 参数: 比例
	double hRotateYScaleToGRotateY = (_currentCampus == HITCAMPUS1) ? 1.580000 : 1.780045213;//1090.35 / 675.45;	//1.21; //1.90 / 1.23; // 参数: 比例
	double hMapPointRotateX = gMapPointRotateX * hRotateXScaleToGRotateX; // A
	double hMapPointRotateY = gMapPointRotateY * hRotateYScaleToGRotateY; // B
    //	NSLog(@"hRX[%lf]", hMapPointRotateX);
    //	NSLog(@"hRY[%lf]", hMapPointRotateY);
	
	// change h_rotate to h
	double hMapAngle1 = 31.8 / 360.0 * 2 * M_PI;	// 参数:角度 campus 1 and 2 are same
	double hMapAngle2 = 60.4 / 360.0 * 2 * M_PI;	// 参数:角度
	
	double hMapAngle0 = M_PI_2 - hMapAngle1 + hMapAngle2;
	BOOL hRotateXYGreaterThanZero = ((hMapPointRotateX * hMapPointRotateY) > 0);
	//int oneOrMinusOne = hRotateXYGreaterThanZero ? -1 : 1;
	double tempHAngleC = hMapAngle0; // angle c
	if (hRotateXYGreaterThanZero) {
		tempHAngleC = M_PI - hMapAngle0;
	}
    //	NSLog(@"hCA[%lf]", tempHAngleC / (2*M_PI) * 360);
	double tempHLength = sqrt(pow(hMapPointRotateX, 2.0) + pow(hMapPointRotateY, 2.0) - // C
							  2 * fabs(hMapPointRotateX) * fabs(hMapPointRotateY) * 
							  cos(tempHAngleC));
    //	NSLog(@"HC[%lf]", tempHLength);
	double tempHAngleB = acos((pow(hMapPointRotateX, 2.0) + pow(tempHLength, 2.0) - // B
							   pow(hMapPointRotateY, 2.0)) / (2 * fabs(hMapPointRotateX) * fabs(tempHLength)));
    //	NSLog(@"0hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	if (hMapPointRotateX > 0 && hMapPointRotateY > 0) {
		tempHAngleB = tempHAngleB;
        //		NSLog(@"1hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	else if (hMapPointRotateX > 0 && hMapPointRotateY <= 0) {
		tempHAngleB = 2 * M_PI - tempHAngleB;
        //		NSLog(@"2hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	else if (hMapPointRotateX <= 0 && hMapPointRotateY > 0) {
		tempHAngleB = M_PI - tempHAngleB;
        //		NSLog(@"3hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	else {
		tempHAngleB = M_PI + tempHAngleB;
        //		NSLog(@"4hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	
	
	double tempHAngle = tempHAngleB + hMapAngle1;
	double hMapPointX = tempHLength * cos(tempHAngle);
	double hMapPointY = tempHLength * sin(tempHAngle);
    //	NSLog(@"hX[%lf]", hMapPointX);
    //	NSLog(@"hY[%lf]", hMapPointY);
	
	int hMapPointXInt = (int)hMapPointX + ((_currentCampus == HITCAMPUS1) ? OFFSET1_ORIGINALPOINT_X : OFFSET2_ORIGINALPOINT_X);
    int hMapPointYInt = (_currentCampus == HITCAMPUS1) ? (CAMPUS1_HEIGHT - (int)(hMapPointY + OFFSET1_ORIGINALPOINT_Y)) : (CAMPUS2_HEIGHT - (int)(hMapPointY + OFFSET2_ORIGINALPOINT_Y));
    //	NSLog(@"hMapPointXInt[%d]", hMapPointXInt);
    //	NSLog(@"hMapPointYInt[%d]", hMapPointYInt);
	if ((hMapPointXInt <= 100) || 
		(hMapPointXInt >= ((_currentCampus == HITCAMPUS1) ? CAMPUS1_WIDTH : CAMPUS2_WIDTH) - 100) || 
		(hMapPointYInt <= 100) ||
		(hMapPointYInt >= ((_currentCampus == HITCAMPUS1) ? CAMPUS1_HEIGHT : CAMPUS2_HEIGHT) - 100)) {
		[self outOfCampusAlert];
		return CGPointMake(-1, -1);
	}
    return CGPointMake(hMapPointXInt, hMapPointYInt);
    //return CGPointMake(1947, 1939); //Center of a circle in campus1
}

- (CGFloat)convertToCGFloatFromAccuracy:(CLLocationAccuracy)accuracy {
    //accuracy = 100;
    return (CGFloat)accuracy * 2.4; // same value for two campus
}

#pragma mark - Settings View Delegate

- (void)shouldCurlViewDown {
    [_curlViewControl curlViewDown];
    _viewCurlUp = NO;
}

- (void)shouldShowAnnotatoins:(BOOL)show {
    if (_showAnnotations != show) {
        if (show) {
            [self addAnnotations];
        }
        else {
            [_mapScrollView removeAllAnnotations];
            _annotaionShouldStay = nil;
        }
        _showAnnotations = show;
    }
    [_curlViewControl curlViewDown];
    _viewCurlUp = NO;
}

- (void)shouldRemoveUserLocation {
    [_mapScrollView setShowUserLocation:NO];
    [_curlViewControl curlViewDown];
    _viewCurlUp = NO;
}

- (void)shouldChangeToCampus:(HITCampus)campus {
    if (_currentCampus != campus) {
        _currentCampus = campus;
        [self selectCampus:_currentCampus];
    }
    [_curlViewControl curlViewDown];
    _viewCurlUp = NO;
}

#pragma mark - SearchBar Delegate and Related

- (void)searchForText:(NSString *)text {
    [_searchAnnotationResults removeAllObjects];
    
    if ([text length] > 0) {
        for (HITPlaceAnotation *annotatoin in _currentCampusPlaces) {
            NSRange range = [annotatoin.title rangeOfString:text options:NSCaseInsensitiveSearch];
            if (range.length > 0) {
                [_searchAnnotationResults addObject:annotatoin];
            }
        }
    }
    else {
        [_searchAnnotationResults addObjectsFromArray:_currentCampusPlaces];
    }
    [_placesTableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // NSLog(@"searchbar frame:%@", NSStringFromCGRect(_searchBar.frame));
    [self.view addSubview:_placesTableView];
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionLayoutSubviews 
                     animations:^(void) {
                         [_placesTableView setAlpha:1.0f];
                         [_searchBar setFrame:CGRectMake(0, 0, 320, 44)];
                     } completion:NULL];
    
    [self searchForText:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchForText:searchBar.text];
}

- (void)cancleBarButtonClicked:(UIBarButtonItem *)barButtonItem {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [_searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionLayoutSubviews 
                     animations:^(void) {
                         [_placesTableView setAlpha:0.0f];
                         [_searchBar setFrame:CGRectMake(44 + 5, 0, 320 - 44 - 5, 44)];
                     } completion:^(BOOL finished) {
                         [_placesTableView removeFromSuperview];
                     }];

}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchAnnotationResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell.textLabel setText:[(HITPlaceAnotation *)[_searchAnnotationResults objectAtIndex:indexPath.row] title]];
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self cancleBarButtonClicked:nil];
    [_placesTableView deselectRowAtIndexPath:indexPath animated:YES];
    HITPlaceAnotation *annotation = [_searchAnnotationResults objectAtIndex:indexPath.row];
    [self showAndSelectAnnotation:annotation];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

@end
