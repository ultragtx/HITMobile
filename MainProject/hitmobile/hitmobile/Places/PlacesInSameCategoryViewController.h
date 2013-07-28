//
//  PlacesInSameCategoryViewController.h
//  iHIT
//
//  Created by FoOTOo on 11-6-15.
//  Copyright 2011 HIT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlacesInSameCategoryViewController : UITableViewController {
	NSInteger category;
	
	NSArray *placesNames;
	NSArray *placesGeos;
	
	NSArray *plays;
}

@property (nonatomic, assign) NSInteger category;
@property (nonatomic, retain) NSArray *placesNames;
@property (nonatomic, retain) NSArray *placesGeos;

@property (nonatomic, retain) NSArray *plays;

- (void)getRoute:(NSString *)destination;
- (void)setUpPlaysArray:(NSInteger)index;
@end
