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
    [HKMultiFileDownloader hk_downloadWithURL:@"http://buspic.gpsoo.net/goome01/M00/00/21/wKgCoVcSDCeEBHmZAAAAAA9L7Zk38.jpeg" completion:^(NSData *data, NSUInteger totalLength) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
