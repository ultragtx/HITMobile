//
//  PopupImageView.h
//  iHIT
//
//  Created by Hiro on 11-4-5.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PopupImageView : UIView {
	UIImageView *tweetLargeImage;
	UIActivityIndicatorView *activityIndicator;
	UIScrollView *imageScrollView;
}

@property (nonatomic, retain) IBOutlet UIImageView *tweetLargeImage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIScrollView *imageScrollView;

- (void)setImageForImageScrollView:(UIImage *)tweetImage;

@end
