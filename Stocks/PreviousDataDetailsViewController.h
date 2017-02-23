//
//  PreviousDataDetailsViewController.h
//  Stocks
//
//  Created by Nagam Pawan on 10/27/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface PreviousDataDetailsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate, NSURLSessionDataDelegate>{
    
    Reachability *reachability;
    
}

@property (strong, nonatomic) NSString *urlStringnew;
@property (strong, nonatomic) UIDatePicker *startDatePicker;
@property (strong, nonatomic) UIDatePicker *endDatePicker;

@property (strong, nonatomic) NSMutableArray *stockSymbol;
@property (strong, nonatomic) NSMutableArray *dateArray;
@property (strong, nonatomic) NSMutableArray *dateArray2;
@property (strong, nonatomic) id date;
@property (strong, nonatomic) NSMutableArray *openValueArray;
@property (strong, nonatomic) NSMutableArray *openValueArray2;
@property (strong, nonatomic) id openValue;
@property (strong, nonatomic) NSMutableArray *highValueArray;
@property (strong, nonatomic) NSMutableArray *highValueArray2;
@property (strong, nonatomic) id highValue;
@property (strong, nonatomic) NSMutableArray *lowValueArray;
@property (strong, nonatomic) NSMutableArray *lowValueArray2;
@property (strong, nonatomic) id lowValue;
@property (strong, nonatomic) NSMutableArray *closingValueArray;
@property (strong, nonatomic) NSMutableArray *closingValueArray2;
@property (strong, nonatomic) id closingValue;
@property (strong, nonatomic) NSMutableArray *adjClosingValueArray;
@property (strong, nonatomic) NSMutableArray *adjClosingValueArray2;
@property (strong, nonatomic) id adjClosingValue;
@property (strong, nonatomic) NSMutableArray *volumeArray;
@property (strong, nonatomic) NSMutableArray *volumeArray2;
@property (strong, nonatomic) id volume2;
@property (strong, nonatomic) NSMutableString *dataString;


@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITextField *startDateTextField;
@property (strong, nonatomic) IBOutlet UITextField *endDateTextField;

- (IBAction)go:(id)sender;
- (IBAction)tapGesture:(id)sender;

@end
