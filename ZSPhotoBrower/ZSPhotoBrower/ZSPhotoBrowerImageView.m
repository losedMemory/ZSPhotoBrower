//
//  ZSPhotoBrowerImageView.m
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/2.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSPhotoBrowerImageView.h"
#import "ZSProgressHUD.h"
#import "UIImageView+WebCache.h"


@interface ZSPhotoBrowerImageView ()<UIScrollViewDelegate>{
    ZSProgressHUD  *_progressHUD;
    NSURL          *_url;
    UIImage        *_placeHolder;
    
}

@property (nonatomic,strong) UILabel *reloadLabel;//重新加载label

@end
@implementation ZSPhotoBrowerImageView

- (UIImageView *)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]init];
        _imageView.userInteractionEnabled = YES;
        _imageView.frame = CGRectMake(0, 0,ScreenWidth , ScreenHeight);
    }
    return _imageView;
    
}

- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth);
        [_scrollView addSubview:self.imageView];
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = YES;
    }
    return _scrollView;
}

- (UILabel *)reloadLabel{
    if (_reloadLabel == nil) {
        _reloadLabel = [[UILabel alloc]init];
        _reloadLabel.backgroundColor = [UIColor blackColor];
        _reloadLabel.layer.cornerRadius = 5;
        _reloadLabel.clipsToBounds = YES;
        _reloadLabel.font = [UIFont systemFontOfSize:18];
        _reloadLabel.textColor = [UIColor whiteColor];
        _reloadLabel.textAlignment = NSTextAlignmentCenter;
        _reloadLabel.bounds = CGRectMake(0, 0, 100, 35);
        _reloadLabel.text = @"重新加载";
        _reloadLabel.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reloadImage)];
        [_reloadLabel addGestureRecognizer:tap];
        
        [self addSubview:_reloadLabel];
        
    }
    return _reloadLabel;
}

///重新加载图片
- (void)reloadImage{
    _reloadLabel.hidden = YES;
    [self sd_ImageWithURL:_url placeHolder:_placeHolder];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.scrollView];
        [self initDefaultData];
    }
    return self;
}

///加载数据
- (void)initDefaultData{
    
    //轻触手势,有两种,一种是点一下,另一种是点两下
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollviewDidTap:)];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollviewDidDoubleTap:)];
    
    //设置手势的要求
    tap.numberOfTapsRequired = 1;//触摸的次数
    tap.numberOfTouchesRequired = 1;//触摸的手指数
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    
    //避免两种手势冲突
    [tap requireGestureRecognizerToFail:doubleTap];
    
    //添加手势
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:doubleTap];
}

///点击一下
- (void)scrollviewDidTap:(UITapGestureRecognizer *)tap{
    if (_singleTapBlock) {
        _singleTapBlock(tap);
    }
    
}
///连续点击两下
- (void)scrollviewDidDoubleTap:(UITapGestureRecognizer *)doubleTap{
    //先判断图片是否下载好,如果没有下载好,直接return
    if (_imageView.image == nil) {
        return;
    }
    //缩放比,如果是默认的状态,也就是没有改变大小时,双击,会放大
    if (_scrollView.zoomScale <= 1) {
        //1.获取到手势在自身的位置
        //2.手势的x需要放大图片的x点
        CGFloat x = [doubleTap locationInView:self].x;
        //3.手势的y需要放大的图片的y点
        CGFloat y = [doubleTap locationInView:self].y ;
        [_scrollView zoomToRect:CGRectMake(x,y,0, 0) animated:YES];
    }else{
        //还原
        [_scrollView setZoomScale:1.f animated:YES];
    }
    
}

- (void)sd_ImageWithURL:(NSURL *)url placeHolder:(UIImage *)placeHolder{
    
    _url = url;
    _placeHolder = placeHolder;
    
    __weak typeof(self)weakSelf = self;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    //从缓存中取出图片
    [[manager imageCache]queryDiskCacheForKey:[url absoluteString] done:^(UIImage *image, SDImageCacheType cacheType) {
        
        if (_progressHUD) {//如果加载圈存在,则消失
            
            [_progressHUD removeFromSuperview];
        }
        
        if (image) {//如果缓存中有图片,就直接赋值
            _imageView.image = image;
            
        }else{//缓存中没有图片则下载
            //显示加载圈
            ZSProgressHUD *progressHUD = [ZSProgressHUD showHUDAddTo:self animation:YES];
            _progressHUD = progressHUD;
            
            //SDWebImage下载图片
            [_imageView sd_setImageWithURL:url placeholderImage:placeHolder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
                CGFloat progress = ((CGFloat)receivedSize / expectedSize);
                progressHUD.progress = progress;//设置进度
                if (progress == 1) {//如果进度=1,则消失
                    if (!progressHUD) {
                        [progressHUD dismiss];
                    }
                }
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                [_scrollView setZoomScale:1.f animated:YES];
                if (error) {
                    [_progressHUD dismiss];
                    [weakSelf.reloadLabel setHidden:NO];
                }else{
                    [weakSelf layoutSubviews];
                }
            }];
            
        }
        
        
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    
    [self reloadFrame];
}

- (void)reloadFrame{
    CGRect frame = self.frame;
    if (_imageView.image) {
      
        CGSize imageSize = _imageView.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        //如果scrollView的宽<=高,将图片的宽设置成scrollView的宽,高度等比率缩放,在竖屏状态下,宽度是比高度要小的
        if (frame.size.width <= frame.size.height) {
            CGFloat ratio = frame.size.width / imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height * ratio;
            imageFrame.size.width = frame.size.width;
            
        }else{//在横屏模式下,宽度会比高度大
            
            //如果scrollView的宽>高,图片的高设置scrollView的高,宽度按比例缩放
            CGFloat ratio = frame.size.height / frame.size.width;
            imageFrame.size.width = frame.size.width * ratio;
            imageFrame.size.height = frame.size.height;
        }
        
        //设置imageView的frame
        _imageView.frame = imageFrame;
        
        //设置scrollView的滚动范围
        _scrollView.contentSize = _imageView.frame.size;
        
        //将scrollView的contentSize辅助为图片的大小,再获取图片的中心点
        _imageView.center = [self centerOfScrollViewContent:_scrollView];
        
        //获取scrollView的高和图片高的比率
        CGFloat maxScale = frame.size.height / imageFrame.size.height;
        
        //获取宽度的比率
        CGFloat widthRadio = frame.size.width / imageFrame.size.width;
        
        //取出最大的比率
        maxScale = widthRadio > maxScale ? widthRadio : maxScale;
        
        //如果最大比率 >= 2倍,则取最大比率,否则取2倍
        maxScale = maxScale > 2 ? maxScale : 2;
        
        //设置最大和最小的缩放比
        _scrollView.minimumZoomScale = 0.6;
        _scrollView.maximumZoomScale = maxScale;
        
        //设置原始缩放比
        _scrollView.zoomScale = 1.0;
    }else{
        
        frame.origin = CGPointZero;
        _imageView.frame = frame;
        _scrollView.contentSize = _imageView.size;
    }
    _scrollView.contentOffset = CGPointZero;

}

///获取图片的中心点
- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView{
    
    //在竖屏模式下,offsetX是0
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    //在横屏模式下offsetY是0
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    
    return actualCenter;
}
#pragma  mark --代理

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //每次拖动都重置图片的中心点
    _imageView.center = [self centerOfScrollViewContent:scrollView];
}

@end

















