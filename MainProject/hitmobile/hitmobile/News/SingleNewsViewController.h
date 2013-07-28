//
//  SingleNewsViewController2.h
//  iHITNews
//
//  Created by keywind on 11-9-18.
//  Copyright 2011年 Hit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTemplateEngine.h"
#import "MBProgressHUD.h"
#import "SDWebImageManager.h"
#import "SDWebDataManager.h"

@interface SingleNewsViewController : UIViewController <MGTemplateEngineDelegate, MBProgressHUDDelegate, SDWebImageManagerDelegate, SDWebDataManagerDelegate> {
    NSString *newsTitle;
    NSString *newsDate;
    NSString *newsAuthor;
    NSString *newsDetail;
    NSString *newsDetailText;
    NSString *newsImageURL;
    NSString *newsImage;
    NSString *newsLargeImageURL;
    NSString *newsLargeImage;
    UIWebView *newsWebView;
    
    NSString *contentImage;
    NSURLConnection *newsConnection;
    NSMutableData *newsData;
    
    NSInteger count;
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) NSString *newsTitle;
@property (nonatomic, retain) NSString *newsDate;
@property (nonatomic, retain) NSString *newsAuthor;
@property (nonatomic, retain) NSString *newsDetail;
@property (nonatomic, retain) NSString *newsDetailText;
@property (nonatomic, retain) NSString *newsImageURL;
@property (nonatomic, retain) NSString *newsImage;
@property (nonatomic, retain) NSString *newsLargeImageURL;
@property (nonatomic, retain) NSString *newsLargeImage;
@property (nonatomic, retain) NSString *contentImage;
@property (nonatomic, retain) IBOutlet UIWebView *newsWebView;
@property (nonatomic, retain) IBOutlet UIImageView *imageZoom;
@property (nonatomic, retain) IBOutlet UIView *imageZoomView;

@property (nonatomic, retain) NSURLConnection *newsConnection;
@property (nonatomic, retain) NSMutableData *newsData;

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, retain) MBProgressHUD *HUD;

- (void) loadMGTemplate;

@end
