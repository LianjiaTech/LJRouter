// 页面 : webview 
LJRouterUsePage(webview, (NSString*)url);
// 页面 : webview 
LJRouterUsePage(webview, (NSString*)htmlString);
// action : 接收js命令
// 接收一个字符串 添加_haha结尾 
LJRouterUseAction(somejscmd, void, (NSString*)str, (LJRouterCallbackBlock)callback);
// action : 设置UIWebView标题 
LJRouterUseAction(setWebViewTitle, void, (UIWebView*)sender, (NSString*)title);
// action : 设置UIWebView标题 
LJRouterUseAction(setWebViewTitle2, void, (LJRouterSenderContext*)sender, (NSString*)title);
