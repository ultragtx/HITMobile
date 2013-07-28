//
//  GSAnnotationCalloutContentView.h
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-9.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSAnnotationCalloutContentView : UIView {
    UIView *_leftCalloutAccessoryView;
    UIView *_rightCalloutAccessoryView;
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    NSString *_title;
    NSString *_subtitle;
    
    @private
    CGSize _titleLabelSize;
    CGSize _subtitleLabelSize;
    CGFloat _maxLabelWidth;
    CGSize _contentSize;
}

@property (nonatomic, strong) UIView *leftCalloutAccessoryView;
@property (nonatomic, strong) UIView *rightCalloutAccessoryView;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *subtitleLabel;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

- (id)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle leftCalloutAccessoryView:(UIView *)leftCalloutAccessoryView rightCalloutAccessoryView:(UIView *)rightCalloutAccessoryView;

- (CGSize)calculateContentSize;

@end
