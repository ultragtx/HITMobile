//
//  SinaTweetQueue.h
//  iHIT
//
//  Created by Hiro on 11-4-1.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetSinaTweet.h"
#import "ImageDownloader.h"

typedef enum{
	TABLEVIEW_UPDATE,
	TABLEVIEW_RELOAD
}UpdateType;

typedef enum{
	ADD_STATUS_TYPE_LATTER,
	ADD_STATUS_TYPE_EARLIER,
	ADD_STATUS_TYPE_CURRENT,
	ADD_STATUS_TYPE_NONEED
}AddStatusType;

@protocol SinaTweetQueueDelegate

- (void) viewShouldUpdate:(UpdateType)updateType updateRowsAtIndexPaths:(NSArray *)indexPaths;
- (void) networkError;

@end


@interface SinaTweetQueue : NSObject <GetSinaTweetDelegate, ImageDownloaderDelegate>{
	
	NSMutableArray *statusArray;
	BOOL isNotFirstTime;
	id <SinaTweetQueueDelegate> delegate;
	NSMutableArray *getSinaTweetArray;
	BOOL isLoadingEarlier;
	
	ImageDownloader *profileImageDownloader;
}

@property (nonatomic, retain) NSMutableArray *statusArray;
@property (nonatomic, assign) BOOL isNotFirstTime;
@property (nonatomic, assign) BOOL isLoadingEarlier;
@property (nonatomic, retain) NSMutableArray *getSinaTweetArray;
@property (nonatomic, assign) id <SinaTweetQueueDelegate> delegate;
@property (nonatomic, retain) ImageDownloader *profileImageDownloader;

- (int) tweetCount;
- (void) getProfileName:(NSString **)userName tweetBody:(NSString **)tweetBody andSendTime:(NSString **)sendTime atIndex:(int)index;
- (void) cancelProfileImageDownload;
- (UIImage *)getProfileImageAtIndex:(int)index;
- (void) updateData;
- (void) loadEarlierData;

+ (NSString *)dateFormatWithTimeVal:(time_t)timeValSince1970;
+ (NSString *)getProfileNameFromStatus:(Status *)status;
+ (NSString *)getTextFromStatus:(Status *)status;
+ (NSString *)getCreatedAtFromStatus:(Status *)status;

@end
