//
//  SingleNewsViewController2.m
//  iHITNews
//
//  Created by keywind on 11-9-18.
//  Copyright 2011年 Hit. All rights reserved.
//

#import "SingleNewsViewController.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"
#import "SDImageCache.h"
#import "SDDataCache.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>

@implementation SingleNewsViewController

@synthesize newsTitle;
@synthesize newsDate;
@synthesize newsAuthor;
@synthesize newsDetail;
@synthesize newsDetailText;
@synthesize newsImageURL;
@synthesize newsImage;
@synthesize newsLargeImageURL;
@synthesize newsLargeImage;
@synthesize newsWebView;
@synthesize imageZoom;
@synthesize imageZoomView;

@synthesize contentImage;
@synthesize newsConnection;
@synthesize newsData;

@synthesize count;
@synthesize HUD;

- (BOOL)isNetworkReachable{  
	// Create zero addy  
	struct sockaddr_in zeroAddress;  
	bzero(&zeroAddress, sizeof(zeroAddress));  
	zeroAddress.sin_len = sizeof(zeroAddress);  
	zeroAddress.sin_family = AF_INET;  
	
	// Recover reachability flags  
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);  
	SCNetworkReachabilityFlags flags;  
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);  
	CFRelease(defaultRouteReachability);  
	
	if (!didRetrieveFlags)  
	{  
		return NO;  
	}  
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;  
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;  
	return (isReachable && !needsConnection) ? YES : NO;  
}  

- (void)dealloc
{
    [newsTitle release];
    [newsDate release];
    [newsAuthor release];
    [newsDetail release];
    [newsDetailText release];
    [newsImageURL release];
    [newsImage release];
    [newsLargeImageURL release];
    [newsLargeImage release];
    [newsWebView release];
    
    [contentImage release];
    [newsConnection release];
    [newsData release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Load text & image Method

- (void)loadImages {
    if ([self.newsImageURL isEqualToString:@""]) {
        self.contentImage = [NSString stringWithString:@""];
        [self loadMGTemplate];
    }
    else {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSURL *imageURL = [NSURL URLWithString:self.newsImageURL];
        UIImage *cachedImage = [manager imageWithURL:imageURL];
        NSURL *largeImageURL = [NSURL URLWithString:self.newsLargeImageURL];
        UIImage *cachedLargeImage = [manager imageWithURL:largeImageURL];
        
        if (!cachedImage) {
            [manager downloadWithURL:imageURL delegate:self];
            NSLog(@"Image From Interner");
        } else {
            self.count++;
            NSLog(@"Image From Cache");
        }
        NSString *fullpath = [[SDImageCache sharedImageCache] cachePathForKey:[[NSURL URLWithString:self.newsImageURL] absoluteString]];
        NSArray *items = [fullpath componentsSeparatedByString:@"/"];
        NSString *latestItem = [items objectAtIndex:[items count]-1];
        self.newsImage = [NSString stringWithFormat:@"../Library/Caches/ImageCache/%@", latestItem];
        
        if (!cachedLargeImage) {
            [manager downloadWithURL:largeImageURL delegate:self];
            NSLog(@"LargeImage From Interner");
        }
        else {
            self.count++;
            NSLog(@"LargeImage From Cache");
        }
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            if ([[UIScreen mainScreen] scale] == 2) {
                // Use high resolution images
                self.contentImage = [NSString stringWithFormat:@"<a href=\"javascript:clickLink()\"><img class=\"photo\" src=\"%@\"/></a><img class=\"plus\" src=\"contentview_plus@2x.png\"/>", self.newsImage];
            } else {
                self.contentImage = [NSString stringWithFormat:@"<a href=\"javascript:clickLink()\"><img class=\"photo\" src=\"%@\"/></a><img class=\"plus\" src=\"contentview_plus.png\"/>", self.newsImage];
            }
        }
        
        if (self.count == 2) {
            [self loadMGTemplate];
        }
    }
}

- (void)loadText {
    SDWebDataManager *manager = [SDWebDataManager sharedManager];
    NSURL *textURL = [NSURL URLWithString:self.newsDetail];
    NSData *text = [manager dataWithURL:textURL];
    if (!text) {
        if ([self isNetworkReachable]) {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.delegate = self;
            [HUD show:YES];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [manager downloadWithURL:textURL delegate:self];
        } else {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error_load.png"]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView;            
            HUD.delegate = self;
            HUD.labelText = @"没有缓存";            
            [HUD show:YES];
            [HUD hide:YES afterDelay:1];
        }
    } else {
        //NSLog(@"Text From Cache");
        self.newsDetailText = [[NSString alloc]initWithData:text encoding:NSUTF8StringEncoding];
        [self loadImages]; 
    }
}

- (void)loadMGTemplate{
    // Set up template engine with your chosen matcher.
    MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
    [engine setDelegate:self];
    [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    
    // Get path to template.
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"content_template" ofType:@"html"];
    NSDictionary *variables = [NSDictionary dictionaryWithObjectsAndKeys: 
    						   [NSString stringWithString:self.newsTitle], @"title", 
    						   [NSString stringWithString:self.newsDate], @"ptime", 
                               [NSString stringWithString:self.newsAuthor], @"author",
                               [NSString stringWithString:self.contentImage], @"content_image",
                               [NSString stringWithString:self.newsDetailText], @"body",
    						   nil];
    // Process the template and display the results.
    NSString *result = [engine processTemplateInFileAtPath:templatePath withVariables:variables];
    [HUD hide:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.newsWebView loadHTMLString:result baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleLargeImageTap:)];
    [self.imageZoomView addGestureRecognizer:recognizer];
    [recognizer release];
    self.imageZoomView.hidden = YES;
    self.count = 0;
    [self loadText];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.newsWebView = nil;
    self.view = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
    //self.newsWebView = nil;
    //self.view = nil;
}

