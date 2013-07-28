//
//  ImageDownloader.h
//  iHIT
//
//  Created by Hiro on 11-4-4.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
	IMAGE_SMALL,
	IMAGE_LARGE
}ImageType;

@protocol ImageDownloaderDelegate

- (void)imageDidLoad:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath imageType:(ImageType)imageType;

@end


@interface ImageDownloader : NSObject {
	NSIndexPath *indexPathInTableView;
	id <ImageDownloaderDelegate> delegate;
	
	NSMutableData *activeDownload;
	NSURLConnection *imageConnection;
	
	ImageType imageType;
}

@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

@property (nonatomic) ImageType imageType;

- (void)startDownload:(NSString *)imageURL atIndexPath:(NSIndexPath *) indexPath imageType:(ImageType)imageType;
- (void)cancelDownload;

@end
