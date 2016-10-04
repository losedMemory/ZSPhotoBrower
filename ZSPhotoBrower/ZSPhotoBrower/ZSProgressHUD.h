//
//  ZSProgressHUD.h
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/2.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSProgressHUD : UIView

//显示加载圈
+ (instancetype)showHUDAddTo:(UIView *)superView animation:(BOOL)animation;

//加载圈整体的颜色
@property (nonatomic,strong) UIColor *HUDColor;

//加载扇形的颜色  白色
@property (nonatomic,strong) UIColor *sectorColor;

//边框的颜色 白色
@property (nonatomic,strong) UIColor *sectorBoldColor;

//进度范围 0 - 1
@property (nonatomic,assign) CGFloat progress;

//消失
- (void)dismiss;

@end
