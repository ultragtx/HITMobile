//
//  EmergencyTableViewCell.h
//  iHIT
//
//  Created by Bai Yalong on 11-3-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmergencyCell.h"

@interface EmergencyTableViewCell : EmergencyCell
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *englishDescriptionLabel;
    IBOutlet UILabel *chineseDescriptionLabel;
    IBOutlet UILabel *telephoneNumberLabel;
}

@end
