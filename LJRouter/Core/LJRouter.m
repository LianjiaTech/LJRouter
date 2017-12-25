//
//  LJRouter.m
//  invocation
//
//  Created by fover0 on 2017/5/28.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld_images.h>
#import <objc/runtime.h>

#ifndef __LP64__
	#define section_ section
	#define mach_header_ mach_header
#else
	#define section_ section_64
	#define mach_header_ mach_header_64
#endif

#import "LJRouter.h"
#import "LJInvocationCenter.h"


#define LJRouterCallbackBlockName @"LJRouterCallbackBlock"

@implementation UIViewController(LJRouter)

static char ljRouterKeyKey;
- (void)setLjRouterKey:(NSString *)ljRouterKey
{
    objc_setAssociatedObject(self, &ljRouterKeyKey, [ljRouterKey copy], OBJC_ASSOCIATION_RETAIN);
}

- (NSString*)ljRouterKey
{
    return objc_getAssociatedObject(self, &ljRouterKeyKey);
}

@end

@interface LJRouterSenderContext()

// 原始sender
@property (nonatomic, retain) UIResponder *originSender;

// 以下函数 会按照originSender本身以及nextResponder依次寻找命中该类型的对象
@property (nonatomic, retain) UIView *contextView;
@property (nonatomic, retain) UIViewController *contextViewController;
@property (nonatomic, retain) UIWindow *contextWindow;
@property (nonatomic, retain) id<UIApplicationDelegate> contextAppDelegate;
@property (nonatomic, retain) UIApplication *contextAppliaction;

@end

@implementation LJRouterSenderContext

- (instancetype)initWithSender:(UIResponder*)sender
{
    self = [super init];
    if (self)
    {
        self.originSender = sender;
        [self loadResponderWithSender:sender];
    }
    return self;
}

- (void)loadResponderWithSender:(UIResponder*)sender
{
    UIResponder *r = sender;
    while (r) {
        if ([r isKindOfClass:[UIView class]])
        {
            if (!_contextView)
            {
                _contextView = (UIView*)r;
                _contextWindow = _contextView.window;
            }
        }
        else if ([r isKindOfClass:[UIViewController class]])
        {
            if (!_contextViewController)
            {
                _contextViewController = (UIViewController*)r;
            }
        }
        else if ([r isKindOfClass:[UIApplication class]])
        {
            if (!_contextAppliaction)
            {
                _contextAppliaction = (UIApplication*)r;
                _contextAppDelegate = _contextAppliaction.delegate;
            }
        }

        r = r.nextResponder;
    }
}

@end


@interface LJRouter ()
{
	void(^_openControllerBlock)(UIViewController*vc,id sender);
    void(^_openControllerWithSenderBlock)(UIViewController*vc,LJRouterSenderContext *senderContext);
    LJRouterCheckPolicy _checkPolicy;
    NSArray *_checkPolicyModules;
}

@property (nonatomic, retain) LJInvocationCenter *pageInvocationCenter;
@property (nonatomic, retain) LJInvocationCenter *actionInvocationCenter;
@end

static NSMutableDictionary *allKeyMethods = nil;

@implementation LJRouter

@synthesize convertManager = _convertManager;

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initPrivate];
    });
    return instance;
}

