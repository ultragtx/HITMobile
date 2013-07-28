//
//  RootViewController.h
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>
#import "TiledMapViewController.h"

@class OverlayViewController;

@interface SearchTableViewController : UITableViewController {
	
	NSMutableArray *listOfItems;
	NSMutableArray *copyListOfItems;
	
	BOOL searching;
	BOOL letUserSelectRow;
	
	OverlayViewController *ovController;
	UISearchBar *searchBar;
	UINavigationBar *customHeaderView;
	UIBarButtonItem *cancleBarButton;
	
	TiledMapViewController *parentTiledMapViewController;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UINavigationBar *customHeaderView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancleBarButton;
@property (nonatomic, retain) TiledMapViewController *parentTiledMapViewController;

- (void) searchTableView;
- (void) doneSearching_Clicked:(id)sender;
- (IBAction) cancleBarButtonPressed:(id)sender;

@end
