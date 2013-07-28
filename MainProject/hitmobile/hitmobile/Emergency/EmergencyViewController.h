//
//  EmergencyViewController.h
//  iHIT
//
//  Created by Bai Yalong on 11-3-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmergencyCell.h"

@class EmergencyOverlayViewController;

@interface EmergencyViewController : UITableViewController<UIAlertViewDelegate> {
	NSMutableArray *listOfItems;
	EmergencyCell *tmpcell;
	UINib 	*cellnib;
	
	NSMutableArray *copyListOfItems_icon;
	NSMutableArray *copyListOfItems_chineseDescription;
	NSMutableArray *copyListOfItems_englishDescription;
	NSMutableArray *copyListOfItems_telephoneNumber;
	IBOutlet UISearchBar *searchBar;
	BOOL searching;
	BOOL letUserSelectRow;
	
	EmergencyOverlayViewController *ovController;
}
@property (nonatomic, retain) IBOutlet EmergencyCell *tmpCell;

@property (nonatomic, retain) UINib *cellNib;
- (IBAction)telephoneCall:(NSString *)input;
- (void) searchTableView;
- (void) doneSearching_Clicked:(id)sender;

@end
