//
//  SingleTweetViewController.m
//  iHIT
//
//  Created by Hiro on 11-4-3.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import "SingleTweetViewController.h"
#import "AppDelegate.h"
#import "UIButton+WebCache.h"

@implementation SingleTweetViewController

@synthesize profileImageView;
@synthesize labelForProfileName;

@synthesize tweetScrollView;
@synthesize labelForTweetBody;
@synthesize labelForSendTime;
@synthesize imageButton;
@synthesize profileImage;
@synthesize indexNumber;
@synthesize tweetSmallImage;
@synthesize tweetBigImage;
@synthesize tweetSmallImageURL;
@synthesize tweetBigImageURL;
@synthesize tweetSmallImageDownloader;
@synthesize popUpImageView;

@synthesize singleStatus;
@synthesize composeViewController;
@synthesize textViewForTweetBody;
@synthesize successActionSheet;

+ (NSString *)dateFormatWithTimeVal:(time_t)timeValSince1970 {
	NSDate *tempDate = [NSDate dateWithTimeIntervalSince1970:timeValSince1970];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateFormatter setLocale:locale];
	[locale release];
	[dateFormatter setDateFormat:@"发送时间: yyyy-MM-dd HH:mm:ss"];
	NSString *targetDateString;
	targetDateString = [NSString stringWithString:[dateFormatter stringFromDate:tempDate]];
	[dateFormatter release];
	return targetDateString;
}

- (void)initWork {

}

- (void)startImageDownload:(NSString *)imageURL imageType:(ImageType) imageType;{
	tweetSmallImageDownloader = [[ImageDownloader alloc] init];
	tweetSmallImageDownloader.delegate = self;
	[tweetSmallImageDownloader startDownload:imageURL atIndexPath:nil imageType:imageType];
}

- (void)setViewData {
	profileImageView.image = self.profileImage;//[UIImage imageNamed:@"hitSinaImage.png"];
	//NSLog(@"statusId: %llu", singleStatus.statusId);
	labelForProfileName.text = singleStatus.user.screenName;
	
	//chage UILable to UITextView for the body
	textViewForTweetBody = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, 320 - 10 * 2, 2000)];
	textViewForTweetBody.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
	textViewForTweetBody.text = [SinaTweetQueue getTextFromStatus:self.singleStatus];
	[textViewForTweetBody sizeToFit];
	textViewForTweetBody.dataDetectorTypes = UIDataDetectorTypeLink;
	textViewForTweetBody.editable = NO;
	textViewForTweetBody.scrollEnabled = NO;
	[self.tweetScrollView addSubview:textViewForTweetBody];
	
	self.tweetBigImageURL = [self.singleStatus.bmiddlePic length] == 0 ? self.singleStatus.retweetedStatus.bmiddlePic : self.singleStatus.bmiddlePic;
	self.tweetSmallImageURL = [self.singleStatus.thumbnailPic length] == 0 ? self.singleStatus.retweetedStatus.thumbnailPic : self.singleStatus.thumbnailPic;
	if ([self.tweetSmallImageURL length]) {
		imageButton = [[UIButton alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(textViewForTweetBody.frame) + 10, 320 - 40 * 2, 100)];
        [imageButton setImageWithURL:[NSURL URLWithString:tweetSmallImageURL] placeholderImage:[UIImage imageNamed:@"contentview_image_default.png"]];
		/*[imageButton setImage:(tweetSmallImage ? tweetSmallImage : [UIImage imageNamed:@"Placeholder.png"])
					 forState:UIControlStateNormal];
		if (!tweetSmallImage) {
			[self startImageDownload:tweetSmallImageURL imageType:IMAGE_SMALL];
		}*/
		//[imageButton sizeToFit];
		imageButton.contentMode = UIViewContentModeScaleAspectFit;
		[imageButton addTarget:self action:@selector(imageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self.tweetScrollView addSubview:imageButton];
	}
	
	labelForSendTime = [[UILabel alloc] initWithFrame:CGRectMake(8, CGRectGetMaxY(imageButton ? imageButton.frame : textViewForTweetBody.frame) + 5, 320 - 8 * 2, 2000)];
	labelForSendTime.textColor = [UIColor grayColor];
	labelForSendTime.numberOfLines = 1;
	labelForSendTime.font = [UIFont systemFontOfSize:13];
	labelForSendTime.text = [SingleTweetViewController dateFormatWithTimeVal:self.singleStatus.createdAt];
	[labelForSendTime sizeToFit];
	[self.tweetScrollView addSubview:labelForSendTime];
	
	[self.tweetScrollView setContentSize:CGSizeMake(self.view.frame.size.width, fmax(self.tweetScrollView.frame.size.height + 1, CGRectGetMaxY(labelForSendTime.frame) + 25))];
}

