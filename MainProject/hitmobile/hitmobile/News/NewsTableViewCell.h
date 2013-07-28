//
//  NewsTableViewCell.h
//  iHITNews
//
//  Created by keywind on 11-9-12.
//  Copyright 2011年 Hit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTableViewCell : UITableViewCell {
    IBOutlet UIImageView *newsImageView;
    IBOutlet UILabel *newsTitleLabel;
    IBOutlet UILabel *newsDateLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *newsImageView;
@property (nonatomic, retain) IBOutlet UILabel *newsTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *newsDateLabel;

@end
