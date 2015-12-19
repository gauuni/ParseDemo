//
//  StudentCell.h
//  ParseDemo
//
//  Created by Nguyen Khoi Nguyen on 12/18/15.
//  Copyright © 2015 Nguyen Khoi Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
@interface StudentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet PFImageView *imageView_Avatar;

@property (nonatomic, weak) IBOutlet UILabel *label_Name;
@property (nonatomic, weak) IBOutlet UILabel *label_Email;
@property (nonatomic, weak) IBOutlet UILabel *label_Phone;
@property (nonatomic, weak) IBOutlet UILabel *label_Address;

@end
