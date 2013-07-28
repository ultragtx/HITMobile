
#import "Play.h"


@implementation Play

@synthesize name, quotations;

- (void)dealloc {
    [name release];
    [quotations release];
    [super dealloc];
}

@end
