//
//  SearchViewController.h
//  Stocks
//
//  Created by Nagam Pawan on 10/24/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchViewControllerDelegate <NSObject>

-(void) searchText: (NSString *)text;

@end

@interface SearchViewController : UIViewController<UISearchBarDelegate, UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *json;
@property (strong, nonatomic) NSDictionary *results;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSMutableArray *stocksListArray;
@property (strong, nonatomic) id<SearchViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *searchTableView;
@property (strong, nonatomic) IBOutlet UILabel *searchLetterLabel;


@end
