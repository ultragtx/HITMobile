//
//  SearchMapView.m
//  iHIT
//
//  Created by Bai Yalong on 11-3-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchMapView.h"


@implementation SearchMapView

@synthesize selectedPlace, HITmap, flag;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	CGPoint Offset;
	//Display the selected country.
	//lblText.text = selectedCountry;
	
	NSString *bundlePathofPlist = [[NSBundle mainBundle]pathForResource:@"newLocation.plist" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
	NSArray *locate1FromPlist = [dict valueForKey:@"Region1place"];
	NSInteger index = [locate1FromPlist indexOfObject:selectedPlace];
	if(index != NSNotFound){
		NSArray *CoorX1FromPlist = [dict valueForKey:@"Region1CoordinatesX"];
		CoorX = [[CoorX1FromPlist objectAtIndex:index] intValue];
		NSArray *CoorY1FromPlist = [dict valueForKey:@"Region1CoordinatesY"];
		CoorY = [[CoorY1FromPlist objectAtIndex:index] intValue];
//		NSArray *Description1FromPlist = [dict valueForKey:@"Region1description"];
//		Description.text = [Description1FromPlist objectAtIndex:index];
		
		[self setHITmap:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HIT_MAP_2_OUT.jpg"]]];
		[MapView setContentSize:CGSizeMake(HITmap.frame.size.width, HITmap.frame.size.height)];
		NSLog(@"setContentSize:%f %f", HITmap.frame.size.width, HITmap.frame.size.height);
		MapView.maximumZoomScale = MaxZoom1;
		MapView.minimumZoomScale = MinZoom1;
		MapView.clipsToBounds = YES;
		[MapView setScrollEnabled:YES];
		MapView.delegate = self;
		Offset.x = CoorX - HalfscreenWidth;
		Offset.y = CoorY - HalfScreenHeight;
		[self SetOffsetOfHITMap:Offset];
		[MapView addSubview:HITmap];
		MapWidth = Location1MapWidth;
		MapHeight = Location1MapHeight;
		

		CGRect frame = CGRectMake(CoorX - FlagWidth / 2, CoorY - FlagHeight, FlagWidth, FlagHeight);
		flag = [[UIImageView alloc] initWithFrame:frame];
		flag.image = [UIImage imageNamed:@"Flagcon.png"];
		[MapView addSubview:flag];
	}
	else{
		NSArray *locate2FromPlist = [dict valueForKey:@"Region2place"];
		index = [locate2FromPlist indexOfObject:selectedPlace];
		NSArray *CoorX2FromPlist = [dict valueForKey:@"Region2CoordinatesX"];
		CoorX = [[CoorX2FromPlist objectAtIndex:index] intValue];
		NSArray *CoorY2FromPlist = [dict valueForKey:@"Region2CoordinatesY"];
		CoorY = [[CoorY2FromPlist objectAtIndex:index] intValue];
		
		[self setHITmap:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HIT_MAP_1_OUT.jpg"]]];
		[MapView setContentSize:CGSizeMake(HITmap.frame.size.width, HITmap.frame.size.height)];
		NSLog(@"setContentSize:%f %f", HITmap.frame.size.width, HITmap.frame.size.height);
		MapView.maximumZoomScale = MaxZoom2;
		MapView.minimumZoomScale = MinZoom2;
		MapView.clipsToBounds = YES;
		[MapView setScrollEnabled:YES];
		MapView.delegate = self;
		Offset.x = CoorX - HalfscreenWidth;
		Offset.y = CoorY - HalfScreenHeight;
		NSLog(@"%f %f",MapView.frame.size.width,MapView.frame.size.height);
		NSLog(@"%f, %f", Offset.x, Offset.y);
		[self SetOffsetOfHITMap:Offset];
		[MapView addSubview:HITmap];
		MapHeight = Location2MapHeight;
		MapWidth  = Location2MapWidth;
		
		CGRect frame = CGRectMake(CoorX - FlagWidth / 2, CoorY - FlagHeight, FlagWidth, FlagHeight);
		flag = [[UIImageView alloc] initWithFrame:frame];
		flag.image = [UIImage imageNamed:@"Flagcon.png"];
		[MapView addSubview:flag];
		
	}
	//Set the title of the navigation bar
	self.navigationItem.title = selectedPlace;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
	[flag removeFromSuperview];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
	
	NSLog(@"%f ----- %f", MapView.frame.size.width, MapView.frame.size.height);
	float x = HITmap.frame.size.width * CoorX / MapWidth - FlagWidth / 2;
	float y = HITmap.frame.size.height * CoorY / MapHeight - FlagHeight;
	CGRect frame = CGRectMake(x,y, FlagWidth, FlagHeight);
	flag = [[UIImageView alloc] initWithFrame:frame];
	flag.image = [UIImage imageNamed:@"Flagcon.png"];
	[MapView addSubview:flag];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return HITmap;
}

- (IBAction)SetOffsetOfHITMap:(CGPoint) input
{
	MapView.contentOffset=input;
}
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}



- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

//- (void)didReceiveMemoryWarning {
//    // Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//    
//    // Release any cached data, images, etc. that aren't in use.
//}
//
//- (void)viewDidUnload {
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}
//
//
//- (void)dealloc {
//    [super dealloc];
//}
//
//
//@end
