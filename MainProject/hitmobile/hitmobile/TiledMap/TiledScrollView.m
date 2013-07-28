//
//  TiledScrollView.m
//  HIT_MAP
//
//  Created by Hiro on 11-5-28.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TiledScrollView.h"
#import "TapDetectingView.h"
#import <CoreLocation/CoreLocation.h>
#import "TiledMapViewController.h"
#define DEFAULT_TILE_SIZE 100

#define ANNOTATE_TILES YES

@interface TiledScrollView ()
- (void)annotateTile:(UIView *)tile;
- (void)updateResolution;
- (void)showPin;
@end

@implementation TiledScrollView
@synthesize tileSize;
@synthesize tileContainerView;
@synthesize dataSource;
@dynamic minimumResolution;
@dynamic maximumResolution;
@synthesize needPin;
@synthesize pinXOnOriginalMap;
@synthesize pinYOnOriginalMap;
@synthesize originalX;
@synthesize originalY; 

- (id)initWithFrame:(CGRect)frame {
	//NSLog(@"initWithFrame");
    if (self = [super initWithFrame:frame]) {
        
        // we will recycle tiles by removing them from the view and storing them here
        reusableTiles = [[NSMutableSet alloc] init];
        
        // we need a tile container view to hold all the tiles. This is the view that is returned
        // in the -viewForZoomingInScrollView: delegate method, and it also detects taps.
        tileContainerView = [[TapDetectingView alloc] initWithFrame:CGRectZero];
        [tileContainerView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:tileContainerView];
        [self setTileSize:CGSizeMake(DEFAULT_TILE_SIZE, DEFAULT_TILE_SIZE)];
		
        // no rows or columns are visible at first; note this by making the firsts very high and the lasts very low
        firstVisibleRow = firstVisibleColumn = NSIntegerMax;
        lastVisibleRow  = lastVisibleColumn  = NSIntegerMin;
		
        // the TiledScrollView is its own UIScrollViewDelegate, so we can handle our own zooming.
        // We need to return our tileContainerView as the view for zooming, and we also need to receive
        // the scrollViewDidEndZooming: delegate callback so we can update our resolution.
        [super setDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [reusableTiles release];
    [tileContainerView release];
    [super dealloc];
}

// we don't synthesize our minimum/maximum resolution accessor methods because we want to police the values of these ivars
- (int)minimumResolution { return minimumResolution; }
- (int)maximumResolution { return maximumResolution; }
- (void)setMinimumResolution:(int)res { minimumResolution = MIN(res, 0); } // you can't have a minimum resolution greater than 0
- (void)setMaximumResolution:(int)res { maximumResolution = MAX(res, 0); } // you can't have a maximum resolution less than 0

- (UIView *)dequeueReusableTile {
	//NSLog(@"dequeueReusableTile");
    UIView *tile = [reusableTiles anyObject];
    if (tile) {
        // the only object retaining the tile is our reusableTiles set, so we have to retain/autorelease it
        // before returning it so that it's not immediately deallocated when we remove it from the set
        [[tile retain] autorelease];
        [reusableTiles removeObject:tile];
    }
    return tile;
}

- (void)reloadData {
	//NSLog(@"reloadData");
    // recycle all tiles so that every tile will be replaced in the next layoutSubviews
    for (UIView *view in [tileContainerView subviews]) {
        [reusableTiles addObject:view];
        [view removeFromSuperview];
    }
    
    // no rows or columns are now visible; note this by making the firsts very high and the lasts very low
    firstVisibleRow = firstVisibleColumn = NSIntegerMax;
    lastVisibleRow  = lastVisibleColumn  = NSIntegerMin;
    
    [self setNeedsLayout];
}

- (void)reloadDataWithNewContentSize:(CGSize)size {
	//NSLog(@"reloadDataWithNewContentSize");
    // since we may have changed resolutions, which changes our maximum and minimum zoom scales, we need to 
    // reset all those values. After calling this method, the caller should change the maximum/minimum zoom scales
    // if it wishes to permit zooming.
    
    [self setZoomScale:1.0];
    [self setMinimumZoomScale:1.0];
    [self setMaximumZoomScale:1.0];
    resolution = 0;
    
    // now that we've reset our zoom scale and resolution, we can safely set our contentSize. 
    [self setContentSize:size];
    
    // we also need to change the frame of the tileContainerView so its size matches the contentSize
    [tileContainerView setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    [self reloadData];
}

#pragma mark -
#pragma mark image in thread tile in main thread

- (void)loadUIImageInNewThread:(NSMutableArray *)array {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSNumber *rowObject = [array objectAtIndex:0];
	NSNumber *colObject = [array objectAtIndex:1];
	NSNumber *resolutionObject = [array objectAtIndex:2];
	int row = [rowObject intValue];
	int col = [colObject intValue];
	int currentResolution = [resolutionObject intValue];
	UIImage *tileImage = [dataSource imageWithRow:row column:col resolution:currentResolution];
	[array addObject:tileImage];
	[self performSelectorOnMainThread:@selector(createAndAddTileToView:) withObject:array waitUntilDone:YES];
	[pool release];
}

- (void)createAndAddTileToView:(NSMutableArray *)array {
	NSNumber *rowObject = [array objectAtIndex:0];
	NSNumber *colObject = [array objectAtIndex:1];
	//NSNumber *resolutionObject = [array objectAtIndex:2];
	int row = [rowObject intValue];
	int col = [colObject intValue];
	//int currentResolution = [resolutionObject intValue];
	UIImage *tileImage = [array objectAtIndex:3];
	
	UIImageView *tile = (UIImageView *)[self dequeueReusableTile];
	if (!tile) {
		tile = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
		[tile setContentMode:UIViewContentModeTopLeft];
	}
	if (!tileImage) {
		NSLog(@"tileImage not Found");
	}
	[tile setImage:tileImage];
	CGRect frame = CGRectMake([self tileSize].width * col, [self tileSize].height * row, [self tileSize].width, [self tileSize].height);
	[tile setFrame:frame];
	[tileContainerView addSubview:tile];
	//[self annotateTile:tile];
}

/***********************************************************************************/
/* Most of the work of tiling is done in layoutSubviews, which we override here.   */
/* We recycle the tiles that are no longer in the visible bounds of the scrollView */
/* and we add any tiles that should now be present but are missing.                */
/***********************************************************************************/
- (void)layoutSubviews {
	//NSLog(@"layoutSubviews");
    [super layoutSubviews];
    
    CGRect visibleBounds = [self bounds];
	
    // first recycle all tiles that are no longer visible
    for (UIView *tile in [tileContainerView subviews]) {
        
        // We want to see if the tiles intersect our (i.e. the scrollView's) bounds, so we need to convert their
        // frames to our own coordinate system
        CGRect scaledTileFrame = [tileContainerView convertRect:[tile frame] toView:self];
		
        // If the tile doesn't intersect, it's not visible, so we can recycle it
        if (! CGRectIntersectsRect(scaledTileFrame, visibleBounds)) {
			/*NSLog(@"[%f][%f][%f][%f][%f][%f][%f][%f]", CGRectGetMinX(visibleBounds), CGRectGetMinY(visibleBounds),
				  CGRectGetMaxX(visibleBounds), CGRectGetMaxY(visibleBounds), CGRectGetMinX(scaledTileFrame),
				  CGRectGetMinY(scaledTileFrame), CGRectGetMaxX(scaledTileFrame), CGRectGetMaxY(scaledTileFrame));*/
			if (CGRectGetMaxX(visibleBounds) == CGRectGetMinX(scaledTileFrame) ||
				CGRectGetMaxY(visibleBounds) == CGRectGetMinY(scaledTileFrame) ||
				CGRectGetMaxX(scaledTileFrame) == CGRectGetMinX(visibleBounds) ||
				CGRectGetMaxY(scaledTileFrame) == CGRectGetMinY(visibleBounds)) {
				// don't remove till
			}
			else {
				[reusableTiles addObject:tile];
				//NSLog(@"tile remove");
				[tile removeFromSuperview];
			}

        }
    }
    
    // calculate which rows and columns are visible by doing a bunch of math.
    float scaledTileWidth  = [self tileSize].width  * [self zoomScale];
    float scaledTileHeight = [self tileSize].height * [self zoomScale];
    int maxRow = floorf([tileContainerView frame].size.height / scaledTileHeight); // this is the maximum possible row
    int maxCol = floorf([tileContainerView frame].size.width  / scaledTileWidth);  // and the maximum possible column
    int firstNeededRow = MAX(0, floorf(visibleBounds.origin.y / scaledTileHeight));
    int firstNeededCol = MAX(0, floorf(visibleBounds.origin.x / scaledTileWidth));
    int lastNeededRow  = MIN(maxRow, floorf(CGRectGetMaxY(visibleBounds) / scaledTileHeight));
    int lastNeededCol  = MIN(maxCol, floorf(CGRectGetMaxX(visibleBounds) / scaledTileWidth));
	//NSLog(@"[%d][%d][%d][%d]", firstNeededRow, firstNeededCol, lastNeededRow, lastNeededCol);
    // iterate through needed rows and columns, adding any tiles that are missing
    for (int row = firstNeededRow; row <= lastNeededRow; row++) {
        for (int col = firstNeededCol; col <= lastNeededCol; col++) {
			
            BOOL tileIsMissing = (firstVisibleRow > row || firstVisibleColumn > col || 
                                  lastVisibleRow  < row || lastVisibleColumn  < col);
            //NSLog(@"tile is missing [%@]", tileIsMissing ? @"yes" : @"no");
            if (tileIsMissing) {
				if (NO) {
					// original load image add tile in main thread
					NSLog(@"missing[%d][%d]",row, col);
					UIView *tile = [dataSource tiledScrollView:self tileForRow:row column:col resolution:resolution];
					
					// set the tile's frame so we insert it at the correct position
					CGRect frame = CGRectMake([self tileSize].width * col, [self tileSize].height * row, [self tileSize].width, [self tileSize].height);
					[tile setFrame:frame];
					[tileContainerView addSubview:tile];
					
					// annotateTile draws green lines and tile numbers on the tiles for illustration purposes. 
					[self annotateTile:tile];
				}
				
				if (YES) {
					// load image in child thread but create and add tile vie in maim thread
					NSNumber *rowObject = [[NSNumber alloc] initWithInt:row];
					NSNumber *colObject = [[NSNumber alloc] initWithInt:col];
					NSNumber *resolutionObject = [[NSNumber alloc] initWithInt:resolution];
					NSMutableArray *array = [NSMutableArray arrayWithObjects:rowObject, colObject, resolutionObject, nil];
					[rowObject release];
					[colObject release];
					[resolutionObject release];
					//[NSThread detachNewThreadSelector:@selector(loadUIImageInNewThread:) toTarget:self withObject:array];	
                    
                    // TEST GCD HERE
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *tileImage = [dataSource imageWithRow:row column:col resolution:resolution];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImageView *tile = (UIImageView *)[self dequeueReusableTile];
                            if (!tile) {
                                tile = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
                                [tile setContentMode:UIViewContentModeTopLeft];
                            }
                            if (!tileImage) {
                                NSLog(@"tileImage not Found");
                            }
                            [tile setImage:tileImage];
                            CGRect frame = CGRectMake([self tileSize].width * col, [self tileSize].height * row, [self tileSize].width, [self tileSize].height);
                            [tile setFrame:frame];
                            [tileContainerView addSubview:tile];  
                        });
                        
                    });
				}
				
                
            }
        }
    }
    
    // update our record of which rows/cols are visible
    firstVisibleRow = firstNeededRow; firstVisibleColumn = firstNeededCol;
    lastVisibleRow  = lastNeededRow;  lastVisibleColumn  = lastNeededCol;            
}


