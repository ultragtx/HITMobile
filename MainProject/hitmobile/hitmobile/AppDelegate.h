//
//  iHITAppDelegate.h
//  iHIT
//
//  Created by keywind on 11-9-26.
//  Copyright 2011年 Hit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsViewController.h"
#import "Places/PlacesViewController.h"
#import "SinaTweetQueueViewController.h"
#import "TiledMapViewController.h"
#import "EmergencyViewController.h"

#import "MapViewController.h"
#import "MenuTableViewController.h"
#import "IIViewDeckController.h"
#import "TransparentOverlayView.h"

@class BCTabBarController;
@interface AppDelegate : NSObject <UIApplicationDelegate, IIViewDeckControllerDelegate> {
    UIWindow *window;
	BCTabBarController *tabBarController;
    
    
    MenuTableViewController *_leftVC;
    
    IIViewDeckController *_deckViewController;
    
    NSArray *_viewControllers;
    
    TransparentOverlayView *_transparentOverlayView;
    
    int _currentVCIndex;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) BCTabBarController *tabBarController;

- (void)switchToViewControllerAtIndex:(int)index;
- (void)toggleRightView;
- (void)toggleLeftView;

@end
