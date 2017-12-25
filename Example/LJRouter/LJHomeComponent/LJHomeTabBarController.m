//
//  LJHomeTabBarController.m
//  invocation
//
//  Created by fover0 on 2017/6/20.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "LJRouter.h"
#import "UIViewController+LJNavigation.h"
@interface LJHomeTabBarController : UITabBarController

@end

@implementation LJHomeTabBarController

LJRouterUsePageObj(Home, (NSString*)titlex);
LJRouterUsePageObj(setting);

@end

@interface LJHomeTabBarController (something)

@end

@implementation LJHomeTabBarController(something)

LJRouterInit(@"首页tabbar",homeTabbar)
{
    self = [self init];
    if (self)
    {
        NSArray *viewcontrollers = @[
                                     get_Home_controller_with_titlex(@"我就是个title"),
                                     get_setting_controller(),
                                     ];

        self.viewControllers = viewcontrollers;
    }
    return self;
}

@end
