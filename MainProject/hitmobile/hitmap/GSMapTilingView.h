//
//  TilingView.h
//  hitmobile
//
//  Created by 鑫容 郭 on 11-12-21.
//  Copyright (c) 2011年 HIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSMapTilingView : UIView {
    NSString *imageName;
}

- (id)initWithImageName:(NSString *)name size:(CGSize)size;
- (UIImage *)tileForScale:(CGFloat)scale row:(int)row col:(int)col;

@end
