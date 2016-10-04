//
//  ZSPhotoBrowerImageView.h
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/2.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SingleTapBlock)(UITapGestureRecognizer *tap);
@interface ZSPhotoBrowerImageView : UIView

@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,copy) SingleTapBlock singleTapBlock;

- (void)sd_ImageWithURL:(NSURL *)url placeHolder:(UIImage *)placeHolder;

- (void)reloadFrame;

@end
