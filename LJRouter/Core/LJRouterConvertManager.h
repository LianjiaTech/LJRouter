//
//  LJRouterConvertManager.h
//  LJRouter
//
//  Created by fover0 on 2017/11/28.
//

#import <Foundation/Foundation.h>

@class LJInvocationCenterItemParam;

// 类型转化结果
@interface LJRouterConvertInvokeValue : NSObject

@property (nonatomic, readonly) void* result;

+ (instancetype)valueWithCType:(void*)result freeWhenDone:(BOOL)free;
+ (instancetype)valueWithRetainObj:(id)result;
+ (instancetype)valueError;

@end


@interface LJRouterConvertManager : NSObject

- (LJRouterConvertInvokeValue*)invokeValueWithJson:(id)jsonValue param:(LJInvocationCenterItemParam*)param;
- (id)jsonValueWithInvokeValue:(void*)jsonValue param:(LJInvocationCenterItemParam*)param;

- (void)addCovertInvokeValueBlock:(LJRouterConvertInvokeValue*(^)(LJRouterConvertManager *manager,
                                                                  id value,
                                                                  LJInvocationCenterItemParam *targetParam))invokeValue;


- (void)addConvertJsonValueBlock:(id(^)(LJRouterConvertManager *manager,
                                        void* value,
                                        LJInvocationCenterItemParam *valueParam))jsonValueBlock;

@end
