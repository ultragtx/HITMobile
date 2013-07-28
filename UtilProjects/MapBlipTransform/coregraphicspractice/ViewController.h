//
//  ViewController.h
//  coregraphicspractice
//
//  Created by 鑫容 郭 on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomView.h"

@interface ViewController : UIViewController {
    BOOL shouldMoveCustomView;
}

@property (nonatomic, retain) IBOutlet CustomView *customView;
@property (nonatomic, retain) IBOutlet UISlider *xslider;
@property (nonatomic, retain) IBOutlet UISlider *yslider;
@property (nonatomic, retain) IBOutlet UISlider *zslider;
@property (nonatomic, retain) IBOutlet UILabel *xlabel;
@property (nonatomic, retain) IBOutlet UILabel *ylabel;
@property (nonatomic, retain) IBOutlet UILabel *zlabel;

@property (nonatomic, retain) IBOutlet UISlider *angleslider;
@property (nonatomic, retain) IBOutlet UILabel *anglelabel;

@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (IBAction)sliderChanged:(id)sender;


@end
