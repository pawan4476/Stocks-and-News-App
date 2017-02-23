//
//  ViewController.m
//  Stocks
//
//  Created by Nagam Pawan on 10/20/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "SearchViewController.h"
#import "DetailsViewController.h"
#import "ModelStock.h"

@interface ViewController ()<SearchViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.stocksArray = [[NSMutableArray alloc]init];
    self.positiveArray = [[NSMutableArray alloc]init];
    self.negativeArray = [[NSMutableArray alloc]init];
    self.positiveSet= [[NSMutableOrderedSet alloc]init];
    self.negativeSet = [[NSMutableOrderedSet alloc]init];
    
#pragma mark - BackGroundBlurr
    
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
    
    [self setNeedsStatusBarAppearanceUpdate];
    
#pragma mark - Reachability Methods
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if (remoteHostStatus == NotReachable) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network not found" message:@"Please connect to the internet" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"stocks"];
        NSDictionary *jsonDic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self parseData:jsonDic];
        
    }
    else {

        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray* companyNames = [userDefaults arrayForKey:@"CompaniesNames"];
        if (companyNames == nil || companyNames.count == 0) {
            companyNames = [NSArray arrayWithObjects:@"%22YHOO%22", @"%22AAPL%22", @"%22GOOG%22", @"%22MSFT%22", nil];
            [userDefaults setObject:companyNames forKey:@"CompaniesNames"];
            
            [userDefaults synchronize];
        }
        NSString* companyNamesStr = [companyNames componentsJoinedByString:@"%2C"];
        NSString* url = @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%@)%0A%09%09&env=http%3A%2F%2Fdatatables.org%2Falltables.env&format=json";
        url = [url stringByReplacingOccurrencesOfString:@"%@" withString:companyNamesStr];
        [self getsession:url];
        
    }
    
#pragma mark - RefreshController
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView1 addSubview:refresh];
    
}

-(void)refresh:(UIRefreshControl *)refresh{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM d, hh:mm a"];
    NSString *titleString = [NSString stringWithFormat:@"Last Update: %@",[formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDic = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:titleString attributes:attrsDic];
    refresh.attributedTitle = attributedTitle;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"stocks"];
    NSDictionary *jsonDic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self parseData:jsonDic];
    
    [self.tableView1 reloadData];
    [refresh endRefreshing];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
    
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

-(void)alert{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Slow network Connection" message:@"Please try again after some time" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)parseData:(NSDictionary *)jsonAPI{
    
    id quote = [[[jsonAPI valueForKey:@"query"] valueForKey:@"results"] valueForKey:@"quote"];
    
    if (quote != nil) {
        
        if ([quote isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary* dict in quote) {
                ModelStock *stocks = [[ModelStock alloc]initWithDict:dict];
                for (ModelStock *model in self.stocksArray) {
                    if ([model.stockNameString isEqualToString:stocks.stockNameString]) {
                        [self.stocksArray removeObject:model];
                        break;
                    }
                }
                
                [self.stocksArray addObject:stocks];
            }
        } else if ([quote isKindOfClass:[NSDictionary class]]) {
            ModelStock *stocks = [[ModelStock alloc]initWithDict:quote];
            
            for (ModelStock *model in self.stocksArray) {
                if ([model.stockNameString isEqualToString:stocks.stockNameString]) {
                    [self.stocksArray removeObject:model];
                    break;
                }
            }
            
            [self.stocksArray addObject:stocks];
            
        }
        
        [self.positiveSet removeAllObjects];
        [self.negativeSet removeAllObjects];
        for (int i = 0; i < self.stocksArray.count; i++) {
            
            ModelStock *new = [self.stocksArray objectAtIndex:i];
            if ([new.changeInPercentageString hasPrefix:@"+"]) {
                
                [self.positiveSet addObject:new];
                
            }
            else if ([new.changeInPercentageString hasPrefix:@"-"]){
                
                [self.negativeSet addObject:new];
                
            }
        }
        
        self.positiveArray = [_positiveSet mutableCopy];
        self.negativeArray = [_negativeSet mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView1 reloadData];
            
        });
        
    }
    
    else{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error in loading" message:@"Data not found" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}

-(void)getsession: (NSString *)jsonUrl{
    
    [UIApplication sharedApplication]. networkActivityIndicatorVisible = YES;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:jsonUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            
            [UIApplication sharedApplication]. networkActivityIndicatorVisible = NO;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if (json) {
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:json];
                [defaults setObject:data forKey:@"stocks"];
                [defaults synchronize];
                
            }
            
            [self parseData:json];
            
        }
        
        else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error in loading" message:@"Data not found" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }];
    
    [dataTask resume];
    
}

