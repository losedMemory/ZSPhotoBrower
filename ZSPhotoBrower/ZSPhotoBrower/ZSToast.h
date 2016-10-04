//
//  ZSToast.h
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/2.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>
//此类是为了展示对图片操作后的结果信息,例如保存图片后成功信息或者失败信息
@interface ZSToast : UIView

+ (instancetype)shareToast;
//供外界调用
- (void)initWithText:(NSString *)text;

- (void)initWithText:(NSString *)text offsetY:(CGFloat)offsetY;

//供外界调用
- (void)initWithText:(NSString *)text duration:(NSInteger)duration;

- (void)initWithText:(NSString *)text duration:(NSInteger)duration offsetY:(CGFloat)offsetY;


@end
