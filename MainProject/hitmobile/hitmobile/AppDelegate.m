//
//  iHITAppDelegate.m
//  iHIT
//
//  Created by keywind on 11-9-26.
//  Copyright 2011年 Hit. All rights reserved.
//

#import "AppDelegate.h"
#import "BCTabBarController.h"
#import "NewsViewController.h"
#import "Places/PlacesViewController.h"
#import "SinaTweetQueueViewController.h"
#import "TiledMapViewController.h"
#import "EmergencyViewController.h"

#import "MapViewController.h"
#import "MenuTableViewController.h"
#import "IIViewDeckController.h"

#define DECKVIEW_MAX_OFFSET 275.0f
#define TRANSPARENTVIEW_MAX_ALPHA 0.3f

@implementation AppDelegate

@synthesize window, tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	self.tabBarController = [[[BCTabBarController alloc] init] autorelease];
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:
											 [[[UINavigationController alloc]
                                               initWithRootViewController:[[[NewsViewController alloc] init] autorelease]]
											  autorelease],
											 [[[UINavigationController alloc]
                                               initWithRootViewController:[[[SinaTweetQueueViewController alloc] 
                                                                            initWithNibName:@"SinaTweetQueueTableView" 
                                                                            bundle:nil] autorelease]]
											  autorelease],
											 [[[UINavigationController alloc]
                                               initWithRootViewController:[[[TiledMapViewController alloc] init] autorelease]]
											  autorelease],
											 [[[UINavigationController alloc]
                                               initWithRootViewController:[[[PlacesViewController alloc] init] autorelease]]
											  autorelease],
											 [[[UINavigationController alloc]
                                               initWithRootViewController:[[[EmergencyViewController alloc] initWithNibName:@"EmergencyViewController" bundle:nil] autorelease]]
											  autorelease],
											 nil];
	[self.window addSubview:self.tabBarController.view];
    [self.window makeKeyAndVisible];
    return YES;*/
    
    _currentVCIndex = 0;
  
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _transparentOverlayView = [[TransparentOverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 480 - 20)];
    [_transparentOverlayView setAlpha:0.0f];
    
    NewsViewController *newVC = [[NewsViewController alloc] init];
    SinaTweetQueueViewController *sinaWeiboVC = [[SinaTweetQueueViewController alloc] initWithNibName:@"SinaTweetQueueTableView" bundle:nil];
    MapViewController *mapVC = [[MapViewController alloc] init];
    PlacesViewController *placesVC = [[PlacesViewController alloc] init];
    EmergencyViewController *emergencyVC = [[EmergencyViewController alloc] initWithNibName:@"EmergencyViewController" bundle:nil] ;
    
    _leftVC = [[[MenuTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    
    UINavigationController *newsNavViewController = [[UINavigationController alloc] initWithRootViewController:newVC];
    UINavigationController *sinaWeiboNavViewController = [[UINavigationController alloc] initWithRootViewController:sinaWeiboVC];
    UINavigationController *mapviewNavController = [[UINavigationController alloc] initWithRootViewController:mapVC];
    UINavigationController *placesNavViewController = [[UINavigationController alloc] initWithRootViewController:placesVC];
    UINavigationController *emergencyNavViewController = [[UINavigationController alloc] initWithRootViewController:emergencyVC];
    
    _viewControllers = [[NSArray alloc] initWithObjects:newsNavViewController, sinaWeiboNavViewController, mapviewNavController, placesNavViewController, emergencyNavViewController, nil];
    
    [newVC  release];
    [sinaWeiboVC release];
    [mapVC release];
    [placesVC release];
    [emergencyVC release];
    
    [newsNavViewController release];
    [sinaWeiboNavViewController release];
    [mapviewNavController release];
    [placesNavViewController release];
    [emergencyNavViewController release];
    
    _deckViewController = [[IIViewDeckController alloc] initWithCenterViewController:[_viewControllers objectAtIndex:_currentVCIndex] leftViewController:_leftVC];
    [_deckViewController setDelegate:self];
    
    self.window.rootViewController = _deckViewController;
    [self.window makeKeyAndVisible];
    
    // Show menu first
    [self toggleLeftView];
    
    
    return YES;
}

- (void)dealloc
{
    [tabBarController release];
    [window release];
    
    [_leftVC release];
    [_deckViewController release];

    [_transparentOverlayView release];
    
    [_viewControllers release];
     
    [super dealloc];
}

#pragma mark - Public Method

- (void)toggleLeftView {
    [_deckViewController toggleLeftViewAnimated:YES];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_transparentOverlayView setAlpha:TRANSPARENTVIEW_MAX_ALPHA];
    }];
}

- (void)toggleRightView {
    [_deckViewController closeLeftViewAnimated:YES];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_transparentOverlayView setAlpha:0.0];
    }];
}

- (void)switchToViewControllerAtIndex:(int)index {
    _currentVCIndex = index;
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_transparentOverlayView setAlpha:0.0];
    }];
    
    [_deckViewController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        [_deckViewController setCenterController:[_viewControllers objectAtIndex:_currentVCIndex]];
    }];
}

#pragma mark - IIViewDeckControllerDelegate

- (void)viewDeckController:(IIViewDeckController*)viewDeckController didPanToOffset:(CGFloat)offset; {
    
    CGFloat alpha = offset / DECKVIEW_MAX_OFFSET * TRANSPARENTVIEW_MAX_ALPHA;
    [_transparentOverlayView setAlpha:alpha];
}

- (BOOL)viewDeckControllerWillOpenLeftView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    //NSLog(@"will  open left");
    UIViewController *vc = [_viewControllers objectAtIndex:_currentVCIndex];
    [vc.view addSubview:_transparentOverlayView];
    return YES;
}

- (void)viewDeckControllerDidCloseLeftView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    //NSLog(@"did close left");
    [_transparentOverlayView removeFromSuperview];
    
}

@end
