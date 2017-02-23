//
//  ModelStock.m
//  Stocks
//
//  Created by Nagam Pawan on 11/25/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import "ModelStock.h"

@implementation ModelStock

- (instancetype)initWithDict:(NSDictionary*)quoteDictionary {
    self = [super init];
    if (self) {
        self.stockNameString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"Symbol"]];
        self.lastTradePriceString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"LastTradePriceOnly"]];
        self.changeInPercentageString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"ChangeinPercent"]];
        self.changeInPercentageString = [self.changeInPercentageString stringByReplacingOccurrencesOfString:@"%" withString:@""];
        self.titleNameString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"Name"]];
        self.openValueString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"Open"]];
        self.highValueString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"DaysHigh"]];
        self.lowValueString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"DaysLow"]];
        self.volumeString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"Volume"]];
        self.peRatioString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"PERatio"]];
        self.mktCapString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"MarketCapitalization"]];
        self.yearHighString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"YearHigh"]];
        self.yearLowString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"YearLow"]];
        self.avgVolumeString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"AverageDailyVolume"]];
        self.yieldString = [NSString stringWithFormat:@"%@", [quoteDictionary valueForKey:@"DividendYield"]];
        self.defaultArray = [[NSMutableArray alloc]initWithObjects:self.stockNameString, self.lastTradePriceString, self.changeInPercentageString, nil];
    }
    
    return self;
}

-(NSString *)description {

    return [NSString stringWithFormat:@"stockName string is :%@\nlastTradePrice is :%@\nchangeInPercentage is :%@\ntitleName is :%@ Defaults Array is :%@", self.stockNameString, self.lastTradePriceString, self.changeInPercentageString, self.titleNameString, self.defaultArray];
    
  }

@end
