//
//  NEWSViewController.m
//  Stocks
//
//  Created by Nagam Pawan on 12/8/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import "NEWSViewController.h"
#import "NEWSTableViewCell.h"
#import "NEWSDescriptionViewController.h"

@interface NEWSViewController ()

@end

@implementation NEWSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"NEWS";
    
    self.newsChannelsArray = @[@"bbc-news", @"bbc-sport", @"business-insider", @"buzzfeed", @"cnbc", @"cnn", @"entertainment-weekly", @"espn", @"espn-cric-info", @"financial-times", @"google-news", @"mtv-news", @"national-geographic", @"new-york-magazine", @"techcrunch", @"the-hindu", @"the-new-york-times", @"the-times-of-india"];
    
    [self getSession:@"https://newsapi.org/v1/articles?source=techcrunch&sortBy=top&apiKey=fe17681c56fb4f9bb56c0113bcd06e4f"];
    
    self.channelPicker = [[UIPickerView alloc]init];
    self.channelPicker.delegate = self;
    self.channelPicker.dataSource = self;
    self.newsChannelTf.inputView = self.channelPicker;
    
#pragma mark - RefreshController
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.newsTableView addSubview:refresh];
    
    // Do any additional setup after loading the view.
}

-(void)refresh:(UIRefreshControl *)refresh{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM d, hh:mm a"];
    NSString *titleString = [NSString stringWithFormat:@"Last Update: %@",[formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDic = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:titleString attributes:attrsDic];
    refresh.attributedTitle = attributedTitle;
    
    if (self.newsChannelTf.text.length == 0) {
        
         [self getSession:@"https://newsapi.org/v1/articles?source=techcrunch&sortBy=top&apiKey=fe17681c56fb4f9bb56c0113bcd06e4f"];
        
    }
    
    else{
        
        [self getSession:[NSString stringWithFormat:@"https://newsapi.org/v1/articles?source=%@&sortBy=top&apiKey=fe17681c56fb4f9bb56c0113bcd06e4f", self.newsChannelTf.text]];
        
    }
    
    [self.newsTableView reloadData];
    [refresh endRefreshing];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getSession: (NSString *)newsJsonUrl{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:newsJsonUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [self parseNews:json];
            
        }
        
        else{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error in loading" message:@"Data not found" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        
        }
        
    }];
    
    [dataTask resume];
    
}

-(void)parseNews: (NSDictionary *)json{
    
    self.article = [json valueForKey:@"articles"];
    if (self.article != nil) {
        
    self.authorArray = [self.article valueForKey:@"author"];
    self.titleArray = [self.article valueForKey:@"title"];
        self.descriptionArray = [self.article valueForKey:@"description"];
        self.imageArray = [self.article valueForKey:@"urlToImage"];
        self.urlArray = [self.article valueForKey:@"url"];
        
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.newsTableView reloadData];
        
    });
        
    }
    
    else{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error in loading" message:@"Data not found" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.titleArray.count;
    
}

#pragma mark - TableView Delegate and datasource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NEWSTableViewCell *cell = [self.newsTableView dequeueReusableCellWithIdentifier:@"newsCell"];
    id newsTitle = [self.titleArray objectAtIndex:indexPath.row];
    id author = [self.authorArray objectAtIndex:indexPath.row];
    
    if ([newsTitle isKindOfClass:[NSNull class]]) {
        
        cell.textLabel.text = @"----------------";
        
    }
    
    else{
        
    cell.textLabel.text = [NSString stringWithFormat:@"%@", newsTitle];
        
    }
    
    if ([author isKindOfClass:[NSNull class]]) {
        
        cell.detailTextLabel.text = @"Published By : Unknown";
        
    }
    
    else{
        
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Published By : %@", author];
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.newsTableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - PickerView delegate and datasource Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return self.newsChannelsArray.count;
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return self.newsChannelsArray[row];
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    self.newsChannelTf.text = self.newsChannelsArray[row];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getNews:(id)sender {
    
    if (self.newsChannelTf.text.length == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TextField is empty" message:@"Please select the channel first" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    else{
        
    [self.channelPicker removeFromSuperview];
    [self getSession:[NSString stringWithFormat:@"https://newsapi.org/v1/articles?source=%@&sortBy=top&apiKey=fe17681c56fb4f9bb56c0113bcd06e4f", self.newsChannelTf.text]];
        [self.newsChannelTf endEditing:YES];
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSIndexPath *path = [[self.newsTableView indexPathsForSelectedRows] objectAtIndex:0];
    
    if ([segue.identifier isEqualToString:@"news"]) {
        
        NEWSDescriptionViewController *vc = [segue destinationViewController];
        vc.titleNewsString = [self.titleArray objectAtIndex:path.row];
        vc.descriptionString = [self.descriptionArray objectAtIndex:path.row];
        vc.imageString = [self.imageArray objectAtIndex:path.row];
        vc.urlString = [self.urlArray objectAtIndex:path.row];
        
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    textField.text = self.newsChannelTf.text;
    
}

@end