/*****************************************************************************************/
/* The following method handles changing the resolution of our tiles when our zoomScale  */
/* gets below 50% or above 100%. When we fall below 50%, we lower the resolution 1 step, */
/* and when we get above 100% we raise it 1 step. The resolution is stored as a power of */
/* 2, so -1 represents 50%, and 0 represents 100%, and so on.                            */
/*****************************************************************************************/
- (void)updateResolution {
    //NSLog(@"updateResolution");
    // delta will store the number of steps we should change our resolution by. If we've fallen below
    // a 25% zoom scale, for example, we should lower our resolution by 2 steps so delta will equal -2.
    // (Provided that lowering our resolution 2 steps stays within the limit imposed by minimumResolution.)
    int delta = 0;
    
    // check if we should decrease our resolution
    for (int thisResolution = minimumResolution; thisResolution < resolution; thisResolution++) {
        int thisDelta = thisResolution - resolution;
        // we decrease resolution by 1 step if the zoom scale is <= 0.5 (= 2^-1); by 2 steps if <= 0.25 (= 2^-2), and so on
        float scaleCutoff = pow(2, thisDelta); 
        if ([self zoomScale] <= scaleCutoff) {
            delta = thisDelta;
            break;
        } 
    }
    
    // if we didn't decide to decrease the resolution, see if we should increase it
    if (delta == 0) {
        for (int thisResolution = maximumResolution; thisResolution > resolution; thisResolution--) {
            int thisDelta = thisResolution - resolution;
            // we increase by 1 step if the zoom scale is > 1 (= 2^0); by 2 steps if > 2 (= 2^1), and so on
            float scaleCutoff = pow(2, thisDelta - 1); 
            if ([self zoomScale] > scaleCutoff) {
                delta = thisDelta;
                break;
            } 
        }
    }
    
    if (delta != 0) {
        resolution += delta;
        
        // if we're increasing resolution by 1 step we'll multiply our zoomScale by 0.5; up 2 steps multiply by 0.25, etc
        // if we're decreasing resolution by 1 step we'll multiply our zoomScale by 2.0; down 2 steps by 4.0, etc
        float zoomFactor = pow(2, delta * -1); 
        
        // save content offset, content size, and tileContainer size so we can restore them when we're done
        // (contentSize is not equal to containerSize when the container is smaller than the frame of the scrollView.)
        CGPoint contentOffset = [self contentOffset];   
        CGSize  contentSize   = [self contentSize];
        CGSize  containerSize = [tileContainerView frame].size;
        
        // adjust all zoom values (they double as we cut resolution in half)
        [self setMaximumZoomScale:[self maximumZoomScale] * zoomFactor];
        [self setMinimumZoomScale:[self minimumZoomScale] * zoomFactor];
        [super setZoomScale:[self zoomScale] * zoomFactor];
        
        // restore content offset, content size, and container size
        [self setContentOffset:contentOffset];
        [self setContentSize:contentSize];
        [tileContainerView setFrame:CGRectMake(0, 0, containerSize.width, containerSize.height)];    
        
        // throw out all tiles so they'll reload at the new resolution
        [self reloadData];        
    }        
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	[self removePinTemporary:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return tileContainerView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	//NSLog(@"scrollViewDidEndZooming");
    if (scrollView == self) {
        //NSLog(@"current zoom scale [%f]", [self zoomScale]);
        // the following two lines are a bug workaround that will no longer be needed after OS 3.0.
        //[super setZoomScale:scale+0.01 animated:NO];
        //[super setZoomScale:scale animated:NO];
        
        // after a zoom, check to see if we should change the resolution of our tiles
        [self updateResolution];
    }
	[self showPin];
}

#pragma mark UIScrollView overrides

// the scrollViewDidEndZooming: delegate method is only called after an *animated* zoom. We also need to update our 
// resolution for non-animated zooms. So we also override the new setZoomScale:animated: method on UIScrollView
- (void)setZoomScale:(float)scale animated:(BOOL)animated {
    [super setZoomScale:scale animated:animated];
    
    // the delegate callback will catch the animated case, so just cover the non-animated case
    if (!animated) {
        [self updateResolution];
    }
}

// We override the setDelegate: method because we can't manage resolution changes unless we are our own delegate.
- (void)setDelegate:(id)delegate {
    //NSLog(@"You can't set the delegate of a TiledZoomableScrollView. It is its own delegate.");
}


#pragma mark
#define LABEL_TAG 3

- (void)annotateTile:(UIView *)tile {
    static int totalTiles = 0;
    
    UILabel *label = (UILabel *)[tile viewWithTag:LABEL_TAG];
    if (!label) {  
        totalTiles++;  // if we haven't already added a label to this tile, it's a new tile
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 80, 50)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTag:LABEL_TAG];
        [label setTextColor:[UIColor greenColor]];
        [label setShadowColor:[UIColor blackColor]];
        [label setShadowOffset:CGSizeMake(1.0, 1.0)];
        [label setFont:[UIFont boldSystemFontOfSize:40]];
        [label setText:[NSString stringWithFormat:@"%d", totalTiles]];
        [tile addSubview:label];
        [label release];
        [[tile layer] setBorderWidth:2];
        [[tile layer] setBorderColor:[[UIColor greenColor] CGColor]];
    }
    
    [tile bringSubviewToFront:label];
}


