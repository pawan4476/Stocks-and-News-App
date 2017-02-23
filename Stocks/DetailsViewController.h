//
//  DetailsViewController.h
//  Stocks
//
//  Created by Nagam Pawan on 10/24/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelStock.h"
#import "Reachability.h"

@interface DetailsViewController : UIViewController<NSURLSessionDownloadDelegate, UICollectionViewDelegate, UICollectionViewDataSource>{
    
    Reachability *reachability;
    
}

@property (strong, nonatomic) NSArray *labelNamesArray;
@property (strong, nonatomic) NSArray *valuesArray;
@property (strong, nonatomic) NSArray *cellColorsArray;

@property (strong, nonatomic) NSString *stockSymbolString;
@property (strong, nonatomic) NSString *openValueString;
@property (strong, nonatomic) NSString *highValueString;
@property (strong, nonatomic) NSString *lowValueString;
@property (strong, nonatomic) NSString *volumeString;
@property (strong, nonatomic) NSString *PERatioString;
@property (strong, nonatomic) NSString *mktCapString;
@property (strong, nonatomic) NSString *yearHighString;
@property (strong, nonatomic) NSString *YearLowString;
@property (strong, nonatomic) NSString *avgVolumeString;
@property (strong, nonatomic) NSString *yieldString;
@property (strong, nonatomic) NSString *titleString;
@property (strong,nonatomic) NSString *stockSymbolUrlString;

@property (strong, nonatomic) NSString *imageString;
@property (strong, nonatomic) NSString *weekImageString;
@property (strong, nonatomic) NSString *monthImageString;
@property (strong, nonatomic) NSString *sixMonthsImageString;
@property (strong, nonatomic) NSString *yearImageString;

@property (strong, nonatomic) IBOutlet UIImageView *graphImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)history:(id)sender;
- (IBAction)refresh:(id)sender;

- (IBAction)weekGraph:(id)sender;
- (IBAction)monthGraph:(id)sender;
- (IBAction)mGraph:(id)sender;
- (IBAction)yearGraph:(id)sender;

@end
