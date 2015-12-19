//
//  StudentDetailViewController.h
//  ParseDemo
//
//  Created by Nguyen Khoi Nguyen on 12/18/15.
//  Copyright © 2015 Nguyen Khoi Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol StudentDetailViewControllerDelegate <NSObject>

@optional
-(void)didCompleteWithObject: (PFObject *)studentObject;

@end
@interface StudentDetailViewController : UIViewController

@property (nonatomic, strong) PFObject *studentObject;
@property (nonatomic, weak) id<StudentDetailViewControllerDelegate> delegate;
@end
