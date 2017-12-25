//
//  UIViewController+LJNavigation.h
//  invocation
//
//  Created by fover0 on 2017/6/20.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LJNavigationType)
{
    LJNavigationTypePush                    = 0,
    LJNavigationTypePresent                 = 1,
    LJNavigationTypePresentWithNavigation   = 2,

    LJNavigationTypeNoAnimation             = 1 << 16,
};

// 对于导航的一些配置
@interface LJNavigationConfig : NSObject

@property (nonatomic, retain) Class navigationControllerClass;
@property (nonatomic, copy) __kindof UIViewController*(^findTopViewControllerBlock)(void);

- (void)setup;

@end

@interface UIViewController (LJNavigation)

@property (nonatomic, assign) LJNavigationType ljNavigationType;

// 自己被别的vc打开时调用  定制当前vc的显示方式 或者弹出登录框等操作
- (void)LJNavigationOpenedByViewController:(__kindof UIViewController*)viewController;

// 要打开别的vc时调用
- (void)LJNavigationOpenViewController:(__kindof UIViewController*)nextViewController;

// 当要打开一个vc时  没有当前vc时调用
+ (void)LJNavigationOpenViewController:(__kindof UIViewController*)nextViewController;

- (void)closeSelf;

@end
