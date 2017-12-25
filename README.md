#LJRouter
## 1.接入
### 1.1 拉取代码
推荐使用cocoapods进行接入，
在项目的Podfile中添加如下代码
```ruby
pod 'LJRouter'
```
然后执行 pod install/update
### 1.2 编译配置
在项目的BuildPhases的设置中，点击左上角加号，再点击New Run Script Phase.在新出现的Run Script添加如下代码。
```powershell
${PODS_ROOT}/LJRouter/build /LJAutogenComponentHeaders
```
LJAutogenComponentHeaders 可以修改为您需要的名字，后续自动生成的代码会导出到你的项目下该名字的目录中。
`注意:文件夹只有以Module结尾时被认为是一个模块,该文件夹下的文件才可以生成头文件(递归)`
### 1.3 添加文件
进行过 1.1 和 1.2 步骤之后，编译您的代码，然后您会在项目的目录下发现 1.2 中的文件夹，在xcode的源码管理页面中，选择Add files to "xxxxx"，然后选择Create folder references，去掉target选项，再选择 步骤1.2 的文件夹，点击Add.后续自动生成的头文件就会出现在该文件夹中了。
`注意:请不要直接引用自动生成的头文件`

### 1.4 跳转页面配置
默认路由只处理分发消息，不处理跳转逻辑，如果搭配LJNavigation使用，请在AppDelegate中添加以下代码。
```objectivec
[[LJRouter sharedInstance] setOpenControllerWithContextBlock:^(UIViewController *vc, LJRouterSenderContext *senderContext) {
    if (senderContext)
    {
        [senderContext.contextViewController LJNavigationOpenViewController:vc];
    }
    else
    {
        [UIViewController LJNavigationOpenViewController:vc];
    }
}];
```
### 1.5 自定义类型配置(可选)
LJRouter默认支持 数字与字符串的转换，如果您希望将一些其他类型的参数通过外部字符串调用，则需要主动注册一些解析函数，下面的例子是注册一个Json字符串转NSDictionary的例子
```objectivec
[[LJRouter sharedInstance] addParamConvertTypeBlock:^LJInvocationCenterConvertResult *(id value, NSString *typeName, NSString *typeEncoding) {
    if ([typeEncoding isEqualToString:@"@"]
        && [typeName hasPrefix:NSStringFromClass([NSDictionary class])])
    {
        NSData *stringData = [value dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:stringData options:0 error:nil];
        if ([json isKindOfClass:[NSDictionary class]])
        {
            return [LJInvocationCenterConvertResult resultWithRetainObj:json];
        }
    }
    return nil;
}];
```



## 2 使用
### 2.1 注册
#### 2.1.1 页面注册
注册方式如下
```objectivec
LJRouterInit(@"注释", 页面Key, (类型1)参数名1, (类型2)参数名2, ...) // 没有参数可以不写
```
在某ViewController的类中写入以下代码即可完成详情页的注册
```objectivec
LJRouterInit(@"详情页面", detailPage, (NSString*)someId)
{
    self = [self init];
    if (self)
    {
        // 初始化代码
    }
    return self;
}
```
#### 2.1.2 action注册
注册方式如下
```objectivec
LJRouterInit(@"注释", 页面Key, 返回值类型, (类型1)参数名1, (类型2)参数名2, ...) // 没有参数可以不写
```
在任意类的代码中加入如下代码，即可完成一个判断登录状态action的注册.
``` objectivec
LJRouterRegistAction(@"判断是否登录", isLogin, BOOL)
{
    return _isLogin;
}
```

#### 2.1.3 注册参数类型的支持
以上两种注册方式支持任意类型，包括block等.
1.另外如果您需要某Action与JS通信并返回值，则需要声明一个LJRouterCallbackBlock的参数，调用该参数可以将返回值传递回JS
``` objectivec
LJRouterRegistAction(@"接收js命令", somejscmd,
                     void, (NSString*)orignstring,
                     (LJRouterCallbackBlock)callback)
{
    callback([orignstring stringByAppendingString:@"_hello"], YES);
}
```

2.默认要求外部传递所有参数才可通过验证进入到注册的函数，如果您有一个参数不是必须的，则声明为 __nullable即可.(如果是值类型，nullable的变量会默认传0，或者{0,0}这样的结构体)
```objectivec
LJRouterInit(@"详情页面", detailPage, (NSString*)someId, (__nullable NSString*)title)
{
    self = [self init];
    if (self)
    {
        if (title)
        {
            self.title = title;
        }
        // 初始化代码
    }
    return self;
}
```
3.如果你的某个注册函数，需要调用者，例如webview中调用设置页面title的action，那么这个action需要声明一个sender参数来接收调用方，sender类型可以是任意UIResponder的子类，或者声明为LJRouterSenderContext，如果直接声明为UIResponder的子类你需要对sender类型进行判断再进行相关的操作。

