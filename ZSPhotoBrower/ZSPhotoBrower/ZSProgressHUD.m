//
//  ZSProgressHUD.m
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/2.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSProgressHUD.h"

@interface ZSProgressHUD (){
    
    CGFloat       _width;
    CGFloat       _height;
    CGFloat       _bordLineWidth;
    CAShapeLayer *_sectorLayer;
    CAShapeLayer *_borderLayer;
    UIBezierPath *_sectorBezierPath;
}

@end

static CGSize _superViewSize;
static bool _animated;
@implementation ZSProgressHUD

+ (instancetype)showHUDAddTo:(UIView *)superView animation:(BOOL)animation{
    _animated = animation;
    ZSProgressHUD *hud = [[self alloc]initWithSuperView:superView];
    
    [superView addSubview:hud];
    
    return hud;
}

- (instancetype)initWithSuperView:(UIView *)superView{
    //断言,前面是判断条件 ,如果不符合判断条件就会自动打印后面的语句,只在debug版本中起作用
    NSAssert(superView, @"superView can not be nil");
    
    BOOL isOk = [self judgeSuperViewHasFrame:superView];
    
    NSAssert(isOk, @"superView needs frame");
    
    _superViewSize = CGSizeMake(superView.frame.size.width, superView.frame.size.height);
    
    return [self init];
}

///判断父控件是否为空或不合理
- (BOOL)judgeSuperViewHasFrame:(UIView *)superView{
    if (superView.frame.size.width <= 0 || superView.frame.size.height <= 0) {
        return NO;
    }
    return YES;
}

- (instancetype)init{
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self initDefaultData];
    }
    
    return self;
}

///初始化默认的数据
- (void)initDefaultData{
    
    _width = 22;
    _height = _width;
    _bordLineWidth = 1.5f;
    _HUDColor = [UIColor whiteColor];
    _sectorColor = _HUDColor;
    _sectorBoldColor = _HUDColor;
    _progress = 0.f;
    
    [self loadSubViews];
}

///加载所有子视图
- (void)loadSubViews{
    
    self.frame = CGRectMake(0, 0, (_width + _bordLineWidth * 2) * 2, (_height + _bordLineWidth * 2 * 2));
    
    self.center = CGPointMake(_superViewSize.width * 0.5, _superViewSize.height * 0.5);
    
    //1.扇形
    CAShapeLayer *sectorLayer = [CAShapeLayer layer];
    sectorLayer.fillColor = nil;
    //填充颜色
    sectorLayer.strokeColor = _sectorBoldColor.CGColor;
    sectorLayer.lineWidth = _width;
    _sectorLayer = sectorLayer;
    [self.layer addSublayer:sectorLayer];
    
    //2.边框
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.fillColor = nil;
    borderLayer.strokeColor = _sectorBoldColor.CGColor;
    borderLayer.path = [[UIBezierPath bezierPathWithArcCenter:CGPointMake(_width + _bordLineWidth * 2, _height + _bordLineWidth * 2) radius:(_width + _bordLineWidth * 2) startAngle:0 endAngle:M_PI  * 2 clockwise:YES]CGPath];
    borderLayer.lineWidth = _bordLineWidth;
    _borderLayer = borderLayer;
    [self.layer addSublayer:borderLayer];
    
}

- (void)setProgress:(CGFloat)progress{
    if (progress > 1) {
        return;
    }
    _sectorBezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_width + _bordLineWidth * 2, _height + _bordLineWidth *2) radius:_width * 0.5 startAngle:-M_PI_2 endAngle:-M_PI_2 + progress *M_PI * 2 clockwise:YES];
    _sectorLayer.path = _sectorBezierPath.CGPath;
    
    if (progress == 1) {
        if (!_animated) {
            [self removeFromSuperview];
            return;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)setHUDColor:(UIColor *)HUDColor{
    _sectorLayer.strokeColor = HUDColor.CGColor;
    _borderLayer.strokeColor = HUDColor.CGColor;
    
}

- (void)setSectorBoldColor:(UIColor *)sectorBoldColor{
    _borderLayer.strokeColor = sectorBoldColor.CGColor;
}

- (void)setSectorColor:(UIColor *)sectorColor{
    _sectorLayer.strokeColor = sectorColor.CGColor;
    
}

- (void)dismiss{
    [self removeFromSuperview];
}

@end













