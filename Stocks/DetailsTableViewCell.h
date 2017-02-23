//
//  DetailsTableViewCell.h
//  Stocks
//
//  Created by Nagam Pawan on 10/27/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *openValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *highValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *lowValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *closingValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *volumeLabel;
@property (strong, nonatomic) IBOutlet UILabel *adjCloseLabel;


@end
