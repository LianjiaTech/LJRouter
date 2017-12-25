//
//
//  LJRouterExportModule.m
//
//  Created by fover0 on 2017/5/31.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>
#import <fcntl.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <sys/mman.h>
#import <stdio.h>
#import <unistd.h>
#import "LJRouterExportModule.h"

#import "../Core/LJRouterPrivate.h"

@interface LJRegistExportItemParam ()

@property (nonatomic, assign) BOOL    isRequire;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, copy) NSString *typeEncoding;
@property (nonatomic, copy) NSString *paramDescription;

@end

@implementation LJRegistExportItemParam

- (NSString*)description
{
    return [NSString stringWithFormat:@"name:%@\n"
                                       "type:%@\n"
                                    "require:%@",
                                        self.name,
                                        self.typeName,
                                        self.isRequire?@"必须":@"可选"];
}
@end

@interface LJRegistExportItem ()
@property (nonatomic, assign) BOOL isAction;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *returnTypeName;
@property (nonatomic, copy) NSString *returnTypeEncoding;
@property (nonatomic, copy) NSString *returnAttrDesp;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *keyDescription;
@property (nonatomic, retain) NSArray<LJRegistExportItemParam*> *params;
@property (nonatomic, copy) NSString *selName;
@property (nonatomic, copy) NSString *filepath;

@end

@implementation LJRegistExportItem
- (NSString*)description
{
    return [NSString stringWithFormat:@"className:%@\n"
                                             "key:%@\n"
                                     "description:%@",
                                             self.className,
                                             self.key,
                                             self.keyDescription];
}
@end

// 模拟一个假的结构体  引用C语言的结构体 内存布局是固定的
struct stringstruct {
    void* isa;
    uint64_t encoding;
    char* cstring;
    uint64_t len;
};

static void* getPointerFromAddr(void*data , void* offset)
{
    uint8_t *pointer = (uint8_t*)((uint8_t*)data + (uint32_t)offset);
    return pointer;
}

static NSString* getStringFromAddr(void *data, __unsafe_unretained NSString *offset)
{
    struct stringstruct *strStruct = getPointerFromAddr(data, (__bridge void*)offset);
    char* strPointer = getPointerFromAddr(data, strStruct->cstring);
    NSString *string = nil;
    if (strStruct->encoding == 0x000007D0) {
        string = [[NSString alloc] initWithBytes:strPointer length:strStruct->len * 2 encoding:NSUTF16LittleEndianStringEncoding];
    }
    else
    {
        string = [[NSString alloc] initWithBytes:strPointer length:strStruct->len encoding:NSUTF8StringEncoding];
    }
    return string;
}

static NSArray<LJRegistExportItem*>* readLJRouterStruct(void *data,struct section_64 *section)
{
    uint64_t routerSize = section->size/sizeof(struct LJRouterRegister);
    struct LJRouterRegister *Res = (struct LJRouterRegister *)((uint8_t*)data + section->offset);
    NSMutableArray *allItems = [[NSMutableArray alloc] init];
    for (int k = 0; k < routerSize; k++)
    {
        LJRegistExportItem *item = [[LJRegistExportItem alloc] init];
        [allItems addObject:item];
        item.isAction = Res[k].isAction;

        NSString *functionName = [NSString stringWithUTF8String:getPointerFromAddr(data, Res[k].objcFunctionName)];
        NSRange range = [functionName rangeOfString:@" "];
        functionName = [functionName substringWithRange:NSMakeRange(2, range.location - 2)];
        NSString *className = functionName;
        NSString *categroyName = nil;
        range = [functionName rangeOfString:@"("];
        if (range.length != 0)
        {
            className = [functionName substringToIndex:range.location];
            categroyName = [functionName substringWithRange:NSMakeRange(range.location + 1, functionName.length - 2 - className.length)];
        }
        item.className = className;
        item.categoryName = categroyName;

        item.returnTypeName = getStringFromAddr(data, Res[k].returnTypeName);
        item.returnTypeEncoding = [NSString stringWithUTF8String: getPointerFromAddr(data, Res[k].returnTypeEncoding)];

        item.key = getStringFromAddr(data, Res[k].key);
        item.keyDescription = getStringFromAddr(data, Res[k].keyDescription);
        item.selName = getStringFromAddr(data,Res[k].selName);
        item.filepath = [[NSString alloc] initWithUTF8String:getPointerFromAddr(data, Res[k].filePath)];

        NSMutableArray *paramsArray = nil;
        if (Res[k].paramscount)
        {
            paramsArray = [[NSMutableArray alloc] init];
        }
        item.params = paramsArray;

        // params
        uint32_t paramscount = Res[k].paramscount;
        struct LJRouterRegisterParam *params = getPointerFromAddr(data,Res[k].params);
        for(int l = 0; l < paramscount; l++)
        {
            LJRegistExportItemParam *p = [[LJRegistExportItemParam alloc] init];
            p.name = getStringFromAddr(data, params[l].name);
            p.typeName = getStringFromAddr(data, params[l].typeName);
            const char *typeEncoding = getPointerFromAddr(data, params[l].typeEncoding);
            p.typeEncoding = [NSString stringWithUTF8String:typeEncoding] ;
            p.isRequire = params[l].isRequire;
            [paramsArray addObject:p];
        }
    }
    return allItems;
}

NSArray<LJRegistExportItem*>* loadAllRegItemByPath(NSString* path)
{
    // 全局
    NSArray *allItems = nil;

    // 开始工作
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    NSString *file = path;

    int fileid = open(file.UTF8String, 0, O_RDONLY);
    off_t len = lseek(fileid, 0, SEEK_END);

    void *data =  mmap(NULL,
                       len,
                       PROT_READ,
                       MAP_PRIVATE,
                       fileid,
                       0);
    // 最最外层是fat
    // 最外层header
    struct mach_header_64 header = *((struct mach_header_64*)data);
    //    NSLog(@"header magic Number is %x",header.magic);
    if ((MH_MAGIC_64 != header.magic )&& (MH_CIGAM_64 != header.magic)) { // 忽略32位
        close(fileid);
        return nil;
    }
    // 第二层是 command // 强转为uint8是因为不强转 指针转换按照 操作系统长度操作 64位下就是8字节
    struct load_command *cmds = (struct load_command *)((uint8_t*)data + sizeof(struct mach_header_64));
    
    for (uint32_t i = 0 ; i < header.ncmds ; i++,cmds = (struct load_command *)((uint8_t*)cmds + cmds->cmdsize)) {
        // 如果是 segment_command_64(一般只关注2种 __DATA,__TEXT)
        //        则有第三层 section
        if (cmds->cmd != LC_SEGMENT_64) {
            continue;
        }
        struct segment_command_64 *segmentCmd = (struct segment_command_64 *)cmds;
        char *name = segmentCmd->segname;
        if (0 != strcmp(name, "__DATA")) {
            continue;
        }
        struct section_64 *secions = (struct section_64 *)((uint8_t*)cmds + sizeof(struct segment_command_64));

        for (uint32_t j = 0 ; j < segmentCmd->nsects ; j++, secions += 1)
        {
            if (0 == strcmp(secions->sectname, "__LJRouter"))
            {
                allItems = readLJRouterStruct(data, secions);
            }
            else
            {
                continue;
            }
        }
    }
    close(fileid);
    return allItems;
}



