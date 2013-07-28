//
//  SinaTweetQueueTableViewController.m
//  iHIT
//
//  Created by Hiro on 11-4-2.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import "SinaTweetQueueViewController.h"

#define DEFAULT_HEIGHT 60.0f
#define DEFAULT_NUMBER_OF_ROWS 0

#define FONT_SIZE 12.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 6.0f
#define LABEL_SENDTIME_WIDTH 110.0f
#define LABEL_NAME_WIDTH 120.0f
#define A_BIG_HEIGHT 20000.0f
#define IMAGE_SIZE 50.0f
#define LABEL_MIN_HEIGHT 21.0f
#define LABEL_BODY_Y 25.0f


@implementation SinaTweetQueueViewController

@synthesize sinaTableView;
@synthesize sinaTweetQueue;
@synthesize lastCellActivityIndicator;
@synthesize loadingView;
@synthesize profileImageForPerformance;

#pragma mark -
#pragma mark View lifecycle


- (void) initDragAndUpdateHeader {
	// drag and update part
	  if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.sinaTableView.bounds.size.height, self.view.frame.size.width, self.sinaTableView.bounds.size.height)];
		view.delegate = self;
		[self.sinaTableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];

}

- (void) initSinaTweetQueue {
	sinaTweetQueue = [[SinaTweetQueue alloc] init];
	sinaTweetQueue.delegate = self;
	//self.userImageForPerformance = [UIImage imageNamed:@"hitSinaImage.png"];
}

