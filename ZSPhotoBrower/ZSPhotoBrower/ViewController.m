//
//  ViewController.m
//  ZSPhotoBrower
//
//  Created by 周松 on 16/9/29.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "ZSPhotoBorwers.h"
#import "ZSPhotoBrowerImageView.h"
#import "ZSToast.h"
#import "ZSPhotoBorwerItem.h"
@interface ViewController ()<ZSPhotoBorwerDelegate>{
    BOOL   _applicationStatusIsHidden;
}

@property (nonatomic,strong) NSMutableArray *itemArray;

@property (nonatomic,strong) NSMutableArray *actionSheetArray;//右上角弹框信息

@property (nonatomic,strong) ZSPhotoBorwers *photoBrower;

@end

@implementation ViewController

- (NSMutableArray *)itemArray{
    if (_itemArray == nil) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (NSMutableArray *)actionSheetArray{
    if (_actionSheetArray == nil) {
        _actionSheetArray = [NSMutableArray array];
        
    }
    return _actionSheetArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"图片浏览器";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[SDWebImageManager sharedManager].imageCache clearDisk];
    
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    NSArray *urlArray = @[@"http://ww4.sinaimg.cn/thumbnail/7f8c1087gw1e9g06pc68ug20ag05y4qq.gif",
                          @"http://ww2.sinaimg.cn/thumbnail/642beb18gw1ep3629gfm0g206o050b2a.gif",
                          @"http://ww2.sinaimg.cn/thumbnail/677febf5gw1erma104rhyj20k03dz16y.jpg",
                          @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg",
                          @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",
                          @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg",
                          @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg",
                          @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                          @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg"];

    self.actionSheetArray = [NSMutableArray array];
    [self.actionSheetArray addObject:@"第一个"];
    [self.actionSheetArray addObject:@"第二个"];
    [self.actionSheetArray addObject:@"第三个"];
    [self.actionSheetArray addObject:@"第四个"];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = CGRectMake(0, -100, 50, 50);
    [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg"]];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
    [imageView addGestureRecognizer:tap];
    imageView.tag = 0;
    ZSPhotoBorwerItem *items = [[ZSPhotoBorwerItem alloc]init];
    items.url = @"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg";
    items.sourceView = imageView;
    [self.itemArray addObject:items];
    
    //布局
    for (NSInteger i = 0; i < urlArray.count; i ++ ) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        [imageView addGestureRecognizer:tap];
        imageView.tag = i + 1;
        [imageView sd_setImageWithURL:urlArray[i]];
        CGFloat width = (self.view.frame.size.width - 40 ) / 3;
        NSInteger row = i / 3;
        NSInteger col = i % 3;
        CGFloat x = 10 + col * (10 + width);
        CGFloat y = 10 + row * (10 + width);
        imageView.frame = CGRectMake(x, y, width, width);
        ZSPhotoBorwerItem *items = [[ZSPhotoBorwerItem alloc]init];
        items.url = [urlArray[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        items.sourceView = imageView;
        [self.itemArray addObject:items];
        
        [self.view addSubview:imageView];
        
    }
    
}
- (void)click:(UITapGestureRecognizer *)tap{

    ZSPhotoBorwers *photoBrower = [[ZSPhotoBorwers alloc]init];
    photoBrower.itemArrary = [_itemArray copy];
    photoBrower.currentIndex = tap.view.tag;
    
    [photoBrower present];
    
    _photoBrower = photoBrower;
    photoBrower.delegate = self;
    
    _applicationStatusIsHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden{
    
    if (_applicationStatusIsHidden) {
        return YES;
    }
    return NO;
}

- (void)photoBrowerRightOperationActionWithIndex:(NSInteger)index{
    _applicationStatusIsHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)photoBrowerWillDismiss{
    
    _applicationStatusIsHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)photoBrowerWriteSavedPhotoAlbumStatus:(BOOL)success{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end









