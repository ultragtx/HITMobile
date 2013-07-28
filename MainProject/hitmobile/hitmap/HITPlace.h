//
//  HITPlace.h
//  hitmobile
//
//  Created by 鑫容 郭 on 12-1-19.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HITPLACE_CANTEEN,
    HITPLACE_STUDYING,
    HITPLACE_PARKING
}HITPlaceType;

@interface HITPlace : NSObject {
    float _coordinateX;
    float _coordinateY;
    
    NSString *_name;
    NSString *_detail;
    
    // high displayLevel places will not show when zoomScale is low
    int _displayLevel;
    
    // 
    HITPlaceType _type;
    
}

@property (nonatomic, assign) float coordinateX;
@property (nonatomic, assign) float coordinateY;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, assign) int displayLevel;
@property (nonatomic, assign) HITPlaceType type;

@end
