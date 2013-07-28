//
//  SinaTweetQueueTableViewController.h
//  iHIT
//
//  Created by Hiro on 11-4-2.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "SinaTweetQueue.h"
#import "SingleTweetViewController.h"



@interface SinaTweetQueueViewController : UIViewController 
<EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, SinaTweetQueueDelegate>{
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes 
	BOOL _reloading;
	
	UITableView *sinaTableView;
	
	SinaTweetQueue *sinaTweetQueue;
	
	UIActivityIndicatorView *lastCellActivityIndicator;
	
	UIView *loadingView;
	
	UIImage *profileImageForPerformance;
}

@property (nonatomic, retain) IBOutlet UITableView *sinaTableView;
@property (nonatomic, retain) SinaTweetQueue *sinaTweetQueue;
@property (nonatomic, retain) UIActivityIndicatorView *lastCellActivityIndicator;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) UIImage *profileImageForPerformance;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
