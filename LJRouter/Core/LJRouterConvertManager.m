//
//  LJRouterConvertManager.m
//  LJRouter
//
//  Created by fover0 on 2017/11/28.
//

#import "LJRouterConvertManager.h"
#import "LJInvocationCenter.h"
#import "LJRouter.h"

@interface LJRouterConvertInvokeValue()
{
@public
    __strong id _resultObj;
    void* _resultPointer;
    BOOL _freeWhenDone;
}

@end

@implementation LJRouterConvertInvokeValue

+ (instancetype)valueWithRetainObj:(id)result
{
    LJRouterConvertInvokeValue *ret = [[self alloc] init];
    ret->_resultObj = result;
    return ret;
}

+ (instancetype)valueWithCType:(void *)result freeWhenDone:(BOOL)free
{
    LJRouterConvertInvokeValue *ret = [[self alloc] init];
    ret->_resultPointer = result;
    ret->_freeWhenDone = free;
    return ret;
}

- (void*)result
{
    if (_resultObj)
    {
        return &_resultObj;
    }
    else
    {
        return _resultPointer;
    }
}

+ (instancetype)valueError
{
    static id error = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        error = [[self alloc] init];
    });
    return error;
}

- (void)dealloc
{
    if (self->_freeWhenDone)
    {
        free(self->_resultPointer);
        self->_resultPointer = NULL;
    }
}

@end

@interface LJRouterConvertManager()
@property (nonatomic, retain) NSMutableArray *invokeValueBlocks;
@property (nonatomic, retain) NSMutableArray *jsonValueBlocks;
@end

@implementation LJRouterConvertManager

#define ALL_NUMBER_TYPE(CONVERT_NUMBER)  \
    CONVERT_NUMBER(signed char          ,_C_CHR     , charValue)                \
    CONVERT_NUMBER(unsigned char        ,_C_UCHR    , unsignedCharValue)        \
    CONVERT_NUMBER(signed short         ,_C_SHT     , shortValue)               \
    CONVERT_NUMBER(unsigned short       ,_C_USHT    , unsignedShortValue)       \
    CONVERT_NUMBER(signed int           ,_C_INT     , intValue)                 \
    CONVERT_NUMBER(unsigned int         ,_C_UINT    , unsignedIntValue)         \
    CONVERT_NUMBER(signed long          ,_C_LNG     , longValue)                \
    CONVERT_NUMBER(unsigned long        ,_C_ULNG    , unsignedLongValue)        \
    CONVERT_NUMBER(signed long long     ,_C_LNG_LNG , longLongValue)            \
    CONVERT_NUMBER(bool                 ,_C_BOOL    , boolValue)                \
    CONVERT_NUMBER(unsigned long long   ,_C_ULNG_LNG, unsignedLongLongValue)    \
    CONVERT_NUMBER(float                ,_C_FLT     , floatValue)               \
    CONVERT_NUMBER(double               ,_C_DBL     , doubleValue)              \

- (void)regNumberConvert
{
    [self addCovertInvokeValueBlock:^LJRouterConvertInvokeValue *(LJRouterConvertManager *manager,
                                                                  id value,
                                                                  LJInvocationCenterItemParam *targetParam) {
        NSNumber*(^getNumber)(id numberObj) =  ^NSNumber*(id numberObj){
            if ([numberObj isKindOfClass:[NSString class]])
            {
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                return [f numberFromString:numberObj];
            }
            else if ([numberObj isKindOfClass:[NSNumber class]])
            {
                return numberObj;
            }
            else
            {
                return @0;
            }
        };

        const char* type = targetParam.typeEncoding.UTF8String;
        switch (type[0]) {
            // 处理数字
            #define CONVERT_NUMBER(TYPE,TYPENAME,METHODNAME)                                        \
                case TYPENAME:                                                                      \
                    {                                                                               \
                        TYPE c = [getNumber(value) METHODNAME];                                     \
                        TYPE *result = (void*)malloc(sizeof(TYPE));                                 \
                        *result = c;                                                                \
                        return                                                                      \
                        [LJRouterConvertInvokeValue valueWithCType:result freeWhenDone:YES];       \
                    }                                                                               \

            ALL_NUMBER_TYPE(CONVERT_NUMBER)
            #undef CONVERT_NUMBER
            default:
            return nil;
        }
    }];

    [self addConvertJsonValueBlock:^id(LJRouterConvertManager *manager,
                                       void *value,
                                       LJInvocationCenterItemParam *valueParam) {
        const char* type = valueParam.typeEncoding.UTF8String;
        switch (type[0]) {
            #define CONVERT_NUMBER(TYPE,TYPENAME,METHODNAME)                                        \
                case TYPENAME:                                                                      \
                    {                                                                               \
                        TYPE *c = (TYPE*)value;                                                     \
                        return @(*c);                                                               \
                    }                                                                               \

            ALL_NUMBER_TYPE(CONVERT_NUMBER)
            #undef CONVERT_NUMBER
            default:
                return nil;
        }
    }];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.invokeValueBlocks = [[NSMutableArray alloc] init];
        self.jsonValueBlocks = [[NSMutableArray alloc] init];

        [self regNumberConvert];
    }
    return self;
}

- (void)addCovertInvokeValueBlock:(LJRouterConvertInvokeValue *(^)(LJRouterConvertManager *,id,LJInvocationCenterItemParam *))invokeValue
{
    if (invokeValue)
    {
        [self.invokeValueBlocks addObject:invokeValue];
    }
}
- (void)addConvertJsonValueBlock:(id (^)(LJRouterConvertManager *, void *, LJInvocationCenterItemParam *))jsonValueBlock
{
    if (jsonValueBlock)
    {
        [self.jsonValueBlocks addObject:jsonValueBlock];
    }
}

- (id)jsonValueWithInvokeValue:(void *)jsonValue param:(LJInvocationCenterItemParam *)param
{
    for (id (^block)(LJRouterConvertManager *, void *, LJInvocationCenterItemParam *)  in self.jsonValueBlocks)
    {
        id result = block(self,jsonValue,param);
        if (result)
        {
            return result;
        }
    }
    return nil;
}

- (LJRouterConvertInvokeValue*)invokeValueWithJson:(id)jsonValue param:(LJInvocationCenterItemParam*)param
{
    for (LJRouterConvertInvokeValue *(^block)(LJRouterConvertManager *,id,LJInvocationCenterItemParam *) in self.invokeValueBlocks)
    {
        LJRouterConvertInvokeValue * value = block(self,jsonValue,param);
        if (value)
        {
            if (value == [LJRouterConvertInvokeValue valueError])
            {
                return nil;
            }
            return value;
        }
    }
    return nil;
}

@end


