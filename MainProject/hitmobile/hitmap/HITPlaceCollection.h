//
//  HITPlaceCollection.h
//  hitmobile
//
//  Created by 鑫容 郭 on 12-1-19.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HITPlaceCollection : NSObject {
    NSArray *_places;
    
    
}

- (id)initWithArrayOfX:(NSArray *)arrayOfX 
              arrayOfY:(NSArray *)arrayOfY 
           arrayOfName:(NSArray *)arrayOfName 
         arrayOfDetail:(NSArray *)arrayOfDetail 
   arrayOfDisplayLevel:(NSArray *)arrayOfDisplayLevel 
           arrayOfType:(NSArray *)arrayOfType;

- (NSArray *)placesBetweenMinX:(float)minX MinY:(float)minY MaxX:(float)maxX MaxY:(float)maxY;

@end
