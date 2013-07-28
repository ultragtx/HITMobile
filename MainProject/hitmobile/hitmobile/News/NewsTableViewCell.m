//
//  NewsTableViewCell.m
//  iHITNews
//
//  Created by keywind on 11-9-12.
//  Copyright 2011年 Hit. All rights reserved.
//

#import "NewsTableViewCell.h"


@implementation NewsTableViewCell

@synthesize newsImageView;
@synthesize newsTitleLabel;
@synthesize newsDateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

@end
