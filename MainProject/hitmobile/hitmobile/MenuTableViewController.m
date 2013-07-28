//
//  UselessTableViewController.m
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-18.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import "MenuTableViewController.h"
#import "AppDelegate.h"


@implementation MenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _menuItems = [[NSArray alloc] initWithObjects:@"新闻", @"微博", @"地图", @"周边", @"联系", nil];
        [self.tableView setBackgroundColor:[UIColor underPageBackgroundColor]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MenuBackground.jpg"]];
        [self.tableView setBackgroundView:imageView];
        
        [self.tableView setSeparatorColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        
        /*for (NSString *fontName in [UIFont familyNames]) {
            NSLog(@"%@", fontName);
        }*/
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //[cell setBackgroundColor:[UIColor clearColor]];
        UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [cell setBackgroundView:backgroundView];
        [cell.backgroundView setBackgroundColor:[UIColor blackColor]];
        [cell.backgroundView setAlpha:0.2];
        
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        [selectedBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [cell setSelectedBackgroundView:selectedBackgroundView];
        [cell.selectedBackgroundView setBackgroundColor:[UIColor blackColor]];
        [cell.selectedBackgroundView setAlpha:0.5];
        
        [cell.textLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setShadowColor:[UIColor blackColor]];
        [cell.textLabel setShadowOffset:CGSizeMake(0.0f, -0.1f)];
    }
    
    [cell.textLabel setText:[_menuItems objectAtIndex:indexPath.row]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 38.0f)];
    [headerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 320, 28.0f)];
    [headerTitle setBackgroundColor:[UIColor clearColor]];
    [headerTitle setText:@"HIT Mobile"];
    [headerTitle setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [headerTitle setTextColor:[UIColor lightGrayColor]];
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(AppDelegate *)[UIApplication sharedApplication].delegate switchToViewControllerAtIndex:indexPath.row];
}

@end
