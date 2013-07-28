//
//  PlacesViewController.m
//  iHIT
//
//  Created by FoOTOo on 11-6-15.
//  Copyright 2011 HIT. All rights reserved.
//

#import "PlacesViewController.h"
#import "PlacesInSameCategoryViewController.h"

@implementation PlacesViewController
@synthesize categories;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Added by G
    // Toggle Menu
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"] style:UIBarButtonItemStyleBordered target:[UIApplication sharedApplication].delegate action:@selector(toggleLeftView)];
    [self.navigationItem setLeftBarButtonItem:menuBarButtonItem];
    [menuBarButtonItem release];
    // End
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
	self.title = @"哈工大周边";
	self.categories = [NSArray arrayWithObjects:@"餐馆", @"旅店", @"电影院", @"KTV", @"酒吧", @"美发", @"网吧", @"公交", @"其他", nil];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSString *)iconImageName {
	return @"NearIcon.png";
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.categories count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [self.categories objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlacesInSameCategoryViewController *placesInSameCategoryViewController = [[PlacesInSameCategoryViewController alloc] initWithNibName:@"PlacesInSameCategoryViewController" bundle:nil];
    placesInSameCategoryViewController.category = indexPath.row;
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:placesInSameCategoryViewController animated:YES];
    [placesInSameCategoryViewController release];
    
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
	[categories release];
    [super dealloc];
}


@end