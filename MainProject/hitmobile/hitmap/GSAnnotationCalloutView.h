//
//  CallOutView.h
//  hitmobile
//
//  Created by 鑫容 郭 on 12-1-22.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSAnnotationCalloutContentView;
@class GSAnnotationView;

@interface GSAnnotationCalloutView : UIView {
    GSAnnotationView *__unsafe_unretained _parenAnnotationView;
    
    @private
    GSAnnotationCalloutContentView *_contentView;
    CGFloat _middleLeftWidth;
    CGFloat _middleRightWidth;
    
    CGSize _contentSize;
    CGFloat _calloutWidth;
}

@property (nonatomic, unsafe_unretained) GSAnnotationView *parenAnnotationView;

- (id)initWithParentAnnotationView:(GSAnnotationView *)parenAnnotationView;

@end
