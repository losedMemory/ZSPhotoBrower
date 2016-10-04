//
//  ZSPhotoBrowerCell.h
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/2.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSPhotoBrowerImageView.h"

typedef void(^SingleTap)() ;
@interface ZSPhotoBrowerCell : UICollectionViewCell

- (void)sd_ImageWithURL:(NSString *)url placeHolder:(UIImage *)placeHolder;
//单击图片时被调用
@property (nonatomic,copy)SingleTap singleTap;

@property (nonatomic,strong) ZSPhotoBrowerImageView *photoBrowerImageView;


@end
