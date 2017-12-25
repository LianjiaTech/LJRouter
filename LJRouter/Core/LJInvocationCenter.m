//
//  LJInvocationCenter.m
//  IM
//
//  Created by fover0 on 2017/5/28.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "LJInvocationCenter.h"
#import <objc/runtime.h>
#import <dlfcn.h>

@interface LJInvocationCenterItemParam()
{
    BOOL _classLazyLoadFinish;
}
@end

@implementation LJInvocationCenterItemParam
@synthesize objcClass = _objcClass;
@synthesize objectTypes = _objectTypes;

- (instancetype)initWithName:(NSString *)name
					typeName:(NSString *)typpName
				typeEncoding:(NSString *)typeEncoding
				   isRequire:(BOOL)isRequire
						info:(id)info
{
    self = [super init];
    if (self)
    {
        _classLazyLoadFinish = NO;
        _name = [name copy];
        _typeName = [typpName copy];
		_typeEncoding = [typeEncoding copy];
        _isRequire = isRequire;
        _info = info;

        _objcClass = Nil;
        _objectTypes = nil;
    }
    return self;
}

- (void)findObjectTypesInString:(NSString*)str
                   outTypeNames:(NSArray**)outTypeNames
                outTypeEncoding:(NSArray**)outTypeEncodings
{
    NSRange range;
    NSInteger stackCount = 0;
    NSInteger beginIndex = 0;
    NSString *typeEncoding = @"@";
    NSMutableArray *_outTypeNames = nil;
    NSMutableArray *_outTypeEncodings = nil;
    for(int i = 0 ; i < str.length; i += range.length)
    {
        range = [str rangeOfComposedCharacterSequenceAtIndex:i];
        if (range.length == 1)
        {
            NSString *s = [str substringWithRange:range];
            if ([s isEqualToString:@"<"]
                || [s isEqualToString:@"("]
                || [s isEqualToString:@"["]
                || [s isEqualToString:@"{"])
            {
                stackCount ++;
            }
            if ([s isEqualToString:@">"]
                || [s isEqualToString:@")"]
                || [s isEqualToString:@"]"]
                || [s isEqualToString:@"}"])
            {
                stackCount --;
            }

            if (stackCount == 0)
            {
                NSString *typeName = nil;
                if ([s isEqualToString:@","])
                {
                    typeName  = [str substringWithRange:NSMakeRange(beginIndex, range.location - beginIndex)];


                }
                else if (range.length + range.location == str.length)
                {
                    typeName = [str substringFromIndex:beginIndex];
                }
                else if ([s isEqualToString:@"^"])
                {
                    typeEncoding = @"?";
                }

                if (typeName)
                {
                    if (!_outTypeNames)
                    {
                        _outTypeNames = [[NSMutableArray alloc] init];
                        _outTypeEncodings = [[NSMutableArray alloc] init];
                        if (outTypeNames)
                        {
                            *outTypeNames = _outTypeNames;
                            *outTypeEncodings = _outTypeEncodings;
                        }
                    }
                    [_outTypeNames addObject:typeName];
                    [_outTypeEncodings addObject:typeEncoding];
                    typeEncoding = @"@";
                    beginIndex = range.location + 1;
                }
            }
        }
    }
}


- (void)lazyloadClassAndObjectTypes
{
    if (_classLazyLoadFinish)
    {
        return;
    }
    @synchronized(self) {
        if (_classLazyLoadFinish)
        {
            return;
        }

        if (![self.typeEncoding isEqualToString:@"@"])
        {
            return;
        }

        NSMutableArray *objectTypesArray = nil;

        NSRange range = [self.typeName rangeOfString:@"<"];
        if (range.length)
        {
            NSRange endRange = [self.typeName rangeOfString:@">" options:NSBackwardsSearch];
            if (endRange.length)
            {
                NSString *startStr = [self.typeName substringToIndex:range.location];
                _objcClass = NSClassFromString(startStr);
                if (_objcClass)
                {
                    NSString *objectTypesString = [self.typeName substringWithRange:NSMakeRange(range.location + 1, endRange.location - range.location - 1 )];
                    NSArray *typeNames = nil;
                    NSArray *typeEncoding = nil;
                    [self findObjectTypesInString:objectTypesString
                                     outTypeNames:&typeNames
                                  outTypeEncoding:&typeEncoding];
                    for (NSInteger i = 0 ; i < typeNames.count ; i ++)
                    {
                        LJInvocationCenterItemParam *param =
                        [[LJInvocationCenterItemParam alloc] initWithName:@""
                                                                 typeName:typeNames[i]
                                                             typeEncoding:typeEncoding[i]
                                                                isRequire:self.isRequire
                                                                     info:self.info];
                        if (objectTypesArray == nil)
                        {
                            objectTypesArray = [[NSMutableArray alloc] init];
                            _objectTypes = objectTypesArray;
                        }
                        [objectTypesArray addObject:param];
                    }
                }
            }
        }
        else
        {
            NSString *className = [self.typeName stringByReplacingOccurrencesOfString:@" " withString:@""];
            className = [className stringByReplacingOccurrencesOfString:@"*" withString:@""];
            _objcClass = NSClassFromString(className);
        }
        _classLazyLoadFinish = YES;
    }
}

- (Class)objcClass
{
    [self lazyloadClassAndObjectTypes];
    return _objcClass;
}

- (NSArray<Class>*)objectTypes
{
    [self lazyloadClassAndObjectTypes];
    return _objectTypes;
}

