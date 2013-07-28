//
//  NewsViewController.m
//  iHIT
//
//  Created by keywind on 11-9-7.
//  Copyright 2011年 Hit. All rights reserved.
//

#import "NewsViewController.h"
#import "UIImageView+WebCache.h"
#import "NewsCell.h"
#import "NewsTableViewCell.h"
#import "SingleNewsViewController.h"
#import "ParseOperation.h"
#import "LoadingTableViewCell.h"
#import "EndStreamTableViewCell.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>

#define FHost @"http://219.217.227.65"

@interface NewsViewController ()
- (NSInteger)startInfoDownload;
@end

@implementation NewsViewController

@synthesize entries, newsListData, queue, newsFeedConnection, isLoading, isLoadFailed, end, isFromHeader, lastest, oldest;
@synthesize cachePlist, cacheTitle, cacheDate, cacheAuthor, cacheCellImage, cacheTextURL, cacheImageURL, cacheLargeImageURL, cachePath;

- (BOOL)isNetworkReachable{  
	// Create zero addy  
	struct sockaddr_in zeroAddress;  
	bzero(&zeroAddress, sizeof(zeroAddress));  
	zeroAddress.sin_len = sizeof(zeroAddress);  
	zeroAddress.sin_family = AF_INET;  
	
	// Recover reachability flags  
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);  
	SCNetworkReachabilityFlags flags;  
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);  
	CFRelease(defaultRouteReachability);  
	
	if (!didRetrieveFlags)  
	{  
		return NO;  
	}  
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;  
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;  
	return (isReachable && !needsConnection) ? YES : NO;  
}  

- (void)dealloc
{
    [entries release];
    [newsListData release];
    [queue release];
    [newsFeedConnection release];
    
    [cachePlist release];
    [cacheTitle release];
    [cacheDate release];
    [cacheAuthor release];
    [cacheTextURL release];
    [cacheImageURL release];
    [cacheLargeImageURL release];
    [cacheCellImage release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Cache Operation
- (void)initCache{
	
	self.cachePlist = [NSMutableArray array];
	self.cacheTitle = [NSMutableArray array];
	self.cacheDate = [NSMutableArray array];
    self.cacheAuthor = [NSMutableArray array];
    self.cacheCellImage = [NSMutableArray array];
    self.cacheTextURL = [NSMutableArray  array];
    self.cacheImageURL = [NSMutableArray array];
    self.cacheLargeImageURL = [NSMutableArray array];
	
    [self.cachePlist addObject:cacheTitle];
	[self.cachePlist addObject:cacheDate];
    [self.cachePlist addObject:cacheAuthor];
    [self.cachePlist addObject:cacheCellImage];
    [self.cachePlist addObject:cacheTextURL];
    [self.cachePlist addObject:cacheImageURL];
    [self.cachePlist addObject:cacheLargeImageURL];
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);	
	self.cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"NewsCache"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:self.cachePath
								  withIntermediateDirectories:NO
												   attributes:nil
														error:nil];
	}
}

- (void)loadCacheData{
	NSArray *readCachePlist = [NSArray arrayWithContentsOfFile:[self.cachePath stringByAppendingPathComponent:@"newsCache.plist"]];
    if (readCachePlist) {
        NSArray *readCacheTitle = [readCachePlist objectAtIndex:0];
        NSArray *readCacheDate = [readCachePlist objectAtIndex:1];
        NSArray *readCacheAuthor = [readCachePlist objectAtIndex:2];
        NSArray *readCacheCellImage = [readCachePlist objectAtIndex:3];
        NSArray *readCacheTextURL = [readCachePlist objectAtIndex:4];
        NSArray *readCacheImageURL = [readCachePlist objectAtIndex:5];
        NSArray *readCacheLargeImageURL = [readCachePlist objectAtIndex:6];
        for (NSInteger i = 0; i < [readCacheTitle count]; i++) {
            NewsCell *cell = [[NewsCell alloc] init];
            cell.newsTitle = [readCacheTitle objectAtIndex:i];
            cell.newsDate = [readCacheDate objectAtIndex:i];
            cell.newsAuthor = [readCacheAuthor objectAtIndex:i];
            cell.newsCellImageURL = [readCacheCellImage objectAtIndex:i];
            cell.newsDetail = [readCacheTextURL objectAtIndex:i];
            cell.newsImageURL = [readCacheImageURL objectAtIndex:i];
            cell.newsLargeImageURL = [readCacheLargeImageURL objectAtIndex:i];
            [self.entries addObject:cell];
            [cell release];
        }
    }	
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Added by G
    // Toggle Menu
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"] style:UIBarButtonItemStyleBordered target:[UIApplication sharedApplication].delegate action:@selector(toggleLeftView)];
    [self.navigationItem setLeftBarButtonItem:menuBarButtonItem];
    [menuBarButtonItem release];
    // End
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    self.title = @"哈工大新闻";
    self.tableView.rowHeight = 70;
    self.entries = [NSMutableArray array];
    [self initCache];
    
    if (_refreshHeaderView == nil) {		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:238.0/255.0 alpha:1.0];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];		
	}
    
    if ([self isNetworkReachable]) {
        firstLoad = YES;
        self.lastest = 200;
        while (self.lastest == 200) {
            self.lastest = [self startInfoDownload];
        }
        self.oldest = (self.lastest + 9) % 10;
        self.isFromHeader = NO;
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/iHIT/%d.rss", FHost, self.lastest]]];
        self.newsFeedConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }  else {
        [self loadCacheData];
        [self.tableView reloadData];
    }
}

