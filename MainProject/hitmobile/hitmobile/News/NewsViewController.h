//
//  NewsViewController.h
//  iHIT
//
//  Created by keywind on 11-9-7.
//  Copyright 2011年 Hit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"
#import "ParseOperation.h"
#import "EGORefreshTableHeaderView.h"
#import <SystemConfiguration/SCNetworkReachability.h>

@interface NewsViewController : UITableViewController <SDWebImageManagerDelegate, ParseOperationDelegate, EGORefreshTableHeaderDelegate>{
    NSMutableArray *entries;
    NSOperationQueue *queue;
    
    NSURLConnection *newsFeedConnection;
    NSMutableData *newsListData;
    
    BOOL isLoading;//是否正在加载
	BOOL isLoadFailed;//是否加载失败
	BOOL end;
    
    BOOL isFromHeader;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;

    NSInteger lastest;
    NSInteger oldest;
    
    NSMutableArray *cachePlist;
	NSMutableArray *cacheTitle;
	NSMutableArray *cacheDate;
    NSMutableArray *cacheAuthor;
    NSMutableArray *cacheCellImage;
    NSMutableArray *cacheTextURL;
    NSMutableArray *cacheImageURL;
    NSMutableArray *cacheLargeImageURL;
    NSString *cachePath;
    
    BOOL firstLoad;
}

@property (nonatomic, retain) NSMutableArray *entries;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSURLConnection *newsFeedConnection;
@property (nonatomic, retain) NSMutableData *newsListData;

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isLoadFailed;
@property (nonatomic, assign) BOOL end;
@property (nonatomic, assign) BOOL isFromHeader;
@property (nonatomic, assign) NSInteger lastest;
@property (nonatomic, assign) NSInteger oldest;

@property (nonatomic, retain) NSMutableArray *cachePlist;
@property (nonatomic, retain) NSMutableArray *cacheTitle;
@property (nonatomic, retain) NSMutableArray *cacheDate;
@property (nonatomic, retain) NSMutableArray *cacheAuthor;
@property (nonatomic, retain) NSMutableArray *cacheCellImage;
@property (nonatomic, retain) NSMutableArray *cacheTextURL;
@property (nonatomic, retain) NSMutableArray *cacheImageURL;
@property (nonatomic, retain) NSMutableArray *cacheLargeImageURL;
@property (nonatomic, retain) NSString *cachePath;

- (UITableViewCell *)dequeueReusableEndCell;
@end
