//
//  UIViewController+LJNavigation.m
//  invocation
//
//  Created by fover0 on 2017/6/20.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "UIViewController+LJNavigation.h"
#import <objc/runtime.h>

static LJNavigationConfig *usedConfig;
@implementation LJNavigationConfig

- (void)setup
{
    usedConfig = self;
}

@end

@implementation UIViewController (LJNavigation)

static char navigationTypeKey;
- (void)setLjNavigationType:(LJNavigationType)ljNavigationType
{
    objc_setAssociatedObject(self, &navigationTypeKey, [NSNumber numberWithInteger:ljNavigationType], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LJNavigationType)ljNavigationType
{
    return [objc_getAssociatedObject(self, &navigationTypeKey) integerValue];
}

static char navigationCloseBlockKey;
- (void)setLJNavigationCloseBlock:(void(^)(void))closeBlock
{
    objc_setAssociatedObject(self, &navigationCloseBlockKey, [closeBlock copy], OBJC_ASSOCIATION_COPY);
}

- (void(^)(void))LJNavigationCloseBlock
{
    return objc_getAssociatedObject(self, &navigationCloseBlockKey);
}


static BOOL tryPushOpen(UIViewController *fromVC,UIViewController *toVC,BOOL animated)
{
    if (fromVC.navigationController)
    {
        [fromVC.navigationController pushViewController:toVC animated:animated];
        [toVC setLJNavigationCloseBlock:^{
            [fromVC.navigationController popViewControllerAnimated:animated];
        }];
        return YES;
    }
    else
    {
        return tryPresentWithNavigationOpen(fromVC, toVC,animated);
    }
}

static BOOL tryPresentOpen(UIViewController *fromVC,UIViewController *toVC,BOOL animated)
{
    [fromVC presentViewController:toVC animated:animated completion:nil];
    __weak UIViewController *wvc = toVC;
    [toVC setLJNavigationCloseBlock:^{
        [wvc dismissViewControllerAnimated:animated completion:nil];
    }];
    return YES;
}

static BOOL tryPresentWithNavigationOpen(UIViewController *fromVC,UIViewController *toVC,BOOL animated)
{
    Class navClass = Nil;
    if ([usedConfig.navigationControllerClass isSubclassOfClass:[UINavigationController class]])
    {
        navClass = usedConfig.navigationControllerClass;
    }
    else
    {
        navClass = [UINavigationController class];
    }

    UINavigationController *navVC = [[navClass alloc] initWithRootViewController:toVC];
    navVC.modalPresentationStyle = toVC.modalPresentationStyle;
    [fromVC presentViewController:navVC animated:animated completion:nil];

    __weak UINavigationController *weakNavVC = navVC;

    [toVC setLJNavigationCloseBlock:^{
        UINavigationController *strongNavVC = weakNavVC;
        [strongNavVC dismissViewControllerAnimated:animated completion:nil];
    }];

    return YES;
}

// 自己被别的vc打开时调用  定制当前vc的显示方式 或者弹出登录框等操作
- (void)LJNavigationOpenedByViewController:(__kindof UIViewController*)viewController
{
    LJNavigationType type = self.ljNavigationType;
    BOOL animated = !(type & LJNavigationTypeNoAnimation);
    if (!animated)
    {
        type = type - LJNavigationTypeNoAnimation;
    }

    switch (type) {
        case LJNavigationTypePush :
            tryPushOpen(viewController,self,animated);
            break;
        case LJNavigationTypePresent :
            tryPresentOpen(viewController, self,animated);
            break;
        case LJNavigationTypePresentWithNavigation :
            tryPresentWithNavigationOpen(viewController, self,animated);
            break;
        default:
            // do nothing
            break;
    }
}

// 要打开别的vc时调用
- (void)LJNavigationOpenViewController:(__kindof UIViewController*)nextViewController
{
    [nextViewController LJNavigationOpenedByViewController:self];
}

// 当要打开一个vc时  没有当前vc时调用
+ (void)LJNavigationOpenViewController:(__kindof UIViewController*)nextViewController
{
    UIViewController *curVC = usedConfig.findTopViewControllerBlock ? usedConfig.findTopViewControllerBlock() : nil;
    if (!curVC)
    {
        id appdelegate = [UIApplication sharedApplication].delegate;
        UIWindow *window = nil;
        // 一般默认生成appdelegate的window属性
        if ([appdelegate respondsToSelector:@selector(window)])
        {
            window = [appdelegate performSelector:@selector(window)];
        }
        // 如果没有window属性
        else
        {
            if ([UIApplication sharedApplication].windows.count > 0)
            {
                window = [UIApplication sharedApplication].windows[0];
            }
        }
        curVC = window.rootViewController;
        while (1) {
            if (curVC.presentingViewController && ![curVC.presentingViewController isKindOfClass:[UIAlertController class]])
            {
                curVC = curVC.presentingViewController;
            }
            else if ([curVC isKindOfClass:[UINavigationController class]])
            {
                UINavigationController *vc = (id)curVC;
                curVC = vc.topViewController;
            }
            else if ([curVC isKindOfClass:[UITabBarController class]])
            {
                UITabBarController *vc = (id)curVC;
                curVC = vc.selectedViewController;
            }
            else
            {
                break;
            }
        }
    }
    if (curVC)
    {
        [curVC LJNavigationOpenViewController:nextViewController];
    }
    else
    {
        [nextViewController LJNavigationOpenedByViewController:nil];
    }
}

- (void)closeSelf
{
    void(^closeBlock)(void) = [self LJNavigationCloseBlock];
    if (closeBlock)
    {
        closeBlock();
    }
    else
    {
        BOOL animated = !(self.ljNavigationType & LJNavigationTypeNoAnimation);
        if (self.navigationController)
        {
            if (self.navigationController.viewControllers.count == 1)
            {
                [self.navigationController dismissViewControllerAnimated:animated completion:nil];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:animated];
            }
        }
        else if (self.presentedViewController)
        {
            [self dismissViewControllerAnimated:animated completion:nil];
        }
    }
}


@end
