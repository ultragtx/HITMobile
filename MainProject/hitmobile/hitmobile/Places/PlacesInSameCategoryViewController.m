//
//  PlacesInSameCategoryViewController.m
//  iHIT
//
//  Created by FoOTOo on 11-6-15.
//  Copyright 2011 HIT. All rights reserved.
//

#import "PlacesInSameCategoryViewController.h"
#import "ExpandViewController.h"
#import "Play.h"

#define RESTAURANT 0
#define HOTEL 1
#define CINEMA 2
#define KTV 3
#define WINEBAR 4
#define FAIRCUT 5
#define NETBAR 6
#define TRAFFIC 7
#define OTHER 8

@implementation PlacesInSameCategoryViewController
@synthesize category;
@synthesize placesNames;
@synthesize placesGeos;

@synthesize plays;
#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	NSString *bundlePathofPlist = [[NSBundle mainBundle] pathForResource:@"PlacesData" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
    switch (self.category) {
		case RESTAURANT:
			self.title = @"餐馆";
			self.placesNames = [dict valueForKey:@"restaurant_names"];
			self.placesGeos = [dict valueForKey:@"restaurant_geos"];
			break;
		case HOTEL:
			self.title = @"旅店";
			self.placesNames = [dict valueForKey:@"hotel_names"];
			self.placesGeos = [dict valueForKey:@"hotel_geos"];
			break;
		case CINEMA:
			self.title = @"电影院";
			self.placesNames = [dict valueForKey:@"cinema_names"];
			self.placesGeos = [dict valueForKey:@"cinema_geos"];
			break;
		case KTV:
			self.title = @"KTV";
			self.placesNames = [dict valueForKey:@"ktv_names"];
			self.placesGeos = [dict valueForKey:@"ktv_geos"];
			break;
		case WINEBAR:
			self.title = @"酒吧";
			self.placesNames = [dict valueForKey:@"winebar_names"];
			self.placesGeos = [dict valueForKey:@"winebar_geos"];
			break;
		case FAIRCUT:
			self.title = @"美发";
			self.placesNames = [dict valueForKey:@"faircut_names"];
			self.placesGeos = [dict valueForKey:@"faircut_geos"];
			break;
		case NETBAR:
			self.title = @"网吧";
			self.placesNames = [dict valueForKey:@"netbar_names"];
			self.placesGeos = [dict valueForKey:@"netbar_geos"];
			break;
		case TRAFFIC:
			self.title = @"公交";
			self.placesNames = [dict valueForKey:@"traffic_names"];
			self.placesGeos = [dict valueForKey:@"traffic_geos"];
			break;
		case OTHER:
			self.title = @"其他";
			self.placesNames = [dict valueForKey:@"other_names"];
			self.placesGeos = [dict valueForKey:@"other_geos"];
			break;
		default:
			break;
	}
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.placesNames count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [self.placesNames objectAtIndex:indexPath.row];
	if (self.category == TRAFFIC) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}

    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (self.category == TRAFFIC) {
		[self setUpPlaysArray:indexPath.row];
		
		ExpandViewController *aTableViewController = [[ExpandViewController alloc] initWithStyle:UITableViewStylePlain];
		aTableViewController.plays = self.plays;
		aTableViewController.placeName = [self.placesNames objectAtIndex:indexPath.row];
		[self.navigationController pushViewController:aTableViewController animated:YES];
		[aTableViewController release];
		
	} 

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	[self getRoute:[self.placesGeos objectAtIndex:indexPath.row]];
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	
	[placesNames release];
	[placesGeos release];
	[plays release];
    [super dealloc];
}

- (void)getRoute:(NSString *)destination{
	NSString *source = @"当前位置";	
	NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@",
					 [source stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					 [destination stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
}


- (void)setUpPlaysArray:(NSInteger)index{
	
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"traffic" withExtension:@"plist"];
    NSArray *playDictionariesArray = [[NSArray alloc ] initWithContentsOfURL:url];
	NSArray *playInOneArray = [playDictionariesArray objectAtIndex:index];
    NSMutableArray *playsArray = [NSMutableArray arrayWithCapacity:[playInOneArray count]];
    for (NSDictionary *playDictionary in playInOneArray) {
        
        Play *play = [[Play alloc] init];
        play.name = [playDictionary objectForKey:@"playName"];
        NSArray *quotationDictionaries = [playDictionary objectForKey:@"quotations"];
        NSMutableArray *quotations = [NSMutableArray arrayWithCapacity:[quotationDictionaries count]];
        for (NSString *quotationDictionary in quotationDictionaries) {
			
			[quotations addObject:quotationDictionary];
        }
        play.quotations = quotations;
        [playsArray addObject:play];
        [play release];
    }
    
    self.plays = playsArray;
    [playDictionariesArray release];
}

@end