@end

@implementation LJInvocationCenterItemRule

- (instancetype)initWithSelector:(SEL)selector
                  returnTypeName:(NSString *)returnTypeName
              returnTypeEncoding:(NSString *)returnTypeEncoding
                          params:(NSArray<LJInvocationCenterItemParam *> *)params{
    self = [super init];
    if (self)
    {
        _selector = selector;
        _returnTypeName = [returnTypeName copy];
        _returnTypeEncoding = [returnTypeEncoding copy];
        _paramas = params;

    }
    return self;
}

@end

@interface LJInvocationCenterItem()
{
    NSMutableArray<LJInvocationCenterItemRule*>* _rules;
    __unsafe_unretained id unsafeTarget;
    id safeTarget;
}

@end

@implementation LJInvocationCenterItem

- (NSArray<LJInvocationCenterItemRule*>*)rules
{
    return _rules;
}

- (instancetype)initWithKey:(NSString*)key target:(__unsafe_unretained id)target
{
    self = [super init];
    if (self)
    {
        _rules  = [[NSMutableArray alloc] init];
        _key    = [key copy];

        Dl_info dlInfo;
        memset(&dlInfo, 0, sizeof(Dl_info));
        dladdr((__bridge void*)target, &dlInfo);
        if (object_isClass(target) && dlInfo.dli_fbase != 0)
        {
            unsafeTarget = target;
            safeTarget = Nil;
        }
        else
        {
            unsafeTarget = Nil;
            safeTarget = target;
        }
    }
    return self;
}

- (id)target
{
    return unsafeTarget ? unsafeTarget : safeTarget;
}

- (void)addRule:(LJInvocationCenterItemRule*)rule
{
    [_rules addObject:rule];
}

@end

@interface LJInvocationCenter()

@property (nonatomic, retain) NSMutableDictionary<NSString*,LJInvocationCenterItem*> *allItem;

@end

@implementation LJInvocationCenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.allItem = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)addInvocationWithKey:(NSString *)key
                      target:(__unsafe_unretained id)target
                        rule:(LJInvocationCenterItemRule *)rule
{
    if (!key.length || !target || !rule || !rule.selector || !rule.returnTypeName.length )
    {
        return;
    }




    // 一共分三种情况
    LJInvocationCenterItem *item = self.allItem[key];

    // 1.直接添加
    if (!item)
    {
        item = [[LJInvocationCenterItem alloc] initWithKey:key target:target];
        [item addRule:rule];
        self.allItem[key] = item;
    }
    // 2.相同target
    else if (item.target == target)
    {
        for (LJInvocationCenterItemRule *registedRule in item.rules)
        {
            // 和已有的rule冲突失败
            if (registedRule.selector == rule.selector)
            {
                return;
            }
        }
        [item addRule:rule];
    }
    else
    {
        NSLog(@"页面 %@ 与 页面 %@ 同时注册了 key:\"%@\"",item.target,target,key);
        assert(0);
    }
}

- (NSInvocation*)invocationForTarget:(id)target rule:(LJInvocationCenterItemRule*)rule data:(NSDictionary*)data
{
    NSMutableArray *paramValues = [[NSMutableArray alloc] init];
    for (LJInvocationCenterItemParam *param in rule.paramas)
    {
        id value = [data valueForKey:param.name];
        if (!value && param.isRequire)
        {
            return nil;
        }
        [paramValues addObject:value?:[NSNull null]];
    }

    Class clazz = object_getClass(target);
    Method method = class_getInstanceMethod(clazz, rule.selector);

    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = rule.selector;



    NSMutableArray *allInvokeValue = nil;
	for (NSInteger idx = 0 ; idx < paramValues.count ; idx ++)
	{
		id obj = paramValues[idx];
		if (obj == [NSNull null])
		{
			continue;
		}
        LJInvocationCenterItemParam *param = rule.paramas[idx];

        LJRouterConvertInvokeValue *invokeValue = [self.convertManager invokeValueWithJson:obj param:param];

        if (invokeValue)
        {
            [invocation setArgument:invokeValue.result atIndex:idx+2];
            if (!allInvokeValue)
            {
                allInvokeValue = [[NSMutableArray alloc] init];
                static char someKey;
                objc_setAssociatedObject(invocation, &someKey , allInvokeValue, OBJC_ASSOCIATION_RETAIN);
            }
            [allInvokeValue addObject:invokeValue];
        }
        else
        {
			[invocation setArgument:(void*)&obj atIndex:idx + 2];
        }
	}

    return invocation;
}

- (void)runInvocation:(NSInvocation*)invocation
{
    [invocation invoke];
}

- (NSInvocation*)invocationWithKey:(NSString *)key
                              data:(NSDictionary *)data
                           outItem:(LJInvocationCenterItem *__autoreleasing *)outItem
                           outRule:(LJInvocationCenterItemRule *__autoreleasing *)outRule
{
    LJInvocationCenterItem *item = self.allItem[key];
    for (LJInvocationCenterItemRule *rule in item.rules)
    {
        NSInvocation *invocation = [self invocationForTarget:item.target rule:rule data:data];
        if (invocation)
        {
            if (outItem)
            {
                *outItem = item;
            }
            if (outRule)
            {
                *outRule = rule;
            }
            return invocation;
        }
    }
    return nil;
}

- (LJInvocationCenterItem*)getInvocationCenterItemByKey:(NSString*)key
{
    return [self.allItem valueForKey:key];
}

@end