#pragma mark - TableView Delegate and Datasource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        
        return self.positiveArray.count;
        
    }
    
    else  {
        
        return self.negativeArray.count;
        
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TableViewCell *cell = [_tableView1 dequeueReusableCellWithIdentifier:@"cell"];
    NSNumberFormatter *numberFormatt = [[NSNumberFormatter alloc]init];
    [numberFormatt setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatt setMaximumFractionDigits:2];
    [numberFormatt setRoundingMode:NSNumberFormatterRoundUp]; 
    
    if (indexPath.section == 0) {
        
        ModelStock *data = [self.positiveArray objectAtIndex:indexPath.row];
        cell.stockNameLabel.text = data.stockNameString ;
        cell.stockCompanyNameLabel.text = data.titleNameString;
        
        if ([data.lastTradePriceString isEqualToString:@"<null>"]) {
            
            cell.lastTradePriceLabel.text = @"--";
            
        }
        
        else{
            
            cell.lastTradePriceLabel.text = data.lastTradePriceString;
            
        }
        
        if ([data.changeInPercentageString isEqualToString:@"<null>"]) {
            
            cell.changeInPercentLabel.text = @"--";
            cell.changeInPercentLabel.textColor = [UIColor grayColor];
            
        }
        
        else if ([data.changeInPercentageString hasPrefix:@"+"]) {
            
            float changeInPercentage = [data.changeInPercentageString floatValue];
            cell.changeInPercentLabel.text = [NSString stringWithFormat:@"+%@%%↑", [numberFormatt stringFromNumber:[NSNumber numberWithFloat:changeInPercentage]]];
            cell.changeInPercentLabel.textColor = [UIColor greenColor];
            
        }
        
        else {
            
            cell.changeInPercentLabel.text = [NSString stringWithFormat:@"%@%%↓", data.changeInPercentageString];
            cell.changeInPercentLabel.textColor = [UIColor redColor];
            
        }
        
            if ([data.stockNameString isEqualToString:@"YHOO"]) {
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"YHOO.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"AAPL"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"AAPL.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"GOOG"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"GOOG.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"MSFT"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"MSFT.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"SBUX"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"SBUX.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"FB"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"FB.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"AMZN"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"AMZN.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"BRK-A"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"BRK-A.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"XOM"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"XOM.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"JNJ"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"JNJ.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"JPM"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"JPM.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"GE"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"GE.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"WFC"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"WFC.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"TCEHY"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"TCEHY.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"1398.HK"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"1398.HK.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"T"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"T.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"PG"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"PG.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"PEP"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"PEP.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"PGRE"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"PGRE.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"005930.KS"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"005930.KS.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"OHI"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"OHI.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"ORCL"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"ORCL.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"NSANY"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"NSANY.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"^N225"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"^N225.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"NI"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"NI.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"NFG"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"NFG.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"NKE"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"NKE.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"NVDA"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"NVDA.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"NFLX"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"NFLX.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"MA"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"MA.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"JBLU"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"JBLU.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"APA"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"APA.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"F"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"F.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"G"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"G.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"HPQ"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"HPQ.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"INTC"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"INTC.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"WMT"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"WMT.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"^IXIC"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"^IXIC.png"];
        
            }
        
            else if ([data.stockNameString isEqualToString:@"WWE"]){
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"WWE.png"];
        
            }
        
        
            else{
        
                cell.stockSymbolImage.image = [UIImage imageNamed:@"No_Image_Available.png"];
        
            }
        
    }
    
    else{
        
        ModelStock *data = [self.negativeArray objectAtIndex:indexPath.row];
        cell.stockNameLabel.text = [NSString stringWithFormat:@"%@", data.stockNameString];
        cell.stockCompanyNameLabel.text = data.titleNameString;
        
        if ([data.lastTradePriceString isEqualToString:@"<null>"]) {
            
            cell.lastTradePriceLabel.text = @"--";
            
        }
        
        else{
            
            cell.lastTradePriceLabel.text = data.lastTradePriceString;
            
        }
        
        
        if ([data.changeInPercentageString isEqualToString:@"<null>"]) {
            
            cell.changeInPercentLabel.text = @"--";
            cell.changeInPercentLabel.textColor = [UIColor grayColor];
            
        }
        
        else if ([data.changeInPercentageString hasPrefix:@"+"]) {
            
            cell.changeInPercentLabel.text = data.changeInPercentageString;
            cell.changeInPercentLabel.textColor = [UIColor greenColor];
            
        }
        
        else{
            
            float changeInPercentage = [data.changeInPercentageString floatValue];
            cell.changeInPercentLabel.text = [NSString stringWithFormat:@"%@%%↓", [numberFormatt stringFromNumber:[NSNumber numberWithFloat:changeInPercentage]]];
            cell.changeInPercentLabel.textColor = [UIColor redColor];
            
        }
                if ([data.stockNameString isEqualToString:@"YHOO"]) {
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"YHOO.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"AAPL"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"AAPL.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"GOOG"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"GOOG.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"MSFT"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"MSFT.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"SBUX"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"SBUX.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"FB"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"FB.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"AMZN"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"AMZN.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"BRK-A"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"BRK-A.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"XOM"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"XOM.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"JNJ"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"JNJ.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"JPM"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"JPM.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"GE"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"GE.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"WFC"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"WFC.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"TCEHY"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"TCEHY.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"1398.HK"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"1398.HK.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"T"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"T.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"PG"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"PG.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"PEP"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"PEP.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"PGRE"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"PGRE.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"005930.KS"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"005930.KS.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"OHI"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"OHI.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"ORCL"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"ORCL.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"NSANY"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"NSANY.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"^N225"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"^N225.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"NI"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"NI.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"NFG"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"NFG.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"NKE"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"NKE.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"NVDA"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"NVDA.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"NFLX"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"NFLX.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"MA"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"MA.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"JBLU"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"JBLU.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"APA"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"APA.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"F"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"F.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"G"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"G.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"HPQ"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"HPQ.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"INTC"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"INTC.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"WMT"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"WMT.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"^IXIC"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"^IXIC.png"];
        
                }
        
                else if ([data.stockNameString isEqualToString:@"WWE"]){
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"WWE.png"];
        
                }
        
                else{
        
                    cell.stockSymbolImage.image = [UIImage imageNamed:@"No_Image_Available.png"];
        
                }
        
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView1 deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* companyNames = [[userDefaults arrayForKey:@"CompaniesNames"]mutableCopy];
    
    TableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString* company = @"%22%@%22";
    company = [company stringByReplacingOccurrencesOfString:@"%@" withString:cell.stockNameLabel.text];
    [companyNames removeObject:company];
    [userDefaults setObject:companyNames forKey:@"CompaniesNames"];
    [userDefaults synchronize];
    
    if (editingStyle == UITableViewCellEditingStyleDelete && (indexPath.section == 0)) {
        
        [self.positiveArray removeObjectAtIndex:indexPath.row];
        [self.tableView1 deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        
        [self.negativeArray removeObjectAtIndex:indexPath.row];
        [self.tableView1 deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

#pragma mark - cellSeparatorInset

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
    
    if ([self.tableView1 respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView1 setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([self.tableView1 respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView1 setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"add"]) {
        
        SearchViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        
    }
    
    else if ([segue.identifier isEqualToString:@"details1"]) {
        
        NSIndexPath *path = [[self.tableView1 indexPathsForSelectedRows] objectAtIndex:0];
        
        DetailsViewController *vc = [segue destinationViewController];
        
        if (path.section == 0) {
            
            ModelStock *data = [self.positiveArray objectAtIndex:path.row];
            if ([data.titleNameString isEqualToString:@"<null>"]) {
                
                vc.titleString = @"-------";
                
            }
            
            else{
                
                vc.titleString = data.titleNameString;
                
            }
            
            if ([data.openValueString isEqualToString:@"<null>"]) {
                
                vc.openValueString = @"--";
                
            }
            
            else{
                
                vc.openValueString = data.openValueString;
                
            }
            
            if ([data.highValueString isEqualToString:@"<null>"]) {
                
                vc.highValueString = @"--";
                
            }
            
            else{
                
                vc.highValueString = data.highValueString;
                
            }
            
            if ([data.lowValueString isEqualToString:@"<null>"]) {
                
                vc.lowValueString = @"--";
                
            }
            
            else{
                
                vc.lowValueString = data.lowValueString;
                
            }
            
            if ([data.volumeString isEqualToString:@"<null>"]) {
                
                vc.volumeString = @"--";
                
            }
            
            else{
                
                vc.volumeString = data.volumeString;
                
            }
            
            if ([data.peRatioString isEqualToString:@"<null>"]) {
                
                vc.PERatioString = @"--";
                
            }
            
            else{
                
                vc.PERatioString = data.peRatioString;
                
            }
            
            if ([data.mktCapString isEqualToString:@"<null>"]) {
                
                vc.mktCapString = @"--";
                
            }
            
            else{
                
                vc.mktCapString = data.mktCapString;
                
            }
            
            if ([data.yearHighString isEqualToString:@"<null>"]) {
                
                vc.yearHighString = @"--";
                
            }
            
            else{
                
                vc.yearHighString = data.yearHighString;
                
            }
            
            if ([data.yearLowString isEqualToString:@"<null>"]) {
                
                vc.YearLowString = @"--";
                
            }
            
            else{
                
                vc.YearLowString = data.yearLowString;
                
            }
            
            if ([data.avgVolumeString isEqualToString:@"<null>"]) {
                
                vc.avgVolumeString = @"--";
                
            }
            
            else{
                
                vc.avgVolumeString = data.avgVolumeString;
                
            }
            
            if ([data.yieldString isEqualToString:@"<null>"]) {
                
                vc.yieldString = @"--";
                
            }
            
            else{
                
                vc.yieldString = data.yieldString;
                
            }
            
            self.imsgeUrlString = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@&t=3m&q=l&l=on&z=s&p=m50,m200", data.stockNameString];
            vc.stockSymbolString = data.stockNameString;
            
        }
        
        else if (path.section == 1){
            
            ModelStock *data = [self.negativeArray objectAtIndex:path.row];
            
            if ([data.titleNameString isEqualToString:@"<null>"]) {
                
                vc.titleString = @"-------";
                
            }
            
            else{
                
                vc.titleString = data.titleNameString;
                
            }
            
            if ([data.openValueString isEqualToString:@"<null>"]) {
                
                vc.openValueString = @"--";
                
            }
            
            else{
                
                vc.openValueString = data.openValueString;
                
            }
            
            if ([data.highValueString isEqualToString:@"<null>"]) {
                
                vc.highValueString = @"--";
                
            }
            
            else{
                
                vc.highValueString = data.highValueString;
                
            }
            
            if ([data.lowValueString isEqualToString:@"<null>"]) {
                
                vc.lowValueString = @"--";
                
            }
            
            else{
                
                vc.lowValueString = data.lowValueString;
                
            }
            
            if ([data.volumeString isEqualToString:@"<null>"]) {
                
                vc.volumeString = @"--";
                
            }
            
            else{
                
                vc.volumeString = data.volumeString;
                
            }
            
            if ([data.peRatioString isEqualToString:@"<null>"]) {
                
                vc.PERatioString = @"--";
                
            }
            
            else{
                
                vc.PERatioString = data.peRatioString;
                
            }
            
            if ([data.mktCapString isEqualToString:@"<null>"]) {
                
                vc.mktCapString = @"--";
                
            }
            
            else{
                
                vc.mktCapString = data.mktCapString;
                
            }
            
            if ([data.yearHighString isEqualToString:@"<null>"]) {
                
                vc.yearHighString = @"--";
                
            }
            
            else{
                
                vc.yearHighString = data.yearHighString;
                
            }
            
            if ([data.yearLowString isEqualToString:@"<null>"]) {
                
                vc.YearLowString = @"--";
                
            }
            
            else{
                
                vc.YearLowString = data.yearLowString;
                
            }
            
            if ([data.avgVolumeString isEqualToString:@"<null>"]) {
                
                vc.avgVolumeString = @"--";
                
            }
            
            else{
                
                vc.avgVolumeString = data.avgVolumeString;
                
            }
            
            if ([data.yieldString isEqualToString:@"<null>"]) {
                
                vc.yieldString = @"--";
                
            }
            
            else{
                
                vc.yieldString = data.yieldString;
                
            }
            
            self.imsgeUrlString = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@&t=3m&q=l&l=on&z=s&p=m50,m200", data.stockNameString];
            vc.stockSymbolString = data.stockNameString;
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            vc.imageString = self.imsgeUrlString;
            
        });
        
    }
    
}

-(void) searchText: (NSString *)text{
    
    NSString* newCompanyName = @"%22%@%22";
    newCompanyName = [newCompanyName stringByReplacingOccurrencesOfString:@"%@" withString:text];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* companyNames = [[userDefaults arrayForKey:@"CompaniesNames"]mutableCopy];
    if ([companyNames containsObject:newCompanyName]) {
        [companyNames removeObject:newCompanyName];
    }
    [companyNames addObject:newCompanyName];
    [userDefaults setObject:companyNames forKey:@"CompaniesNames"];
    [userDefaults synchronize];
    
    
    NSString *urlString = @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22%@%22)%0A%09%09&env=http%3A%2F%2Fdatatables.org%2Falltables.env&format=json";
    NSString *urlString1 = [urlString stringByReplacingOccurrencesOfString:@"%@" withString:text];
    NSString *urlString2 = [urlString1 stringByReplacingOccurrencesOfString:@"^" withString:@"%5E"];
    [self getsession:urlString2];
    
}

@end
