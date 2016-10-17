//
//  ZSPhotoBrowerCell.m
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/2.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSPhotoBrowerCell.h"
#import "ZSPhotoBrowerImageView.h"
@implementation ZSPhotoBrowerCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
       
        [self setupImageView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame: frame]) {
        [self setupImageView];
    }
    return self;
}

- (void)setupImageView{
    
    __weak typeof(self)weakSelf = self;
    ZSPhotoBrowerImageView *photoBrowerImageView = [[ZSPhotoBrowerImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //当图片被单点时调用
    photoBrowerImageView.singleTapBlock = ^(UITapGestureRecognizer *tap){
        if (weakSelf.singleTap) {
            weakSelf.singleTap();
        }
    };
    
    _photoBrowerImageView = photoBrowerImageView;
    [self.contentView addSubview:photoBrowerImageView];
    
}

- (void)sd_ImageWithURL:(NSString *)url placeHolder:(UIImage *)placeHolder{
    
    [_photoBrowerImageView.scrollView setZoomScale:1 animated:NO];
    
    [_photoBrowerImageView sd_ImageWithURL:[NSURL URLWithString:url] placeHolder:placeHolder];
    //设置缩放比
    [_photoBrowerImageView reloadFrame];
}
//从总览图进入图片浏览
- (void)dealloc{
    [_photoBrowerImageView.scrollView setZoomScale:1.0 animated:NO];
}

@end






















