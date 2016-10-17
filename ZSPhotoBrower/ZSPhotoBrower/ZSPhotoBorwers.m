//
//  ZSPhotoBorwers.m
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/16.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSPhotoBorwers.h"
#import "ZSPhotoBrowerCell.h"
#import "UIImageView+WebCache.h"
#import "ZSPhotoBorwerItem.h"
#import "ZSPhotoBrowerNumLabel.h"
#import "ZSToast.h"
#import "ZSActionSheet.h"


@interface ZSPhotoBorwers ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    
    ZSPhotoBrowerCell       *_collectionViewCell;
    ZSPhotoBrowerNumLabel   *_numLabel;//数字
    UICollectionView        *_collectionView;
    UIButton                *_operationButton;//操作按钮
    UIPageControl           *_pageControl;
    BOOL                     _isFirstShow;//是否是第一次展示
    CGFloat                  _contentOffsetX;//偏移量
    NSInteger                _page;//页数
    
}

@end

static NSString *Id = @"ZSCollectionView";
@implementation ZSPhotoBorwers

- (instancetype)init{
    
    if (self = [super init]) {
        [self initializeDefaultProperty];
    }
    return self;
}

#pragma mark -移动到父控件上
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [self initializeCollectionView];
    [self initializeDefaultProperty];
    [self initializePageLabel];
    [self initializeOperationView];
    
}


#pragma  mark --初始化基本属性
- (void)initializeDefaultProperty{
    self.backgroundColor = [UIColor orangeColor];
    self.alpha = 1.f;
    
    self.actionSheetArray = [NSMutableArray array];
    _isNeesPageNumView = YES;
    _isNeedRightButton = YES;
    _isNeedPageControl = NO;
}

#pragma  mark --初始化CollectionView
- (void)initializeCollectionView{
    
    CGRect bounds = CGRectMake(0, 0, self.width, self.height);
    bounds.size.width += PhotoBrowerMargin;
    
    //流式布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = bounds.size;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:bounds collectionViewLayout:layout];
    
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.pagingEnabled = YES;
    collectionView.bounces = YES;
    
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[ZSPhotoBrowerCell class] forCellWithReuseIdentifier:Id];
    _collectionView = collectionView;
    [self addSubview:collectionView];
}

#pragma  mark -- 初始化pageLabel
- (void)initializePageLabel{
    ZSPhotoBrowerNumLabel *numLabel = [[ZSPhotoBrowerNumLabel alloc]init];
    numLabel.frame = CGRectMake(0, 25, ScreenWidth, 25);
    [numLabel setCurrentNum:(_currentIndex + 1) totalNum:_itemArrary.count - 1];
    _page = numLabel.currentNum;
    numLabel.hidden = !_isNeesPageNumView;//显示
    
    if (_itemArrary.count == 1) {
        numLabel.hidden = YES;
    }
    _numLabel = numLabel;
    [self addSubview:numLabel];
}

#pragma  mark --初始化右上角操作按钮
- (void)initializeOperationView{
    UIButton *operationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    operationButton.layer.cornerRadius = 3;
    operationButton.clipsToBounds = YES;
    operationButton.backgroundColor = [UIColor blackColor];
    operationButton.alpha = 0.4;
    [operationButton setBackgroundImage:[UIImage imageNamed:@"more_tap"] forState:UIControlStateNormal];
    operationButton.frame = CGRectMake(ScreenWidth - 35 - 15, 25, 35, 20);
    [operationButton addTarget:self action:@selector(operationButtonIBAction) forControlEvents:UIControlEventTouchUpInside];
    operationButton.hidden = !_isNeedRightButton ;
    _operationButton = operationButton;
    [self addSubview:operationButton];
    
}

