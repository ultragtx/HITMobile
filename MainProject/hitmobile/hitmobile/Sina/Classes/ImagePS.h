//
//  ImagePS.h
//  iHIT
//
//  Created by Hiro on 11-6-20.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImagePS : NSObject { 

}

+ (UIImage *) createRoundedRectImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *) changeImageSize:(UIImage *)image size:(CGSize)size;

@end