- (void)handleLargeImageTap:(UITapGestureRecognizer *)recognizer {
    
    self.imageZoomView.hidden = YES;
}

- (void)zoomImage {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSURL *largeImageURL = [NSURL URLWithString:self.newsLargeImageURL];
    UIImage *cachedLargeImage = [manager imageWithURL:largeImageURL];
    
    if (!cachedLargeImage) {
        [manager downloadWithURL:largeImageURL delegate:self];
    }
    else {
        self.imageZoomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        self.imageZoom.image = cachedLargeImage;
        
        self.imageZoom.alpha = 0.f;
        self.imageZoom.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        self.imageZoomView.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.imageZoom.alpha = 1.f;
            self.imageZoom.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    if ([requestString isEqualToString:@"hit:image:zoom"]) {
        [self zoomImage];
        return NO;
    }
	return YES;
}

#pragma mark - MGTemplateEngine Method

// ****************************************************************
// 
// Methods below are all optional MGTemplateEngineDelegate methods.
// 
// ****************************************************************

- (void)templateEngine:(MGTemplateEngine *)engine blockStarted:(NSDictionary *)blockInfo
{
	//NSLog(@"Started block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngine:(MGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo
{
	//NSLog(@"Ended block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngineFinishedProcessingTemplate:(MGTemplateEngine *)engine
{
	//NSLog(@"Finished processing template.");
}


- (void)templateEngine:(MGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing;
{
	NSLog(@"Template error: %@", error);
}

#pragma mark - SDWebImage Method

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    self.count++;
    if (self.count == 2) {
        [self loadMGTemplate];
    }
}

- (void)webDataManager:(SDWebDataManager *)dataManager didFinishWithData:(NSData *)aData isCache:(BOOL)isCache 
{
    self.newsDetailText = [[NSString alloc]initWithData:aData encoding:NSUTF8StringEncoding];
    [self loadImages];
}

#pragma mark MBPregressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}
@end
