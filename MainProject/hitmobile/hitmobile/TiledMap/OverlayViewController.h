//
//  OverlayViewController.h
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>

@class SearchTableViewController;

@interface OverlayViewController : UIViewController {

	SearchTableViewController *rvController;
}

@property (nonatomic, retain) SearchTableViewController *rvController;

@end
