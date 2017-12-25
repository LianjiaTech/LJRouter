//
//  LJRouterPrivate.h
//  invocation
//
//  Created by fover0 on 2017/5/28.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "metamacros.h"

#ifdef DEBUG
	#define LJROUTER_ENABLE_CHECK 1
	#define LJROUTER_ENABLE_TIP_INFO 1
	#define LJROUTER_ENABLE_FILE_INFO 1
    #define LJROUTER_ENABLE_DOC_ATTR 1
#endif

#define LJROUTER_ENABLE_RUNTIME_ATTR 1
#define LJROUTER_ENABLE_IMP_ON_CALLER 1


struct LJRouterRegisterParam {
    __unsafe_unretained NSString *name;
    __unsafe_unretained NSString *typeName;
	char *typeEncoding;
    BOOL isRequire;
};

struct LJRouterUseInfo {
    char* filePath;
    uint64_t lineNumber;
    __unsafe_unretained NSString *key;
    __unsafe_unretained NSString *returnTypeName;
    struct LJRouterRegisterParam *params;
    uint32_t paramCount;
    void* assertBlock;
};

struct LJRouterRegister {
    char* objcFunctionName;
    char* filePath;
    BOOL isAction;

    __unsafe_unretained NSString *key;
    __unsafe_unretained NSString *keyDescription;

    __unsafe_unretained NSString *returnTypeName;
    char                         *returnTypeEncoding;

    struct LJRouterRegisterParam *params;
    uint32_t                     paramscount;

    __unsafe_unretained NSString *selName;

};


// 基础使用

#define metamacro_concat_all(...)                       \
        metamacro_concat(metamacro_concat_all,metamacro_argcount(__VA_ARGS__))(__VA_ARGS__)

#define metamacro_concat_all1(...) __VA_ARGS__
#define metamacro_concat_all2(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all1(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all3(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all2(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all4(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all3(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all5(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all4(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all6(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all5(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all7(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all6(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all8(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all7(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all9(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all8(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all10(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all9(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all11(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all10(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all12(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all11(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all13(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all12(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all14(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all13(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all15(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all14(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all16(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all15(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all17(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all16(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all18(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all17(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all19(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all18(metamacro_tail(__VA_ARGS__)))
#define metamacro_concat_all20(...) metamacro_concat(metamacro_head(__VA_ARGS__),metamacro_concat_all19(metamacro_tail(__VA_ARGS__)))


#define metamacro_stringify_all(SUB, ...) \
    metamacro_concat(metamacro_stringify_all,metamacro_argcount(__VA_ARGS__))(SUB,__VA_ARGS__)

#define metamacro_stringify_all1(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__))

#define metamacro_stringify_all2(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all1(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all3(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all2(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all4(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all3(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all5(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all4(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all6(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all5(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all7(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all6(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all8(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all7(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all9(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all8(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all10(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all9(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all11(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all10(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all12(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all11(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all13(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all12(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all14(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all13(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all15(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all14(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all16(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all15(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all17(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all16(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all18(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all17(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all19(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all18(SUB,metamacro_tail(__VA_ARGS__))
#define metamacro_stringify_all20(SUB, ...) \
    metamacro_stringify(metamacro_head(__VA_ARGS__)) SUB  metamacro_stringify_all19(SUB,metamacro_tail(__VA_ARGS__))

#define metamacro_delete_last(...) metamacro_take(metamacro_dec( metamacro_argcount(__VA_ARGS__)) , __VA_ARGS__)


// 遍历
#define LJ_ROUTER_FOREACH_ARGS(MACRO, ...)                                                      \
    metamacro_if_eq(1,metamacro_argcount(__VA_ARGS__))                                          \
    ()                                                                                          \
    (metamacro_foreach(MACRO,, metamacro_tail(__VA_ARGS__)))                                    \

