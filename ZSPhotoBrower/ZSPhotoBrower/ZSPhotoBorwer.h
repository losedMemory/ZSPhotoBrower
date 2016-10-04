//
//  ZSPhotoBorwer.h
//  ZSPhotoBrower
//
//  Created by 周松 on 16/9/29.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZSPhotoBorwer : NSObject

@property (nonatomic,copy) NSString *url;

@property (nonatomic,strong) UIView *sourceView;

@end


@protocol ZSPhotoBorwerDelegate <NSObject>

//即将消失
- (void)photoBrowerWillDismiss;

//保存图片是否成功
- (void)photoBrowerWriteSavedPhotoAlbumStatus:(BOOL)success;

//右上角按钮的点击
- (void)photoBrowerRightPoerationActionWithIndex:(NSInteger)index;

@end


@interface ZSPhotoBorwers : UIView

//当前图片的下标
@property (nonatomic,assign) NSInteger currentIndex;

//存放图片的模型
@property (nonatomic,strong) NSArray *itemArrary;

//存放ActionSheet弹出框内容:NSString类型
@property (nonatomic,strong) NSMutableArray *actionSheetArray;

//是否需要顶部控件
@property (nonatomic,assign) BOOL isNeesPageNumView;

//是否需要底部控件
@property (nonatomic,assign) BOOL isNeedPageControl;

@property (nonatomic,weak) id <ZSPhotoBorwerDelegate>delegate;

//展现
- (void)present;

//消失
- (void)dismiss;

@end