- (void)loadAllPageProperty
{
    LJRouterConvertManager *convertManager = [[LJRouterConvertManager alloc] init];
    _convertManager = convertManager;

    LJInvocationCenter *pageCenter = [[LJInvocationCenter alloc] init];
    _pageInvocationCenter = pageCenter;
    _pageInvocationCenter.convertManager = convertManager;

    LJInvocationCenter *actionCenter = [[LJInvocationCenter alloc] init];
    _actionInvocationCenter = actionCenter;
    _actionInvocationCenter.convertManager = convertManager;

    uint32_t count =  _dyld_image_count();
    for (uint32_t i = 0 ; i < count ; i++)
    {
        const struct mach_header_* header = (void*)_dyld_get_image_header(i);
        unsigned long size = 0;
        // 注册所有的vc
        uint8_t *data = getsectiondata(header, "__DATA", "__LJRouter",&size);
        if (data && size > 0)
        {
            struct LJRouterRegister *items = (struct LJRouterRegister*)data;
            uint32_t count = (uint32_t)(size / sizeof(struct LJRouterRegister));
            for (uint32_t i = 0 ; i < count ; i ++)
            {
                NSMutableString *methodKeyTypeVarName = [[NSMutableString alloc] initWithString:items[i].returnTypeName];
                NSMutableArray *params = nil;
                if (items[i].paramscount)
                {
                    params = [[NSMutableArray alloc] init];
                    for (uint32_t j = 0 ; j < items[i].paramscount ; j ++)
                    {
                        BOOL isRequire = items[i].params[j].isRequire;
                        if ([items[i].params[j].typeName isEqualToString:LJRouterCallbackBlockName])
                        {
                            isRequire = NO;
                        }

                        LJInvocationCenterItemParam *param =
                        [[LJInvocationCenterItemParam alloc] initWithName:items[i].params[j].name.lowercaseString
                                                                 typeName:items[i].params[j].typeName
									 typeEncoding:[NSString stringWithFormat:@"%s",items[i].params[j].typeEncoding]
                                                                isRequire:isRequire
                                                                     info:nil];

                        [params addObject:param];

                        [methodKeyTypeVarName appendString:items[i].params[j].typeName];
                        [methodKeyTypeVarName appendString:items[i].params[j].name];
                    }
                }

                NSMutableArray *methodNames = allKeyMethods[items[i].key.lowercaseString];
                if (!methodNames)
                {
                    methodNames = [[NSMutableArray alloc] init];
                    allKeyMethods[items[i].key.lowercaseString] = methodNames;
                }
                [methodNames addObject:[methodKeyTypeVarName stringByReplacingOccurrencesOfString:@" " withString:@""]];

                LJInvocationCenter *center = items[i].isAction ? actionCenter : pageCenter;

                NSString *functionName = [[NSString alloc] initWithUTF8String:items[i].objcFunctionName];
                NSRange range = [functionName rangeOfString:@" "];
                NSString *className = [functionName substringWithRange:NSMakeRange(2, range.location - 2)];
                range = [className rangeOfString:@"("];
                if (range.length)
                {
                    className = [className substringToIndex:range.location];
                }

                LJInvocationCenterItemRule *rule =
                [[LJInvocationCenterItemRule alloc] initWithSelector:NSSelectorFromString(items[i].selName)
                                                      returnTypeName:items[i].returnTypeName
                                                  returnTypeEncoding:[NSString stringWithUTF8String:items[i].returnTypeEncoding]
                                                              params:params];

                [center addInvocationWithKey:items[i].key.lowercaseString
                                      target:NSClassFromString(className)
                                        rule:rule];
            }
            break;
        }
    }
}

BOOL LJRouterCheckMethodType(NSString *key,
                             NSString *returnTypeName,
                             struct LJRouterRegisterParam* originParams,
                             uint32_t paramsCount,
                             NSString **errorMessage)
{
    NSMutableString *methodName = [[NSMutableString alloc] initWithString:returnTypeName];
    for (uint32_t i = 0 ; i < paramsCount ; i++)
    {
        struct LJRouterRegisterParam *param = originParams + i;
        [methodName appendString:param->typeName];
        [methodName appendString:param->name];
    }
    NSString *methodNameComp = [methodName stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSArray *methodNamesArray = [allKeyMethods valueForKey:key.lowercaseString];
    for (NSString *name in methodNamesArray)
    {
        if ([name isEqualToString:methodNameComp])
        {
            return YES;
        }
    }
    if (errorMessage)
    {
        *errorMessage = @"参数类型或变量名不匹配,请检查";
    }

    return NO;

}

- (BOOL)checkInModules:(NSString*)filePath
{
    if (self.checkPolicyModules.count == 0)
    {
        return YES;
    }

    NSArray *paths = [filePath componentsSeparatedByString:@"/"];
    for (NSString *path in paths)
    {
        for (NSString *module in self.checkPolicyModules)
        {
            if ([path isEqualToString:module])
            {
                return YES;
            }
        }
    }
    return NO;
}

- (void)checkAllMethodTypeName
{
    uint32_t count =  _dyld_image_count();
    for (uint32_t i = 0 ; i < count ; i++)
    {
        const struct mach_header_* header = (void*)_dyld_get_image_header(i);
        unsigned long size = 0;
        // 检查所有的函数类型
        uint8_t *data = getsectiondata(header, "__DATA", "__LJRouterUseINF",&size);
        if (data && size > 0)
        {
            struct LJRouterUseInfo* infos = (void*)data;
            uint32_t count = (uint32_t)(size / sizeof(struct LJRouterUseInfo));
            NSMutableString *alertMessage = nil;
            for (uint32_t i = 0 ; i < count ; i ++)
            {
                struct LJRouterUseInfo *info = infos + i;
                NSString *filePath = [NSString stringWithUTF8String:info->filePath];
                if (![self checkInModules:filePath])
                {
                    continue;
                }

                NSString *message = nil;
                BOOL check =
                LJRouterCheckMethodType(info->key,
                                        info->returnTypeName,
                                        info->params,
                                        info->paramCount,
                                        &message);
                if (!check)
                {
                    if (self.checkPolicy == LJRouterCheckPolicyAssert)
                    {
                        void** addr = (void**)info->assertBlock;
                        void(^block)(NSString*) = (__bridge id)*addr;
                        block(message);
                    }
                    else if (self.checkPolicy == LJRouterCheckPolicyConsole)
                    {
                        NSLog(@"文件 %s 行号 %llu",info->filePath,info->lineNumber);
                    }
                    else if (self.checkPolicy == LJRouterCheckPolicyAlert)
                    {
                        if (!alertMessage)
                        {
                            alertMessage = [[NSMutableString alloc] init];
                        }

                        NSString *file = [[NSString alloc] initWithUTF8String:info->filePath];
                        NSArray *comp = [file componentsSeparatedByString:@"/"];

                        [alertMessage appendFormat:@"%@:%llu %@\n",comp.lastObject,info->lineNumber,info->key];
                    }
                }
            }
            if (alertMessage.length)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"校验错误" message:alertMessage delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self)
    {
		_openControllerBlock = nil;
        allKeyMethods = [[NSMutableDictionary alloc] init];
        _checkPolicy = LJRouterCheckPolicyAssert;
        _checkPolicyModules = nil;
    }
    return self;
}

- (void)loadAndCheck
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadAllPageProperty];
        [self checkAllMethodTypeName];
    });
}

