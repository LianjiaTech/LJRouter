//
//  LJSettingViewController.m
//  invocation
//
//  Created by fover0 on 2017/6/20.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "LJRouter.h"

@interface LJSettingViewController : UIViewController
@end

@implementation LJSettingViewController

LJRouterInit(@"设置页面", setting)
{
    self =  [super init];
    if (self)
    {
        self.title = @"设置";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100,100,200,100)];
        [btn setTitle:@"个人信息" forState:0];
        btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }

    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100,300,200,100)];
        [btn setTitle:@"退出登录" forState:0];
        btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

LJRouterUsePage(myProfile, (unsigned long)userId);
- (void)click
{
    open_myProfile_controller_with_userId(self, 1000);
}

LJRouterUseAction(logout, void);
- (void)click2
{
    action_logout();
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已经退出" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