- (NSString *)iconImageName {
	return @"NewsIcon.png";
}

- (NSInteger)startInfoDownload{
    NSURL *infoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/iHIT/info", FHost]];
	NSData *infoData;
	NSInteger latestItem;
	@try {
		infoData = [[NSData alloc]initWithContentsOfURL:infoURL];
	}
	@catch (NSException * e) {
		//Some error while downloading data
		latestItem = 200;
        return latestItem;
	}
	
    NSString *info = [[NSString alloc]initWithData:infoData encoding:NSUTF8StringEncoding];
    NSArray *items = [info componentsSeparatedByString:@"^"];
    latestItem = [[items objectAtIndex:[items count]-1] integerValue];
    [infoData release];
    [info release];
    
    if (latestItem < 9) {
        return 9;
    } else {
        return latestItem/10-1;
    }
}

- (void)loadMore {
    if (!self.end && [self isNetworkReachable]) {
        self.isFromHeader = NO;
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/iHIT/%d.rss", FHost, self.oldest]]];
        self.newsFeedConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
        self.oldest = (self.oldest + 9) % 10;
    }
}
// -------------------------------------------------------------------------------
//	handleLoadedApps:notif
// -------------------------------------------------------------------------------
- (void)handleLoadedNews:(NSArray *)loadedNews
{
    if (isFromHeader) {        
        NSRange range = NSMakeRange(0, [loadedNews count]);     
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.entries insertObjects:loadedNews atIndexes:indexSet];
        
        NSMutableArray *indexPathArray = [NSMutableArray arrayWithCapacity:[loadedNews count]];
        [indexPathArray removeAllObjects];
        NSIndexPath *indexPath;
        
        for (NSInteger i = 0; i < [loadedNews count]; i++) {
            NewsCell *cell = [loadedNews objectAtIndex:i];
            [self.cacheTitle insertObject:cell.newsTitle atIndex:0];
            [self.cacheDate insertObject:cell.newsDate atIndex:0];
            [self.cacheAuthor insertObject:cell.newsAuthor atIndex:0];
            [self.cacheCellImage insertObject:cell.newsCellImageURL atIndex:0];
            [self.cacheTextURL insertObject:cell.newsDetail atIndex:0];
            [self.cacheImageURL insertObject:cell.newsImageURL atIndex:0];
            [self.cacheLargeImageURL insertObject:cell.newsLargeImageURL atIndex:0];
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPathArray addObject:indexPath];
        }
        NSString *filePath = [self.cachePath stringByAppendingPathComponent:@"newsCache.plist"];
        [self.cachePlist writeToFile:filePath atomically:YES];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } else {
        [self.entries addObjectsFromArray:loadedNews];
        for (NSInteger i = 0; i < [loadedNews count]; i++) {
            NewsCell *cell = [loadedNews objectAtIndex:i];
            [self.cacheTitle addObject:cell.newsTitle];
            [self.cacheDate addObject:cell.newsDate];
            [self.cacheAuthor addObject:cell.newsAuthor];
            [self.cacheCellImage addObject:cell.newsCellImageURL];
            [self.cacheTextURL addObject:cell.newsDetail];
            [self.cacheImageURL addObject:cell.newsImageURL];
            [self.cacheLargeImageURL addObject:cell.newsLargeImageURL];
        }
        NSString *filePath = [self.cachePath stringByAppendingPathComponent:@"newsCache.plist"];
        [self.cachePlist writeToFile:filePath atomically:YES];
        [self.tableView reloadData];
    }
}

// -------------------------------------------------------------------------------
//	didFinishParsing:newsList
// -------------------------------------------------------------------------------
- (void)didFinishParsing:(NSArray *)newsList
{	
    [self performSelectorOnMainThread:@selector(handleLoadedNews:) withObject:newsList waitUntilDone:NO];
    
    self.queue = nil;   // we are finished with the queue and our ParseOperation
}

- (void)parseErrorOccurred:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

