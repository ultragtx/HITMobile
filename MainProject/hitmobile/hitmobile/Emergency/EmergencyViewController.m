//
//  EmergencyViewController.m
//  iHIT
//
//  Created by Bai Yalong on 11-3-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EmergencyViewController.h"
#import "EmergencyOverlayViewController.h"

/*
 Predefined colors to alternate the background color of each cell row by row
 (see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
 */
#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]

#define EMERGENCY			0
#define	HOSPITAL_SECTION	1
#define POLICE_SECTION		2
#define SCHOOL_SECTION		3
#define MANAGER_SECTION		4
#define OTHER_SECTION		5


@implementation EmergencyViewController

@synthesize tmpCell, cellNib;


#pragma mark -
#pragma mark View controller methods

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
	// Configure the table view.
    self.tableView.rowHeight = 72.0 ;
//    self.tableView.backgroundColor = DARK_BACKGROUND;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
	// Load the data.
//    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
//    self.data = [NSArray arrayWithContentsOfFile:dataPath];

	listOfItems = [[NSMutableArray alloc] init];
		
	NSString *bundlePathofPlist = [[NSBundle mainBundle]pathForResource:@"data" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
	NSArray *dataFromPlist = [dict valueForKey:@"hospital"];
	NSArray *Hospital = dataFromPlist;
	NSDictionary *HospitalInDict = [NSDictionary dictionaryWithObject:Hospital forKey:@"Coordinates"];
	dataFromPlist = [dict valueForKey:@"police"];
	NSArray *Police = dataFromPlist;
	NSDictionary *PoliceInDict = [NSDictionary dictionaryWithObject:Police forKey:@"Coordinates"];
	dataFromPlist = [dict valueForKey:@"manager"];
	NSArray *Manager = dataFromPlist;
	NSDictionary *ManagerInDict = [NSDictionary dictionaryWithObject:Manager forKey:@"Coordinates"];
	dataFromPlist = [dict valueForKey:@"school"];
	NSArray *School = dataFromPlist;
	NSDictionary *SchoolInDict = [NSDictionary dictionaryWithObject:School forKey:@"Coordinates"];
	dataFromPlist = [dict valueForKey:@"other"];
	NSArray *Other = dataFromPlist;
	NSDictionary *OtherInDict = [NSDictionary dictionaryWithObject:Other forKey:@"Coordinates"];
	dataFromPlist = [dict valueForKey:@"emergency"];
	NSArray *Emergency = dataFromPlist;
	NSDictionary *EmergencyInDIct = [NSDictionary dictionaryWithObject:Emergency forKey:@"Coordinates"];
	
	[listOfItems addObject:EmergencyInDIct];
	[listOfItems addObject:HospitalInDict];
	[listOfItems addObject:PoliceInDict];
	[listOfItems addObject:SchoolInDict];
	[listOfItems addObject:ManagerInDict];
	[listOfItems addObject:OtherInDict];
	
	self.navigationItem.title = @"工大通讯录";
	// create our UINib instance which will later help us load and instanciate the
	// UITableViewCells's UI via a xib file.
	//
	// Note:
	// The UINib classe provides better performance in situations where you want to create multiple
	// copies of a nib file’s contents. The normal nib-loading process involves reading the nib file
	// from disk and then instantiating the objects it contains. However, with the UINib class, the
	// nib file is read from disk once and the contents are stored in memory.
	// Because they are in memory, creating successive sets of objects takes less time because it
	// does not require accessing the disk.
	//
	self.cellNib = [UINib nibWithNibName:@"EmergencyTableViewCell" bundle:nil];
	
	//Initialize the copy array.
	copyListOfItems_icon = [[NSMutableArray alloc] init];
	copyListOfItems_chineseDescription =[[NSMutableArray alloc] init];
	copyListOfItems_englishDescription = [[NSMutableArray alloc] init];
	copyListOfItems_telephoneNumber = [[NSMutableArray alloc] init];
	
	//Add the search bar
	self.tableView.tableHeaderView = searchBar;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	
	searching = NO;
	letUserSelectRow = YES;

}