#pragma mark -
#pragma mark Show Location
#define PINIMAGE_TAG 5
#define PINIAMGE_WIDTH 32
#define PINIMAGE_HEIGHT 39
#define LOCATIIONIMAGE_WIDTH 23
#define LOCATIIONIMAGE_HEIGHT 23
#define PINIMAGE_OFFSETX 8
#define PINIMAGE_OFFSETY 35
#define LOCATEIMAGE_OFFSETX 11.5
#define LOCATEIMAGE_OFFSETY 11.5
#define OFFSET1_ORIGINALPOINT_X 800
#define OFFSET1_ORIGINALPOINT_Y 400
#define OFFSET2_ORIGINALPOINT_X 1180
#define OFFSET2_ORIGINALPOINT_Y 388//366


- (void)outOfCampusAlert {
	UIAlertView *outOfCampusAlert = [[UIAlertView alloc] initWithTitle:@"定位"//@"ごめんなさい!" 
															   message:@"您所在的位置超出了当前地图的显示范围，您可尝试切换校区并重新定位。"
															  delegate:self
													 cancelButtonTitle:@"确认"
													 otherButtonTitles:nil];
	[outOfCampusAlert show];
	[outOfCampusAlert release];
}

- (void)showPin {
	if (needPin) {
		[self showPinAtPointX:self.pinXOnOriginalMap Y:self.pinYOnOriginalMap PinType:currentPinType SholdMoveTo:NO];
	}
}

