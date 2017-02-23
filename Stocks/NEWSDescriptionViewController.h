//
//  NEWSDescriptionViewController.h
//  Stocks
//
//  Created by Nagam Pawan on 12/8/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEWSDescriptionViewController : UIViewController<NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSString *descriptionString;
@property (strong, nonatomic) NSString *imageString;
@property (strong, nonatomic) NSString *titleNewsString;
@property (strong, nonatomic) NSString *urlString;

@property (strong, nonatomic) IBOutlet UIImageView *newsImage;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UILabel *titleNewsLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIButton *buttonOutlet;
- (IBAction)urlButton:(id)sender;

@end