- (NSString *)iconImageName {
	return @"ContactIcon.png";
}
//- (void)viewDidUnload
//{
//	[super viewDidLoad];
//	
//	self.listOfItems = nil;
//	self.tmpCell = nil;
//	self.cellNib = nil;
//}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (searching)
		return 1;
	else
		return [listOfItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	if (searching)
		return [copyListOfItems_icon count];
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
	
	switch (section) {
		case EMERGENCY:
			return @"仅紧急情况下使用";
			break;
		case HOSPITAL_SECTION:
			return @"校医院";
			break;
		case POLICE_SECTION:
			return @"保卫处";
			break;
		case MANAGER_SECTION:
			return @"行政部门";
			break;
		case SCHOOL_SECTION:
			return @"学院信息";
			break;
		case OTHER_SECTION:
			return @"其他部门";
			break;
		default:
			break;
	}
	return @"error";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EmegencyCell";
    
    EmergencyCell *cell = (EmergencyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
    {
		//#if USE_INDIVIDUAL_SUBVIEWS_CELL
        [self.cellNib instantiateWithOwner:self options:nil];
		cell = tmpCell;
		self.tmpCell = nil;
    }
    
	// Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
//    cell.useDarkBackground = (indexPath.row % 2 == 0);
	
	// Configure the data for the cell.	
	NSString *bundlePathofPlist = [[NSBundle mainBundle]pathForResource:@"data" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
	NSArray *dataFromPlist;
	
	if (searching) {
		cell.icon = [UIImage imageNamed:[copyListOfItems_icon objectAtIndex:indexPath.row]];
		cell.telephoneNumber = [copyListOfItems_telephoneNumber objectAtIndex:indexPath.row];
		cell.englishDescription = [copyListOfItems_englishDescription objectAtIndex:indexPath.row];
		cell.chineseDescription = [copyListOfItems_chineseDescription objectAtIndex:indexPath.row];
	}
	else {
		switch (indexPath.section) {
			case EMERGENCY:
				dataFromPlist = [dict valueForKey:@"emergency"];
				cell.chineseDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"emergency_english"];
				cell.englishDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"telephone_emergency"];
				cell.telephoneNumber = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"photo_emergency"];
				cell.icon = [UIImage imageNamed:[dataFromPlist objectAtIndex:indexPath.row]];	
				break;
			case HOSPITAL_SECTION:
				dataFromPlist = [dict valueForKey:@"hospital"];
				cell.chineseDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"hospital_english"];
				cell.englishDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"telephone_hospital"];
				cell.telephoneNumber = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"photo_hospital"];
				cell.icon = [UIImage imageNamed:[dataFromPlist objectAtIndex:indexPath.row]];	
				break;
			case POLICE_SECTION:
				dataFromPlist = [dict valueForKey:@"police"];
				cell.chineseDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"police_english"];
				cell.englishDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"telephone_police"];
				cell.telephoneNumber = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"photo_police"];
				cell.icon = [UIImage imageNamed:[dataFromPlist objectAtIndex:indexPath.row]];
				break;
			case MANAGER_SECTION:
				dataFromPlist = [dict valueForKey:@"manager"];
				cell.chineseDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"manager_english"];
				cell.englishDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"telephone_manager"];
				cell.telephoneNumber = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"photo_manager"];
				cell.icon = [UIImage imageNamed:[dataFromPlist objectAtIndex:indexPath.row]];
				break;
			case SCHOOL_SECTION:
				dataFromPlist = [dict valueForKey:@"school"];
				cell.chineseDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"school_english"];
				cell.englishDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"telephone_school"];
				cell.telephoneNumber = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"photo_school"];
				cell.icon = [UIImage imageNamed:[dataFromPlist objectAtIndex:indexPath.row]];
				break;
			case OTHER_SECTION:
				dataFromPlist = [dict valueForKey:@"other"];
				cell.chineseDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"other_english"];
				cell.englishDescription = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"telephone_other"];
				cell.telephoneNumber = [dataFromPlist objectAtIndex:indexPath.row];
				dataFromPlist = [dict valueForKey:@"photo_other"];
				cell.icon = [UIImage imageNamed:[dataFromPlist objectAtIndex:indexPath.row]];
				break;
			default:
				break;
				
		}
		
	}
    return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.backgroundColor = ((EmergencyCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
//}
- (void)telephoneCall:(NSString *)input
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", input]]];
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(letUserSelectRow){
		return indexPath;
	}else {
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *bundlePathofPlist = [[NSBundle mainBundle]pathForResource:@"data" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
	
	NSArray *dataFromPlist;
	NSString *telephonecall;
	
	if(searching){
		telephonecall = [copyListOfItems_telephoneNumber objectAtIndex:indexPath.row];
	}
	else {
		switch (indexPath.section) {
			case EMERGENCY:
				dataFromPlist = [dict valueForKey:@"telephone_emergency"];
				break;
			case HOSPITAL_SECTION:
				dataFromPlist = [dict valueForKey:@"telephone_hospital"];
				break;
			case POLICE_SECTION:
				dataFromPlist = [dict valueForKey:@"telephone_police"];
				break;
			case MANAGER_SECTION:
				dataFromPlist = [dict valueForKey:@"telephone_manager"];
				break;
			case SCHOOL_SECTION:
				dataFromPlist = [dict valueForKey:@"telephone_school"];
				break;
			case OTHER_SECTION:
				dataFromPlist = [dict valueForKey:@"telephone_other"];
				break;
			default:
				break;
		}
		telephonecall = [dataFromPlist objectAtIndex:indexPath.row];
	}
    
    UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:@"确认呼叫" 
                                                        message:telephonecall
                                                       delegate:self 
                                              cancelButtonTitle:@"取消" 
                                              otherButtonTitles:@"呼叫", nil];
    [callAlert show];
    [callAlert release];
	//[self telephoneCall:telephonecall];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self telephoneCall:alertView.message];
    }
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//	
//	//return UITableViewCellAccessoryDetailDisclosureButton;
//	return UITableViewCellAccessoryDisclosureIndicator;
//}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark Search Bar 

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	//This method is called again when the user clicks back from teh detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if(searching)
		return;
	
	//Add the overlay view.
	if(ovController == nil)
		ovController = [[EmergencyOverlayViewController alloc] initWithNibName:@"EmergencyOverlayViewController" bundle:[NSBundle mainBundle]];
	
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
	[copyListOfItems_icon removeAllObjects];
	[copyListOfItems_telephoneNumber removeAllObjects];
	[copyListOfItems_chineseDescription removeAllObjects];
	[copyListOfItems_englishDescription removeAllObjects];
	
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
//	NSArray *listOfItems_english = [[NSArray alloc] init];
//	NSString *bundlePathofPlist = [[NSBundle mainBundle]pathForResource:@"data" ofType:@"plist"];
//	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
//	NSArray *dataFromPlist = [dict valueForKey:@"emergency_english"];
//	listOfItems_english = dataFromPlist;
//	dataFromPlist = [dict valueForKey:@"hospital_english"];
//	[listOfItems_english ]
	
	
	NSString *bundlePathofPlist = [[NSBundle mainBundle]pathForResource:@"data" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
	NSArray *dataFromPlist = [dict valueForKey:@"hospital_english"];
	NSArray *Hospital = dataFromPlist;
//	NSDictionary *HospitalInDict = [NSDictionary dictionaryWithObject:Hospital forKey:@"english"];
	dataFromPlist = [dict valueForKey:@"police_english"];
	NSArray *Police = dataFromPlist;
//	NSDictionary *PoliceInDict = [NSDictionary dictionaryWithObject:Police forKey:@"english"];
	dataFromPlist = [dict valueForKey:@"manager_english"];
	NSArray *Manager = dataFromPlist;
//	NSDictionary *ManagerInDict = [NSDictionary dictionaryWithObject:Manager forKey:@"english"];
	dataFromPlist = [dict valueForKey:@"school_english"];
	NSArray *School = dataFromPlist;
//	NSDictionary *SchoolInDict = [NSDictionary dictionaryWithObject:School forKey:@"english"];
	dataFromPlist = [dict valueForKey:@"other_english"];
	NSArray *Other = dataFromPlist;
//	NSDictionary *OtherInDict = [NSDictionary dictionaryWithObject:Other forKey:@"english"];
	dataFromPlist = [dict valueForKey:@"emergency_english"];
	NSArray *Emergency = dataFromPlist;
//	NSDictionary *EmergencyInDIct = [NSDictionary dictionaryWithObject:Emergency forKey:@"english"];

	NSMutableArray *listOfItems_english = [[NSMutableArray alloc] init];
	
	[listOfItems_english addObjectsFromArray:Emergency];
	[listOfItems_english addObjectsFromArray:Hospital];
	[listOfItems_english addObjectsFromArray:Police];
	[listOfItems_english addObjectsFromArray:School];
	[listOfItems_english addObjectsFromArray:Manager];
	[listOfItems_english addObjectsFromArray:Other];
	
	dataFromPlist = [dict valueForKey:@"telephone_hospital"];
	Hospital = dataFromPlist;
//	HospitalInDict = [NSDictionary dictionaryWithObject:Hospital forKey:@"telephone"];
	dataFromPlist = [dict valueForKey:@"telephone_police"];
	Police = dataFromPlist;
//	PoliceInDict = [NSDictionary dictionaryWithObject:Police forKey:@"telephone"];
	dataFromPlist = [dict valueForKey:@"telephone_manager"];
	Manager = dataFromPlist;
//	ManagerInDict = [NSDictionary dictionaryWithObject:Manager forKey:@"telephone"];
	dataFromPlist = [dict valueForKey:@"telephone_school"];
	School = dataFromPlist;
//	SchoolInDict = [NSDictionary dictionaryWithObject:School forKey:@"telephone"];
	dataFromPlist = [dict valueForKey:@"telephone_other"];
	Other = dataFromPlist;
//	OtherInDict = [NSDictionary dictionaryWithObject:Other forKey:@"telephone"];
	dataFromPlist = [dict valueForKey:@"telephone_emergency"];
	Emergency = dataFromPlist;
//	EmergencyInDIct = [NSDictionary dictionaryWithObject:Emergency forKey:@"telephone"];
	
	NSMutableArray *listOfItems_telephone= [[NSMutableArray alloc] init];
	
	[listOfItems_telephone addObjectsFromArray:Emergency];
	[listOfItems_telephone addObjectsFromArray:Hospital];
	[listOfItems_telephone addObjectsFromArray:Police];
	[listOfItems_telephone addObjectsFromArray:School];
	[listOfItems_telephone addObjectsFromArray:Manager];
	[listOfItems_telephone addObjectsFromArray:Other];
	
	dataFromPlist = [dict valueForKey:@"hospital"];
	Hospital = dataFromPlist;
	//	HospitalInDict = [NSDictionary dictionaryWithObject:Hospital forKey:@"telephone"];
	dataFromPlist = [dict valueForKey:@"police"];
	Police = dataFromPlist;
	//	PoliceInDict = [NSDictionary dictionaryWithObject:Police forKey:@"telephone"];
	dataFromPlist = [dict valueForKey:@"manager"];
	Manager = dataFromPlist;
	//	ManagerInDict = [NSDictionary dictionaryWithObject:Manager forKey:@"telephone"];
	dataFromPlist = [dict valueForKey:@"school"];
	School = dataFromPlist;
	//	SchoolInDict = [NSDictionary dictionaryWithObject:School forKey:@"telephone"];
	dataFromPlist = [dict valueForKey:@"other"];
	Other = dataFromPlist;
	//	OtherInDict = [NSDictionary dictionaryWithObject:Other forKey:@"telephone"];
	dataFromPlist = [dict valueForKey:@"emergency"];
	Emergency = dataFromPlist;
	//	EmergencyInDIct = [NSDictionary dictionaryWithObject:Emergency forKey:@"telephone"];
	
	NSMutableArray *listOfItems_chinese= [[NSMutableArray alloc] init];
	
	[listOfItems_chinese addObjectsFromArray:Emergency];
	[listOfItems_chinese addObjectsFromArray:Hospital];
	[listOfItems_chinese addObjectsFromArray:Police];
	[listOfItems_chinese addObjectsFromArray:School];
	[listOfItems_chinese addObjectsFromArray:Manager];
	[listOfItems_chinese addObjectsFromArray:Other];
	
	for (NSDictionary *dictionary in listOfItems)
	{
		NSArray *array = [dictionary objectForKey:@"Coordinates"];
		[searchArray addObjectsFromArray:array];
	}
	int i = 0;
	
	for (NSString *sTemp in searchArray)
	{
		NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0){
			[copyListOfItems_chineseDescription addObject:sTemp];
			NSString *temp = [[NSArray arrayWithArray:listOfItems_english] objectAtIndex:i];
			[copyListOfItems_englishDescription addObject:temp];
			temp = [[NSArray arrayWithArray:listOfItems_telephone] objectAtIndex:i];
			[copyListOfItems_telephoneNumber addObject:temp];
			temp = [NSString stringWithFormat:@"%@.png",temp];
			[copyListOfItems_icon addObject:temp];
		}
		++i;
	}
	
//	NSLog(@"OK");
	
//	for (NSDictionary *dictionary in listOfItems_english) {
//		NSArray *array = [dictionary objectForKey:@"english"];
//		[searchArray addObjectsFromArray:array];
//	}
//	i = 0;
	i = 0;
	
	for (NSString *sTemp in listOfItems_english) {
		NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0) {
			[copyListOfItems_englishDescription addObject:sTemp];
			NSString *temp = [[NSArray arrayWithArray:listOfItems_chinese] objectAtIndex:i];
			[copyListOfItems_chineseDescription addObject:temp];
			temp = [[NSArray arrayWithArray:listOfItems_telephone] objectAtIndex:i];
			[copyListOfItems_telephoneNumber addObject:temp];
			temp = [NSString stringWithFormat:@"%@.png",temp];
			[copyListOfItems_icon addObject:temp];
		}
		++i;
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
#pragma mark Memory management

- (void)dealloc
{
    [listOfItems release];
	[tmpCell release];
	[cellNib release];
    [super dealloc];
}

@end