#pragma mark --右上角按钮点击
- (void)operationButtonIBAction{
    __weak typeof (self)weakSelf = self;
    //如果是自定义的选项
    if (_actionSheetArray.count != 0) {
        ZSActionSheet *actionSheet = [[ZSActionSheet alloc]initWithCancelBtnTitle:nil destructiveButtonTitle:nil otherBtnTitlesArr:[_actionSheetArray copy] actionBlock:^(NSInteger buttonIndex) {
            if ([weakSelf.delegate respondsToSelector:@selector(photoBrowerRightOperationActionWithIndex:)]) {
                [weakSelf.delegate photoBrowerRightOperationActionWithIndex:buttonIndex];
            }
            
        }];
        [actionSheet show];
    }else{
        
        ZSActionSheet *actionSheet = [[ZSActionSheet alloc]initWithCancelBtnTitle:nil destructiveButtonTitle:nil otherBtnTitlesArr:@[@"保存图片",@"转发微博",@"赞"] actionBlock:^(NSInteger buttonIndex) {
            if ([weakSelf.delegate respondsToSelector:@selector(photoBrowerRightOperationActionWithIndex:)]) {
                
                [weakSelf.delegate photoBrowerRightOperationActionWithIndex:buttonIndex];
            }
            switch (buttonIndex) {
                case 0:{
                    SDWebImageManager *manager = [SDWebImageManager sharedManager];
                    if ([manager diskImageExistsForURL:[NSURL URLWithString:_itemArrary[_currentIndex]]]) {
                        [[ZSToast shareToast]initWithText:@"图片需要下载"];
                        return ;
                    }else{
                        UIImage *image = [[manager imageCache]imageFromDiskCacheForKey:_itemArrary[_currentIndex]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
                        });
                    }
                }
                    
                    break;
                    
                default:
                    break;
            }
        }];
        
        [actionSheet show];
    }
}

#pragma  mark --将相片存入相册的调用
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    __weak typeof(self)weakSelf = self;
    if (!error) {
        [[ZSToast shareToast]initWithText:PhotoSaveImageSuccessMessage duration:PhotoSaveImageMessageTime];
    }else{
        [[ZSToast shareToast]initWithText:PhotoSaveImageFailureMessage duration:PhotoSaveImageMessageTime];
    }
    
    if ([weakSelf.delegate respondsToSelector:@selector(photoBrowerWriteSavedPhotoAlbumStatus:)]) {
        //如果存在错误,保存就不成功
        [weakSelf.delegate photoBrowerWriteSavedPhotoAlbumStatus:error?NO:YES];
    }
    
}

#pragma mark --  UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _itemArrary.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak typeof(self)weakSelf = self;
    ZSPhotoBrowerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Id forIndexPath:indexPath];
    
    ZSPhotoBorwerItem *item = _itemArrary[indexPath.row];
    NSString *url = item.url;
    UIImageView *tempView = [weakSelf tempViewFromSourceViewWithCurrentIndex:indexPath.row];
    
    [cell sd_ImageWithURL:url placeHolder:tempView.image];
    
    cell.singleTap = ^(){
        [weakSelf dismiss];
    };
    
    _collectionViewCell = cell;
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

///滚动方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    _currentIndex = scrollView.contentOffset.x / (ScreenWidth + PhotoBrowerMargin);
    
    CGFloat scrollViewW = scrollView.frame.size.width;
    CGFloat x = scrollView.contentOffset.x;
    NSInteger page = (x + scrollViewW / 2) / scrollViewW;
    if (_page != page) {
        _page = page;
        if (_page + 1 <= _itemArrary.count) {
            [_numLabel setCurrentNum:_page];
            [_pageControl setCurrentPage:_page];
        }
    }
}

#pragma mark 私有方法,将子控件上的控件转成ImageView
- (UIImageView *)tempViewFromSourceViewWithCurrentIndex:(NSInteger)currentIndex{
    
    //生成一个临时的imageView去做动画
    UIImageView *tempView = [[UIImageView alloc]init];
    ZSPhotoBorwerItem *item = _itemArrary[currentIndex];
    if ([item.sourceView isKindOfClass:[UIImageView class]]) {
        UIImageView *imgv = (UIImageView *)item.sourceView;
        [tempView setImage:[imgv image]];
    }
    
    if ([item.sourceView isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)item.sourceView;
        [tempView setImage:[btn currentBackgroundImage]?[btn currentBackgroundImage]:[btn currentImage]];
    }
    //占位图片
    if (!tempView.image) {
        [tempView setImage:[UIImage imageNamed:@"defaultPlaceHolder"]];
    }
    return tempView;
}

