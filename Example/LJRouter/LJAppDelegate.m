//
//  LJAppDelegate.m
//  LJRouter
//
//  Created by fover0 on 06/23/2017.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "LJAppDelegate.h"
#import "LJRouter.h"
#import "LJUrlRouter.h"
#import "UIViewController+LJNavigation.h"

@implementation LJAppDelegate

LJRouterUsePageObj(webview, (NSString*)url);
- (void)globalConfig
{
    [LJRouter sharedInstance].checkPolicy = LJRouterCheckPolicyAssert;
//    [LJRouter sharedInstance].checkPolicyModules = @[@"LJPersonalComponent"];
    [LJRouter sharedInstance].createWebviewBlock = ^UIViewController *(NSString *url) {
        return get_webview_controller_with_url(url);
    };

    [[LJRouter sharedInstance].convertManager
         addConvertJsonValueBlock:^id(LJRouterConvertManager *manager,
                                      void *value,
                                      LJInvocationCenterItemParam *valueParam) {
             if ([valueParam.objcClass isKindOfClass:[NSDictionary class]]
                 || [valueParam.objcClass isKindOfClass:[NSArray class]])
             {
                 void** p = (void**)value;
                 id dict = (__bridge id)(*p);
                 NSData *data =
                 [NSJSONSerialization dataWithJSONObject:dict
                                                 options:0
                                                   error:nil];
                 return [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
             }
             return nil;
    }];

    [[LJRouter sharedInstance].convertManager addCovertInvokeValueBlock:
     ^LJRouterConvertInvokeValue *(LJRouterConvertManager *manager,
                                   id value,
                                   LJInvocationCenterItemParam *targetParam) {
         if ([value isKindOfClass:[NSString class]])
         {
             if (targetParam.objcClass == [NSDictionary class]
                 || targetParam.objcClass == [NSArray class])
             {
                 NSData *stringData = [value dataUsingEncoding:NSUTF8StringEncoding];
                 id jsonObj = [NSJSONSerialization JSONObjectWithData:stringData options:0 error:nil];
                 if ([jsonObj isKindOfClass:targetParam.objcClass])
                 {
                     return [LJRouterConvertInvokeValue valueWithRetainObj:jsonObj];
                 }
             }
         }
         return nil;
     }];
}

LJRouterUsePageObj(homeTabbar);

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self globalConfig];

    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:get_homeTabbar_controller()];
    window.rootViewController = vc;
    self.window = window ;
    [window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)app
			openURL:(NSURL *)url
			options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
	return
	[[LJRouter sharedInstance] routerUrlString:url.absoluteString
										sender:self
									 pageBlock:^(__kindof UIViewController *viewController) {
								   [UIViewController LJNavigationOpenViewController:viewController];
							   }
                                 callbackBlock:nil
                             canNotRouterBlock:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
