//
//  ZSPhotoBrowerNumLabel.h
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/2.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSPhotoBrowerNumLabel : UILabel

//设置label的字符串
- (void)setCurrentNum:(NSInteger)currentNum totalNum:(NSInteger)totalNum;

@property (nonatomic,assign) NSInteger currentNum;

@property (nonatomic,assign) NSInteger totalNum;

@end
