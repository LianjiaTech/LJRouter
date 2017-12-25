//
//  
//  LJRouterExportModule.h
//
//  Created by fover0 on 2017/5/31.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>

@interface LJRegistExportItemParam : NSObject

@property (nonatomic, readonly) BOOL    isRequire;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *typeName;
@property (nonatomic, readonly) NSString *typeEncoding;

@end

@interface LJRegistExportItem : NSObject

@property (nonatomic, readonly) BOOL isAction;
@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSString *categoryName;
@property (nonatomic, readonly) NSString *returnTypeName;
@property (nonatomic, readonly) NSString *returnTypeEncoding;
@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) NSString *keyDescription;
@property (nonatomic, readonly) NSArray<LJRegistExportItemParam*> *params;
@property (nonatomic, readonly) NSString *selName;
@property (nonatomic, readonly) NSString *filepath;

@end

NSArray<LJRegistExportItem*>* loadAllRegItemByPath(NSString* path);

