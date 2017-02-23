//
//  ModelStock.h
//  Stocks
//
//  Created by Nagam Pawan on 11/25/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelStock : NSObject

@property (strong, nonatomic) NSString *stockNameString;
@property (strong, nonatomic) NSString *lastTradePriceString;
@property (strong, nonatomic) NSString *changeInPercentageString;
@property (strong, nonatomic) NSString *titleNameString;
@property (strong, nonatomic) NSString *openValueString;
@property (strong, nonatomic) NSString *highValueString;
@property (strong, nonatomic) NSString *lowValueString;
@property (strong, nonatomic) NSString *volumeString;
@property (strong, nonatomic) NSString *peRatioString;
@property (strong, nonatomic) NSString *mktCapString;
@property (strong, nonatomic) NSString *yearHighString;
@property (strong, nonatomic) NSString *yearLowString;
@property (strong, nonatomic) NSString *avgVolumeString;
@property (strong, nonatomic) NSString *yieldString;
@property (strong, nonatomic) NSMutableArray *defaultArray;

- (instancetype)initWithDict:(NSDictionary*)quoteDictionary;

@end
