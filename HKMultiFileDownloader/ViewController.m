//
//  ViewController.m
//  HKMultiFileDownloader
//
//  Created by HuangKai on 16/4/25.
//  Copyright © 2016年 HuangKai. All rights reserved.
//

#import "ViewController.h"
#import "HKMultiFileDownloader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)onMultiDownloader:(id)sender{
    [HKMultiFileDownloader hk_downloadWithURL:@"http://ww1.sinaimg.cn/mw690/5993966fjw1f5v1u972lbj20sg0iztby.jpg" completion:^(NSData *data, NSUInteger totalLength) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
