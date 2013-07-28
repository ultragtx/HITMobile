//
//  ComposeViewController.m
//  SinaUnOffiTest
//
//  Created by Hiro on 11-5-2.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import "ComposeViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ComposeViewController

@synthesize buttonSend;
@synthesize buttonCancle;
@synthesize buttonChangeUser;
@synthesize textViewMessage;
@synthesize draft;
@synthesize userListViewController;
@synthesize currentUser;
@synthesize sinaRetweetCommentArray;
@synthesize wordCounterLabel;
@synthesize wordCount;
@synthesize delegate;

- (void)prepareWithComposeType:(DraftType) type StatusID:(long long) statusID {
	[draft release];
	//draftType = type;
	switch (type) {
		case DraftTypeReTweet:
			self.buttonSend.title = @"转发";
			break;
		case DraftTypeReplyComment:
			self.buttonSend.title = @"评论";
			break;
		default:
			break;
	}
	draft = [[Draft alloc]initWithType:type];
	draft.statusId = statusID;
}

- (void)loadUserFromPlist {
	if (currentUser) {
        [_changeUserButton setTitle:[currentUser screenName] forSegmentAtIndex:0];
        [_changeUserButton setEnabled:YES forSegmentAtIndex:0];
	}
	else {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSData *tempDataForStatus = [userDefaults objectForKey:@"SinaUser_0"];
		[Status setDecodeCount:0];
		[Status setEncodeCount:0];
		[User setDecodeCount:0];
		[User setEncodeCount:0];		
		self.currentUser = [((Status *)[NSKeyedUnarchiver unarchiveObjectWithData:tempDataForStatus]) user];
		NSString *tempTitleString = self.currentUser ? self.currentUser.screenName : @"新用户";
        [_changeUserButton setTitle:tempTitleString forSegmentAtIndex:0];
        [_changeUserButton setEnabled:(self.currentUser != nil) forSegmentAtIndex:0];

	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    buttonSend = [[UIBarButtonItem alloc] initWithTitle:@"转发" style:UIBarButtonItemStyleBordered target:self action:@selector(sendButtonPressed:)];
    buttonCancle = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(cancleButtonPressed:)];
    
    _changeUserButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"新用户"]];
    [_changeUserButton setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_changeUserButton setTintColor:[UIColor darkGrayColor]];
    [_changeUserButton setMomentary:YES];
    [_changeUserButton addTarget:self action:@selector(changeUserButtonPressed:) forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setLeftBarButtonItem:buttonCancle];
    [self.navigationItem setRightBarButtonItem:buttonSend];
    [self.navigationItem setTitleView:_changeUserButton];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textViewMessageDidChange:)
												 name:UITextViewTextDidChangeNotification
											   object:textViewMessage];
	sinaRetweetCommentArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    wordCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(258, 203 - 44 - 44, 42, 21)];
    
	self.wordCounterLabel.textAlignment = UITextAlignmentRight;
	self.wordCounterLabel.textColor = [UIColor grayColor];
    [self.view addSubview:wordCounterLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	
    
    _blockerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 200, 60)];
	_blockerView.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.8];
	_blockerView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
	_blockerView.alpha = 0.0;
	_blockerView.clipsToBounds = YES;
	if ([_blockerView.layer respondsToSelector: @selector(setCornerRadius:)]) [(id) _blockerView.layer setCornerRadius: 10];
	
	UILabel	*label = [[[UILabel alloc] initWithFrame: CGRectMake(0, 5, _blockerView.bounds.size.width, 15)] autorelease];
    label.text = NSLocalizedString(@"发送中...", nil);
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = UITextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize: 15];
	[_blockerView addSubview: label];
	
	UIActivityIndicatorView				*spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite] autorelease];
	
	spinner.center = CGPointMake(_blockerView.bounds.size.width / 2, _blockerView.bounds.size.height / 2 + 10);
	[_blockerView addSubview: spinner];
	//[self.view addSubview: _blockerView];
    
	[spinner startAnimating];

}

- (void)viewWillAppear:(BOOL)animated {
	[textViewMessage becomeFirstResponder];
	[self loadUserFromPlist];
    self.wordCounterLabel.text = [NSString stringWithFormat:@"%d", textViewMessage.text.length];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:_blockerView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_blockerView removeFromSuperview];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (int)sinaCountWord:(NSString*)s {
    int i,n=[s length],l=0,a=0,b=0;
    unichar c;
    for (i = 0; i < n; i++) {
        c=[s characterAtIndex:i];
        if (isblank(c)){
            b++;
        }
		else if (isascii(c)) {	
            a++;
        }else {
            l++;
        }
    }
    if(a == 0 && l == 0) return 0;
    return l + (int)ceilf((float)(a + b) / 2.0);
	
}

- (void)textViewMessageDidChange:(id)sender {
	buttonSend.enabled = textViewMessage.text.length > 0;
	draft.text = textViewMessage.text;
	// TODO: limit 140
	self.wordCount = [self sinaCountWord:textViewMessage.text];
	self.wordCounterLabel.text = [NSString stringWithFormat:@"%d", wordCount];
	self.wordCounterLabel.textColor = wordCount > 140 ? [UIColor redColor] : [UIColor grayColor];
	
}

