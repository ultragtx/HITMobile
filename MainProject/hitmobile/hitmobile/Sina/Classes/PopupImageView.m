//
//  PopupImageView.m
//  iHIT
//
//  Created by Hiro on 11-4-5.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import "PopupImageView.h"


@implementation PopupImageView

@synthesize tweetLargeImage;
@synthesize activityIndicator;
@synthesize imageScrollView;

- (void)setImageForImageScrollView:(UIImage *)tweetImage {
	float maxWidth = self.imageScrollView.frame.size.width;
	//float maxHeight = self.imageScrollView.frame.size.height;
	//NSLog(@"imageScrollView w:[%f] h:[%f]", maxWidth, maxHeight);
	float imageWidth = tweetImage.size.width;
	float imageHeight = tweetImage.size.height;
	float aspectRatio = imageWidth / imageHeight;
	
	//NSLog(@"image  w:[%f] h:[%f]", imageWidth, imageHeight);
	CGRect imageViewFrame = CGRectMake(0, 0, maxWidth,  maxWidth / aspectRatio);
	UIButton *imageButton = [[UIButton alloc] initWithFrame:imageViewFrame];
	[imageButton setImage:tweetImage forState:UIControlStateNormal];
	[imageButton addTarget:self
					action:@selector(imageButtonTouchUpInside:)
		  forControlEvents:UIControlEventTouchUpInside];
	[self.imageScrollView addSubview:imageButton];
	double minScrollViewHeight = fmin(self.imageScrollView.frame.size.height, imageButton.frame.size.height);
	self.imageScrollView.frame = CGRectMake(self.imageScrollView.frame.origin.x,
											self.imageScrollView.frame.origin.y, 
											self.imageScrollView.frame.size.width, 
											minScrollViewHeight);
	self.imageScrollView.center = self.center;
	[self.imageScrollView setContentSize:CGSizeMake(imageButton.frame.size.width, 
													imageButton.frame.size.height + 1)];
	[self.imageScrollView flashScrollIndicators];
	

}

- (IBAction)imageButtonTouchUpInside:(id)sender {
	[self removeFromSuperview];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self removeFromSuperview];
}

- (void)dealloc {
	[tweetLargeImage release];
	[activityIndicator release];
	[imageScrollView release];
	[super dealloc];
}

@end