使用LJRouterSenderContext方式如下
```objectivec
LJRouterRegistAction(@"设置UIWebView标题", setWebViewTitle2,
                     void, (LJRouterSenderContext*)sender, (NSString*)title)
{
    sender.contextViewController.title = title;
}
```
使用自定义UIResponder子类方式如下
```objectivec
LJRouterRegistAction(@"设置UIWebView标题",  setWebViewTitle,
                     void, (UIWebView*)sender, (NSString*)title)
{
    if (![sender isKindOfClass:[UIView class]])
    {
        return;
    }
    UIResponder *responder = sender ;
    while (responder)
    {
        responder = [responder nextResponder];
        if ([responder isKindOfClass:[UIViewController class]])
        {
            UIViewController *vc = (id)responder;
            vc.title = title;
        }
    }
}
```
#### 2.1.4 注册key的注意事项
1.请注意 key会编译为函数的一部分，所以只支持数字字符下划线.
2.不同的页面注册相同的key会在router启动阶段报错以保证安全.
3.同一个class可以对同一个key注册多次，但是需要有不同的参数列表，类似java的重载，但是如果某一个参数列表去掉__nullable的参数与另一参数列表相同的话，则有可能发生预期外的行为.
4.外部调用时，会忽略Key的大小写.
#### 2.1.5 注册的附加属性
注册之后会默认生成文档，您可以在宏的第一个参数中填写更详尽的解释，同时如果有需求，您也可以为返回值和某个参数单独添加注释，这些注释只会在debug版本使用，并不会增加您发布版本的体积.
使用方式如下
```objectivec
LJRouterRegistAction(@"attr测试action有参数",  attr_action_1,
                     NSInteger, (NSString*)something)
{
    LJRouterReturnDescription(@"just return int");//为返回值加注释
    LJRouterParamDescription(something, @"something ");//为参数加注释
    return 0;
}
```
生成文档如下
```objectivec
// action : attr测试action有参数
// @param something something
// @return NSInteger just return int
LJRouterUseAction(attr_action_1, NSInteger, (NSString*)something);
```


### 2.2 模块间调用
在-步骤2.1-注册过之后，build项目即可在 -步骤1.2- 设定的文件夹中产生出对应的头文件，示例如下:
```objectivec
// 页面 : // webview// 外部url
LJRouterUsePage(webview, (NSString*)url);
// action : // 接收js命令// 接收一个字符串 添加_haha结尾
LJRouterUseAction(somejscmd, void, (NSString*)str, (LJRouterCallbackBlock)callback);
// action : // 设置UIWebView标题
LJRouterUseAction(setWebViewTitle, void, (UIWebView*)sender, (NSString*)title);
```
####2.2.1 跳转页面
直接复制头文件中的代码 到你的代码中即可调用 open_Key_controller_的c函数进行跳转 例如
```objectivec
LJRouterUsePage(webview, (NSString*)url);
- (void)click
{
    NSString *url = @"xxxxxx";
    open_webview_controller_with_htmlString(self, url);
}
```
#### 2.2.2 获取页面对象
如果你想使用某一个页面的对象，而不是直接跳转，可以拷贝头文件的代码后面加Obj结尾，即可调用get_key_controller_的c函数进行获取 例如
```objectivec
LJRouterUsePageObj(webview, (NSString*)url);
- (void)click2
{
    NSString *url = @"xxxxxx";
    UIViewController *webVC = get_webview_controller_with_url(url);
    //  do something ...
}
```
#### 2.2.3 调用action
同2.2.1直接复制之后会产生 action_key_xxxx的c函数，直接调用即可

### 2.3 外部调用/动态调用
动态调用请使用下面函数进行调用
```objectivec
- (BOOL)routerKey:(NSString *)key
             data:(NSDictionary *)data
           sender:(UIResponder *)sender
        pageBlock:(void(^)(__kindof UIViewController* viewController))pageBlock
    callbackBlock:(void(^)(NSString *key,
                           NSString *value,
                           NSString *data,
                           BOOL complete))callbackBlock
canNotRouterBlock:(void(^)(void))canNotRouterBlock;

- (BOOL)routerUrlString:(NSString *)url
                 sender:(UIResponder *)sender
              pageBlock:(void(^)(__kindof UIViewController* viewController))pageBlock
          callbackBlock:(void(^)(NSString *key,
                                 NSString *value,
                                 NSString *data,
                                 BOOL complete))callbackBlock
      canNotRouterBlock:(void(^)(void))canNotRouterBlock;

```
以上两个函数的区别在于一个接受 key+data形式为数据 一个接受url为数据，内部实现上，url会转化为key+data的形式，默认拆解方式为，问号前面的部分为key，query部分拆解为data。

相同的参数部分
**sender**:传入触发该action的UIResponder的子类。
**pageBlock**:是该key分发成功并且为页面时的回调，你应该在这里进行跳转.
**callbackBlock**:分发成功并且存在callbackblock时的回调，一般用该block与webview/js通讯
**canNotRouterBlock**:是不能被分发时的回调

webview拦截request的通讯方式实现如下
```objectivec
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
                                             callbackBlock:^(NSString *key,
                                                             NSString *value,
                                                             NSString *data,
                                                             BOOL complete) {
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
```

## 3 导出文档的二次开发

你可以对导出文档部分进行二次开发，最便捷的方式是在项目中新建一个mac的target，然后将LJRouter/Export/下面的文件加入到target中，然后新建自定义的导出文档的文件，你可以使用 LJRouterExportModule.h中的loadAllRegItemByPath函数读取所有的注册信息.你需要自行管理文档文件，二次开发只提供的基础的读取注册信息的功能.

