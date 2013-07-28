//
//  SinaTweetQueue.m
//  iHIT
//
//  Created by Hiro on 11-4-1.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import "SinaTweetQueue.h"
#import "ImagePS.h"

#define KEY_ISNOTFIRSTTIME @"notFirstTimeLoad"
#define KEY_LATEST_PROFILEIMAGE_DATE @"latestProfileImage"
#define MAX_SAVE_STATUS 20

@implementation SinaTweetQueue

@synthesize statusArray;
@synthesize isNotFirstTime;
@synthesize getSinaTweetArray;
@synthesize isLoadingEarlier;
@synthesize delegate;
@synthesize profileImageDownloader;


#pragma mark -
#pragma mark Class Method

// conver time_t to string
+ (NSString *)dateFormatWithTimeVal:(time_t)timeValSince1970 {
	NSDate *tempDate = [NSDate dateWithTimeIntervalSince1970:timeValSince1970];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateFormatter setLocale:locale];
	[locale release];
	[dateFormatter setDateFormat:@"yy.MM.dd HH:mm"];
	NSString *targetDateString;
	targetDateString = [NSString stringWithString:[dateFormatter stringFromDate:tempDate]];
	[dateFormatter release];
	return targetDateString;
}

+ (NSString *)getProfileNameFromStatus:(Status *)status {
	return [NSString stringWithString:[[status user] screenName]];
}

+ (NSString *)getTextFromStatus:(Status *)status {
	NSMutableString *tempString = [[NSMutableString alloc] init];
	[tempString appendString:[status text]];
	if ([status retweetedStatus]) {
		[tempString appendString: @"\n@"];
		[tempString appendString:[[[status retweetedStatus]user] screenName]];
		[tempString appendFormat: @": "];
		[tempString appendString:[[status retweetedStatus] text]];
	}
	return [tempString autorelease];
}

+ (NSString *)getCreatedAtFromStatus:(Status *)status {
	return [SinaTweetQueue dateFormatWithTimeVal:[status createdAt]];
}

#pragma mark -
#pragma mark private methos

// check if the statusDatas.plist file exist to know if need to load status when run
- (void) loadIsNotFirstTimeFromUserDefaults {
	NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *statusPlistPath =  [[cachePaths objectAtIndex:0] stringByAppendingPathComponent:@"statusDatas.plist"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	self.isNotFirstTime = [fileManager fileExistsAtPath:statusPlistPath];
	//NSLog(@"isNotFirstTime [%@]", isNotFirstTime ? @"Yes" : @"NO");
	/*NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	self.isNotFirstTime = [userDefaults boolForKey:KEY_ISNOTFIRSTTIME];
	if (!isNotFirstTime) {
		NSLog(@"FirstTime");
	}*/
}

- (void) loadSavedDataFromPlist {
	NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *statusPlistPath =  [[cachePaths objectAtIndex:0] stringByAppendingPathComponent:@"statusDatas.plist"];
	NSMutableDictionary *dicionaryForStatusAndPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:statusPlistPath];
	int statusCount = [dicionaryForStatusAndPlist count];
	for (int i = 0; i < statusCount; i++) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[Status setDecodeCount:0];
		[Status setEncodeCount:0];
		[User setDecodeCount:0];
		[User setEncodeCount:0];
		NSData *tempStatusData = [dicionaryForStatusAndPlist objectForKey:[NSString stringWithFormat:@"Status_%d", i]];
		Status *tempStatus = [NSKeyedUnarchiver unarchiveObjectWithData:tempStatusData];
		[statusArray addObject:tempStatus];
		[pool release];
	}
	[dicionaryForStatusAndPlist release];
}

- (void) loadTweetData {
	if (!self.isNotFirstTime) {
		//NSLog(@"GetSinaTweet start here");
		[self updateData];
	}
	else {
		[self loadSavedDataFromPlist];
	}
}

- (id) init {
	if (self = [super init]) {
		self.isLoadingEarlier = NO;
		self.statusArray = [[NSMutableArray alloc] init];
		self.getSinaTweetArray = [[NSMutableArray alloc] init];
		[self loadIsNotFirstTimeFromUserDefaults];
		
		[self loadTweetData];
	}
	return self;
}

- (BOOL) saveLatestStatus {
	// save the latest MAX_SAVE_STATUS status
	NSMutableDictionary *dicionaryForStatusAndPlist = [[NSMutableDictionary alloc] init];
	
	for (int i = 0; i < MAX_SAVE_STATUS; i++) {
		[Status setDecodeCount:0];
		[Status setEncodeCount:0];
		[User setDecodeCount:0];
		[User setEncodeCount:0];
		NSData *statusData = [NSKeyedArchiver archivedDataWithRootObject:[statusArray objectAtIndex:i]];
		[dicionaryForStatusAndPlist setObject:statusData forKey:[NSString stringWithFormat:@"Status_%d",i]];
	}
	
	NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *statusPlistPath =  [[cachePaths objectAtIndex:0] stringByAppendingPathComponent:@"statusDatas.plist"];
	// from isWriteSuccess we can know wether to save the latest update date or remain the previous one
	BOOL isWriteSuccess = [dicionaryForStatusAndPlist writeToFile:statusPlistPath atomically:YES];
	[dicionaryForStatusAndPlist release];
	return isWriteSuccess;
}