- (void) showLoadingView {
	
	self.loadingView.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Added by G
    // Toggle Menu
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"] style:UIBarButtonItemStyleBordered target:[UIApplication sharedApplication].delegate action:@selector(toggleLeftView)];
    [self.navigationItem setLeftBarButtonItem:menuBarButtonItem];
    [menuBarButtonItem release];
    // End
    
	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
	[self initDragAndUpdateHeader];

	[self initSinaTweetQueue];
	if (![sinaTweetQueue tweetCount]) {
		[self showLoadingView];
	}
	[self setTitle:@"工大新浪微博"];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSString *)iconImageName {
	return @"WeiboIcon.png";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.sinaTableView deselectRowAtIndexPath:[self.sinaTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[sinaTweetQueue cancelProfileImageDownload];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {

    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    int rowsCount = [sinaTweetQueue tweetCount];
	
	return rowsCount? rowsCount + 1 : DEFAULT_NUMBER_OF_ROWS;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int rowsCount = [sinaTweetQueue tweetCount];
	BOOL isLastCell = NO;
	if (indexPath.row == rowsCount) {
		rowsCount = 0;
		isLastCell = YES;
	}
    NSString *CellIdentifier = rowsCount ? @"SinaTweetCell" : @"PlaceHolderCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if (rowsCount) {
			//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			UILabel *label[3];
			for (int i = 0; i < 3; i++) {
				label[i] = [[UILabel alloc] initWithFrame:CGRectZero];
				label[i].numberOfLines = 0;
				if (i == 3) {
					label[i].textAlignment = UITextAlignmentRight;
				}
				label[i].tag = i + 1;
				label[i].lineBreakMode = UILineBreakModeWordWrap;
				if (i == 0) {
					label[i].font = [UIFont fontWithName:@"HelveticaBold" size:11.0f];
				}
				else {
					label[i].font = [UIFont fontWithName:@"Helvetica" size:11.0f];
				}
				if (i == 2) {
					label[i].textColor = [UIColor grayColor];
					label[i].numberOfLines = 1;
				}
				label[i].highlightedTextColor = [UIColor whiteColor];
				
				label[i].opaque = NO; // 选中Opaque表示视图后面的任何内容都不应该绘制
				label[i].backgroundColor = [UIColor clearColor];
				[cell.contentView addSubview:label[i]];
				[label[i] release];
			}
			UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
			profileImageView.tag = 3 + 1;
			profileImageView.opaque = NO;
			[cell.contentView addSubview:profileImageView];
			[profileImageView release];
		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}

    }
    
	if (rowsCount) {
		NSString *text[3];
		[sinaTweetQueue getProfileName:&text[0] tweetBody:&text[1] andSendTime:&text[2] atIndex:indexPath.row];
		
		CGRect cellFrame = [cell frame];
		cellFrame.origin = CGPointMake(0, 0);
		
		UILabel *label[3];
		UIImageView *profileImageView;
		
		CGRect rect[4];
		
		rect[0] = CGRectMake(64, 6, 320 - 70, 2000);
		rect[1] = CGRectMake(64, 27, 320 - 70, 2000);
		rect[2] = CGRectMake(240, 8, 320 - 240, 2000);
		rect[3] = CGRectMake(6, 6, 320 - 6 , 2000);
		
		for (int i = 0; i < 3; i++) {
			label[i] = (UILabel *)[cell viewWithTag:(i + 1)];
			label[i].text = text[i];
			label[i].frame = rect[i];
			[label[i] sizeToFit];
		}
		
		cellFrame.size.height = MAX(62, 58 + label[0].frame.size.height + label[1].frame.size.height - 46);
		
		profileImageView = (UIImageView *)[cell viewWithTag:(3 + 1)];
		if (self.profileImageForPerformance) {
			profileImageView.image = self.profileImageForPerformance;
		}
		else {
			profileImageView.image = [sinaTweetQueue getProfileImageAtIndex:indexPath.row];
			self.profileImageForPerformance = profileImageView.image;
		}

		
		profileImageView.frame = rect[3];
		[profileImageView sizeToFit];
		[cell setFrame:cellFrame];
	}
	else {
		if (indexPath.row == 0) {
			cell.detailTextLabel.text = @"加载中...";
		}
		else if (isLastCell) {
			//cell.textLabel.textAlignment = UITextAlignmentRight;
			cell.textLabel.text = @"更多...    ";
			if (!lastCellActivityIndicator) {
				[lastCellActivityIndicator removeFromSuperview];
				[lastCellActivityIndicator release];
			}
			lastCellActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			CGRect cellFrame = [cell frame];
			[lastCellActivityIndicator setCenter:CGPointMake(200, cellFrame.size.height / 2)];
			[cell addSubview:lastCellActivityIndicator];
		}
	}

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {	
	int rowsCount = [sinaTweetQueue tweetCount];
	UITableViewCell *cell = [self tableView:aTableView cellForRowAtIndexPath:indexPath];

	return rowsCount? cell.frame.size.height : 62;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    int rowsCount = [sinaTweetQueue tweetCount];
	BOOL isLastCell = NO;
	if (indexPath.row == rowsCount) {
		isLastCell = YES;
	}
	if (isLastCell) {
		[sinaTweetQueue loadEarlierData];
		[self.sinaTableView deselectRowAtIndexPath:indexPath animated:YES];
		[lastCellActivityIndicator startAnimating];
	}
	else {
		SingleTweetViewController *detailViewController = [[SingleTweetViewController alloc] initWithNibName:@"SingleTweetView" bundle:nil];
		detailViewController.indexNumber = indexPath.row;
		detailViewController.singleStatus = [sinaTweetQueue.statusArray objectAtIndex:indexPath.row];
		detailViewController.profileImage = self.profileImageForPerformance;
		[self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
	}
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	[sinaTweetQueue updateData];
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.sinaTableView];
	
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
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


#pragma mark -
#pragma mark Should Run On MainThread

- (void) tableViewReloadData {
	[self.sinaTableView reloadData];
	self.loadingView.hidden = YES;
}

- (void) tableViewUpdate: (NSArray *)indexPathsArray {
	[lastCellActivityIndicator stopAnimating];
	if (indexPathsArray) {
		[self.sinaTableView beginUpdates];
		[self.sinaTableView insertRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
		[self.sinaTableView endUpdates];
	}
	[self doneLoadingTableViewData];
}

- (void) showUIAlertView {
	[lastCellActivityIndicator stopAnimating];
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Oops!" message:@"更新错误，请检查网络!" 
						  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[self doneLoadingTableViewData];
	self.loadingView.hidden = YES;
}


#pragma mark -
#pragma mark SinaTweetQueueDelegate



- (void) viewShouldUpdate:(UpdateType)updateType updateRowsAtIndexPaths:(NSArray *)indexPaths {
	switch (updateType) {
		case TABLEVIEW_UPDATE:
			[self tableViewUpdate:indexPaths];
			break;
		case TABLEVIEW_RELOAD:
			[self tableViewReloadData];
			break;
		default:
			NSLog(@"fake updateType");
			break;
	}
}

- (void) networkError {
	[self performSelectorOnMainThread:@selector(showUIAlertView) withObject:nil waitUntilDone:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	sinaTableView = nil;
	_refreshHeaderView = nil;
	lastCellActivityIndicator = nil;
	loadingView = nil;
}

- (void)dealloc {
	[_refreshHeaderView release];
	[sinaTweetQueue release];
	[lastCellActivityIndicator release];
	[loadingView release];
	//[userImageForPerformance release];

    [super dealloc];
}


@end

