//
//  LJMyProfileViewController.m
//  invocation
//
//  Created by fover0 on 2017/6/20.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "LJRouter.h"
#import "UIViewController+LJNavigation.h"

@interface LJMyProfileViewController : UIViewController
@end

@implementation LJMyProfileViewController

LJRouterInit(@"我的个人页",myProfile,(unsigned long)userId)
{
    self =  [super init];
    if (self)
    {
		NSString *title = [NSString stringWithFormat:@"我的页面 id=%lu",userId];
        self.title = title;
    }
    return self;
}

LJRouterInit(@"个人页", myProfile,(NSDictionary*)user)
{
	self =  [super init];
	if (self)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[user class] description]
                                                        message:user.description
                                                       delegate:nil
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil, nil];
		[alert show];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UITabBarController *tabbarController = self.navigationController.viewControllers.firstObject;
    [tabbarController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       if ([obj.ljRouterKey isEqualToString:@"setting"])
       {
           tabbarController.selectedIndex = idx;
           *stop = YES;
           return ;
       }
    }];
}

LJRouterUseAction(loginIfNeed, void, (UIViewController*)curVC, (void(^)(BOOL))finishBlock);
- (void)LJNavigationOpenedByViewController:(__kindof UIViewController *)viewController
{
    // 这里是登录
    action_loginIfNeed_with_curVC_finishBlock(viewController,^(BOOL succeed) {
        if (succeed)
        {
            if ([self.tabBarController.selectedViewController.ljRouterKey isEqualToString:@"setting"])
            {
                [super LJNavigationOpenedByViewController:viewController];
            }
            else
            {
                [viewController.navigationController setViewControllers:@[viewController.navigationController.viewControllers.firstObject,self] animated:YES];
            }
        }
        else
        {
            // login fail do nothing
        }
    });
}

@end
