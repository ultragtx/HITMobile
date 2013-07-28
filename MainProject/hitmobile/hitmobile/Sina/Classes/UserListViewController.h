//
//  UserListViewController.h
//  iHIT
//
//  Created by Hiro on 11-5-4.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "SinaTweetQueue.h"

@protocol UserListViewControllerDelegate

- (void)didSelectUser:(Status *)status;
- (void)didSelectNewUser;

@end


@interface UserListViewController : UIViewController <UITableViewDelegate,
UITableViewDataSource> {
	UITableView *userListTableView;
	NSMutableArray *userList; // infact it's a status
	id<UserListViewControllerDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITableView *userListTableView;
@property (nonatomic, retain) NSMutableArray *userList;
@property (nonatomic, assign) id<UserListViewControllerDelegate> delegate;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)newUserButtonPressed:(id)sender;

@end
