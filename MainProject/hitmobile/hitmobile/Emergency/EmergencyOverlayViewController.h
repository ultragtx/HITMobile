//
//  EmergencyOverlayViewController.h
//  iHIT
//
//  Created by Bai Yalong on 11-4-4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmergencyViewController;

@interface EmergencyOverlayViewController : UIViewController {
	
	EmergencyViewController *rvController;
}

@property (nonatomic, retain) EmergencyViewController *rvController;

@end