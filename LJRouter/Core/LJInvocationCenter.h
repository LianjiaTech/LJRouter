//
//  LJInvocationCenter.h
//  IM
//
//  Created by fover0 on 2017/5/28.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>
#import "LJRouterConvertManager.h"


// 参数描述
@interface LJInvocationCenterItemParam : NSObject

@property (nonatomic, readonly) BOOL isRequire;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *typeName;
@property (nonatomic, readonly) NSString *typeEncoding;
@property (nonatomic, readonly) id info;

// lazy create   NSArray<NSString*>*    objcClass is NSArray  objectTypes is [NSString]
@property (nonatomic, readonly) Class objcClass;
@property (nonatomic, readonly) NSArray<LJInvocationCenterItemParam*> *objectTypes;


- (instancetype)initWithName:(NSString*)name
                    typeName:(NSString*)typeName
				typeEncoding:(NSString*)typeEncoding
                   isRequire:(BOOL)isRequire
                        info:(id)info;
@end

// 函数重载描述
@interface LJInvocationCenterItemRule : NSObject
@property (nonatomic, readonly) SEL selector;
@property (nonatomic, readonly) NSString *returnTypeName;
@property (nonatomic, readonly) NSString *returnTypeEncoding;
@property (nonatomic, readonly) NSArray<LJInvocationCenterItemParam*>* paramas;

- (instancetype)initWithSelector:(SEL)selector
                  returnTypeName:(NSString*)returnTypeName
              returnTypeEncoding:(NSString*)returnTypeEncoding
                          params:(NSArray<LJInvocationCenterItemParam*>*)params;

@end

// 函数描述
@interface LJInvocationCenterItem : NSObject

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) id target;
@property (nonatomic, readonly) NSArray<LJInvocationCenterItemRule*> *rules;

@end

// 转发中心
@interface LJInvocationCenter : NSObject

@property (nonatomic, retain) LJRouterConvertManager *convertManager;

- (LJInvocationCenterItem*)getInvocationCenterItemByKey:(NSString*)key;

- (void)addInvocationWithKey:(NSString*)key
                      target:(id)target
                        rule:(LJInvocationCenterItemRule*)rule;

- (NSInvocation*)invocationWithKey:(NSString*)key
                              data:(NSDictionary*)data
                           outItem:(LJInvocationCenterItem**)outItem
                           outRule:(LJInvocationCenterItemRule**)outRule;

@end
