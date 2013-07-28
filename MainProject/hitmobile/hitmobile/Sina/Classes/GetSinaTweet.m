//
//  GetSinaTweetOperation.m
//  iHIT
//
//  Created by Hiro on 11-5-1.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import "GetSinaTweet.h"

#define kOAuthConsumerKey				@"2648596655"		
#define kOAuthConsumerSecret			@"bf8a82e0f3574b9fac38dbb5e2991f8b"
#define MY_USERID 1864410213
#define HIT_USERID 1873625985
#define HIT_USERID_STUDENTREQUIRED 1726975032

@interface GetSinaTweet (private)

- (void)netWorkInUse:(BOOL)isNetWorkInUse;

@end


@implementation GetSinaTweet

@synthesize delegate;
@synthesize operationType, sinceID, maxID, userID;
@synthesize _engine, weiboClient, statuses;
@synthesize draft, callerViewController;
//@synthesize needSaveUserInformation;
@synthesize saveUserAtIndex;

#pragma mark -
#pragma mark init

- (id)initWithUserTimeLine:(long long)user_id
				   SinceID:(long long)since_id
					 MaxID:(long long)max_id {
	if (self = [super init]) {
		self.operationType = TYPE_TIMELINE;
		self.sinceID = since_id;
		self.maxID = max_id;
		self.userID = user_id ? user_id : HIT_USERID; //only need to change this to change userid
	}
	return self;
}

- (id)initWithRetweetOrComment:(SinaOperationType) type
		  CallerViewController:(UIViewController *)controller
					  SetDraft:(Draft *)aDraft
			   WithOAuthedUser:(User *)user{
	if (self = [super init]) {
		self.operationType = type;
		self.callerViewController = controller;
		self.draft = aDraft;
		if (!_engine) {
			_engine = [[OAuthEngine alloc] initOAuthWithDelegate:self];
			_engine.consumerKey = kOAuthConsumerKey;
			_engine.consumerSecret = kOAuthConsumerSecret;
			_engine.username = [NSString stringWithFormat:@"%d", user.userId];
			//NSLog(@"******_engine.username = [%@]", _engine.username);
			//NSLog(@"******previous using lld [%@]", [NSString stringWithFormat:@"%lld", user.userId]); // get worong id
		}
		/*if (_engine) {
			[_engine release];
		}
		_engine = [[OAuthEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;
		_engine.username = [NSString stringWithFormat:@"%d", user.userId];
		*/
	}
	return self;
}



