//
//  MapSettingsView.m
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-15.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import "MapSettingsView.h"

#define SEGMENTCONTROL_WIDTH 200.0f
#define SEGMENTCONTROL_HEIGHT 40.0f
#define SEGMENTCONTROL_INSECT_Y 19.0f

@implementation MapSettingsView

static NSString *RemoveAnnotationsTitle = @"移除地点标记";
static NSString *AddAnnotationsTitle = @"添加地点标记";

@synthesize currentCampus = _currentCampus;
@synthesize delegate = _delegate;
@synthesize showAnnotations = _showAnnotaions;
@synthesize removeUserLocation = _removeUserLocation;

- (void)dealloc {
    _delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // default
        _showAnnotaions = YES;
        _removeUserLocation = NO;
        
        // background color
        [self setBackgroundColor:[UIColor underPageBackgroundColor]];
        
        // gesture
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        // UISegmentControl
        UISegmentedControl *campusSwitchSegmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"一校区", @"二校区", nil]];
        [campusSwitchSegmentControl setSegmentedControlStyle:UISegmentedControlStyleBezeled];
        [campusSwitchSegmentControl setTintColor:[UIColor darkGrayColor]];
        //[campusSwitchSegmentControl setAlpha:0.8f];
        [campusSwitchSegmentControl setFrame:CGRectMake(60.0f, self.bounds.size.height - SEGMENTCONTROL_HEIGHT - SEGMENTCONTROL_INSECT_Y, 200.0f, SEGMENTCONTROL_HEIGHT)];
        [campusSwitchSegmentControl setSelectedSegmentIndex:0];
        [campusSwitchSegmentControl addTarget:self action:@selector(campusSwitchSegmentControlValueChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:campusSwitchSegmentControl];
        
        UISegmentedControl *annotationShowSwitch = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:RemoveAnnotationsTitle]];
        [annotationShowSwitch setSegmentedControlStyle:UISegmentedControlStyleBezeled];
        [annotationShowSwitch setMomentary:YES];
        [annotationShowSwitch setTintColor:[UIColor darkGrayColor]];
        //[annotationShowSwitch setAlpha:0.8];
        [annotationShowSwitch setFrame:CGRectMake(60.0f, self.bounds.size.height - SEGMENTCONTROL_HEIGHT * 2 - SEGMENTCONTROL_INSECT_Y * 2, 200.0f, SEGMENTCONTROL_HEIGHT)];
        [annotationShowSwitch addTarget:self action:@selector(annotaionShowSwitchTouchUpInside:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:annotationShowSwitch];
        
        UISegmentedControl *removeLocateButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"移除定位标记"]];
        [removeLocateButton setSegmentedControlStyle:UISegmentedControlStyleBezeled];
        [removeLocateButton setMomentary:YES];
        [removeLocateButton setTintColor:[UIColor darkGrayColor]];
        //[removeLocateButton setAlpha:0.8];
        [removeLocateButton setFrame:CGRectMake(60.0f, self.bounds.size.height - SEGMENTCONTROL_HEIGHT * 3 - SEGMENTCONTROL_INSECT_Y * 3, 200.0f, SEGMENTCONTROL_HEIGHT)];
        [removeLocateButton addTarget:self action:@selector(removeLocateButtonTouchUpInside:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:removeLocateButton];

    }
    return self;
}

#pragma mark - Handle SegmentControl

- (void)campusSwitchSegmentControlValueChange:(UISegmentedControl *)segmentControl {
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
            [_delegate shouldChangeToCampus:HITCAMPUS1];
            break;
        case 1:
            [_delegate shouldChangeToCampus:HITCAMPUS2];
        default:
            break;
    }
}

- (void)annotaionShowSwitchTouchUpInside:(UISegmentedControl *)segmentControl {
    if (_showAnnotaions) {
        _showAnnotaions = NO;
        [segmentControl setTitle:AddAnnotationsTitle forSegmentAtIndex:0];
    }
    else {
        _showAnnotaions = YES;
        [segmentControl setTitle:RemoveAnnotationsTitle forSegmentAtIndex:0];
        
    }
    [_delegate shouldShowAnnotatoins:_showAnnotaions];
}

- (void)removeLocateButtonTouchUpInside:(UISegmentedControl *)segmentControl {
    [_delegate shouldRemoveUserLocation];
}

#pragma mark - Handle Gestures

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [gestureRecognizer locationInView:self];
        if (touchPoint.y <= self.bounds.size.height / 2) {
            [_delegate shouldCurlViewDown];
        }
    }
}

@end
