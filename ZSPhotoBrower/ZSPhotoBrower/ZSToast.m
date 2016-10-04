//
//  ZSToast.m
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/2.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSToast.h"
#ifndef ScreenWidth
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#endif

#ifndef ScreenHeight
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#endif
#define ToastMargin 20


@interface ZSToast (){
    
    UIView *_toastView;
    UILabel *_msgLabel;
    BOOL _isShow;
}

@end
@implementation ZSToast

static id toast;

+ (instancetype)shareToast{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toast = [[ZSToast alloc]init];
    });
    
    return toast;
}
//方法一
- (void)initWithText:(NSString *)text{
    //方法一调用方法三
    [self initWithText:text duration:0];
}
//方法二 未使用这个方法
- (void)initWithText:(NSString *)text offsetY:(CGFloat)offsetY{
    //方法二调用方法四
    [self initWithText:text duration:0 offsetY:offsetY];
}
//方法三
- (void)initWithText:(NSString *)text duration:(NSInteger)duration{
    //方法三调用方法四
    [self initWithText:text duration:duration offsetY:0];
}
//方法四
- (void)initWithText:(NSString *)text duration:(NSInteger)duration offsetY:(CGFloat)offsetY{
    
    if (_isShow) {
        return;
    }
    
    if (text == nil || text == NULL || [text isKindOfClass:[NSNull class]] || [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        
        return;
    }
    
    if (duration < 1.f) {
        duration = 1.f;

    }
    _isShow = YES;
    
    //文字信息
    _msgLabel = [[UILabel alloc]init];
    [_msgLabel setTextAlignment:NSTextAlignmentCenter];
    [_msgLabel setText:text];
    [_msgLabel setNumberOfLines:0];
    [_msgLabel setTextColor:[UIColor whiteColor]];
    _msgLabel.font = [UIFont systemFontOfSize:16];
    
    //遮罩视图
    _toastView = [[UIView alloc]init];
    [_toastView setBackgroundColor:[UIColor blackColor]];
    _toastView.layer.cornerRadius = 5.f;
    _toastView.clipsToBounds = YES;
    _toastView.alpha = 0.9f;
    [_toastView addSubview:_msgLabel];
    
    NSDictionary *dict = @{NSFontAttributeName:[_msgLabel font]};
    //??
    
    CGSize size = [text boundingRectWithSize:CGSizeMake(ScreenWidth -ToastMargin, ScreenHeight - ToastMargin) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    CGPoint CenterPoint;
    if (offsetY <= 0 || offsetY >=ScreenHeight) {
        CenterPoint = (CGPoint){ScreenWidth * 0.5,ScreenHeight * 0.5};
    }else{//这个不会调用,因为只有方法三调用方法四,传入的offsetY是0
        CenterPoint = (CGPoint){ScreenHeight * 0.5,offsetY + size.height};
    }
    
    _toastView.bounds = CGRectMake(0, 0, size.width + ToastMargin, size.height + ToastMargin);
    _toastView.center = CenterPoint;
    
    _msgLabel.bounds = CGRectMake(0, 0, size.width, size.height);
    _msgLabel.center = CGPointMake(size.width * 0.5 + ToastMargin * 0.5, size.height * 0.5 +ToastMargin * 0.5);
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:_toastView];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:duration];
    }];
}

- (void)dismiss{
    _isShow = NO;
    [_toastView removeFromSuperview];
}

@end














