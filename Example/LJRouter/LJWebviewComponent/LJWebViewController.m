//
//  LJWebViewController.m
//  invocation
//
//  Created by fover0 on 2017/6/18.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "LJRouter.h"
#import "LJUrlRouter.h"

@interface LJWebViewController : UIViewController<UIWebViewDelegate>
@property (nonatomic, retain) UIWebView *webview;
@property (nonatomic, copy) NSString *htmlString;
@property (nonatomic, copy) NSString *url;
@end

@implementation LJWebViewController

LJRouterInit(@"webview",
             webview,
             (NSString*)url)
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.url = url;
    }
    return self;
}

LJRouterInit(@"webview",
             webview,
             (NSString*)htmlString)
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.htmlString = htmlString;
    }
    return self;
}


LJRouterRegistAction(@"接收js命令// 接收一个字符串 添加_haha结尾",
                     somejscmd,
                     void,(NSString*)str,
                     (LJRouterCallbackBlock)callback)
{
    callback(@"1",NO);
    callback(@"2",NO);
    callback([str stringByAppendingString:@"_haha"],YES);
}

LJRouterRegistAction(@"设置UIWebView标题", setWebViewTitle, void,(UIWebView*)sender,(NSString*)title)
{
	if (![sender isKindOfClass:[UIView class]])
	{
		return;
	}
	UIResponder *responder = sender ;
	while (responder) {
		responder = [responder nextResponder];
		if ([responder isKindOfClass:[UIViewController class]])
		{
			UIViewController *vc = (id)responder;
			vc.title = title;
		}
	}
}

LJRouterRegistAction(@"设置UIWebView标题", setWebViewTitle2, void,(LJRouterSenderContext*)sender,(NSString*)title)
{
    sender.contextViewController.title = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIWebView *webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webview = webview;
    [self.view addSubview:webview];
    webview.delegate = self;


    if (self.url.length)
    {
        [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    }
    else if (self.htmlString.length)
    {
        [webview loadHTMLString:self.htmlString baseURL:nil];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme hasPrefix:@"lianjia"])
    {
        return !
        [[LJRouter sharedInstance] routerUrlString:request.URL.absoluteString
											sender:webView
									     pageBlock:^(__kindof UIViewController *viewController) {
                                           [[LJRouter sharedInstance] openViewController:viewController withSender:self];
                                       }
                                     callbackBlock:^(NSString *key, NSString *value, NSString *data, BOOL complete) {
                                         if (value.length && data.length)
                                         {
                                             NSString *cmd = [[NSString alloc] initWithFormat:@"%@('%@');",value,data];
                                             [self.webview stringByEvaluatingJavaScriptFromString:cmd];
                                         }
                                     }
                                 canNotRouterBlock:nil];
    }
    return YES;
}

@end
