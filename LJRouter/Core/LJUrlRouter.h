//
//  LJUrlRouter.h
//  invocation
//
//  Created by fover0 on 2017/6/6.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "LJRouter.h"



@interface  LJRouter(LJUrlRouter)

- (BOOL)canOpenUrlString:(NSString*)url;
- (BOOL)routerUrlString:(NSString*)url
				 sender:(UIResponder*)sender
			  pageBlock:(void(^)(__kindof UIViewController* viewController))pageBlock
          callbackBlock:(void(^)(NSString* key,NSString *value,NSString* data,BOOL complete))callbackBlock
	  canNotRouterBlock:(void(^)(void))canNotRouterBlock;
@end

@interface LJRouter(LJUrlRouterConfig)

@property (nonatomic, copy) UIViewController *(^createWebviewBlock)(NSString* url);
@property (nonatomic, copy) NSURL *(^urlProcessorBlock)(NSURL* url);

@end

@interface UIViewController(LJUrlRouter)

+ (void)LJSetWebViewControllerBlock:(__kindof UIViewController *(^)(NSString* url))block __deprecated;
- (BOOL)LJOpenUrlString:(NSString*)url;

@end