- (LJInvocationCenter*)actionInvocationCenter
{
    [self loadAndCheck];
    return _actionInvocationCenter;
}

- (LJInvocationCenter*)pageInvocationCenter
{
    [self loadAndCheck];
    return _pageInvocationCenter;
}

- (LJRouterConvertManager*)convertManager
{
    [self loadAndCheck];
    return _convertManager;
}

- (instancetype)init
{
    return [[self class] sharedInstance];
}

- (BOOL)canRouterKey:(NSString *)key data:(NSDictionary *)data
{
    NSInvocation *pageInvocation =
    [self.pageInvocationCenter invocationWithKey:key.lowercaseString
                                            data:data
                                         outItem:nil
                                         outRule:nil];
    if (pageInvocation)
    {
        return YES;
    }

    NSInvocation *actionInvocation =
    [self.actionInvocationCenter invocationWithKey:key.lowercaseString
                                              data:data
                                           outItem:nil
                                           outRule:nil];
    if (actionInvocation)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)routerKey:(NSString *)key
             data:(NSDictionary *)data
           sender:(UIResponder *)sender
        pageBlock:(void (^)(__kindof UIViewController *))pageBlock
    callbackBlock:(void (^)(NSString *, NSString *, NSString *, BOOL))callbackBlock
canNotRouterBlock:(void (^)(void))canNotRouterBlock
{
    NSInvocation *invocation = [self.pageInvocationCenter invocationWithKey:key.lowercaseString
                                                                       data:data
                                                                    outItem:nil
                                                                    outRule:nil];
    if (invocation)
    {
        [invocation invoke];
        __unsafe_unretained UIViewController *unsafeVC = nil;
        [invocation getReturnValue:&unsafeVC];
        UIViewController *ret = unsafeVC;
        if (pageBlock)
        {
            pageBlock(ret);
        }
        return YES;
    }

    LJInvocationCenterItem *outItem = nil;
    LJInvocationCenterItemRule *outRule = nil;

	NSMutableDictionary *actionData = [[NSMutableDictionary alloc] initWithDictionary:data];
    actionData[@"sender"] = sender;
    invocation = [self.actionInvocationCenter invocationWithKey:key.lowercaseString
                                                           data:actionData
                                                        outItem:&outItem
                                                        outRule:&outRule];

    if (invocation)
    {
        __block BOOL hasCallbackBlock = NO;
        [outRule.paramas enumerateObjectsUsingBlock:^(LJInvocationCenterItemParam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            NSString *senderClass = NSStringFromClass([LJRouterSenderContext class]);

            if([obj.typeName hasPrefix:senderClass]
               && [obj.name.lowercaseString isEqualToString:@"sender"])
            {
                __unsafe_unretained id originSender = nil;
                [invocation getArgument:&originSender atIndex:idx+2];
                LJRouterSenderContext *senderContext = [[LJRouterSenderContext alloc] initWithSender:originSender];
                [invocation setArgument:&senderContext atIndex:idx+2];
                [invocation retainArguments];
            }
            else if ([obj.typeName isEqualToString:LJRouterCallbackBlockName])
            {
                hasCallbackBlock = YES;
                __unsafe_unretained id unsafe_data = nil;
                [invocation getArgument:&unsafe_data atIndex:idx+2];
                id data = unsafe_data;

                void (^_callbackBlock)(NSString *,NSString *,NSString *,BOOL) = [callbackBlock copy];

                void(^block)(NSString*,BOOL) = ^(NSString *blockData,BOOL complete) {
                    if (_callbackBlock)
                    {
                        _callbackBlock(obj.name,data,blockData,complete);
                    }
                };
                block = [block copy];
                [invocation setArgument:&block atIndex:idx+2];
                [invocation retainArguments];
            }
        }];
        [invocation invoke];


        if (!hasCallbackBlock && callbackBlock)
        {
            callbackBlock(nil,nil,nil,YES);
        }
        return YES;
    }

    if (canNotRouterBlock)
    {
        canNotRouterBlock();
    }
    return NO;
}