- (void) viewWillAppear:(BOOL)animated {
	[self initWork];
	[self setViewData];
	
	//set bar button
	UIBarButtonItem *commentOrRetweetButton = [[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
											   target:self action:@selector(commentOrRetweetButtonPressed:)];
	self.navigationItem.rightBarButtonItem = commentOrRetweetButton;
	[commentOrRetweetButton release];
}

- (void) viewWillDisappear:(BOOL)animated {
	if (tweetSmallImageDownloader) {
		[tweetSmallImageDownloader cancelDownload];
		tweetSmallImageDownloader = nil;
	} 
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)beginCompose {
	//[self presentModalViewController:self.composeViewController animated:YES];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [navController.navigationBar setBarStyle:UIBarStyleBlack];
    [self presentModalViewController:navController animated:YES];
	[composeViewController prepareWithComposeType:currentDraftType StatusID:self.singleStatus.statusId];
	composeViewController.delegate = self;
}


#pragma mark -
#pragma mark Button Event

- (void)imageButtonPressed:(id)sender {
	//NSLog(@"imageButtonPressed");

	[self.view addSubview:popUpImageView];
	//popUpImageView.tweetLargeImage = (UIImageView *)[popUpImageView viewWithTag:1];
	//popUpImageView.activityIndicator = (UIActivityIndicatorView *)[popUpImageView viewWithTag:2];
	popUpImageView.activityIndicator.hidesWhenStopped = YES;
	if (!tweetBigImage) {
		[self startImageDownload:tweetBigImageURL imageType:IMAGE_LARGE];
		[popUpImageView.activityIndicator startAnimating];
	}
	else {
		//[popUpImageView.tweetLargeImage setImage:tweetBigImage];
		[popUpImageView setImageForImageScrollView:self.tweetBigImage];
	}
}

- (void)commentOrRetweetButtonPressed:(id)sender
{
	//NSLog(@"commentOrRetweetButtonPressed");
	UIActionSheet *commentOrRetweetMenu = [[UIActionSheet alloc] 
										   initWithTitle:@"" delegate:self 
										   cancelButtonTitle:@"取消" 
										   destructiveButtonTitle:nil
										   otherButtonTitles:@"转发", @"评论", nil];
	//[commentOrRetweetMenu showInView:self.view];
    [commentOrRetweetMenu showInView:[[[UIApplication sharedApplication] delegate] window]];
    [commentOrRetweetMenu release];
	
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {		
		case 0:
			currentDraftType = DraftTypeReTweet;
			break;
		case 1:
			currentDraftType = DraftTypeReplyComment;
			break;
		default:
			return;
	}
	[self beginCompose];
}

#pragma mark -
#pragma mark ImageDownloaderDelegate

- (void)imageDidLoad:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath imageType:(ImageType)imageType{
	//NSLog(@"imageDidLoad");
	switch (imageType) {
		case IMAGE_SMALL:
			[self setTweetSmallImage:image];
			[imageButton setImage:self.tweetSmallImage forState:UIControlStateNormal];
			break;
		case IMAGE_LARGE:
			[self setTweetBigImage:image];
			[popUpImageView.activityIndicator stopAnimating];
			//[popUpImageView.tweetLargeImage setImage:self.tweetBigImage];
			[popUpImageView setImageForImageScrollView:self.tweetBigImage];
			break;
		default:
			NSLog(@"bad image type!");
			break;
	}
}

#pragma mark -
#pragma mark ComposeViewControllerDelegate

- (void)dissmissTweetSendSuccess {
	[successActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)tweetSendSuccess {
	if (!successActionSheet) {
		successActionSheet = [[UIActionSheet alloc] initWithTitle:@"发送成功" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	}
	//[successActionSheet showInView:self.view];
    [successActionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
	[self performSelector:@selector(dissmissTweetSendSuccess) withObject:nil afterDelay:1];
}

#pragma mark -
#pragma mark Memory Contol

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	profileImageView = nil;
	labelForProfileName = nil;
	tweetScrollView = nil;
	popUpImageView = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[profileImageView release];
	[labelForProfileName release];
	
	[tweetScrollView release];
	[labelForTweetBody release];
	[labelForSendTime release];
	[imageButton release];
	
	[profileImage release];
	[tweetSmallImage release];
	[tweetBigImage release];
	[tweetSmallImageURL release];
	[tweetBigImageURL release];
	[tweetSmallImageDownloader release];
	
	[popUpImageView release];
	
	[singleStatus release];
	[composeViewController release];
	[textViewForTweetBody release];

    [super dealloc];
}


@end
