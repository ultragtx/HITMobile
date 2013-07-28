//
//  HITPlaceCollection.m
//  hitmobile
//
//  Created by 鑫容 郭 on 12-1-19.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import "HITPlaceCollection.h"
#import "HITPlace.h"

@implementation HITPlaceCollection

NSInteger sortUsingCoordinateX(HITPlace *place1, HITPlace *place2, void *reverse);


- (id)initWithArrayOfX:(NSArray *)arrayOfX 
              arrayOfY:(NSArray *)arrayOfY 
           arrayOfName:(NSArray *)arrayOfName 
         arrayOfDetail:(NSArray *)arrayOfDetail 
   arrayOfDisplayLevel:(NSArray *)arrayOfDisplayLevel 
           arrayOfType:(NSArray *)arrayOfType {
    
    self = [super init];
    if (self) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[arrayOfX count]];
        for (int i = 0; i < [arrayOfX count]; i++) {
            HITPlace *place = [[HITPlace alloc] init];
            [place setCoordinateX:[(NSNumber *)[arrayOfX objectAtIndex:i] floatValue]];
            [place setCoordinateY:[(NSNumber *)[arrayOfY objectAtIndex:i] floatValue]];
            [place setName:[arrayOfName objectAtIndex:i]];
            if (arrayOfDetail) {
                [place setDetail:[arrayOfDetail objectAtIndex:i]];
            }
            
            [place setDisplayLevel:[(NSNumber *)[arrayOfDisplayLevel objectAtIndex:i] intValue]];
            if (arrayOfType) {
                [place setType:[(NSNumber *)[arrayOfType objectAtIndex:i] intValue]];
            }
            
            [tempArray addObject:place];
        }
        [tempArray sortUsingFunction:sortUsingCoordinateX context:nil];
        
        _places = tempArray;
        
    }
    return self;
}

NSInteger sortUsingCoordinateX(HITPlace *place1, HITPlace *place2, void *reverse) {
    if (place1.coordinateX < place2.coordinateX) {
        return NSOrderedAscending;
    }
    else if (place1.coordinateX > place2.coordinateX) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (int)firstPlaceBetweenMinX:(float)minX MaxX:(float)maxX {
    // Binary search
    int resultIndex = -1;
    
    int startIndex = 0;
    int stopIndex = [_places count] - 1;
    int middleIndex = (startIndex + stopIndex) / 2;
    
    while (startIndex < stopIndex) {
        float middleCoordinateX = [(HITPlace *)[_places objectAtIndex:middleIndex] coordinateX];
        if (middleCoordinateX >= minX) {
            if (middleCoordinateX <= maxX) {
                resultIndex = middleIndex;
            }
            stopIndex = middleIndex - 1;
        }
        else if (middleCoordinateX < minX) {
            startIndex = middleIndex + 1;
        }
        
        middleIndex = (startIndex + stopIndex) / 2;
    }
    return resultIndex;
}

- (NSArray *)placesBetweenMinX:(float)minX MinY:(float)minY MaxX:(float)maxX MaxY:(float)maxY {
    int firstIndex = [self firstPlaceBetweenMinX:minX MaxX:maxX];
    NSMutableArray *places = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (firstIndex < 0) {
        return places;
    }
    else {
        for (int i = firstIndex; i < [_places count]; i++) {
            float currentCoordinateX = [(HITPlace *)[_places objectAtIndex:i] coordinateX];
            float currentCoordinateY = [(HITPlace *)[_places objectAtIndex:i] coordinateY];
            if (currentCoordinateX > maxX) {
                break;
            }
            else if (currentCoordinateY >= minY && currentCoordinateY <= maxY) {
                [places addObject:[_places objectAtIndex:i]];
            }
        }
    }
    return places;
}



@end
