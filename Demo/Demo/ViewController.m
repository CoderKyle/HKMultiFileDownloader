//
//  ViewController.m
//  Demo
//
//  Created by HuangKai on 16/7/20.
//  Copyright © 2016年 HuangKai. All rights reserved.
//

#import "ViewController.h"
#import "HKMultiFileDownloader.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)onMultiDownloader:(id)sender{
    __weak typeof(self) weakSelf = self;
    [HKMultiFileDownloader hk_downloadWithURL:@"http://ww1.sinaimg.cn/mw690/5993966fjw1f5v1u972lbj20sg0iztby.jpg" completion:^(NSError *error, NSData *data) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data scale:1];
            weakSelf.imageView.image = image;
        }else {
            weakSelf.imageView.image = nil;
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
