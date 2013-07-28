//
//  CalculateAngleAppDelegate.h
//  CalculateAngle
//
//  Created by Hiro on 11-6-9.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CalculateAngleAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	double gMapAngle1;
	double hRotateXScaleToGRotateX;
	double hRotateYScaleToGRotateY;
	
	//double latitude;
	//double longtitude;
	
	int* correctPointX;
	int* correctPointY;
	
	int minAverage;
	
}

@property (assign) IBOutlet NSWindow *window;

@end
