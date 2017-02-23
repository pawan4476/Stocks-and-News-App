//
//  DetailsViewController.m
//  Stocks
//
//  Created by Nagam Pawan on 10/24/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import "DetailsViewController.h"
#import "CollectionViewCell.h"
#import "PreviousDataDetailsViewController.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = false;
    self.labelNamesArray = [NSArray arrayWithObjects:@"OPEN", @"HIGH", @"LOW", @"VOLUME", @"PE RATIO", @"MKT CAP", @"YEAR HIGH", @"YEAR LOW", @"AVG VOL", @"YIELD", nil];
    self.cellColorsArray = [NSArray arrayWithObjects:[UIColor blackColor], [UIColor greenColor], [UIColor redColor], [UIColor blackColor], [UIColor blackColor], [UIColor blackColor], [UIColor greenColor], [UIColor redColor], [UIColor blackColor], [UIColor blackColor], nil];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    
    float volume = self.volumeString.intValue;
    float avgVolume = self.avgVolumeString.intValue;
    
    id volume1 = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:volume/1000000]];
    id avgVolume1 = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:avgVolume/1000000]];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@", self.titleString];
    
    NSString *openString = [NSString stringWithFormat:@"%@", self.openValueString];
    NSString *highString = [NSString stringWithFormat:@"%@", self.highValueString];
    NSString *lowString = [NSString stringWithFormat:@"%@", self.lowValueString];
    NSString *volumeString1 = [NSString stringWithFormat:@"%@M", volume1];
    NSString *peRatioString = [NSString stringWithFormat:@"%@", self.PERatioString];
    NSString *mktCap = [NSString stringWithFormat:@"%@", self.mktCapString];
    NSString *yearHigh = [NSString stringWithFormat:@"%@", self.yearHighString];
    NSString *yearLow = [NSString stringWithFormat:@"%@", self.YearLowString];
    NSString *avgVol = [NSString stringWithFormat:@"%@M", avgVolume1];
    NSString *yield = [NSString stringWithFormat:@"%@%%", self.yieldString];
    
    self.valuesArray = [NSArray arrayWithObjects:openString, highString, lowString, volumeString1, peRatioString, mktCap, yearHigh, yearLow, avgVol, yield, nil];
    
    NSString *previousData = @"https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22%@%22%20and%20startDate%20%3D%20%22%A%22%20and%20endDate%20%3D%20%22%B%22&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=";
    self.stockSymbolUrlString = [previousData stringByReplacingOccurrencesOfString:@"%@" withString:self.stockSymbolString];
    
#pragma mark - Reachability
    
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
        
    dispatch_async(dispatch_get_main_queue(), ^{

        [self ImageDownload:self.imageString];
        
    });
        
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
   
}

-(void)ImageDownload: (NSString *)urlString{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:urlString]];
    [downloadTask resume];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
    NSData *data = [NSData dataWithContentsOfURL:location];
        [self.activityIndicator setHidden:YES];
    [self.graphImage setImage:[UIImage imageWithData:data]];
        
    });
}

- (IBAction)history:(id)sender {
}

#pragma mark - CollectinView delegate and datasource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.labelNamesArray.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.labelNames.text = [self.labelNamesArray objectAtIndex:indexPath.item];
    cell.values.text = [self.valuesArray objectAtIndex:indexPath.item];
    cell.values.textColor = [self.cellColorsArray objectAtIndex:indexPath.item];
    return cell;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"History"]) {
        
        PreviousDataDetailsViewController *vc = [segue destinationViewController];
        vc.urlStringnew = self.stockSymbolUrlString;
        
    }
}

- (IBAction)refresh:(id)sender {
    
    [self.activityIndicator setHidden:NO];
    dispatch_async(dispatch_get_main_queue(), ^{

     [self ImageDownload:self.imageString];
        [self performSelectorOnMainThread:@selector(stopAnimatingg) withObject:self.activityIndicator waitUntilDone:YES];
        
    });
    
}

- (IBAction)weekGraph:(id)sender {
    
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    self.weekImageString = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@&t=7d&q=l&l=on&z=s&p=m50,m200", self.stockSymbolString];
    [self ImageDownload:self.weekImageString];
    
}

- (IBAction)monthGraph:(id)sender {
    
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    self.monthImageString = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@&t=1m&q=l&l=on&z=s&p=m50,m200", self.stockSymbolString];
    [self ImageDownload:self.monthImageString];
    
}

- (IBAction)mGraph:(id)sender {
    
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    self.sixMonthsImageString = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@&t=6m&q=l&l=on&z=s&p=m50,m200", self.stockSymbolString];
    [self ImageDownload:self.sixMonthsImageString];
    
}

- (IBAction)yearGraph:(id)sender {
    
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    self.yearImageString = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@&t=1y&q=l&l=on&z=s&p=m50,m200", self.stockSymbolString];
    [self ImageDownload:self.yearImageString];
    
}

-(void)stopAnimatingg{
    
    [self.activityIndicator setHidesWhenStopped:YES];
    
}
@end
