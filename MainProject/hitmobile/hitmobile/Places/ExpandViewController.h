
#import <Foundation/Foundation.h>
#import "SectionHeaderView.h"

@class QuoteCell;

@interface ExpandViewController : UITableViewController <SectionHeaderViewDelegate> {
}

@property (nonatomic, retain) NSArray* plays;
@property (nonatomic, retain) NSString* placeName;
@end