- (void) initWorks {
	if (!statuses) {
		statuses = [[NSMutableArray alloc] init];
	}
	if (!_engine) {
		_engine = [[OAuthEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;
	}
	//self.needSaveUserInformation = NO;
}


#pragma mark -
#pragma mark load user timeline

- (void) loadTimeLine {
	//NSLog(@"loadTimeLine");
	[OAuthEngine setCurrentOAuthEngine:_engine];
	/*if (weiboClient) {
		return;
	}*/
	weiboClient = [[WeiboClient alloc]initWithTarget:self
											  engine:_engine
											  action:@selector(timelineDidReceive:obj:)];
	//NSLog(@"userID[%lld] siceID[%lld] maxID[%lld]", self.userID, self.sinceID, self.maxID);
	[weiboClient getUserTimeLineUserID:self.userID withSinceID:self.sinceID maxiumumID:self.maxID statringAtPage:0 count:0];
}


- (void)logStatus:(Status *)status {
	int i = 0;
	//NSLog(@"------[%d]--------", i++);
	//NSLog(@"statusid[%lld]", status.statusId);
	//NSLog(@"createdAt[%ld]", status.createdAt);
	//NSLog(@"userName[%@]", status.user.screenName);
	//NSLog(@"text[%@]", status.text);
	//NSLog(@"thumbnailPic[%@]", status.thumbnailPic);
	//NSLog(@"userID lld [%lld]", status.user.userId); //cannot use lld
	//NSLog(@"userID d [%d]", status.user.userId);
	if (status.retweetedStatus) {
		//NSLog(@"retweet text[%@]", status.retweetedStatus.text);
	}
}

- (void)timelineDidReceive:(WeiboClient *)sender obj:(NSObject *)obj {
	//NSLog(@"timelineReceive");
	[self netWorkInUse:NO];
	// error occured
	if (sender.hasError) {
		NSLog(@"timelineDidReceive error!!!, errorMessage:%@, errordetail:%@"
			  , sender.errorMessage, sender.errorDetail);
		//[sender alert];
		[self.delegate gettingTimeLineErrorOccured:sender.errorMessage detail:sender.errorDetail];
	}
	//weiboClient = nil;
	if (obj == nil || ![obj isKindOfClass:[NSArray class]]) {
		NSLog(@"timeline obj is not an array");
		//[self.delegate gettingTimeLineErrorOccured:nil detail:nil];
		return;
	}
	// success
	NSArray *ary = (NSArray *)obj;
	[statuses removeAllObjects];
	for (int i = [ary count] - 1; i >= 0; --i) {
		NSDictionary *dic = (NSDictionary *)[ary objectAtIndex:i];
		if (![dic isKindOfClass:[NSDictionary class]]) {
			continue;
		}
		Status *sts = [Status statusWithJsonDictionary:[ary objectAtIndex:i]];
		//[self logStatus:sts];
		[statuses insertObject:sts atIndex:0];
	}
	[self.delegate didFinishGettingTimeLine:statuses];
}


#pragma mark -
#pragma mark CommentOrRetweet

- (void) sendTweet {
	WeiboClient *client = [[WeiboClient alloc] initWithTarget:self
													   engine:_engine
													   action:@selector(sendTweetDidSuccess:obj:)];
	client.context = [draft retain];
	draft.draftStatus = DraftStatusSending;
	switch (draft.draftType) {
		case DraftTypeReTweet:
			[client repost:draft.statusId tweet:draft.text];
			break;
		case DraftTypeReplyComment:
			[client comment:draft.statusId commentId:0 comment:draft.text];
			break;
		default:
			NSLog(@"error type");
			break;
	}
}

- (void) retweetCommentPrepare {
	UIViewController *controller = [OAuthController controllerToEnterCredentialsWithEngine:_engine delegate:self];
	if (controller) {
		[self.callerViewController presentModalViewController:controller animated:YES];
		//self.needSaveUserInformation = YES;
	}
	else {
		//NSLog(@"Authenicated for [%@]", _engine.username);
		[OAuthEngine setCurrentOAuthEngine:_engine];
		[self sendTweet];
	}

}

- (void)sendTweetDidSuccess:(WeiboClient*)sender obj:(NSObject*)obj {
	[self netWorkInUse:NO];
	Draft *sentDraft = nil;
	if (sender.context && [sender.context isKindOfClass:[Draft class]]) {
		sentDraft = (Draft *)sender.context;
		[sentDraft autorelease];
	}
	
	if (sender.hasError) {
		[sender alert];	
        [delegate didStopSending];
		return;
	}
	
	NSDictionary *dic = nil;
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
		dic = (NSDictionary*)obj;    
	}
	
	if (dic) {
		Status* sts = [Status statusWithJsonDictionary:dic];
		if (sts) {
			//delete draft!
			[self logStatus:sts];
			if (sentDraft) {
				
			}
		}
		[delegate didFinishSending:sts saveUserAtIndex:self.saveUserAtIndex];
	}
	
}
															


#pragma mark -
#pragma mark sinaStart

- (void) sinaStart {
	//NSLog(@"begin operation");
	[self initWorks];
	[self netWorkInUse:YES];
	switch (self.operationType) {
		case TYPE_TIMELINE:
			[self loadTimeLine];
			break;
		case TYPE_RETWEET:
			[self retweetCommentPrepare];
			break;
		case TYPE_COMMENT:
			[self retweetCommentPrepare];
			break;
		default:
			break;
	}
}


#pragma mark -
#pragma mark private Method

- (void)netWorkInUse:(BOOL)isNetWorkInUse {
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = isNetWorkInUse;
}

#pragma mark -
#pragma mark MemoryManagement

- (void)dealloc {
	[_engine release];
	[weiboClient release];
	[statuses release];
	[draft release];
	[callerViewController release];
	[super dealloc];
}

#pragma mark -
#pragma mark OAuthEngineDelegate


- (void) storeCachedOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSLog(@"storeCachedOAuthData [%@]", username);
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	BOOL alreadyHaveThisUserBefore = NO;
	NSString *tempAuthTokenString = [defaults objectForKey:username];
	if (tempAuthTokenString) {
		alreadyHaveThisUserBefore = YES;
	}
	
	// TODO: must Delete this, this is just for easier debug
	//alreadyHaveThisUserBefore = NO;
	
	[defaults setObject: data forKey: username];
	[defaults synchronize];
	
	int savedUserCounts = -1;
	NSData *tempDataForStatus = [defaults objectForKey:[NSString stringWithFormat:@"SinaUser_%d", ++savedUserCounts]];
	Status *tempStatus = nil;
	NSString *tempStringForUserId = nil;
	while (tempDataForStatus) {
		if (alreadyHaveThisUserBefore) {
			[Status setDecodeCount:0];
			[Status setEncodeCount:0];
			[User setDecodeCount:0];
			[User setEncodeCount:0];
			tempStatus = [NSKeyedUnarchiver unarchiveObjectWithData:tempDataForStatus];
			tempStringForUserId = [NSString stringWithFormat:@"%ld", [[tempStatus user] userId]];
			if ([tempStringForUserId isEqualToString:username]) {
				// if alreadyHaveThisUserBefore Must go this step
				break;
			}
		}
		tempDataForStatus = [defaults objectForKey:[NSString stringWithFormat:@"SinaUser_%d", ++savedUserCounts]];
	}
	self.saveUserAtIndex = savedUserCounts;
}

- (NSString *) cachedOAuthDataForUsername: (NSString *) username {
	//NSLog(@"cachedOAuthDataForUsername [%@]", username);
	return [[NSUserDefaults standardUserDefaults] objectForKey: username];
}

- (void)removeCachedOAuthDataForUsername:(NSString *) username{
	//NSLog(@"removeCachedOAuthDataForUsername [%@]", username);
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];

	[defaults removeObjectForKey: username];
	[defaults synchronize];
}

#pragma mark -
#pragma mark OAuthControllerDelegate

- (void) OAuthController: (OAuthController *) controller authenticatedWithUsername: (NSString *) username {
	//NSLog(@"Authenicated for %@", username);
	[self retweetCommentPrepare];
}

- (void) OAuthControllerFailed: (OAuthController *) controller {
	NSLog(@"Authentication Failed!");
    [self netWorkInUse:NO];
	//UIViewController *controller = [OAuthController controllerToEnterCredentialsWithEngine: _engine delegate: self];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                        message:@"认证失败" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"确认" 
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [delegate didStopSending];
	/*if (controller) 
		[self.callerViewController presentModalViewController: controller animated: YES];*/
	
}

- (void) OAuthControllerCanceled: (OAuthController *) controller {
	//NSLog(@"Authentication Canceled.");
    [self netWorkInUse:NO];
    [delegate didStopSending];
	//UIViewController *controller = [OAuthController controllerToEnterCredentialsWithEngine: _engine delegate: self];
	
	/*if (controller) 
		[self.callerViewController presentModalViewController: controller animated: YES];*/
	
}


@end
