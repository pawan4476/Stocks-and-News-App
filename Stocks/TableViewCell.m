//
//  TableViewCell.m
//  Stocks
//
//  Created by Nagam Pawan on 10/24/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

-(void)prepareForReuse
{
    
}

- (void)awakeFromNib {
    
    self.changeInPercentLabel.clipsToBounds = YES;
    self.changeInPercentLabel.layer.cornerRadius = 10;
    
    [self.stockSymbolImage.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.stockSymbolImage.layer setBorderWidth:0.5];
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
