//
//  LJLoginViewController.m
//  invocation
//
//  Created by fover0 on 2017/6/20.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "LJRouter.h"
#import "UIViewController+LJNavigation.h"

@interface LJLoginViewController : UIViewController
@property (nonatomic, copy) void(^finishBlock)(BOOL);
@end

@implementation LJLoginViewController

+ (void)initialize
{
    NSLog(@"%s",__func__);
}

LJRouterInit(@"登录页面", login)
{
    self = [super init];
    if (self)
    {
        self.ljNavigationType = LJNavigationTypePresentWithNavigation;
        self.title = @"登录";
    }
    return self;
}

LJRouterRegistAction(@"判断登录状态,弹出登录页面", loginIfNeed, void, (UIViewController*)curVC, (void(^)(BOOL))finishBlock)
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"islogin"] isEqualToString:@"1"])
    {
        if (finishBlock)
        {
            finishBlock(YES);
        }
    }
    else
    {
        LJLoginViewController *vc = [self get_login_controller];
        vc.finishBlock = finishBlock;
        [curVC LJNavigationOpenViewController:vc];
    }
}

LJRouterRegistAction(@"是否登录状态", isLogin, BOOL)
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"islogin"] isEqualToString:@"1"];
}

LJRouterRegistAction(@"退出登录", logout, void)
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"islogin"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100,100,200,100)];
        [btn setTitle:@"login" forState:0];
        btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }

    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100,300,200,100)];
        [btn setTitle:@"cancel" forState:0];
        btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

- (void)click
{
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"islogin"];
    [self closeSelf];
    if (self.finishBlock)
    {
        self.finishBlock(YES);
    }
}

- (void)click2
{
    [self closeSelf];
    if (self.finishBlock)
    {
        self.finishBlock(NO);
    }

}

@end
