//
//  StudentCell.m
//  ParseDemo
//
//  Created by Nguyen Khoi Nguyen on 12/18/15.
//  Copyright © 2015 Nguyen Khoi Nguyen. All rights reserved.
//

#import "StudentCell.h"

@implementation StudentCell

- (void)awakeFromNib {
    // Initialization code
    self.imageView_Avatar.layer.cornerRadius = self.imageView_Avatar.frame.size.height/2;
    self.imageView_Avatar.clipsToBounds = YES;
    self.imageView_Avatar.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
