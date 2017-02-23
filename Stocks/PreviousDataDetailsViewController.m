//
//  PreviousDataDetailsViewController.m
//  Stocks
//
//  Created by Nagam Pawan on 10/27/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import "PreviousDataDetailsViewController.h"
#import "DetailsTableViewCell.h"

@interface PreviousDataDetailsViewController ()

@end

@implementation PreviousDataDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        
        self.view.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:blurEffectView atIndex:0];
        
    }
    
    else{
        
        self.view.backgroundColor = [UIColor grayColor];
        
    }

    
    self.automaticallyAdjustsScrollViewInsets = false;
    self.navigationItem.title = @"History";
    
    self.dateArray = [[NSMutableArray alloc]init];
    self.dateArray2 = [[NSMutableArray alloc]initWithCapacity:1000];
    self.openValueArray = [[NSMutableArray alloc]init];
    self.openValueArray2 = [[NSMutableArray alloc]initWithCapacity:1000];
    self.highValueArray = [[NSMutableArray alloc]init];
    self.highValueArray2 = [[NSMutableArray alloc]initWithCapacity:1000];
    self.lowValueArray = [[NSMutableArray alloc]init];
    self.lowValueArray2 = [[NSMutableArray alloc]initWithCapacity:1000];
    self.closingValueArray = [[NSMutableArray alloc]init];
    self.closingValueArray2 = [[NSMutableArray alloc]initWithCapacity:1000];
    self.adjClosingValueArray = [[NSMutableArray alloc]init];
    self.adjClosingValueArray2 = [[NSMutableArray alloc]initWithCapacity:1000];
    self.volumeArray = [[NSMutableArray alloc]init];
    self.volumeArray2 = [[NSMutableArray alloc]initWithCapacity:1000];
    self.dataString = [[NSMutableString alloc]init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if (remoteHostStatus == NotReachable) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network not found" message:@"Please connect to the internet" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    else{
        
#pragma mark - DatePicker
    
    NSDate *date = [[NSDate alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    self.endDateTextField.text = dateString;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc]init];
    components.day = -1;
    NSDate *previousDate = [calendar dateByAddingComponents:components toDate:date options:0];
    NSString *previousDateString = [dateFormatter stringFromDate:previousDate];
    self.startDateTextField.text = previousDateString;
    
    NSString *DateUrlString = [self.urlStringnew stringByReplacingOccurrencesOfString:@"%A" withString:self.startDateTextField.text];
    NSString *finalUrlString = [DateUrlString stringByReplacingOccurrencesOfString:@"%B" withString:self.endDateTextField.text];
    [self getSession:finalUrlString];
    
    self.startDatePicker = [[UIDatePicker alloc]init];
    self.startDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.startDatePicker addTarget:self action:@selector(startDateValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.startDateTextField.inputView = self.startDatePicker;
    
    self.endDatePicker = [[UIDatePicker alloc]init];
    self.endDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.endDatePicker addTarget:self action:@selector(endDateValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.endDateTextField.inputView = self.endDatePicker;
        
    }
    
}

-(void)handleNetworkChange: (NSNotification *)notice{
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if (remoteHostStatus == NotReachable) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error in Loading..." message:@"Network not found" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startDateValueChanged:(id)sender{
    
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSDate *dateSelected = [datePicker date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    self.startDateTextField.text = [dateFormat stringFromDate:dateSelected];
    
}

-(void)endDateValueChanged:(id)sender{
    
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSDate *dateSelected = [datePicker date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    self.endDateTextField.text = [dateFormat stringFromDate:dateSelected];
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)parseData: (NSDictionary *)json{
    
    NSDictionary *quoteDictionary = [[[json valueForKey:@"query"] valueForKey:@"results"] valueForKey:@"quote"];

    if (quoteDictionary != nil) {
        
        if ([[quoteDictionary valueForKey:@"Date"] isKindOfClass:[NSArray class]]) {
            
            self.dateArray = [[quoteDictionary valueForKey:@"Date"] mutableCopy];
            NSOrderedSet *dateSet = [NSOrderedSet orderedSetWithArray:self.dateArray];
            NSArray *dateArray1 = [dateSet array];
            self.dateArray2 = [NSMutableArray arrayWithArray:dateArray1];
            
        }
        
        else{
            
            [self.dateArray addObject:[quoteDictionary valueForKey:@"Date"]];
            NSOrderedSet *dateSet = [NSOrderedSet orderedSetWithArray:self.dateArray];
            NSArray *dateArray1 = [dateSet array];
            self.dateArray2 = [NSMutableArray arrayWithArray:dateArray1];
            
        }
        
        if ([[quoteDictionary valueForKey:@"Open"] isKindOfClass:[NSArray class]]) {
            
            self.openValueArray = [[quoteDictionary valueForKey:@"Open"] mutableCopy];
            NSOrderedSet *openValeSet = [NSOrderedSet orderedSetWithArray:self.openValueArray];
            NSArray *openValueArray1 = [openValeSet array];
            self.openValueArray2 = [NSMutableArray arrayWithArray:openValueArray1];
            
        }
        
        else{
            
            [self.openValueArray addObject:[quoteDictionary valueForKey:@"Open"]];
            NSOrderedSet *openValeSet = [NSOrderedSet orderedSetWithArray:self.openValueArray];
            NSArray *openValueArray1 = [openValeSet array];
            self.openValueArray2 = [NSMutableArray arrayWithArray:openValueArray1];
            
        }
        
        if ([[quoteDictionary valueForKey:@"High"] isKindOfClass:[NSArray class]]) {
            
            self.highValueArray = [[quoteDictionary valueForKey:@"High"] mutableCopy];
            NSOrderedSet *highValueSet = [NSOrderedSet orderedSetWithArray:self.highValueArray];
            NSArray *highValueArray1 = [highValueSet array];
            self.highValueArray2 = [NSMutableArray arrayWithArray:highValueArray1];
            
        }
        
        else{
            
            [self.highValueArray addObject:[quoteDictionary valueForKey:@"High"]];
            NSOrderedSet *highValueSet = [NSOrderedSet orderedSetWithArray:self.highValueArray];
            NSArray *highValueArray1 = [highValueSet array];
            self.highValueArray2 = [NSMutableArray arrayWithArray:highValueArray1];
            
        }
        
        if ([[quoteDictionary valueForKey:@"Low"] isKindOfClass:[NSArray class]]) {
            
            self.lowValueArray = [[quoteDictionary valueForKey:@"Low"] mutableCopy];
            NSOrderedSet *lowValueSet = [NSOrderedSet orderedSetWithArray:self.lowValueArray];
            NSArray *lowValueArray1 = [lowValueSet array];
            self.lowValueArray2 = [NSMutableArray arrayWithArray:lowValueArray1];
            
        }
        
        else{
            
            [self.lowValueArray addObject:[quoteDictionary valueForKey:@"Low"]];
            NSOrderedSet *lowValueSet = [NSOrderedSet orderedSetWithArray:self.lowValueArray];
            NSArray *lowValueArray1 = [lowValueSet array];
            self.lowValueArray2 = [NSMutableArray arrayWithArray:lowValueArray1];
            
        }
        
        if ([[quoteDictionary valueForKey:@"Close"] isKindOfClass:[NSArray class]]) {
            
            self.closingValueArray = [[quoteDictionary valueForKey:@"Close"] mutableCopy];
            NSOrderedSet *closingValueSet = [NSOrderedSet orderedSetWithArray:self.closingValueArray];
            NSArray *closingValueArray1 = [closingValueSet array];
            self.closingValueArray2 = [NSMutableArray arrayWithArray:closingValueArray1];
            
        }
        
        else{
            
            [self.closingValueArray addObject:[quoteDictionary valueForKey:@"Close"]];
            NSOrderedSet *closingValueSet = [NSOrderedSet orderedSetWithArray:self.closingValueArray];
            NSArray *closingValueArray1 = [closingValueSet array];
            self.closingValueArray2 = [NSMutableArray arrayWithArray:closingValueArray1];
            
        }
        
        if ([[quoteDictionary valueForKey:@"Adj_Close"] isKindOfClass:[NSArray class]]) {
            
            self.adjClosingValueArray = [[quoteDictionary valueForKey:@"Adj_Close"] mutableCopy];
            NSOrderedSet *adjClosingValueSet = [NSOrderedSet orderedSetWithArray:self.adjClosingValueArray];
            NSArray *adjClosingValueArray1 = [adjClosingValueSet array];
            self.adjClosingValueArray2 = [NSMutableArray arrayWithArray:adjClosingValueArray1];
            
        }
        
        else{
            
            [self.adjClosingValueArray addObject:[quoteDictionary valueForKey:@"Adj_Close"]];
            NSOrderedSet *adjClosingValueSet = [NSOrderedSet orderedSetWithArray:self.adjClosingValueArray];
            NSArray *adjClosingValueArray1 = [adjClosingValueSet array];
            self.adjClosingValueArray2 = [NSMutableArray arrayWithArray:adjClosingValueArray1];
            
        }
        
        
        if ([[quoteDictionary valueForKey:@"Volume"] isKindOfClass:[NSArray class]]) {
            
            self.volumeArray = [[quoteDictionary valueForKey:@"Volume"] mutableCopy];
            NSOrderedSet *volumeSet = [NSOrderedSet orderedSetWithArray:self.volumeArray];
            NSArray *volumeArray1 = [volumeSet array];
            self.volumeArray2 = [NSMutableArray arrayWithArray:volumeArray1];
            
        }
        
        else{
            
            [self.volumeArray addObject:[quoteDictionary valueForKey:@"Volume"]];
            NSOrderedSet *volumeSet = [NSOrderedSet orderedSetWithArray:self.volumeArray];
            NSArray *volumeArray1 = [volumeSet array];
            self.volumeArray2 = [NSMutableArray arrayWithArray:volumeArray1];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.myTableView reloadData];
            
        });
        
    }
    
    else{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error in loading" message:@"Please select previous startDate and EndDate" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    }

}

-(void)getSession: (NSString *)jsonUrl{
    
    [UIApplication sharedApplication]. networkActivityIndicatorVisible = YES;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:jsonUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            
            [UIApplication sharedApplication]. networkActivityIndicatorVisible = NO;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            [self parseData:json];
            
        }
        
        else{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error in loading" message:@"Please select previous startDate and EndDate" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }];
    
    [dataTask resume];
    
}

#pragma mark - TableView delegate and datasource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([self.dateArray2 isKindOfClass:[NSNull class]]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error in loading" message:@"Please select previous startDate and EndDate" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
        
    else{
        
       return self.dateArray2.count;
    }
    
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DetailsTableViewCell *cell = [self.myTableView dequeueReusableCellWithIdentifier:@"cell2"];
    NSNumberFormatter *numberFormatt = [[NSNumberFormatter alloc]init];
    [numberFormatt setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatt setMaximumFractionDigits:2];
    [numberFormatt setRoundingMode:NSNumberFormatterRoundUp];
    
    if ([self.dateArray2 count] > 0 && [self.dateArray2 count] > indexPath.row) {

    self.date = [self.dateArray2 objectAtIndex:indexPath.row];
        
    }
    
    if ([self.openValueArray2 count] > 0 && [self.openValueArray2 count] > indexPath.row){
        
    self.openValue = [self.openValueArray2 objectAtIndex:indexPath.row];
        
    }
    
    if ([self.highValueArray2 count] > 0 && [self.highValueArray2 count] > indexPath.row){
        
    self.highValue = [self.highValueArray2 objectAtIndex:indexPath.row];
        
    }
    
    if ([self.lowValueArray2 count] > 0 && [self.lowValueArray2 count] > indexPath.row){
        
    self.lowValue = [self.lowValueArray2 objectAtIndex:indexPath.row];
        
    }
    
    if ([self.closingValueArray2 count] > 0 && [self.closingValueArray2 count] > indexPath.row){
        
    self.closingValue = [self.closingValueArray2 objectAtIndex:indexPath.row];
        
    }
    
    if ([self.adjClosingValueArray2 count] > 0 && [self.adjClosingValueArray2 count] > indexPath.row) {
        
        self.adjClosingValue = [self.adjClosingValueArray2 objectAtIndex:indexPath.row];
        
    }
    
    if ([self.volumeArray2 count] > 0 && [self.volumeArray2 count] > indexPath.row){
        
    self.volume2 = [self.volumeArray2 objectAtIndex:indexPath.row];
    
    }
    
    if ([self.date isKindOfClass:[NSNull class]]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Data not found" message:@"Please select previousDate" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        cell.dateLabel.text = @"--";
            
        });
        
    }
    
    else{
    
        cell.dateLabel.text = [NSString stringWithFormat:@"%@", [self.dateArray objectAtIndex:indexPath.row]];

    }
    
    if ([self.openValue isKindOfClass:[NSNull class]]) {
        
        cell.openValueLabel.text = @"--";
        
    }
    
    else{
        
        float open = [self.openValue floatValue];
        cell.openValueLabel.text = [NSString stringWithFormat:@"%@",[numberFormatt stringFromNumber:[NSNumber numberWithFloat:open]]];
        
    }
    
    
    if ([self.highValue isKindOfClass:[NSNull class]]) {
        
        cell.highValueLabel.text = @"--";
        
    }
    
    else{
        
        float high = [self.highValue floatValue];
         cell.highValueLabel.text = [NSString stringWithFormat:@"%@", [numberFormatt stringFromNumber:[NSNumber numberWithFloat:high]]];
        
    }
    
    if ([self.lowValue isKindOfClass:[NSNull class]]) {
        
        cell.lowValueLabel.text = @"--";
        
    }
    
    else{
        
        float low = [self.lowValue floatValue];
        cell.lowValueLabel.text = [NSString stringWithFormat:@"%@", [numberFormatt stringFromNumber:[NSNumber numberWithFloat:low]]];

    }
    
    if ([self.closingValue isKindOfClass:[NSNull class]]) {
        
        cell.closingValueLabel.text = @"--";
        
    }
    
    else{
        
         float close = [self.closingValue floatValue];
         cell.closingValueLabel.text = [NSString stringWithFormat:@"%@", [numberFormatt stringFromNumber:[NSNumber numberWithFloat:close]]];
        
    }
    
    if ([self.adjClosingValue isKindOfClass:[NSNull class]]) {
        
        cell.adjCloseLabel.text = @"--";
        
    }
    
    else{
        
        float adjClose = [self.adjClosingValue floatValue];
        cell.adjCloseLabel.text = [NSString stringWithFormat:@"%@", [numberFormatt stringFromNumber:[NSNumber numberWithFloat:adjClose]]];
        
    }
    
    if ([self.volume2 isKindOfClass:[NSNull class]]) {
        
        cell.volumeLabel.text = @"--";
        
    }
    
    else{
        
        float volume = [self.volume2 intValue];
        
        id volume1 = [numberFormatt stringFromNumber:[NSNumber numberWithFloat:volume/1000000]];
        cell.volumeLabel.text = [NSString stringWithFormat:@"%@M", volume1];
        
    }
    
    return cell;
    
}

