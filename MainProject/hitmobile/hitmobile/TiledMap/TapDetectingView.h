//
//  TapDetectingView.h
//  HIT_MAP
//
//  Created by Hiro on 11-5-28.
//  Copyright 2011 FoOTOo. All rights reserved.
//

@protocol TapDetectingViewDelegate;


@interface TapDetectingView : UIView {
	
    id <TapDetectingViewDelegate> delegate;
    
    // Touch detection
    CGPoint tapLocation;         // Needed to record location of single tap, which will only be registered after delayed perform.
    BOOL multipleTouches;        // YES if a touch event contains more than one touch; reset when all fingers are lifted.
    BOOL twoFingerTapIsPossible; // Set to NO when 2-finger tap can be ruled out (e.g. 3rd finger down, fingers touch down too far apart, etc).
}

@property (nonatomic, assign) id <TapDetectingViewDelegate> delegate;

@end



@protocol TapDetectingViewDelegate <NSObject>

@optional
- (void)tapDetectingView:(TapDetectingView *)view gotSingleTapAtPoint:(CGPoint)tapPoint;
- (void)tapDetectingView:(TapDetectingView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint;
- (void)tapDetectingView:(TapDetectingView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint;

@end