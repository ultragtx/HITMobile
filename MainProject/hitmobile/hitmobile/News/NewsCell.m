//
//  NewsCell.m
//  iHIT
//
//  Created by keywind on 11-9-7.
//  Copyright 2011年 Hit. All rights reserved.
//

#import "NewsCell.h"


@implementation NewsCell

@synthesize newsTitle;
@synthesize newsDate;
@synthesize newsAuthor;
@synthesize newsCellImage;
@synthesize newsCellImageURL;
@synthesize newsImage;
@synthesize newsImageURL;
@synthesize newsDetail;
@synthesize newsLargeImage;
@synthesize newsLargeImageURL;

@synthesize hasImage;

- (void)dealloc
{
    [newsTitle release];
    [newsDate release];
    [newsAuthor release];
    [newsCellImage release];
    [newsCellImageURL release];
    [newsImage release];
    [newsImageURL release];
    [newsDetail release];
    [newsLargeImage release];
    [newsLargeImageURL release];
    
    [super dealloc];
}
@end
