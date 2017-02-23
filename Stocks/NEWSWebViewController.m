//
//  NEWSWebViewController.m
//  Stocks Tale
//
//  Created by Nagam Pawan on 1/4/17.
//  Copyright © 2017 Nagam Pawan. All rights reserved.
//

#import "NEWSWebViewController.h"

@interface NEWSWebViewController ()

@end

@implementation NEWSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"NEWS";
       if ([self.urlStringNew isKindOfClass:[NSNull class]]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error in loading" message:@"Url is not valid" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    else{
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.urlStringNew]]) {
            
            [self.myWeb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStringNew]]];
            
        }
        
    }

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    
    self.activityIndicator.hidden = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self.activityIndicator stopAnimating];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
