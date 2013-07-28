//
//  ComposeViewController.h
//  SinaUnOffiTest
//
//  Created by Hiro on 11-5-2.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboClient.h"
#import "Draft.h"
#import "OAuthEngine.h"
#import "GetSinaTweet.h"
#import "UserListViewController.h"
#import "SinaTweetQueue.h"

@protocol ComposeViewControllerDelegate

- (void)tweetSendSuccess;

@end


@interface ComposeViewController : UIViewController <GetSinaTweetDelegate, UserListViewControllerDelegate>{
	UIBarButtonItem *buttonSend;
	UIBarButtonItem *buttonCancle;
	UIBarButtonItem *buttonChangeUser;
	UIButton *buttonInBarButtonChangeUser;
	UITextView *textViewMessage;
	Draft *draft;
	DraftType draftType;
	
	UserListViewController *userListViewController;
	User *currentUser;
	
	NSMutableArray *sinaRetweetCommentArray;
	
	UILabel *wordCounterLabel;
	int wordCount;
	
	id<ComposeViewControllerDelegate> delegate;
    
    UIView *_blockerView;
    
    UISegmentedControl *_changeUserButton;
}

@property (nonatomic, retain) UIBarButtonItem *buttonSend;
@property (nonatomic, retain) UIBarButtonItem *buttonCancle;
@property (nonatomic, retain) UIBarButtonItem *buttonChangeUser;
@property (nonatomic, retain) IBOutlet UITextView *textViewMessage;
@property (nonatomic, retain) Draft *draft;
@property (nonatomic, retain) IBOutlet UserListViewController *userListViewController;
@property (nonatomic, retain) User *currentUser;
@property (nonatomic, retain) NSMutableArray *sinaRetweetCommentArray;
@property (nonatomic, retain) UILabel *wordCounterLabel;
@property (nonatomic, assign) int wordCount;
@property (nonatomic, assign) id<ComposeViewControllerDelegate> delegate;

- (void)prepareWithComposeType:(DraftType) type StatusID:(long long) statusID;

- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)cancleButtonPressed:(id)sender;
- (IBAction)changeUserButtonPressed:(id)sender;

@end
