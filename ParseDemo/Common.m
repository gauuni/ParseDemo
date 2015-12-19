//
//  Common.m
//  ParseDemo
//
//  Created by Nguyen Khoi Nguyen on 12/19/15.
//  Copyright © 2015 Nguyen Khoi Nguyen. All rights reserved.
//

#import "Common.h"

@implementation Common
+ (UIImage*)compressImage:(UIImage*)image
{
    CGSize newSize = CGSizeMake(200, 200);
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+(UIImage*)scaleImage: (UIImage*) sourceImage
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = 200 / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(NSString *)uuidString {
    // Returns a UUID
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}
@end
