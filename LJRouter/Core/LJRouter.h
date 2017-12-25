//
//  LJRouter.h
//  invocation
//
//  Created by fover0 on 2017/5/28.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import <UIKit/UIKit.h>
#import "LJInvocationCenter.h"
#import "LJRouterConvertManager.h"

typedef NS_ENUM(NSUInteger, LJRouterCheckPolicy) {
    LJRouterCheckPolicyAssert  = 0, // default
    LJRouterCheckPolicyConsole = 1,
    LJRouterCheckPolicyAlert   = 2,
};

typedef void(^LJRouterCallbackBlock)(NSString* mess,BOOL complete);

@interface LJRouter : NSObject

@property (nonatomic, readonly) LJRouterConvertManager *convertManager;

// 初始化
+ (instancetype)sharedInstance;
- (instancetype)init __deprecated;

// router
- (BOOL)canRouterKey:(NSString*)key data:(NSDictionary*)data;
- (BOOL)routerKey:(NSString*)key
             data:(NSDictionary*)data
		   sender:(UIResponder*)sender
        pageBlock:(void(^)(__kindof UIViewController* viewController))pageBlock
    callbackBlock:(void(^)(NSString* key,NSString *value,NSString* data,BOOL complete))callbackBlock
canNotRouterBlock:(void(^)(void))canNotRouterBlock;

- (void)openViewController:(UIViewController*)vc withSender:(id)sender;

@end

@interface LJRouterSenderContext : NSObject

// 原始sender
@property (nonatomic, readonly) UIResponder *originSender;

// 以下函数 会按照originSender本身以及nextResponder依次寻找命中该类型的对象
@property (nonatomic, readonly) UIView *contextView;
@property (nonatomic, readonly) UIViewController *contextViewController;
@property (nonatomic, readonly) UIWindow *contextWindow;
@property (nonatomic, readonly) id<UIApplicationDelegate> contextAppDelegate;
@property (nonatomic, readonly) UIApplication *contextAppliaction;

@end


@interface LJRouter(config)

// 默认为nil , nil与@[]时检查所有模块
@property (nonatomic, retain) NSArray<NSString*> *checkPolicyModules;
@property (nonatomic, assign) LJRouterCheckPolicy checkPolicy;

@property (nonatomic, copy) void(^openControllerBlock)(UIViewController*vc,id sender) __deprecated_msg("请使用openControllerWithContextBlock");
@property (nonatomic, copy) void(^openControllerWithContextBlock)(UIViewController*vc, LJRouterSenderContext *senderContext);

@end

@interface UIViewController(LJRouter)

// 属性是通过实例调用 如果该页面通过路由产生 则会返回该次路由所使用的key
// 请不要直接设置该属性
@property (nonatomic, copy) NSString *ljRouterKey;
@end



#import "LJRouterPrivate.h"
