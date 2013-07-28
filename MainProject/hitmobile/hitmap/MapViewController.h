//
//  MasterViewController.h
//  hitmap
//
//  Created by 鑫容 郭 on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSMapView.h"
#import "FDCurlViewControl.h"
#import "MapSettingsView.h"
#import "HITPlaceAnotation.h"

typedef enum {
    LocatingStatus_standBy,
    LocatingStatus_locating
}LocatingStatus;

@interface MapViewController : UIViewController <GSMapViewDelegate, MapSettingsViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>{
    GSMapView *_mapScrollView;
    
    MapSettingsView *_settingsView;  
    
    // add activityindicator to button
    UISegmentedControl *_locateBarButtonInnerButton;
    UIImage *_blankImage;
    UIActivityIndicatorView *_activityIndicator;
    
    NSMutableArray *_campus1Places;
    NSMutableArray *_campus2Places;
    NSArray *_currentCampusPlaces;
    
    int _currentDisplayLevel;
    
    FDCurlViewControl *_curlViewControl;
    BOOL _viewCurlUp;
    
    BOOL _showAnnotations;
    HITCampus _currentCampus;
    
    LocatingStatus _currentLocatingStatus;
    
    HITPlaceAnotation *_annotaionShouldStay;
    
    // Search
    UISearchBar *_searchBar;
    UITableView *_placesTableView;
    NSMutableArray *_searchAnnotationResults;
}


@end