#pragma mark 消失
- (void)dismiss{
    //让代理知道PhotoBrower即将消失
    if ([self.delegate respondsToSelector:@selector(photoBrowerWillDismiss)]) {
        [self.delegate photoBrowerWillDismiss];
    }
    UIImageView *tempView = [[UIImageView alloc]init];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    ZSPhotoBorwerItem *items = _itemArrary[_currentIndex];
    
    if ([manager diskImageExistsForURL:[NSURL URLWithString:items.url]]) {
        //从沙盒中获取
        tempView.image = [[manager imageCache]imageFromDiskCacheForKey:items.url];
    }else{
        tempView.image = [[self tempViewFromSourceViewWithCurrentIndex:_currentIndex]image];
    }
    
    if (!tempView.image) {
        tempView.image = [UIImage imageNamed:@"defaultPlaceHolder"];
    }
    
    _collectionView.hidden = YES;
    _operationButton.hidden = YES;
    _pageControl.hidden = YES;
    _numLabel.hidden = YES;
    
    UIView *sourceView = items.sourceView;
    CGRect rect = [sourceView convertRect:[sourceView bounds] toView:self];
    
    if (rect.origin.y > ScreenHeight || rect.origin.y <= -rect.size.height || rect.origin.x > ScreenWidth || rect.origin.x <= -rect.size.width) {
        [UIView animateKeyframesWithDuration:PhotoBrowerBrowerTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [tempView removeFromSuperview];
            self.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
        return;
    }else{
        CGFloat width = tempView.image.size.width;
        CGFloat height = tempView.image.size.height;
        CGSize tempViewSize = CGSizeMake(ScreenWidth, (height * ScreenWidth / width) > ScreenHeight ? ScreenHeight:(height * ScreenWidth / width));
        tempView.bounds = CGRectMake(0, 0, tempViewSize.width, tempViewSize.height);
        tempView.center = self.center;
        [self addSubview:tempView];
        
        [UIView animateKeyframesWithDuration:PhotoBrowerBrowerTime delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            tempView.frame = rect;
            self.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_isFirstShow) {
        [self photoBrowerWillShowWithAnimated];
    }
}

#pragma mark --展示动画
- (void)photoBrowerWillShowWithAnimated{
    
    //1.判断用户点击了的控件是控制器的第几个图片 在这里设置collectionView的偏移量
    _collectionView.contentOffset = CGPointMake(_currentIndex * (self.width + PhotoBrowerMargin), 0);
    
    _contentOffsetX = _collectionView.contentOffset.x;
    
    ZSPhotoBorwerItem *items = _itemArrary[_currentIndex];
    UIView *sourceView = items.sourceView;
    CGRect rect = [sourceView convertRect:[sourceView bounds] toView:self];
    
    UIImageView *tempView = [self tempViewFromSourceViewWithCurrentIndex:_currentIndex];
    tempView.frame = rect;
    [tempView setContentMode:sourceView.contentMode];
    
    [self addSubview:tempView];
    
    CGSize tempRectSize;
    CGFloat width = tempView.image.size.width;
    CGFloat height = tempView.image.size.height;
    
    tempRectSize = CGSizeMake(ScreenWidth, (height * ScreenWidth / width) > ScreenHeight ? ScreenHeight:(height * ScreenWidth / width));
    _collectionView.hidden = YES;
    
    //时间曲线函数,由快到慢
    [UIView animateKeyframesWithDuration:PhotoBrowerBrowerTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        tempView.center = self.center;
        tempView.bounds = CGRectMake(0, 0, tempRectSize.width, tempRectSize.height);
    } completion:^(BOOL finished) {
        _isFirstShow = YES;
        [tempView removeFromSuperview];
        _collectionView.hidden = NO;
    }];
}

///判断imageUrl数组是否为空
- (BOOL)imageArrayIsEmpty{
    if (_itemArrary == nil || [_itemArrary isKindOfClass:[NSNull class]] || _itemArrary.count == 0) {
        return YES;
    }
    return NO;
}

#pragma  mark --展现
- (void)present{
    if ([self imageArrayIsEmpty]) {
        return;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    self.frame = window.bounds;
    [window addSubview:self];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


@end
