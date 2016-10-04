//
//  ZSActionSheet.h
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/4.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActionBlock) (NSInteger buttonIndex);
@interface ZSActionSheet : UIView


- (instancetype)initWithCancelBtnTitle:(NSString *)cancelBtnTitle
                destructiveButtonTitle:(NSString *)destructiveBtnTitle
                     otherBtnTitlesArr:(NSArray *)otherBtnTitlesArr
                           actionBlock:(ActionBlock)ActionBlock;
- (void)show;
- (void)dismiss;

@end
