//
//  NewsCell.h
//  iHIT
//
//  Created by keywind on 11-9-7.
//  Copyright 2011年 Hit. All rights reserved.
//


@interface NewsCell : NSObject {
    
    NSString *newsTitle;    
	NSString *newsDetail;
	NSString *newsAuthor;
    UIImage *newsCellImage;
    NSString *newsCellImageURL;
	UIImage *newsImage;
    NSString *newsImageURL;
	NSString *newsDate;
	UIImage *newsLargeImage;
    NSString *newsLargeImageURL;
    
    BOOL hasImage;
}

@property (nonatomic, retain) NSString *newsTitle;
@property (nonatomic, retain) NSString *newsDetail;
@property (nonatomic, retain) NSString *newsAuthor;
@property (nonatomic, retain) UIImage *newsCellImage;
@property (nonatomic, retain) NSString *newsCellImageURL;
@property (nonatomic, retain) UIImage *newsImage;
@property (nonatomic, retain) NSString *newsImageURL;
@property (nonatomic, retain) NSString *newsDate;
@property (nonatomic, retain) UIImage *newsLargeImage;
@property (nonatomic, retain) NSString *newsLargeImageURL;

@property (nonatomic, assign) BOOL hasImage;
@end
