//
//  SearchViewController.m
//  Stocks
//
//  Created by Nagam Pawan on 10/24/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    self.navigationItem.title = @"Search";
    self.searchBar.tintColor = [UIColor whiteColor];
    
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

    
    self.results = [[NSDictionary alloc]init];
    self.json = [[NSDictionary alloc]init];
    self.urlString = [[NSString alloc]init];
    self.dataTask = [[NSURLSessionDataTask alloc]init];
    self.stocksListArray = [[NSMutableArray alloc]init];
    NSString *startLetter = @"A";
    self.searchLetterLabel.text = [NSString stringWithFormat:@"  %@", startLetter];
    [self callAPI:startLetter];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) callAPI: (NSString *)stockName {
    
    [UIApplication sharedApplication]. networkActivityIndicatorVisible = YES;
    
    self.urlString = [NSString stringWithFormat:@"http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=%@&region=in&lang=en&callback=", stockName];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    self.dataTask = [session dataTaskWithURL:[NSURL URLWithString:_urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            
            [UIApplication sharedApplication]. networkActivityIndicatorVisible = NO;
            
            self.json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.results = [[self.json valueForKey:@"ResultSet"] valueForKey:@"Result"];
            
            [self.stocksListArray removeAllObjects];
            if (self.results != nil) {
            for (NSDictionary *search in self.results) {
                    
                    NSRange range = [[search valueForKey:@"name"] rangeOfString:stockName];
                    if (range.location != NSNotFound) {
                        
                        [self.stocksListArray addObject:search];
                        
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.searchTableView reloadData];
                    
                });
            }
        }
    }];
    
    [self.dataTask resume];
    
}

#pragma mark - Searchbar Delegate methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
        
        [self.stocksListArray removeAllObjects];
        self.searchLetterLabel.text = nil;
        
    }
    
    else{
        
        [self callAPI:searchText];
        
    }
    
    if ([searchText isEqualToString:@"A"] || [searchText isEqualToString:@"B"] || [searchText isEqualToString:@"C"] || [searchText isEqualToString:@"D"] || [searchText isEqualToString:@"E"] || [searchText isEqualToString:@"F"] || [searchText isEqualToString:@"G"] || [searchText isEqualToString:@"H"] || [searchText isEqualToString:@"I"] || [searchText isEqualToString:@"J"] || [searchText isEqualToString:@"K"] || [searchText isEqualToString:@"L"] || [searchText isEqualToString:@"M"] || [searchText isEqualToString:@"N"] || [searchText isEqualToString:@"O"] || [searchText isEqualToString:@"P"] || [searchText isEqualToString:@"Q"] || [searchText isEqualToString:@"R"] ||[searchText isEqualToString:@"S"] || [searchText isEqualToString:@"T"] || [searchText isEqualToString:@"U"] || [searchText isEqualToString:@"V"] || [searchText isEqualToString:@"W"] || [searchText isEqualToString:@"X"] || [searchText isEqualToString:@"Y"] || [searchText isEqualToString:@"Z"]) {
        
        self.searchLetterLabel.text = [NSString stringWithFormat:@"  %@", searchText];
        
    }
    
    [self.searchTableView reloadData];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    
}

#pragma mark - TableView delegate and datasource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.stocksListArray.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.searchTableView dequeueReusableCellWithIdentifier:@"cell1"];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        
    }
    
    if ([_stocksListArray count] > 0 && [_stocksListArray count] > indexPath.row) {
        
    NSDictionary *object = [self.stocksListArray objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont systemFontOfSize:20.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:20.0];
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.textColor = [UIColor redColor];
    
    cell.textLabel.text = [object valueForKey:@"name"];
    cell.detailTextLabel.text = [object valueForKey:@"symbol"];
        
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_stocksListArray count] > 0 && [_stocksListArray count] > indexPath.row) {
        
        NSDictionary *object = [self.stocksListArray objectAtIndex:indexPath.row];
        [_delegate searchText:[object valueForKey:@"symbol"]];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}


@end
