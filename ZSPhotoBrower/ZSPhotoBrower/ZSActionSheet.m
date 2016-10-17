//
//  ZSActionSheet.m
//  ZSPhotoBrower
//
//  Created by 周松 on 16/10/4.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSActionSheet.h"

@interface ZSActionSheet ()

@property (nonatomic,copy) ActionBlock actionBlock;

@end
@implementation ZSActionSheet{
    
    NSString *_cancelButtonTitle;
    NSString *_destructiveButtonTitle;
    NSArray  *_otherButtonTitleArray;
    
    UIView   *_bgView;
    UIView   *_coverView;//背景遮罩
}

static id ActionSheet;
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!ActionSheet) {
            ActionSheet = [super allocWithZone:zone];
        }
    });
    return ActionSheet;
    
}

- (instancetype)initWithCancelBtnTitle:(NSString *)cancelBtnTitle destructiveButtonTitle:(NSString *)destructiveBtnTitle otherBtnTitlesArr:(NSArray *)otherBtnTitlesArr actionBlock:(ActionBlock)ActionBlock{
    
    if (self = [super init]) {
        _cancelButtonTitle = cancelBtnTitle;
        _destructiveButtonTitle = destructiveBtnTitle;
        NSMutableArray *titleArray = [NSMutableArray array];
        if (_destructiveButtonTitle.length) {
            [titleArray addObject:_destructiveButtonTitle];
        }
        //获取另一个数组中所有元素
        [titleArray addObjectsFromArray:otherBtnTitlesArr];
        _otherButtonTitleArray = [NSArray arrayWithArray:titleArray];
        _actionBlock = ActionBlock;
        [self setupSubViews];
    }
    return self;
}

#pragma mark --初始化子控件
- (void)setupSubViews{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    
    //遮罩
    UIView *coverView = [[UIView alloc]initWithFrame:self.bounds];
    _coverView = coverView;
    coverView.backgroundColor = [UIColor colorWithRed:30/255.f green:30/255.f blue:30/255.f alpha:1.f];
    coverView.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [coverView addGestureRecognizer:tap];
    [self addSubview:coverView];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:1.f];
    _bgView = bgView;
    CGFloat height = 49 * (_otherButtonTitleArray.count + 1);
    _bgView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, height);
    [self addSubview:bgView];
    
    for (NSInteger i = 0; i < _otherButtonTitleArray.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button setTitle:_otherButtonTitleArray[i] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        if (i == 0 && _destructiveButtonTitle.length) {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
        }
        
        UIImage *image = [UIImage imageNamed:@"actionSheetHighLighted"];
        [button setBackgroundImage:image forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat buttonY = 49 * i;
        button.frame = CGRectMake(0, buttonY, ScreenWidth, 49);
        [_bgView addSubview:button];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectZero];
        lineView.backgroundColor = [UIColor colorWithRed:220/255 green:220/255 blue:220/255 alpha:1];
        lineView.frame = CGRectMake(0, buttonY, ScreenWidth, 0.5);
        [_bgView addSubview:lineView];
        
    }
    
    //取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.tag = _otherButtonTitleArray.count;
    [cancelButton setTitle:_cancelButtonTitle?_cancelButtonTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
    UIImage *image = [UIImage imageNamed:@"actionSheetHighLighted"];
    [cancelButton setBackgroundImage:image forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    CGFloat buttonY = 49 * (_otherButtonTitleArray.count) + 5;
    cancelButton.frame = CGRectMake(0, buttonY, ScreenWidth, 49);
    [_bgView addSubview:cancelButton];
    
    
    
    
}


- (void)buttonClick:(UIButton *)sender{
    if (_actionBlock) {
        _actionBlock(sender.tag);
    }
}
//点击遮罩或者取消按钮移除视图
- (void)dismiss{
    [UIView animateWithDuration:0.3 animations:^{
        _coverView.alpha = 0;
        [_bgView setTransform:CGAffineTransformIdentity];//点击之后让图片会到点击前的位置
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
    }];
}

//显示提示视图
- (void)show{
    _coverView.alpha = 0;
    [_bgView setTransform:CGAffineTransformIdentity];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _coverView.alpha = 0.3;
        [_bgView setTransform:CGAffineTransformMakeTranslation(0, -_bgView.frame.size.height)];
    } completion:^(BOOL finished) {
        
    }];
    
}

@end














