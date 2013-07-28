//
//  GSAnnotation.h
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-3.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// IMPORTANT: Make Sure not impletation a method named -(NSComparisonResult)compare:(id)obj;
//

@protocol GSAnnotation <NSObject>

@property (nonatomic, assign) CGPoint coordinate;

@optional

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@end