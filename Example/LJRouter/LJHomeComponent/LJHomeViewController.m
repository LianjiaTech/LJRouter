//
//  LJHomeViewController.m
//  invocation
//
//  Created by fover0 on 2017/6/8.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "LJRouter.h"
#import "LJUrlRouter.h"

@interface LJHomeViewController : UIViewController

@end

@implementation LJHomeViewController

LJRouterInit(@"2017年新版首页",
             Home,
             (NSString*)titlex)
{
    self = [super init];
    if (self)
    {
        self.title = titlex;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100,100,200,100)];
        [btn setTitle:@"push webview with url" forState:0];
        btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100,300,200,100)];
        [btn setTitle:@"push webview urlstring" forState:0];
        btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

- (void)click
{
    [self LJOpenUrlString:@"https://www.lianjia.com"];
}

LJRouterUsePage(webview,(NSString*)htmlString);
- (void)click2
{
    NSArray *urls = @[@"lianjia://somejscmd?str=heihei&callback=callbackFunction",
					  @"lianjia://setWebViewTitle?title=你好",
					  @"lianjia://setWebViewTitle2?title=哈喽",
					  @"lianjia://myProfile?userId=666",
					  @"lianjia://myProfile?user={\"userid\":\"123\"}",];
    NSMutableString *string = [[NSMutableString alloc] initWithString:@"<script>function callbackFunction(message){alert('callback:'+message);}</script>"];

    for (NSString *url in urls)
    {
        [string appendFormat:@"<a href='%@'>%@</a><br/><br/>",url,url];
    }

    open_webview_controller_with_htmlString(self, string);
}

@end

@interface LJHomeViewController (something)
@end

@implementation LJHomeViewController (something)

LJRouterInit(@"泛型测试", objectTypeTest,(NSDictionary<NSString*,NSString*>*)aaa)
{
    return [self init];
}

@end
