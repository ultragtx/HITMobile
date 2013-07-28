//
//  SingleTweetViewController.h
//  iHIT
//
//  Created by Hiro on 11-4-3.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"
#import "PopupImageView.h"
#import "GetSinaTweet.h"
#import "SinaTweetQueue.h"
#import "ComposeViewController.h"

@interface SingleTweetViewController : UIViewController 
<ImageDownloaderDelegate, UIActionSheetDelegate, UITextFieldDelegate, 
UIAlertViewDelegate, UITextViewDelegate, GetSinaTweetDelegate, ComposeViewControllerDelegate>{
	int indexNumber;
	
	UIImageView *profileImageView;
	UILabel *labelForProfileName;
	
	UIScrollView *tweetScrollView;
	UILabel *labelForTweetBody;
	UILabel *labelForSendTime;
	UIButton *imageButton;
	
	UIImage *profileImage;
	UIImage *tweetSmallImage;
	UIImage *tweetBigImage;
	NSString *tweetSmallImageURL;
	NSString *tweetBigImageURL;
	ImageDownloader *tweetSmallImageDownloader;
	
	PopupImageView *popUpImageView;
	
	Status *singleStatus;
	DraftType currentDraftType;
	
	ComposeViewController *composeViewController;
	UITextView *textViewForTweetBody;
	UIActionSheet *successActionSheet;
}

@property (nonatomic) int indexNumber;

@property (nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property (nonatomic, retain) IBOutlet UILabel *labelForProfileName;

@property (nonatomic, retain) IBOutlet UIScrollView *tweetScrollView;
@property (nonatomic, retain) UILabel *labelForTweetBody;
@property (nonatomic, retain) UILabel *labelForSendTime;
@property (nonatomic, retain) UIButton *imageButton;
@property (nonatomic, retain) UIImage *profileImage;
@property (nonatomic, retain) UIImage *tweetSmallImage;
@property (nonatomic, retain) UIImage *tweetBigImage;
@property (nonatomic, retain) NSString *tweetSmallImageURL;
@property (nonatomic, retain) NSString *tweetBigImageURL;
@property (nonatomic, retain) ImageDownloader *tweetSmallImageDownloader;

@property (nonatomic, retain) IBOutlet PopupImageView *popUpImageView;
@property (nonatomic, retain) UIActionSheet *successActionSheet;
@property (nonatomic, retain) Status *singleStatus;
@property (nonatomic, retain) IBOutlet ComposeViewController *composeViewController;
@property (nonatomic, retain) UITextView *textViewForTweetBody;
@end
