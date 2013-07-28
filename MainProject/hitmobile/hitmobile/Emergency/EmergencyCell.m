//
//  EmergencyCell.m
//  iHIT
//
//  Created by Bai Yalong on 11-3-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EmergencyCell.h"

@implementation EmergencyCell

@synthesize icon, englishDescription, chineseDescription, telephoneNumber;

//- (void)setUseDarkBackground:(BOOL)flag
//{
//    if (flag != useDarkBackground || !self.backgroundView)
//    {
//        useDarkBackground = flag;
//		
//        NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:useDarkBackground ? @"DarkBackground" : @"LightBackground" ofType:@"png"];
//        UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
//        self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
//        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.backgroundView.frame = self.bounds;
//    }
//}

- (void)dealloc
{
    [icon release];
    [englishDescription release];
    [chineseDescription release];
    [telephoneNumber release];
    
    [super dealloc];
}

@end
