//
//  CollectionViewCell.m
//  Stocks
//
//  Created by Nagam Pawan on 11/12/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell
-(void)awakeFromNib{
    [super awakeFromNib];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 10;
}



@end
