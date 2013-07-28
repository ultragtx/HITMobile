//
//  RootViewController.m
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "SearchTableViewController.h"
#import "SearchMapView.h"
#import "OverlayViewController.h"

@implementation SearchTableViewController
@synthesize searchBar;
@synthesize customHeaderView;
@synthesize cancleBarButton;
@synthesize parentTiledMapViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Initialize the array.
	listOfItems = [[NSMutableArray alloc] init];
	
	NSString *bundlePathofPlist = [[NSBundle mainBundle]pathForResource:@"locate" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
	NSArray *dataFromPlist = [dict valueForKey:@"Region1place"];
	NSArray *Region1Coor = dataFromPlist;
	
//	NSArray *countriesToLiveInArray = [NSArray arrayWithObjects:@"Iceland", @"Greenland", @"Switzerland", @"Norway", @"New Zealand", @"Greece", @"Italy", @"Ireland", nil];
	NSDictionary *Region1CoorInDict = [NSDictionary dictionaryWithObject:Region1Coor forKey:@"Coordinates"];
	
	dataFromPlist = [dict valueForKey:@"Region2place"];
	NSArray *Region2Coor = dataFromPlist;
//	NSArray *countriesLivedInArray = [NSArray arrayWithObjects:@"India", @"U.S.A", nil];
	NSDictionary *Region2CoorInDict = [NSDictionary dictionaryWithObject:Region2Coor forKey:@"Coordinates"];
	
	[listOfItems addObject:Region1CoorInDict];
	[listOfItems addObject:Region2CoorInDict];
	
	//Initialize the copy array.
	copyListOfItems = [[NSMutableArray alloc] init];
	
	//Set the title
	self.navigationItem.title = @"校内地图";
	
	
	self.tableView.tableHeaderView = self.customHeaderView;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	
	searching = NO;
	letUserSelectRow = YES;
}