- (void)showPinAtPointX:(int)XOnOriginalMap Y:(int)YOnOriginalMap PinType:(pinType)CurrentPinType SholdMoveTo:(BOOL)shouldMove{
	[self removePinTemporary:NO];
	self.needPin = YES;
	self.pinXOnOriginalMap = XOnOriginalMap;
	self.pinYOnOriginalMap = YOnOriginalMap;
	//NSLog(@"xonmap[%d] yonmap[%d]", pinXOnOriginalMap, pinYOnOriginalMap);
	
	float scaleOfOrignalSize = self.zoomScale * pow(2.0, resolution);
	float originalScaleOfPinX = (float)pinXOnOriginalMap / (float)originalX;
	float originalScaleOfPinY = (float)pinYOnOriginalMap / (float)originalY;
	float pinXOnCurrentMap = originalScaleOfPinX * (scaleOfOrignalSize * originalX);
	float pinYOnCurrentMap = originalScaleOfPinY * (scaleOfOrignalSize * originalY);
	
	
	
	//NSLog(@"lots [%f][%f][%f][%d][%d]", scaleOfOrignalSize, originalScaleOfPinX, originalScaleOfPinY,
	//	  pinXOnCurrentMap, pinYOnCurrentMap);
	
	UIImageView *pinView;
	
	switch (CurrentPinType) {
		case PINTYPE_LOCATE:
			pinXOnCurrentMap = pinXOnCurrentMap - LOCATEIMAGE_OFFSETX;
			pinYOnCurrentMap = pinYOnCurrentMap - LOCATEIMAGE_OFFSETY;
			pinView = [[UIImageView alloc] initWithFrame:CGRectMake(pinXOnCurrentMap, pinYOnCurrentMap, LOCATIIONIMAGE_WIDTH, LOCATIIONIMAGE_HEIGHT)];
			[pinView setImage:[UIImage imageNamed:@"MapBlip.png"]];
			break;
		default:
			pinXOnCurrentMap = pinXOnCurrentMap - PINIMAGE_OFFSETX;
			pinYOnCurrentMap = pinYOnCurrentMap - PINIMAGE_OFFSETY;
			pinView = [[UIImageView alloc] initWithFrame:CGRectMake(pinXOnCurrentMap, pinYOnCurrentMap, PINIAMGE_WIDTH, PINIMAGE_HEIGHT)];
			[pinView setImage:[UIImage imageNamed:@"MapPin.png"]];
			break;
	}
	currentPinType = CurrentPinType;
	
	
	[pinView setTag:PINIMAGE_TAG];
	[self addSubview:pinView];
	[pinView release];
	
	if (shouldMove) {
		int offsetX = MAX(0, pinXOnCurrentMap - self.bounds.size.width / 2);
		int offsetY = MAX(0, pinYOnCurrentMap - self.bounds.size.height / 2);
		if (offsetX + self.bounds.size.width > (scaleOfOrignalSize * originalX)) {
			offsetX = (scaleOfOrignalSize * originalX) - self.bounds.size.width;
		}
		if (offsetY + self.bounds.size.height > (scaleOfOrignalSize * originalY)) {
			offsetY = (scaleOfOrignalSize * originalY) - self.bounds.size.height;
		}
		CGPoint pinPoint = CGPointMake(offsetX, offsetY);
		[self setContentOffset:pinPoint animated:YES];
		
	}
}

