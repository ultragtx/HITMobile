//
//  GSAnnotationCalloutContentView.m
//  hitmobile
//
//  Created by 鑫容 郭 on 12-2-9.
//  Copyright (c) 2012年 HIT. All rights reserved.
//

#import "GSAnnotationCalloutContentView.h"


#define HEIGHT 39.0f
#define TITLEHEIGHT 24.0f
#define SPACE_X_BETWEEN 5.0f
#define SUBTITLE_OFFSET_Y 21.0f

#define LEFT_CENTER_X 12.0f
#define TOPLEFT 12.0f
#define TOPRIGHT 5.0f

#define TITLELABEL_FONT_SIZE 16.0f
#define SUBTITLELABEL_FONT_SIZE 13.0f

@implementation GSAnnotationCalloutContentView

@synthesize leftCalloutAccessoryView = _leftCalloutAccessoryView;
@synthesize rightCalloutAccessoryView = _rightCalloutAccessoryView;
@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize title = _title;
@synthesize subtitle = _subtitle;


#pragma mark - Setter Getter

- (void)setRightCalloutAccessoryView:(UIView *)rightCalloutAccessoryView {
    if ([_rightCalloutAccessoryView isEqual:rightCalloutAccessoryView]) {
        return;
    }
    [_rightCalloutAccessoryView removeFromSuperview];
    _rightCalloutAccessoryView = rightCalloutAccessoryView;
    [self addSubview:_rightCalloutAccessoryView];
}

- (void)setLeftCalloutAccessoryView:(UIView *)leftCalloutAccessoryView {
    if ([_leftCalloutAccessoryView isEqual:leftCalloutAccessoryView]) {
        return;
    }
    [_leftCalloutAccessoryView removeFromSuperview];
    _leftCalloutAccessoryView = leftCalloutAccessoryView;
    [self addSubview:_leftCalloutAccessoryView];
}

- (void)setTitle:(NSString *)title {
    if (_title == title) {
        return;
    }
    _title =  title;
    [self setNeedsLayout];
}

- (void)setSubtitle:(NSString *)subtitle {
    if (_subtitle == subtitle) {
        return;
    }
    _subtitle = subtitle;
    [self setNeedsLayout];
}

#pragma mark - init

- (id)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle leftCalloutAccessoryView:(UIView *)leftCalloutAccessoryView rightCalloutAccessoryView:(UIView *)rightCalloutAccessoryView {
    
    CGRect frame = CGRectMake(0, 0, HEIGHT, HEIGHT); // Not CGRectZero to make layoutSubview being called
    self = [super initWithFrame:frame];
    if (self) {
        self.leftCalloutAccessoryView = leftCalloutAccessoryView;
        self.rightCalloutAccessoryView = rightCalloutAccessoryView;
        self.title = title;
        self.subtitle = subTitle;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setShadowColor:[UIColor blackColor]];
        [_titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_subtitleLabel setBackgroundColor:[UIColor clearColor]];
        [_subtitleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_subtitleLabel setTextColor:[UIColor whiteColor]];

        [self addSubview:_titleLabel];
        [self addSubview:_subtitleLabel];
        
        // TEST CODE BELOW
        //[self setBackgroundColor:[UIColor blueColor]];
        
    }
    return self;
}

- (CGSize)calculateContentSize {
    
    _titleLabelSize = [_title sizeWithFont:[UIFont boldSystemFontOfSize:TITLELABEL_FONT_SIZE]];
    _subtitleLabelSize = [_subtitle sizeWithFont:[UIFont systemFontOfSize:SUBTITLELABEL_FONT_SIZE]];
    
    _maxLabelWidth = fmaxf(_titleLabelSize.width, _subtitleLabelSize.width);
    
    CGFloat spacesWidth = ((_leftCalloutAccessoryView == nil) ? 0 : SPACE_X_BETWEEN) + ((_rightCalloutAccessoryView == nil) ? 0 : SPACE_X_BETWEEN);
    
    CGFloat contentWidth = _leftCalloutAccessoryView.frame.size.width + _maxLabelWidth + _rightCalloutAccessoryView.frame.size.width + spacesWidth;
    
    _contentSize = CGSizeMake(contentWidth, HEIGHT);
    
    return _contentSize;
}

- (void)layoutSubviews {
    //NSLog(@"content layoutSubviews");
    [super layoutSubviews];
    
    // GSAnnotationCalloutView will call calculateContentWidth before [self layoutSubviews] to get the content's width so the variables in @private will be precalculated.
    
    [_titleLabel setText:_title];
    [_subtitleLabel setText:_subtitle];
    
    [_leftCalloutAccessoryView setCenter:CGPointMake(_leftCalloutAccessoryView.frame.size.width / 2, HEIGHT / 2)];
    
    CGFloat minXOfTitleLabel = (_leftCalloutAccessoryView == nil) ? 0 : CGRectGetMaxX(_leftCalloutAccessoryView.frame) + SPACE_X_BETWEEN;
    
    if (_title != nil && _subtitle != nil) {
        // Both title and subtitle
        [_titleLabel setFrame:CGRectMake(minXOfTitleLabel, 0, _titleLabelSize.width, _titleLabelSize.height)];
        
        [_subtitleLabel setFrame:CGRectMake(minXOfTitleLabel, SUBTITLE_OFFSET_Y, _subtitleLabelSize.width, _subtitleLabelSize.height)];
    }
    
    else if (_titleLabel.text != nil && _subtitleLabel.text == nil) {
        // Only title
        [_titleLabel setFrame:CGRectMake(minXOfTitleLabel, 0, _titleLabelSize.width, _titleLabelSize.height)];
        [_titleLabel setCenter:CGPointMake(_titleLabel.center.x, HEIGHT / 2)];
    }
    
    else if (_titleLabel.text == nil && _subtitleLabel.text != nil) {
        // Only subtitle; Make it title
        [_subtitleLabel setFrame:CGRectMake(minXOfTitleLabel, 0, _subtitleLabelSize.width, _subtitleLabelSize.height)];
        [_subtitleLabel setCenter:CGPointMake(_subtitleLabel.center.x, HEIGHT / 2)];
    }
    
    else {
        // TODO:WTF if there's no title or subtitle but still wants a callout
    }
    
    CGFloat minXOfRightCallout = fmaxf( CGRectGetMaxX(_titleLabel.frame),  CGRectGetMaxX(_subtitleLabel.frame));
    minXOfRightCallout = (minXOfRightCallout == 0) ? 0 : minXOfRightCallout + SPACE_X_BETWEEN;
    
    [_rightCalloutAccessoryView setCenter:CGPointMake(minXOfRightCallout + _leftCalloutAccessoryView.frame.size.width / 2, HEIGHT / 2)];
    
    //[self setFrame:CGRectMake(0, 0, fmaxf(minXOfRightCallout, CGRectGetMaxX(_rightCalloutAccessoryView.frame)), HEIGHT)];
    [self setBounds:CGRectMake(0, 0, _contentSize.width, HEIGHT)];
    
    //NSLog(@"contentview frame:%@", NSStringFromCGRect(self.frame));
    //NSLog(@"---------------------");
    
}

@end
