//
//  UIImage+Thumb.h
//  luoshixinxun
//
//  Created by  on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(Thumb)
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
-(UIImage*)scaleToSize:(CGSize)size;  
@end
