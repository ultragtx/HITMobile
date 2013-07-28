//
//  EmergencyOverlayViewController.m
//  iHIT
//
//  Created by Bai Yalong on 11-4-4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EmergencyOverlayViewController.h"
#import "EmergencyViewController.h"

@implementation EmergencyOverlayViewController

@synthesize rvController;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[rvController doneSearching_Clicked:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[rvController release];
    [super dealloc];
}


@end