- (void)removePinTemporary:(BOOL)temporarily {
	UIImageView *pinView = (UIImageView *)[self viewWithTag:PINIMAGE_TAG];
	[pinView removeFromSuperview];
	if (!temporarily) {
		self.needPin = NO;
	}
}


- (void)showLocationAtLatitude:(double)latitude lontitude:(double)longtitude originalLatitude:(double)oriLatitude originalLongtitude:(double)oriLongtitude AtCampus:(int)currentCampus SholdMoveTo:(BOOL)shouldMove {
	
	// calculate x y on gMap
	CLLocation *location1 = [[CLLocation alloc] initWithLatitude:oriLatitude longitude:oriLongtitude];
	CLLocation *locationX = [[CLLocation alloc] initWithLatitude:oriLatitude longitude:longtitude];
	CLLocation *locationY = [[CLLocation alloc] initWithLatitude:latitude longitude:oriLongtitude];
	double x = [location1 distanceFromLocation:locationX];
	double y = [location1 distanceFromLocation:locationY];
//	NSLog(@"x [%lf] y [%lf]", x, y);
	
	if (x <= 0 || y <= 0) {
		NSLog(@"x y must bigger than 0 so that the location is in the school");
		// NOTTODO: add delegate here to show a dialog that you are not in the school or maybe in ViewController
		return;
	}
	
	// change g to g_rotateas
	double gMapAngle1 = (currentCampus == 1) ? (51.68 / 360.0 * 2 * M_PI) : (10.5 / 360.0 * 2 * M_PI);  // 参数: 角度
	double gMapPointX = x;	//120;//5;//12.5;					  // 数据
	double gMapPointY = y;	//5;//120;//0;						  // 数据

	double tempGAngle = atan(gMapPointY / gMapPointX) - gMapAngle1;
//	NSLog(@"gtA[%lf]", tempGAngle / (2*M_PI) * 360);
	double tempGLength = sqrt(pow(gMapPointX, 2.0) + pow(gMapPointY, 2.0));
//	NSLog(@"gC[%lf]", tempGLength);
	double gMapPointRotateX = tempGLength * cos(tempGAngle);
	double gMapPointRotateY = tempGLength * sin(tempGAngle);
//	NSLog(@"gRX[%lf]", gMapPointRotateX);
//	NSLog(@"gRY[%lf]", gMapPointRotateY);
	
	// change g_rotate to h_rotate
	double hRotateXScaleToGRotateX = (currentCampus == 1) ? 1.545000 : 1.664836009;//878.38 / 550.8;	//1.09; //2.69 / 2.40; // 参数: 比例
	double hRotateYScaleToGRotateY = (currentCampus == 1) ? 1.580000 : 1.780045213;//1090.35 / 675.45;	//1.21; //1.90 / 1.23; // 参数: 比例
	double hMapPointRotateX = gMapPointRotateX * hRotateXScaleToGRotateX; // A
	double hMapPointRotateY = gMapPointRotateY * hRotateYScaleToGRotateY; // B
//	NSLog(@"hRX[%lf]", hMapPointRotateX);
//	NSLog(@"hRY[%lf]", hMapPointRotateY);
	
	// change h_rotate to h
	double hMapAngle1 = 31.8 / 360.0 * 2 * M_PI;	// 参数:角度 campus 1 and 2 are same
	double hMapAngle2 = 60.4 / 360.0 * 2 * M_PI;	// 参数:角度
	
	double hMapAngle0 = M_PI_2 - hMapAngle1 + hMapAngle2;
	BOOL hRotateXYGreaterThanZero = ((hMapPointRotateX * hMapPointRotateY) > 0);
	//int oneOrMinusOne = hRotateXYGreaterThanZero ? -1 : 1;
	double tempHAngleC = hMapAngle0; // angle c
	if (hRotateXYGreaterThanZero) {
		tempHAngleC = M_PI - hMapAngle0;
	}
//	NSLog(@"hCA[%lf]", tempHAngleC / (2*M_PI) * 360);
	double tempHLength = sqrt(pow(hMapPointRotateX, 2.0) + pow(hMapPointRotateY, 2.0) - // C
							  2 * fabs(hMapPointRotateX) * fabs(hMapPointRotateY) * 
							  cos(tempHAngleC));
//	NSLog(@"HC[%lf]", tempHLength);
	double tempHAngleB = acos((pow(hMapPointRotateX, 2.0) + pow(tempHLength, 2.0) - // B
							   pow(hMapPointRotateY, 2.0)) / (2 * fabs(hMapPointRotateX) * fabs(tempHLength)));
//	NSLog(@"0hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	if (hMapPointRotateX > 0 && hMapPointRotateY > 0) {
		tempHAngleB = tempHAngleB;
//		NSLog(@"1hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	else if (hMapPointRotateX > 0 && hMapPointRotateY <= 0) {
		tempHAngleB = 2 * M_PI - tempHAngleB;
//		NSLog(@"2hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	else if (hMapPointRotateX <= 0 && hMapPointRotateY > 0) {
		tempHAngleB = M_PI - tempHAngleB;
//		NSLog(@"3hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	else {
		tempHAngleB = M_PI + tempHAngleB;
//		NSLog(@"4hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	
	
	double tempHAngle = tempHAngleB + hMapAngle1;
	double hMapPointX = tempHLength * cos(tempHAngle);
	double hMapPointY = tempHLength * sin(tempHAngle);
//	NSLog(@"hX[%lf]", hMapPointX);
//	NSLog(@"hY[%lf]", hMapPointY);
	
	int hMapPointXInt = (int)hMapPointX + ((currentCampus == 1) ? OFFSET1_ORIGINALPOINT_X : OFFSET2_ORIGINALPOINT_X);
	int hMapPointYInt = originalY - (int)(hMapPointY+ ((currentCampus == 1) ? OFFSET1_ORIGINALPOINT_Y : OFFSET2_ORIGINALPOINT_Y));
//	NSLog(@"hMapPointXInt[%d]", hMapPointXInt);
//	NSLog(@"hMapPointYInt[%d]", hMapPointYInt);
	if ((hMapPointXInt <= 100) || 
		(hMapPointXInt >= ((currentCampus == 1) ? CAMPUS1_WIDTH : CAMPUS2_WIDTH) - 100) || 
		(hMapPointYInt <= 100) ||
		(hMapPointYInt >= ((currentCampus == 1) ? CAMPUS1_HEIGHT : CAMPUS2_HEIGHT) - 100)) {
		[self outOfCampusAlert];
		return;
	}
	[self showPinAtPointX:hMapPointXInt Y:hMapPointYInt PinType:PINTYPE_LOCATE SholdMoveTo:shouldMove];
}



@end