// 取得nullable
#define LJ_ROUTER_IS_NULLABLE_CHECK__nullable ,
#define LJ_ROUTER_IS_NULLABLE_CHECK_Nullable ,
#define LJ_ROUTER_IS_NULLABLE_(...)                                                             \
        metamacro_if_eq(metamacro_argcount( LJ_ROUTER_IS_NULLABLE_CHECK ## __VA_ARGS__),        \
                        metamacro_inc(metamacro_argcount(__VA_ARGS__)))


#define LJ_ROUTER_IS_NULLABLE_1_(...) LJ_ROUTER_IS_NULLABLE_CHECK ## __VA_ARGS__ ,
#define LJ_ROUTER_IS_NULLABLE_2_(...) __VA_ARGS__ ,
#define LJ_ROUTER_GET_IS_NULLABLE(...)                                                          \
        metamacro_if_eq(                                                                        \
            metamacro_argcount(LJ_ROUTER_IS_NULLABLE_1_ __VA_ARGS__),                           \
            metamacro_inc(metamacro_argcount(LJ_ROUTER_IS_NULLABLE_2_ __VA_ARGS__))             \
        )

// 取得类型 删掉nullable
#define LJ_ROUTER_GET_TYPE_SET__nullable
#define LJ_ROUTER_GET_TYPE_SET_Nullable
#define LJ_ROUTER_GET_TYPE_(...)                                                                \
        LJ_ROUTER_IS_NULLABLE_(__VA_ARGS__)                                                     \
        (LJ_ROUTER_GET_TYPE_SET ## __VA_ARGS__,)                                                \
        (__VA_ARGS__,)

#define LJ_ROUTER_GET_TYPE(...)                                                                 \
        metamacro_delete_last( LJ_ROUTER_GET_TYPE_ __VA_ARGS__ )

// 取得变量
#define LJ_ROUTER_GET_VAR_(...)
#define LJ_ROUTER_GET_VAR(...) LJ_ROUTER_GET_VAR_ __VA_ARGS__

// 实际使用
#define LJ_ROUTER_PARAMS_LINE_VALUE(INDEX,VALUE)                                                \
        ,metamacro_concat(_,LJ_ROUTER_GET_VAR(VALUE))

#define LJ_ROUTER_PARAMS_DOT_AND_VALUE(INDEX,VALUE)                                             \
        ,LJ_ROUTER_GET_VAR(VALUE)

#define LJ_ROUTER_PARAMS_VALUE_SEL_VALUE(INDEX,VALUE)                                           \
        LJ_ROUTER_GET_VAR(VALUE) : LJ_ROUTER_GET_VAR(VALUE)

#define LJ_ROUTER_PARAMS_DOT_TYPEOF_VALUE(INDEX,VALUE)                                          \
        ,typeof( LJ_ROUTER_GET_VAR(VALUE) )

#define LJ_ROUTER_PARAMS_VAR_SEL_TYPE_VAR(INDEX,VALUE)                                          \
        LJ_ROUTER_GET_VAR(VALUE) : (LJ_ROUTER_GET_TYPE(VALUE)) LJ_ROUTER_GET_VAR(VALUE)

#define LJ_ROUTER_PARAMS_DOT_TYPEOF_TYPE_VALUE_FIRST_NO_DOT(INDEX,VALUE)                        \
        metamacro_if_eq(0,INDEX)()(,)                                                           \
        typeof( LJ_ROUTER_GET_TYPE(VALUE))  LJ_ROUTER_GET_VAR(VALUE)

#define LJ_ROUTER_PARAMS_DOT_TYPEOF_TYPE_VALUE(INDEX,VALUE)                                     \
        ,typeof( LJ_ROUTER_GET_TYPE(VALUE))  LJ_ROUTER_GET_VAR(VALUE)

#define LJ_ROUTER_STRUCT_PARAM(INDEX,VALUE)                                                     \
        metamacro_if_eq(0,INDEX)()(,)                                                           \
        {                                                                                       \
            @metamacro_stringify( LJ_ROUTER_GET_VAR( VALUE)) ,                                  \
            @metamacro_stringify_all(",",LJ_ROUTER_GET_TYPE(VALUE)) ,                           \
			@encode(LJ_ROUTER_GET_TYPE(VALUE)),													\
            LJ_ROUTER_GET_IS_NULLABLE(VALUE)(NO)(YES)		                                    \
        }

#define LJ_ROUTER_REG_NAME(PRENAME,SUFFIXNAME,...)                                              \
        metamacro_concat_all                                                                    \
        (                                                                                       \
            PRENAME LJ_ROUTER_FOREACH_ARGS(LJ_ROUTER_PARAMS_DOT_AND_VALUE,1,##__VA_ARGS__)      \
            ,SUFFIXNAME                                                                         \
        )

#define LJ_ROUTER_CREATE_SEL_STR(INDEX,VALUE)                                                   \
        metamacro_stringify(LJ_ROUTER_GET_VAR(VALUE)) ":"

#define LJ_ROUTER_TYPE_STRING_NAME(INDEX,VALUE)                                                 \
        @metamacro_stringify( LJ_ROUTER_GET_TYPE(VALUE))


// 差异化配置
#ifdef LJROUTER_ENABLE_FILE_INFO
	#define LJ_FILE_NAME __FILE__
#else
	#define LJ_FILE_NAME ""
#endif

#ifdef LJROUTER_ENABLE_TIP_INFO
	#define LJ_GET_TIP_STRING(STR) STR
#else
	#define LJ_GET_TIP_STRING(STR) @""
#endif

#define LJ_ROUTER_IS_VOID_void ,
#define LJ_ROUTER_IS_VOID(...)                                                                  \
        metamacro_if_eq(                                                                        \
            metamacro_argcount( LJ_ROUTER_IS_VOID_ ## __VA_ARGS__ ),                            \
            metamacro_inc( metamacro_argcount(__VA_ARGS__) )                                    \
        )


#define LJ_ROUTER_FUNCTION_PARAM_DEFINE(PREFIX,PREFIX2,MACRO, ...)                              \
			metamacro_concat_all(PREFIX ,														\
			metamacro_if_eq(1,metamacro_argcount(1,##__VA_ARGS__))()(PREFIX2),					\
			LJ_ROUTER_FOREACH_ARGS(MACRO,1,##__VA_ARGS__))										\

#define LJ_ROUTER_BLOCK_PARAM_DEFINE(PREFIX,PREFIX2,MACRO, ...)                                 \
			metamacro_concat(                                                                   \
                PREFIX,                                                                         \
                metamacro_if_eq(1,metamacro_argcount(1,##__VA_ARGS__))                          \
                    ()                                                                          \
                    (PREFIX2)                                                                   \
            )                                                                                   \
			( LJ_ROUTER_FOREACH_ARGS(MACRO,1,##__VA_ARGS__))  )							        \

#define LJ_ROUTER_FUNCTION_PARAM_SELNAME(PREFIX,PREFIX2,MACRO, ...)                             \
			@metamacro_stringify(PREFIX)                                                        \
			metamacro_stringify(                                                                \
                metamacro_if_eq(1,metamacro_argcount(1,##__VA_ARGS__))                          \
                    ()                                                                          \
                    (PREFIX2))                                                                  \
			LJ_ROUTER_FOREACH_ARGS(MACRO,1,##__VA_ARGS__)								        \

// 注册
#define _LJPageAndActionRouterInit_(ReturnTypeName,                                             \
                                    KEY,                                                        \
                                    IsAction,                                                   \
                                    FunctionPrefix,                                             \
                                    FunctionPrefix2,                                            \
                                    TipStringAndParams,                                         \
                                    ...)                                                        \
    /*函数*/                                                                                     \
    + (void) LJ_ROUTER_REG_NAME(LJRouter ## KEY,regInfo ,##__VA_ARGS__)                         \
    {                                                                                           \
        __used static struct LJRouterRegisterParam                                              \
            LJ_ROUTER_REG_NAME(LJRouter ## KEY,Params[],##__VA_ARGS__) =                        \
        {                                                                                       \
            LJ_ROUTER_FOREACH_ARGS(LJ_ROUTER_STRUCT_PARAM,1,##__VA_ARGS__)                      \
        };                                                                                      \
        __used static struct LJRouterRegister                                                   \
            LJ_ROUTER_REG_NAME(LJRouter ## KEY,RegisterStruct,##__VA_ARGS__)                    \
            __attribute__ ((used, section ("__DATA,__LJRouter")))                               \
        = {                                                                                     \
            .objcFunctionName = (char*)__func__,                                                \
            .filePath = LJ_FILE_NAME ,                                                          \
            .key = @#KEY,                                                                       \
            .keyDescription = LJ_GET_TIP_STRING(TipStringAndParams),                            \
            .returnTypeName = @#ReturnTypeName,                                                 \
            .returnTypeEncoding = @encode(ReturnTypeName),                                      \
            .params = LJ_ROUTER_REG_NAME(LJRouter ## KEY,Params,##__VA_ARGS__),                 \
            .paramscount =metamacro_dec(metamacro_argcount(1,##__VA_ARGS__)),                   \
            .isAction = IsAction,                                                               \
            .selName = LJ_ROUTER_FUNCTION_PARAM_SELNAME(FunctionPrefix,                         \
                                                        FunctionPrefix2,                        \
                                                        LJ_ROUTER_CREATE_SEL_STR,               \
                                                        ##__VA_ARGS__),                         \
        };                                                                                      \
    }                                                                                           \


#define LJRouterInit(TipStringAndParams,KEY,...)  /*page*/                                      \
    _LJPageAndActionRouterInit_(UIViewController*,                                              \
                                KEY,                                                            \
                                NO,                                                             \
                                get_##KEY##_controller,                                         \
                                _with_,                                                         \
                                TipStringAndParams ,                                            \
                                ## __VA_ARGS__)                                                 \
	__LJRouterUsePageImpPointer(KEY,##__VA_ARGS__)												\
	__LJRouterUsePageObjImpPointer(KEY,##__VA_ARGS__)											\
    + (instancetype)LJ_ROUTER_FUNCTION_PARAM_DEFINE(get_##KEY##_controller,                     \
                                                    _with_,                                     \
                                                    LJ_ROUTER_PARAMS_VAR_SEL_TYPE_VAR,          \
                                                    ##__VA_ARGS__)                              \
    {                                                                                           \
        id vc =                                                                                 \
        [[self alloc] LJ_ROUTER_FUNCTION_PARAM_DEFINE(init_with_##KEY,                          \
                                                      _,                                        \
                                                      LJ_ROUTER_PARAMS_VALUE_SEL_VALUE,         \
                                                      ##__VA_ARGS__)];                          \
        [vc setLjRouterKey:@#KEY];                                                              \
        return vc;                                                                              \
    }                                                                                           \
    - (instancetype)LJ_ROUTER_FUNCTION_PARAM_DEFINE(init_with_##KEY,                            \
                                                    _,                                          \
                                                    LJ_ROUTER_PARAMS_VAR_SEL_TYPE_VAR,          \
                                                    ##__VA_ARGS__)                              \


#define LJRouterRegistAction(TipStringAndParams,ActionName,ReturnType,...)  /*action*/          \
    _LJPageAndActionRouterInit_(ReturnType,                                                     \
                                ActionName,                                                     \
                                YES,                                                            \
                                action_##ActionName,                                            \
                                _with_,                                                         \
                                TipStringAndParams ,                                            \
                                ## __VA_ARGS__)                                                 \
	__LJRouterUseActionImpPointer(ActionName,ReturnType,## __VA_ARGS__)							\
    + (ReturnType)LJ_ROUTER_FUNCTION_PARAM_DEFINE(action_##ActionName,                          \
                                                  _with_,                                       \
                                                  LJ_ROUTER_PARAMS_VAR_SEL_TYPE_VAR,            \
                                                  ##__VA_ARGS__)                                \

// 校验宏
#if LJROUTER_ENABLE_CHECK
    #define __LJRouterUseCheck(ReturnTypeName,KEY,...)                                          \
        static void(^assertBlock)(NSString*) = ^(NSString* message){                            \
            if (message.length) {NSLog(@"%@",message);}                                         \
            assert(0);                                                                          \
        };                                                                                      \
        static struct LJRouterRegisterParam checkParams[] =                                     \
        {                                                                                       \
            LJ_ROUTER_FOREACH_ARGS(LJ_ROUTER_STRUCT_PARAM,1,##__VA_ARGS__)                      \
        };                                                                                      \
        static struct LJRouterUseInfo userInfo                                                  \
            __attribute__ ((used, section ("__DATA,__LJRouterUseINF"))) =                       \
        {                                                                                       \
            .filePath = LJ_FILE_NAME,                                                           \
            .lineNumber = __LINE__,                                                             \
            .key = @#KEY,                                                                       \
            .returnTypeName = @#ReturnTypeName,                                                 \
            .params = checkParams,                                                              \
            .paramCount = metamacro_argcount(1,##__VA_ARGS__) - 1,                              \
            .assertBlock = &assertBlock                                                         \
        };
#else
    #define __LJRouterUseCheck(ReturnTypeName,KEY,...)
#endif

// use宏
#define __LJRouterUseFunction(NEEDIMP,															\
							  IS_STATIC,														\
							  IS_EXTERN,														\
							  KEY,                                                              \
                              RET_TYPE,FUN_PRE,FUN_PRE2,CUSTOM_PARAM,                           \
                              GET_FUN_RET_TYPE,GET_FUN_PRE,GET_FUN_PRE2,                        \
                              BEFORE_IMP,AFTER_IMP,...)                                         \
	__used 																						\
    metamacro_if_eq(IS_STATIC,1)(static)()														\
	metamacro_if_eq(IS_EXTERN,1)(extern)()														\
	RET_TYPE																					\
	LJ_ROUTER_FUNCTION_PARAM_DEFINE(FUN_PRE,FUN_PRE2,LJ_ROUTER_PARAMS_LINE_VALUE,##__VA_ARGS__) \
    (                                                                                           \
        LJ_ROUTER_IS_VOID(CUSTOM_PARAM)                                                         \
            ()                                                                                  \
            (CUSTOM_PARAM metamacro_if_eq(1,metamacro_argcount(1,##__VA_ARGS__))()(,))          \
        LJ_ROUTER_FOREACH_ARGS(LJ_ROUTER_PARAMS_DOT_TYPEOF_TYPE_VALUE_FIRST_NO_DOT,             \
                                1,##__VA_ARGS__ )                                               \
    )                                                                                           \
    metamacro_if_eq(NEEDIMP,1)                                                                  \
    (                                                                                           \
        {                                                                                       \
            __LJRouterUseCheck(GET_FUN_RET_TYPE,KEY,##__VA_ARGS__)                              \
            Class theClass = LJRouterGetClassForKey(@#KEY);                                     \
            NSString *selName =LJ_ROUTER_FUNCTION_PARAM_SELNAME(GET_FUN_PRE,                    \
                                                                GET_FUN_PRE2,                   \
                                                                LJ_ROUTER_CREATE_SEL_STR,       \
                                                                ##__VA_ARGS__);                 \
            SEL sel = NSSelectorFromString(selName);                                            \
            GET_FUN_RET_TYPE(*imp)(id,SEL                                                       \
                LJ_ROUTER_FOREACH_ARGS(LJ_ROUTER_PARAMS_DOT_TYPEOF_VALUE,1,##__VA_ARGS__  )) =  \
            (void*)class_getMethodImplementation(object_getClass(theClass), sel);               \
            BEFORE_IMP                                                                          \
            imp(theClass,sel                                                                    \
                LJ_ROUTER_FOREACH_ARGS(LJ_ROUTER_PARAMS_DOT_AND_VALUE,1,##__VA_ARGS__));        \
            AFTER_IMP                                                                           \
        };                                                                                      \
    )                                                                                           \
    ()


// 三种不同声明的use
#define __LJRouterUsePageImp(NEEDIMP,IS_STATIC,IS_EXTERN,KEY, ...)                              \
		__LJRouterUseFunction(NEEDIMP,															\
							  IS_STATIC,														\
							  IS_EXTERN,														\
							  KEY,                                                              \
                              void,open_##KEY##_controller,_with,UIViewController *controller,  \
                              UIViewController*,get_##KEY##_controller,_with_,                  \
                              UIViewController *vc =,                                           \
                              [[LJRouter sharedInstance] openViewController:vc                  \
                                                                 withSender:controller];,       \
						      ##__VA_ARGS__)

#define __LJRouterUsePageObjImp(NEEDIMP,IS_STATIC,IS_EXTERN,KEY, ...)                           \
        __LJRouterUseFunction(NEEDIMP,															\
							  IS_STATIC,														\
							  IS_EXTERN,														\
							  KEY,                                                              \
                              UIViewController*,get_##KEY##_controller,_with,void,              \
                              UIViewController*,get_##KEY##_controller,_with_,                  \
                              return,                                                           \
                              ,                                                                 \
                              ##__VA_ARGS__)


#define __LJRouterUseActionImp(NEEDIMP,IS_STATIC,IS_EXTERN,KEY,RETURNTYPE, ...)                 \
		__LJRouterUseFunction(NEEDIMP,															\
							  IS_STATIC,														\
							  IS_EXTERN,														\
						      KEY,                                                              \
                              RETURNTYPE,action_##KEY,_with,void,                               \
                              RETURNTYPE,action_##KEY,_with_,                                   \
                              LJ_ROUTER_IS_VOID(RETURNTYPE)()(return ),                         \
                              ,                                                                 \
                              ##__VA_ARGS__)

// 函数实现策略
#ifdef LJROUTER_ENABLE_IMP_ON_CALLER
	#define LJRouterUsePage(KEY, ...)                                                           \
		    __LJRouterUsePageImp(1,1,0,KEY,##__VA_ARGS__)
	#define LJRouterUsePageObj(KEY, ...)                                                        \
		    __LJRouterUsePageObjImp(1,1,0,KEY,##__VA_ARGS__)
	#define LJRouterUseAction(KEY,RETURNTYPE, ...)                                              \
			__LJRouterUseActionImp(1,1,0,KEY,RETURNTYPE,##__VA_ARGS__)

	#define __LJRouterUsePageImpPointer(KEY, ...)
	#define __LJRouterUsePageObjImpPointer(KEY, ...)
	#define __LJRouterUseActionImpPointer(KEY,RETURNTYPE, ...)

#else
	#define LJRouterUsePage(KEY, ...)                                                           \
		    __LJRouterUsePageImp(0,0,1,KEY,##__VA_ARGS__) ;
    #define LJRouterUsePageObj(KEY, ...)                                                        \
			__LJRouterUsePageObjImp(0,0,1,KEY,##__VA_ARGS__) ;
	#define LJRouterUseAction(KEY,RETURNTYPE, ...)                                              \
			__LJRouterUseActionImp(0,0,1,KEY,RETURNTYPE,##__VA_ARGS__) ;

	#define __LJRouterUsePageImpPointer(KEY, ...)                                               \
			__LJRouterUsePageImp(1,0,0,KEY,##__VA_ARGS__) ;
	#define __LJRouterUsePageObjImpPointer(KEY, ...)                                            \
			__LJRouterUsePageObjImp(1,0,0,KEY,##__VA_ARGS__) ;
	#define __LJRouterUseActionImpPointer(KEY,RETURNTYPE, ...)                                  \
			__LJRouterUseActionImp(1,0,0,KEY,RETURNTYPE,##__VA_ARGS__) ;
#endif

struct LJRouterInvocationStruct
{
    void* value;
    __unsafe_unretained NSString *name;
    __unsafe_unretained NSString *typeName;
    const char* typeEncoding;
};

extern Class LJRouterGetClassForKey(NSString* key);
    

