//
//  LoadingTableViewCell.h
//  iHIT
//
//  Created by keywind on 11-9-18.
//  Copyright 2011年 Hit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadingTableViewCell : UITableViewCell {
	UIActivityIndicatorView *indicator;
	UILabel *loadingLabel;
}
@property(nonatomic,retain) UIActivityIndicatorView *indicator;
@property(nonatomic,retain) UILabel *loadingLabel;
@end 
