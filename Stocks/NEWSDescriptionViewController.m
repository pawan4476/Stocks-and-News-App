//
//  NEWSDescriptionViewController.m
//  Stocks
//
//  Created by Nagam Pawan on 12/8/16.
//  Copyright © 2016 Nagam Pawan. All rights reserved.
//

#import "NEWSDescriptionViewController.h"
#import "NEWSWebViewController.h"

@interface NEWSDescriptionViewController ()

@end

@implementation NEWSDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"NEWS";
    self.descriptionTextView.editable = NO;
    
    if ([self.imageString isKindOfClass:[NSNull class]]) {
        
        self.newsImage.image = [UIImage imageNamed:@"No_Image_Available.png"];
        
    }
    
    else {
        
    dispatch_async(dispatch_get_main_queue(), ^{

     [self imageDownload:self.imageString];

    });
        
    }
       // Do any additional setup after loading the view.
}

-(void) imageDownload: (NSString *)urlString{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:urlString]];
    [downloadTask resume];
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    NSData *data = [NSData dataWithContentsOfURL:location];
    [self.newsImage setImage:[UIImage imageWithData:data]];
        [self.activityIndicator setHidden:YES];
        self.titleNewsLabel.text = [NSString stringWithFormat:@"%@ :", self.titleNewsString];
        self.descriptionTextView.text = [NSString stringWithFormat:@"%@", self.descriptionString];
        
    });
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)urlButton:(id)sender {
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"web"]) {
        
        NEWSWebViewController *vc = [segue destinationViewController];
        vc.urlStringNew = self.urlString;
        
    }
}
@end