// -------------------------------------------------------------------------------
//	handleError:error
// -------------------------------------------------------------------------------
- (void)handleError:(NSError *)error
{
    //    NSString *errorMessage = [error localizedDescription];
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Load News"
    //														message:errorMessage
    //													   delegate:nil
    //											  cancelButtonTitle:@"OK"
    //											  otherButtonTitles:nil];
    //    [alertView show];
    //    [alertView release];
}

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how
// the connection object,  which is working in the background, can asynchronously communicate back to
// its delegate on the thread from which it was started - in this case, the main thread.
//

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.newsListData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [newsListData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else
	{
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    self.newsFeedConnection = nil;   // release our connection
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    NSString *xmlString = [[NSString alloc]initWithData:newsListData encoding:NSUTF8StringEncoding];
    //    NSLog(@"%@", xmlString);
    //    [xmlString release];
    
    self.newsFeedConnection = nil;   // release our connection
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];
    
    // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
    // "ownership of appListData has been transferred to the parse operation and should no longer be
    // referenced in this thread.
    //
    ParseOperation *parser = [[ParseOperation alloc] initWithData:newsListData delegate:self];
    
    [queue addOperation:parser]; // this will start the "ParseOperation"
    
    [parser release];
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.newsListData = nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [entries count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// customize the appearance of table view cells
	//
	static NSString *NewsCellIdentifier = @"NewsTableViewCell";
	UITableViewCell *finalcell;
    if (indexPath.row < [self.entries count])
	{
        NewsTableViewCell *cell = (NewsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NewsCellIdentifier];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewsTableViewCell" owner:self options:nil];
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[UITableViewCell class]])
                {
                    cell = (NewsTableViewCell *)currentObject;
                    break;
                }
            }
            
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_background.png"]] autorelease];
        }
        
        // Set up the cell...
        NewsCell *newsCell = [self.entries objectAtIndex:indexPath.row];
        
        cell.newsTitleLabel.text = newsCell.newsTitle;
        cell.newsDateLabel.text = newsCell.newsDate;
        
        // Only load cached images; defer new downloads until scrolling ends
        if ([newsCell.newsImageURL isEqualToString:@""]) {
            cell.newsImageView.image = [UIImage imageNamed:@"Place_holder.png"];
        } else {
            // Here we use the new provided setImageWithURL: method to load the web image
            [cell.newsImageView setImageWithURL:[NSURL URLWithString:newsCell.newsCellImageURL]
                               placeholderImage:[UIImage imageNamed:@"Place_holder.png"]];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //        cell.newsImageView.alpha = 0.0;
        //        [UIView beginAnimations:nil context:NULL];
        //        [UIView setAnimationDuration:0.3];
        //        [cell.newsImageView setAlpha:1.0f];
        //        [UIView commitAnimations];
        finalcell = cell;
        
    } else {
        if (self.lastest > self.oldest && (self.lastest - self.oldest) < 9) {
            self.end = NO;
		} else if (self.lastest < self.oldest && (self.lastest + 10 - self.oldest) < 9) {
            self.end = NO;
        } else {
			self.end = YES;
		}
		UITableViewCell *cell = [self dequeueReusableEndCell];		
        if (!firstLoad) {
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:1];
        }
        firstLoad = NO;
        finalcell = cell;
    }
    
    return finalcell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.row < [self.entries count]) {
        SingleNewsViewController *detailViewController = [[SingleNewsViewController alloc] init];
        NewsCell *newsCell = [self.entries objectAtIndex:indexPath.row];
        detailViewController.newsTitle = newsCell.newsTitle;
        detailViewController.newsDate = newsCell.newsDate;
        detailViewController.newsAuthor = newsCell.newsAuthor;
        detailViewController.newsDetail = newsCell.newsDetail;
        detailViewController.newsImageURL = newsCell.newsImageURL;
        detailViewController.newsLargeImageURL = newsCell.newsLargeImageURL;
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
}

- (UITableViewCell *)dequeueReusableEndCell{
	static NSString *CellIdentifier = @"LoadingCell";
	static NSString *EndCellIdentifier = @"EndCell";
    
    UITableViewCell *cell ;
	
	if (end || ![self isNetworkReachable]) {
		cell = (EndStreamTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:EndCellIdentifier];
		if (!cell) {
			cell = [[EndStreamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EndCellIdentifier];
		}
	}else {
		cell = (LoadingTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil) {
			cell = [[[LoadingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		[((LoadingTableViewCell *)cell).indicator startAnimating];
		if (isLoadFailed) {
			((LoadingTableViewCell *)cell).loadingLabel.text = @"加载失败";    
			
		} else {
			((LoadingTableViewCell *)cell).loadingLabel.text = @"正在加载...";        
		}
	}
	cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_background.png"]] autorelease];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
	_reloading = YES;
    if ([self isNetworkReachable]) {
        self.isFromHeader = YES;
        NSInteger latestItem = 200;
        while (latestItem == 200) {
            latestItem = [self startInfoDownload];
        }
        if (latestItem != self.lastest) {
            self.lastest = (self.lastest + 1) % 10;
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/iHIT/%d.rss", FHost, self.lastest]]];
            self.newsFeedConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
        }
    }
}

- (void)doneLoadingTableViewData{	
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end
