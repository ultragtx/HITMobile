//
//  HITPlaceAnotation.h
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-8.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSAnnotation.h"

typedef enum {
    HITPLACE_CANTEEN,
    HITPLACE_STUDYING,
    HITPLACE_PARKING
}HITPlaceType;

@interface HITPlaceAnotation : NSObject <GSAnnotation> {
    
    CGPoint _coordinate;
}

@property (nonatomic, assign) CGPoint coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) int displayLevel;
@property (nonatomic, assign) HITPlaceType type;

@end
