//
//  TiledScrollView.h
//  HIT_MAP
//
//  Created by Hiro on 11-5-28.
//  Copyright 2011 FoOTOo. All rights reserved.
//

@class TapDetectingView;

typedef enum {
	PINTYPE_PIN,
	PINTYPE_LOCATE
} pinType;

@protocol TiledScrollViewDataSource;

@interface TiledScrollView : UIScrollView <UIScrollViewDelegate> {
    id <TiledScrollViewDataSource>  dataSource;
    CGSize                          tileSize;
    TapDetectingView                *tileContainerView;
    NSMutableSet                    *reusableTiles;    
	
    int                              resolution;
    int                              maximumResolution;
    int                              minimumResolution;
    
    // we use the following ivars to keep track of which rows and columns are visible
    int firstVisibleRow, firstVisibleColumn, lastVisibleRow, lastVisibleColumn;
	
	// marks for pin
	BOOL needPin;
	int pinXOnOriginalMap;
	int pinYOnOriginalMap;
	int originalX;
	int originalY;
	pinType currentPinType;
}

@property (nonatomic, assign) id <TiledScrollViewDataSource> dataSource;
@property (nonatomic, assign) CGSize tileSize;
@property (nonatomic, readonly) TapDetectingView *tileContainerView;
@property (nonatomic, assign) int minimumResolution;
@property (nonatomic, assign) int maximumResolution;

@property (nonatomic, assign) BOOL needPin;
@property (nonatomic, assign) int pinXOnOriginalMap;
@property (nonatomic, assign) int pinYOnOriginalMap;
@property (nonatomic, assign) int originalX;
@property (nonatomic, assign) int originalY;


- (UIView *)dequeueReusableTile;  // Used by the delegate to acquire an already allocated tile, in lieu of allocating a new one.
- (void)reloadData;
- (void)reloadDataWithNewContentSize:(CGSize)size;
- (void)showPinAtPointX:(int)XOnOriginalMap Y:(int)YOnOriginalMap PinType:(pinType)currentPinType SholdMoveTo:(BOOL)shouldMove;
- (void)removePinTemporary:(BOOL)temporarily;
- (void)showLocationAtLatitude:(double)latitude lontitude:(double)longtitude originalLatitude:(double)oriLatitude originalLongtitude:(double)oriLongtitude AtCampus:(int)currentCampus SholdMoveTo:(BOOL)shouldMove;
@end


@protocol TiledScrollViewDataSource <NSObject>

- (UIView *)tiledScrollView:(TiledScrollView *)scrollView tileForRow:(int)row column:(int)column resolution:(int)resolution;
- (UIImage *)imageWithRow:(int)row column:(int)column resolution:(int)resolution;
//- (void)outOfCampus;
@end


