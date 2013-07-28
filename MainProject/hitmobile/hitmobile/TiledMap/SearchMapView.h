//
//  SearchMapView.h
//  iHIT
//
//  Created by Bai Yalong on 11-3-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define	FlagHeight	96
#define FlagWidth	96
#define MaxZoom1		2.5
#define MinZoom1		0.1
#define MaxZoom2		2.5
#define MinZoom2		0.2
#define HalfScreenHeight	208
#define HalfscreenWidth	160
#define Location1MapWidth	4488
#define Location1MapHeight	5160
#define Location2MapWidth	3300
#define Location2MapHeight	2442

@interface SearchMapView : UIViewController <UIScrollViewDelegate>{
	IBOutlet UIScrollView *MapView;	
	NSString *selectedPlace;
	UIImageView *HITmap;
	UIImageView *flag;
	float MapHeight;
	float MapWidth;
	float	CoorX;
	float	CoorY;
//    IBOutlet  UITextView *Description;
}

@property (nonatomic, strong) NSString *selectedPlace;
@property (nonatomic, strong) UIImageView *HITmap;
@property (nonatomic, strong) UIImageView *flag;

- (IBAction)SetOffsetOfHITMap:(CGPoint) Offset;

@end