#pragma mark - cell separatorInset

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if ([self.myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.myTableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.myTableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

- (IBAction)go:(id)sender {
    
    BOOL missingFields = false;
    
    if (self.startDateTextField.text.length == 0) {
        missingFields = true;
    }
    else if (self.endDateTextField.text.length == 0){
        missingFields = true;
    }
    else{
        missingFields = false;
    }
    
    if (missingFields ==true) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TextFields are Empty" message:@"Please select the date first" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else{
        
    NSString *DateUrlString = [self.urlStringnew stringByReplacingOccurrencesOfString:@"%A" withString:self.startDateTextField.text];
    NSString *finalUrlString = [DateUrlString stringByReplacingOccurrencesOfString:@"%B" withString:self.endDateTextField.text];
     [self getSession:finalUrlString];
        [self.startDatePicker removeFromSuperview];
        [self.endDatePicker removeFromSuperview];
        [self.startDateTextField endEditing:YES];
        [self.endDateTextField endEditing:YES];
        
    }

}

- (IBAction)tapGesture:(id)sender {
    
    [self.startDatePicker removeFromSuperview];
    [self.endDatePicker removeFromSuperview];
    
}

#pragma mark - Textfield Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    textField.text = self.startDateTextField.text;
    textField.text = self.endDateTextField.text;
    textField.text = nil;
}

@end
