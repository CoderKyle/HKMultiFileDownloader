# HKMultiFileDownloader

用法如下：
__weak typeof(self) weakSelf = self;
[HKMultiFileDownloader hk_downloadWithURL:@"http://ww1.sinaimg.cn/mw690/5993966fjw1f5v1u972lbj20sg0iztby.jpg"
                               completion:^(NSError *error, NSData *data) {
                                   if (!error) {
                                       UIImage *image = [UIImage imageWithData:data scale:1];
                                       weakSelf.imageView.image = image;
                                   }else {
                                       weakSelf.imageView.image = nil;
                                   }
                               }];