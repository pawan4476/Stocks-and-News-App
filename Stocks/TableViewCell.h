//
//  TableViewCell.h
//  Stocks
//
//  Created by Nagam Pawan on 10/24/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *stockNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastTradePriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *changeInPercentLabel;
@property (strong, nonatomic) IBOutlet UILabel *stockCompanyNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stockSymbolImage;

@end
