//
//  ImageDownloader.m
//  iHIT
//
//  Created by Hiro on 11-4-4.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import "ImageDownloader.h"


@implementation ImageDownloader

@synthesize delegate;
@synthesize indexPathInTableView;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize imageType;

- (void)dealloc {
	[indexPathInTableView release];
	[activeDownload release];
	[imageConnection release];
	[super dealloc];
}

- (void)netWorkInUse:(BOOL)isNetWorkInUse {
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = isNetWorkInUse;
}

- (void)startDownload:(NSString *)imageURL atIndexPath:(NSIndexPath *) indexPath imageType:(ImageType) theImageType{
	[self netWorkInUse:YES];
	self.indexPathInTableView = indexPath;
	self.imageType = theImageType;
	self.activeDownload = [NSMutableData data];
	NSURLConnection *coon = [[NSURLConnection alloc] initWithRequest:
							 [NSURLRequest requestWithURL:
							  [NSURL URLWithString:imageURL]] delegate:self];
	self.imageConnection = coon;
	[coon release];
}

- (void)cancelDownload {
	[self netWorkInUse:NO];
	[self.imageConnection cancel];
	self.imageConnection = nil;
	self.activeDownload = nil;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//NSLog(@"didReceiveData");
	[self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"ImageDownloader didFailWithError");
	[self netWorkInUse:NO];
	self.activeDownload = nil;
	self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//NSLog(@"connectionDifFinishLoading");
	[self netWorkInUse:NO];
	if (!self.activeDownload) {
		return;
	}
	UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
	
	// maybe resize part here
	// saveImageToDisk
	
	self.activeDownload = nil;
	self.imageConnection = nil;
	
	[delegate imageDidLoad:image atIndexPath:self.indexPathInTableView imageType:self.imageType];
	// !!!: attention image release here
	[image release];
}


@end
