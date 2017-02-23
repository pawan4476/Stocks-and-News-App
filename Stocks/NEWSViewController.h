//
//  NEWSViewController.h
//  Stocks
//
//  Created by Nagam Pawan on 12/8/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEWSViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSDictionary *article;
@property (strong, nonatomic) NSArray *authorArray;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *descriptionArray;
@property (strong, nonatomic) NSArray *imageArray;
@property (strong, nonatomic) NSArray *newsChannelsArray;
@property (strong, nonatomic) NSArray *urlArray;

@property (strong, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong, nonatomic) IBOutlet UITextField *newsChannelTf;
@property (strong, nonatomic) UIPickerView *channelPicker;

- (IBAction)getNews:(id)sender;
@end