- (LJInvocationCenterItem*)invocationItemForKey:(NSString*)key
{
    LJInvocationCenterItem *item = [self.pageInvocationCenter getInvocationCenterItemByKey:key.lowercaseString];
    if (item)
    {
        return item;
    }
    else
    {
        return [self.actionInvocationCenter getInvocationCenterItemByKey:key.lowercaseString];
    }
}

- (void)openViewController:(UIViewController *)vc withSender:(id)sender
{
    if (!vc)
    {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (self.openControllerBlock)
    {
        self.openControllerBlock(vc,sender);
    }

    else if (self.openControllerWithContextBlock)
    {
        self.openControllerWithContextBlock(vc, [[LJRouterSenderContext alloc] initWithSender:sender]);
    }
    else if ([vc respondsToSelector:@selector(LJNavigationOpenedByViewController:)])
    {
        LJRouterSenderContext *senderContext = [[LJRouterSenderContext alloc] initWithSender:sender];
        if (senderContext.contextViewController)
        {
            [vc performSelector:@selector(LJNavigationOpenedByViewController:)
                     withObject: senderContext.contextViewController];
        }
        else
        {
            [UIViewController performSelector:@selector(LJNavigationOpenViewController:) withObject:vc];
        }
    }
#pragma clang diagnostic pop
    else
    {
        NSLog(@"请配置 LJRouter 的 openControllerBlock 属性进行页面打开");
    }
}

@end

@implementation LJRouter(config)

- (void)setCheckPolicy:(LJRouterCheckPolicy)checkPolicy
{
    _checkPolicy = checkPolicy;
}

- (LJRouterCheckPolicy)checkPolicy
{
    return _checkPolicy;
}

- (void)setCheckPolicyModules:(NSArray<NSString *> *)checkPolicyModules
{
    _checkPolicyModules = checkPolicyModules;
}

- (NSArray<NSString*>*)checkPolicyModules
{
    return _checkPolicyModules;
}

- (void)setOpenControllerBlock:(void (^)(UIViewController *, id))openControllerBlock
{
	_openControllerBlock = [openControllerBlock copy];
}

- (void (^)(UIViewController *, id))openControllerBlock
{
	return _openControllerBlock;
}

- (void)setOpenControllerWithContextBlock:(void (^)(UIViewController *, LJRouterSenderContext *))openControllerWithContextBlock
{
    _openControllerWithSenderBlock = openControllerWithContextBlock;
}

- (void(^)(UIViewController*,LJRouterSenderContext*))openControllerWithContextBlock
{
    return _openControllerWithSenderBlock;
}

@end

Class LJRouterGetClassForKey(NSString* key)
{
	LJRouter *router = [LJRouter sharedInstance];
	Class clazz = [router.pageInvocationCenter getInvocationCenterItemByKey:key.lowercaseString].target;
	if (clazz)
	{
		return clazz;
	}
	return [router.actionInvocationCenter getInvocationCenterItemByKey:key.lowercaseString].target;
}

NSInvocation* LJRouterGetInvocation(struct LJRouterInvocationStruct* invocations,uint32_t length)
{
    LJRouterConvertManager *manager = [LJRouter sharedInstance].convertManager;
    NSMutableDictionary *data = nil;
    for (uint32_t i = 0 ; i < length ; i ++)
    {
        struct LJRouterInvocationStruct* invocation = invocations + i;
        LJInvocationCenterItemParam *param = [[LJInvocationCenterItemParam alloc] initWithName:invocation->name
                                                                                      typeName:invocation->typeName
                                                                                  typeEncoding:[NSString stringWithUTF8String:invocation->typeEncoding]
                                                                                     isRequire:NO
                                                                                          info:nil];
        id jsonValue = [manager jsonValueWithInvokeValue:invocation->value param:param];
        if (!jsonValue)
        {
            return nil;
        }
        if (!data)
        {
            data = [[NSMutableDictionary alloc] init];
        }
        data[invocation->name] = jsonValue;
    }

    return nil;
}
