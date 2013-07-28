//
//  EmergencyCell.h
//  iHIT
//
//  Created by Bai Yalong on 11-3-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EmergencyCell : UITableViewCell
{
//    BOOL useDarkBackground;
	
    UIImage *icon;
    NSString *englishDescription;
    NSString *chineseDescription;
    NSString *telephoneNumber;
}

//@property BOOL useDarkBackground;

@property(retain) UIImage *icon;
@property(retain) NSString *englishDescription;
@property(retain) NSString *chineseDescription;
@property(retain) NSString *telephoneNumber;

@end

