//
//  PlacesViewController.h
//  iHIT
//
//  Created by FoOTOo on 11-6-15.
//  Copyright 2011 HIT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlacesViewController : UITableViewController {
	NSArray *categories;
	//NSInteger *categoryIndex;
}

@property (nonatomic, retain) NSArray *categories;
//@property (nonatomic, assign) NSInteger *categoryIndex;
@end