- (void) saveIsNotFirstTime: (BOOL) isWriteSuccess  {
	// set isNotFirstTime
	if (isWriteSuccess) {
		//NSLog(@"write success");
		self.isNotFirstTime = YES;
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setBool:self.isNotFirstTime forKey:KEY_ISNOTFIRSTTIME];
		[userDefaults synchronize];
	}
}

- (void)setSinaListInformation:(NSMutableArray *)theUserTimeLineStatusArray {
	AddStatusType currentType;
	if (![theUserTimeLineStatusArray count]) {
		currentType = ADD_STATUS_TYPE_NONEED;
		[delegate viewShouldUpdate:TABLEVIEW_UPDATE updateRowsAtIndexPaths:nil];
		return;
	}
	int currentStatusCount = [self tweetCount];
	long long latestID = [[theUserTimeLineStatusArray objectAtIndex:0] statusId]; // latestID of the incomming status array
	//long long earliestID = [[theUserTimeLineStatusArray lastObject] statusId];	// earliestID of the incomming status array
	//long long sinceID = currentStatusCount ? [[self.statusArray objectAtIndex:0] statusId]: 0; // latestID of the current status array
	long long maxID = currentStatusCount ? [[self.statusArray lastObject] statusId]: 0;	// earliestID of the current status array	
	
	if (!currentStatusCount) {
		currentType = ADD_STATUS_TYPE_CURRENT;
	}
	else if (latestID == maxID) {
		currentType = ADD_STATUS_TYPE_EARLIER;
	}
	else {
		currentType = ADD_STATUS_TYPE_LATTER;
	}

	// count how many status to add
	int updateCount = [theUserTimeLineStatusArray count];
	NSMutableArray *indexPathsArray = [[[NSMutableArray alloc] init] autorelease];
	
	switch (currentType) {
		case ADD_STATUS_TYPE_LATTER:
			for (int i = 0; i < updateCount; i++) {
				[indexPathsArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
			}
			//[theUserTimeLineStatusArray removeLastObject];
			[theUserTimeLineStatusArray addObjectsFromArray:self.statusArray];
			[self setStatusArray:theUserTimeLineStatusArray];
			break;
		case ADD_STATUS_TYPE_EARLIER:
			updateCount--;
			for (int i = 0; i < updateCount; i++) {
				[indexPathsArray addObject:[NSIndexPath indexPathForRow:i + currentStatusCount inSection:0]];
			}
			[theUserTimeLineStatusArray removeObjectAtIndex:0];
			[self.statusArray addObjectsFromArray:theUserTimeLineStatusArray];
			break;
		case ADD_STATUS_TYPE_CURRENT:
			[self.statusArray addObjectsFromArray:theUserTimeLineStatusArray];
			break;
        case ADD_STATUS_TYPE_NONEED:
            break;
	}
	
	BOOL isWriteSuccess;
	isWriteSuccess = [self saveLatestStatus];
	
	if (!self.isNotFirstTime) {
		//NSLog(@"First Time load");
		[delegate viewShouldUpdate:TABLEVIEW_RELOAD updateRowsAtIndexPaths:nil];
	}
	else {
		//NSLog(@"Not First Time load");
		[delegate viewShouldUpdate:TABLEVIEW_UPDATE updateRowsAtIndexPaths:indexPathsArray];
	}
	[self saveIsNotFirstTime: isWriteSuccess];
	NSLog(@"setSinaListInformation:NSArray end");
}

#pragma mark -
#pragma mark instance Method

- (void)updateData {
	NSLog(@"updateData start");
	long long sinceID;
	if (![statusArray count]) {
		sinceID = 0;
	}
	else {
		sinceID = [[statusArray objectAtIndex:0] statusId];
	}
	/*if (!getSinaUserTimeline) {
		getSinaUserTimeline = [GetSinaTweet alloc];
	}
	[getSinaUserTimeline initWithUserTimeLine:0
									  SinceID:sinceID
										MaxID:0];
	getSinaUserTimeline.delegate = self;
	[getSinaUserTimeline sinaStart];*/
	GetSinaTweet *getSinaUserTimeline = [[GetSinaTweet alloc]
										 initWithUserTimeLine:0
										 SinceID:sinceID
										 MaxID:0];
	getSinaUserTimeline.delegate = self;
	[self.getSinaTweetArray addObject:getSinaUserTimeline];
	[getSinaUserTimeline sinaStart];
	[getSinaUserTimeline release];
	//NSLog(@"updateData end");
}

- (void)loadEarlierData {
	if (!self.isLoadingEarlier) {
		self.isLoadingEarlier = YES;
		//NSLog(@"loadEarlierData start");
		if (![statusArray count]) {
			//NSLog(@"statusArray has no object");
			return;
		}
		long long maxID = [[statusArray lastObject] statusId];
		/*if (!getSinaUserTimeline) {
		 getSinaUserTimeline = [GetSinaTweet alloc];
		 }
		 [getSinaUserTimeline initWithUserTimeLine:0
		 SinceID:0
		 MaxID:maxID];
		 getSinaUserTimeline.delegate = self;
		 [getSinaUserTimeline sinaStart];*/
		GetSinaTweet *getSinaUserTimeline = [[GetSinaTweet alloc]
											 initWithUserTimeLine:0
											 SinceID:0
											 MaxID:maxID];
		getSinaUserTimeline.delegate = self;
		[self.getSinaTweetArray addObject:getSinaUserTimeline];
		[getSinaUserTimeline sinaStart];
		[getSinaUserTimeline release];
		//NSLog(@"loadEarlierData end");
		
	}
	else {
		//NSLog(@"preVious Loading not finish so skip");
	}

}

- (int)tweetCount {
	return [statusArray count];
}

- (void)getProfileName:(NSString **)profileName tweetBody:(NSString **)tweetBody 
		andSendTime:(NSString **)sendTime atIndex:(int)index {
	
	*profileName = [SinaTweetQueue getProfileNameFromStatus:[statusArray objectAtIndex:index]];
	*tweetBody = [SinaTweetQueue getTextFromStatus:[statusArray objectAtIndex:index]];
	*sendTime = [SinaTweetQueue getCreatedAtFromStatus:[statusArray objectAtIndex:index]];
}

- (UIImage *)getProfileImageAtIndex:(int)index {
	NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *profileImagePath =  [[cachePaths objectAtIndex:0] stringByAppendingPathComponent:@"profileImage"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL profileImageDidExist = [fileManager fileExistsAtPath:profileImagePath];
	
	UIImage *profileImage;
	if (profileImageDidExist) {
		profileImage = [[UIImage alloc] initWithContentsOfFile:profileImagePath];
	}
	else {
		
		profileImage = [UIImage imageNamed:@"hitSinaImage.png"];//@"hitSinaImage90.jpg"];
	}
	
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//NSNumber *latestProfileImageDate = [userDefaults objectForKey:KEY_LATEST_PROFILEIMAGE_DATE];
	//NSLog(@"createdAt [%ld] latestDate [%ld]", [[statusArray objectAtIndex:index] createdAt],[latestProfileImageDate longValue]);
	//if (latestProfileImageDate == nil || [latestProfileImageDate longValue] < [[statusArray objectAtIndex:index] createdAt]) {
	//}
	
	// Download new image here whaterver it is needed or not
	// Current solution: this time still load the previous image saved last time or in the resource forlder
	// for all status and next time when Weibo run load the new image form disk.
	// So there is no need to check wether if it need to set a new image just download the image 
	self.profileImageDownloader = [[ImageDownloader alloc] init];
	self.profileImageDownloader.delegate = self;
	[self.profileImageDownloader startDownload:[[(Status *)[statusArray objectAtIndex:index] user] profileLargeImageUrl] atIndexPath:nil imageType:IMAGE_LARGE];

	return profileImage;
}

- (void) cancelProfileImageDownload {
	if (self.profileImageDownloader) {
		[profileImageDownloader cancelDownload];
		profileImageDownloader = nil;
	}
}

#pragma mark -
#pragma mark Memory Control

- (void)releaseGetSinaTweetArray {
	for (GetSinaTweet *tempGetSinaTweet in self.getSinaTweetArray) {
		tempGetSinaTweet.delegate = nil;
	}
	[getSinaTweetArray release];
}

- (void)dealloc {
	[statusArray release];
	[self releaseGetSinaTweetArray];
	[profileImageDownloader release];

    [super dealloc];
}


#pragma mark -
#pragma mark GetSinaTweetOperationDelegate

- (void)didFinishGettingTimeLine:(NSMutableArray *)userTimeLineArray {
	self.isLoadingEarlier = NO;
	//NSLog(@"didFinishGetting delegate");
	[self setSinaListInformation:userTimeLineArray];
}
- (void)gettingTimeLineErrorOccured:(NSString *)errorMessage detail:(NSString *)errorDetail {
	// TODO: fixThis
	self.isLoadingEarlier = NO;
	[delegate networkError];
}

- (void)imageDidLoad:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath imageType:(ImageType)imageType {
	//NSLog(@"profileImageDownloaded resize it and save");
	NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *profileImagePath =  [[cachePaths objectAtIndex:0] stringByAppendingPathComponent:@"profileImage"];
	image = [ImagePS createRoundedRectImage:image size:CGSizeMake(50, 50)];
	[UIImagePNGRepresentation(image) writeToFile:profileImagePath atomically:YES];
}
@end
