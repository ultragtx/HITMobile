//
//  MapSettingsView.h
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-15.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HITCAMPUS1,
    HITCAMPUS2
}HITCampus;

@protocol MapSettingsViewDelegate;

@interface MapSettingsView : UIView {
    HITCampus _currentCampus;
    id<MapSettingsViewDelegate> __unsafe_unretained _delegate;
    
    BOOL _showAnnotaions;
    BOOL _removeUserLocation;
    
}

@property (nonatomic, assign) HITCampus currentCampus;
@property (nonatomic, unsafe_unretained) id<MapSettingsViewDelegate> delegate;
@property (nonatomic, assign) BOOL showAnnotations;
@property (nonatomic, assign) BOOL removeUserLocation;

@end

@protocol MapSettingsViewDelegate

- (void)shouldCurlViewDown;
- (void)shouldRemoveUserLocation;
- (void)shouldShowAnnotatoins:(BOOL)show;
- (void)shouldChangeToCampus:(HITCampus)campus;

@end