- (void)postTweet {
    _blockerView.alpha = 1.0;
	GetSinaTweet *sinaRetweetComment = nil;
	switch (draft.draftType) {
		case DraftTypeReTweet:
			sinaRetweetComment = [[GetSinaTweet alloc] initWithRetweetOrComment:TYPE_RETWEET 
														   CallerViewController:self 
																	   SetDraft:self.draft 
																WithOAuthedUser:self.currentUser];
			sinaRetweetComment.delegate = self;
			[self.sinaRetweetCommentArray addObject:sinaRetweetComment];
			[sinaRetweetComment sinaStart];
			[sinaRetweetComment release];
			break;
		case DraftTypeReplyComment:
			sinaRetweetComment = [[GetSinaTweet alloc] initWithRetweetOrComment:TYPE_COMMENT CallerViewController:self SetDraft:self.draft WithOAuthedUser:self.currentUser];
			sinaRetweetComment.delegate = self;
			[self.sinaRetweetCommentArray addObject:sinaRetweetComment];
			[sinaRetweetComment sinaStart];
			[sinaRetweetComment release];
			break;
		default:
			NSLog(@"error type");
			break;
	}
}


#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    buttonSend = nil;
	buttonCancle = nil;
	buttonChangeUser = nil;
	textViewMessage = nil;
	buttonInBarButtonChangeUser = nil;
	wordCounterLabel = nil;
	
}

- (void)releaseSinaRetweetCommentArray {
	for (GetSinaTweet *tempSinaRetweetComment in self.sinaRetweetCommentArray) {
		tempSinaRetweetComment.delegate = nil;
	}
	[self.sinaRetweetCommentArray release];
}

- (void)dealloc {
	[buttonSend release];
	[buttonCancle release];
	[textViewMessage release];
	[draft release];
	[wordCounterLabel release];
	[buttonChangeUser release];
	[buttonInBarButtonChangeUser release];
	[userListViewController release];
	[currentUser release];
    [_blockerView release];
    
    [_changeUserButton release];
	[self releaseSinaRetweetCommentArray];

    [super dealloc];
}


#pragma mark -
#pragma mark changeUser

- (void)loadChangeUserView {
	NSMutableArray *userListArray = [[NSMutableArray alloc] init];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSData *tempDataForStatus = nil;
	Status *tempStatus = nil;
	int savedUserCounts = -1;
	do {
		[Status setDecodeCount:0];
		[Status setEncodeCount:0];
		[User setDecodeCount:0];
		[User setEncodeCount:0];	
		tempDataForStatus = [userDefaults objectForKey:[NSString stringWithFormat:@"SinaUser_%d", ++savedUserCounts]];
		if (tempDataForStatus) {
			tempStatus = [NSKeyedUnarchiver unarchiveObjectWithData:tempDataForStatus];
			[userListArray addObject:tempStatus];
		}
	} while (tempDataForStatus);
	[userListViewController setUserList:userListArray];
	[userListArray release];
	userListViewController.delegate = self;
	[self presentModalViewController:self.userListViewController animated:YES];
}


#pragma mark -
#pragma mark IBAction

- (IBAction)sendButtonPressed:(id)sender {
	if (self.wordCount > 140) {
		UIAlertView *tooManyWordsAlertView = [[UIAlertView alloc] initWithTitle:@"不允许发送消息" 
																		message:@"消息文字不可以超过140个字" 
																	   delegate:self 
															  cancelButtonTitle:@"确认" 
															  otherButtonTitles:nil];
		[tooManyWordsAlertView show];
		[tooManyWordsAlertView release];
	}
	else {
		[self postTweet];
	}
}

- (IBAction)cancleButtonPressed:(id)sender {
	textViewMessage.text = @"";
	buttonSend.enabled = NO;
	//[self.parentViewController dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)changeUserButtonPressed:(id)sender {
	//NSLog(@"change user button clicked");
	[self loadChangeUserView];
}

#pragma mark -
#pragma mark GetSinaTweetDelegate

- (void)didFinishSending:(Status *)status saveUserAtIndex:(int)index{
	// save curren user information
    _blockerView.alpha = 0.0;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[Status setDecodeCount:0];
	[Status setEncodeCount:0];
	[User setDecodeCount:0];
	[User setEncodeCount:0];
	NSData *tempDataForStatus = [NSKeyedArchiver archivedDataWithRootObject:status];
	[userDefaults setObject:tempDataForStatus forKey:[NSString stringWithFormat:@"SinaUser_%d", index]];
	[userDefaults synchronize];
	self.currentUser = status.user;
	//[self cancleButtonPressed:nil];
    [self performSelector:@selector(cancleButtonPressed:) withObject:nil afterDelay:0.3];
	[delegate tweetSendSuccess];
}

- (void)didStopSending {
    _blockerView.alpha = 0.0;
}


#pragma mark -
#pragma mark UserListViewControllerDelegate

- (void)didSelectUser:(Status *)status {
	//NSLog(@"didselectUser");
	self.currentUser = [status user];
}

- (void)didSelectNewUser {
	//NSLog(@"didSelectNewUser");
	self.currentUser.userId = 0;
	self.currentUser.screenName = @"新用户";
}

#pragma mark -
#pragma mark Keyboard Show Hide

- (void)keyboardWillShow:(NSNotification*) notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    wordCounterLabel.center = CGPointMake(wordCounterLabel.center.x, CGRectGetMinY(keyboardFrame) - 35 - 44); 
}

@end
