//
//  Common.h
//  ParseDemo
//
//  Created by Nguyen Khoi Nguyen on 12/19/15.
//  Copyright © 2015 Nguyen Khoi Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Common : NSObject

+(UIImage*)compressImage:(UIImage*)image;

+(UIImage*)scaleImage: (UIImage*) sourceImage;

+ (NSString *)uuidString;

@end
