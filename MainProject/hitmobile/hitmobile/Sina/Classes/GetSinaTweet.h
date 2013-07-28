//
//  GetSinaTweetOperation.h
//  iHIT
//
//  Created by Hiro on 11-5-1.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthController.h"
#import "WeiboClient.h"
#import "Draft.h"

typedef enum {
	TYPE_TIMELINE,
	TYPE_RETWEET,
	TYPE_COMMENT
} SinaOperationType;

@protocol GetSinaTweetDelegate

@optional
- (void)didFinishGettingTimeLine:(NSMutableArray *)userTimeLineArray;
- (void)gettingTimeLineErrorOccured:(NSString *)errorMessage detail:(NSString *)errorDetail;

- (void)didFinishSending:(Status *)status saveUserAtIndex:(int)index;
- (void)didStopSending;
- (void)updateErrorOccured;

@end


@interface GetSinaTweet : NSObject <OAuthControllerDelegate, OAuthEngineDelegate>{
	id<GetSinaTweetDelegate> delegate;
	SinaOperationType operationType;
	
	OAuthEngine *_engine;
	WeiboClient *weiboClient;
	NSMutableArray *statuses;
	
	long long sinceID;
	long long maxID;
	long long userID;
	
	Draft *draft;
	UIViewController *callerViewController; // viewcont roller of the one who invoked GetSinaTweet
	//BOOL needSaveUserInformation;
	
	int saveUserAtIndex;
}

@property (nonatomic, assign) id<GetSinaTweetDelegate> delegate;
@property (nonatomic, assign) SinaOperationType operationType;
@property (nonatomic, retain) OAuthEngine *_engine;
@property (nonatomic, retain) WeiboClient *weiboClient;
@property (nonatomic, retain) NSMutableArray *statuses;
@property (nonatomic, assign) long long sinceID;
@property (nonatomic, assign) long long maxID;
@property (nonatomic, assign) long long userID;
@property (nonatomic, retain) Draft *draft;
@property (nonatomic, retain) UIViewController *callerViewController;
//@property (nonatomic, assign) BOOL needSaveUserInformation;
@property (nonatomic, assign) int saveUserAtIndex;

- (id)initWithUserTimeLine:(long long)user_id
				   SinceID:(long long)since_id
					 MaxID:(long long)max_id;

- (id)initWithRetweetOrComment:(SinaOperationType) type
		  CallerViewController:(UIViewController *)controller
					  SetDraft:(Draft *)aDraft
			   WithOAuthedUser:(User *)user;

- (void) sinaStart;

@end