- (void)getCoordinateFromPlist:(NSString *)placeName {
	NSString *bundlePathofPlist = [[NSBundle mainBundle]pathForResource:@"newLocation" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
	NSArray *locate1FromPlist = [dict valueForKey:@"Region1place"];
	NSInteger index = [locate1FromPlist indexOfObject:placeName];
	if(index != NSNotFound){
		NSArray *CoorX1FromPlist = [dict valueForKey:@"Region1CoordinatesX"];
		int CoorX = [[CoorX1FromPlist objectAtIndex:index] intValue];
		NSArray *CoorY1FromPlist = [dict valueForKey:@"Region1CoordinatesY"];
		int CoorY = [[CoorY1FromPlist objectAtIndex:index] intValue];
        [self.parentTiledMapViewController.segmentControl setSelectedSegmentIndex:0];
        self.parentTiledMapViewController.currentCampus = 1;
		[self.parentTiledMapViewController chooseCampus1WithPointX:CoorX Y:CoorY];
	}
	else{
		NSArray *locate2FromPlist = [dict valueForKey:@"Region2place"];
		index = [locate2FromPlist indexOfObject:placeName];
		NSArray *CoorX2FromPlist = [dict valueForKey:@"Region2CoordinatesX"];
		int CoorX = [[CoorX2FromPlist objectAtIndex:index] intValue];
		NSArray *CoorY2FromPlist = [dict valueForKey:@"Region2CoordinatesY"];
		int CoorY = [[CoorY2FromPlist objectAtIndex:index] intValue];
        [self.parentTiledMapViewController.segmentControl setSelectedSegmentIndex:1];
        self.parentTiledMapViewController.currentCampus = 2;
		[self.parentTiledMapViewController chooseCampus2WithPointX:CoorX Y:CoorY];
        
	}
	[self cancleBarButtonPressed:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	if (searching)
		return 1;
	else
		return [listOfItems count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (searching)
		return [copyListOfItems count];
	else {
		
		//Number of rows it should expect should be based on the section
		NSDictionary *dictionary = [listOfItems objectAtIndex:section];
		NSArray *array = [dictionary objectForKey:@"Coordinates"];
		return [array count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(searching)
		return @"Search Results";
	
	if(section == 0)
		return @"一校区";
	else
		return @"二校区";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
	if(searching) 
		cell.textLabel.text = [copyListOfItems objectAtIndex:indexPath.row];
	else {
		
		//First get the dictionary object
		NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
		NSArray *array = [dictionary objectForKey:@"Coordinates"];
		NSString *cellValue = [array objectAtIndex:indexPath.row];
		cell.textLabel.text = cellValue;
	}

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//Get the selected country
	
	NSString *selectedPlace	= nil;
	
	if(searching)
		selectedPlace = [copyListOfItems objectAtIndex:indexPath.row];
	else {
	
		NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
		NSArray *array = [dictionary objectForKey:@"Coordinates"];
		selectedPlace = [array objectAtIndex:indexPath.row];
	}
	
	
	[self getCoordinateFromPlist:selectedPlace];
	return;
	//Initialize the detail view controller and display it.
//	DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
//	SearchMapView *dvController = [[SearchMapView alloc] initWithNibName:@"SearchMapView" bundle:nil];
	SearchMapView *dvController = [[SearchMapView alloc] init];
	dvController.selectedPlace = selectedPlace;
	[self.navigationController pushViewController:dvController animated:YES];
	[dvController release];
	dvController = nil;
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(letUserSelectRow)
		return indexPath;
	else
		return nil;
}

/*- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	//return UITableViewCellAccessoryDetailDisclosureButton;
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}*/

#pragma mark -
#pragma mark Search Bar 

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	//This method is called again when the user clicks back from teh detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if(searching)
		return;
	
	//Add the overlay view.
	if(ovController == nil)
		ovController = [[OverlayViewController alloc] initWithNibName:@"OverlayView" bundle:[NSBundle mainBundle]];
	
	CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
	CGFloat width = self.view.frame.size.width;
	CGFloat height = self.view.frame.size.height;
	
	//Parameters x = origion on x-axis, y = origon on y-axis.
	CGRect frame = CGRectMake(0, yaxis, width, height);
	ovController.view.frame = frame;	
	ovController.view.backgroundColor = [UIColor grayColor];
	ovController.view.alpha = 0.5;
	
	ovController.rvController = self;
	
	[self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
	
	searching = YES;
	letUserSelectRow = NO;
	self.tableView.scrollEnabled = NO;
	
	//Add the done button.
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
											   target:self action:@selector(doneSearching_Clicked:)] autorelease];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {

	//Remove all objects first.
	[copyListOfItems removeAllObjects];
	
	if([searchText length] > 0) {
		
		[ovController.view removeFromSuperview];
		searching = YES;
		letUserSelectRow = YES;
		self.tableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		[self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
		
		searching = NO;
		letUserSelectRow = NO;
		self.tableView.scrollEnabled = NO;
	}
	
	[self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	[self searchTableView];
}

- (void) searchTableView {
	
	NSString *searchText = searchBar.text;
	NSMutableArray *searchArray = [[NSMutableArray alloc] init];
	
	for (NSDictionary *dictionary in listOfItems)
	{
		NSArray *array = [dictionary objectForKey:@"Coordinates"];
		[searchArray addObjectsFromArray:array];
	}
	
	for (NSString *sTemp in searchArray)
	{
		NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0)
			[copyListOfItems addObject:sTemp];
	}
	
	[searchArray release];
	searchArray = nil;
}

- (void) doneSearching_Clicked:(id)sender {
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
	letUserSelectRow = YES;
	searching = NO;
	self.navigationItem.rightBarButtonItem = nil;
	self.tableView.scrollEnabled = YES;
	
	[ovController.view removeFromSuperview];
	[ovController release];
	ovController = nil;
	
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Memory Management


- (void)dealloc {
	[parentTiledMapViewController release];

	[searchBar release];
	[customHeaderView release];
	[cancleBarButton release];
	[ovController release];
	[copyListOfItems release];
	[listOfItems release];
    [super dealloc];
}



#pragma mark -
#pragma mark cancleBarButton listener

- (IBAction) cancleBarButtonPressed:(id)sender {
    NSLog(@"cancle Bar button Pressed");
	//[self.parentViewController dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

@end

