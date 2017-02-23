//
//  NEWSWebViewController.h
//  Stocks Tale
//
//  Created by Nagam Pawan on 1/4/17.
//  Copyright © 2017 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEWSWebViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) NSString *urlStringNew;
@property (weak, nonatomic) IBOutlet UIWebView *myWeb;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;



@end
