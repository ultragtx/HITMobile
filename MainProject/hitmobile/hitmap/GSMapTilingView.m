//
//  TilingView.m
//  hitmobile
//
//  Created by 鑫容 郭 on 11-12-21.
//  Copyright (c) 2011年 HIT. All rights reserved.
//

#import "GSMapTilingView.h"
#import <QuartzCore/CATiledLayer.h>
#import "GSAnnotationView.h"

@implementation GSMapTilingView

+ (Class)layerClass {
	return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (id)initWithImageName:(NSString *)name size:(CGSize)size
{
    if ((self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)])) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        imageName = name;
        
        CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
        tiledLayer.levelsOfDetail = 3;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat scale = CGContextGetCTM(context).a;
    CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
    CGSize tileSize = tiledLayer.tileSize;
    
    tileSize.width /= scale;
    tileSize.height /= scale;
    
    // calculate the rows and columns of tiles that intersect the rect we have been asked to draw
    int firstCol = floorf(CGRectGetMinX(rect) / tileSize.width);
    int lastCol = floorf((CGRectGetMaxX(rect)-1) / tileSize.width);
    int firstRow = floorf(CGRectGetMinY(rect) / tileSize.height);
    int lastRow = floorf((CGRectGetMaxY(rect)-1) / tileSize.height);
    
    for (int row = firstRow; row <= lastRow; row++) {
        for (int col = firstCol; col <= lastCol; col++) {
            UIImage *tile = [self tileForScale:scale row:row col:col];
            CGRect tileRect = CGRectMake(tileSize.width * col, tileSize.height * row,
                                         tileSize.width, tileSize.height);
            
            // if the tile would stick outside of our bounds, we need to truncate it so as to avoid
            // stretching out the partial tiles at the right and bottom edges
            tileRect = CGRectIntersection(self.bounds, tileRect);
            
            [tile drawInRect:tileRect];
            
            /*if (self.annotates) {
                [[UIColor whiteColor] set];
                CGContextSetLineWidth(context, 6.0 / scale);
                CGContextStrokeRect(context, tileRect);
            }*/
        }
    }
}

- (UIImage *)tileForScale:(CGFloat)scale row:(int)row col:(int)col {
    NSString *tileName = [NSString stringWithFormat:@"%@_%d_%d_%d", imageName, (int)(scale * 100), row, col];
    NSString *path = [[NSBundle mainBundle] pathForResource:tileName ofType:@"jpg"];
    //NSLog(@"imagePath[%@]", tileName);
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

#pragma mark - Gesture Recognizer

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([[self superview] respondsToSelector:@selector(removeLastCallout)]) {
            [[self superview] performSelector:@selector(removeLastCallout)];
        }
    }
}




@end
