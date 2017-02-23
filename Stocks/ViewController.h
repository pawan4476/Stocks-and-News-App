//
//  ViewController.h
//  Stocks
//
//  Created by Nagam Pawan on 10/20/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "ModelStock.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    
    Reachability *reachability;
    
}

@property (strong, nonatomic) NSMutableArray *stocksArray;
@property (strong, nonatomic) NSMutableArray *positiveArray;
@property (strong, nonatomic) NSMutableArray *negativeArray;
@property (strong, nonatomic) NSMutableOrderedSet *positiveSet;
@property (strong, nonatomic) NSMutableOrderedSet *negativeSet;

@property (strong, nonatomic) NSString *imsgeUrlString;

@property (strong, nonatomic) IBOutlet UITableView *tableView1;
@property (strong, nonatomic) NSIndexPath *path;

@end

