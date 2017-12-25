//
//
//  LJRouterExportDevDocument.m
//
//  Created by fover0 on 2017/5/31.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>
#import <sys/stat.h>

#import "../ExportTool/LJRouterExportModule.h"

NSString *getHeaderFilePathWithFilePath(NSString *curPath, NSString* filePath,BOOL isPage)
{
    NSArray<NSString*> *paths = [filePath pathComponents];
    for (NSInteger i = paths.count - 2; i >=0 ; i--)
    {
        if ([paths[i] hasSuffix:@"Component"] || [paths[i] hasSuffix:@"Module"] )
        {
            return [curPath stringByAppendingFormat:@"/%@Header.h",paths[i]];
        }
    }
    return nil;
}

void writeStringToFile(NSString* string,NSString *file,NSMutableDictionary *opendFiles)
{
    if (!file.length)
    {
        return;
    }

    NSNumber *fileIdNumber = opendFiles[file];
    if (!fileIdNumber)
    {
        int fileid = open(file.UTF8String,O_RDWR | O_CREAT | O_TRUNC, S_IRWXU|S_IRUSR|S_IWUSR|S_IXUSR|S_IRGRP|S_IWGRP|S_IXGRP|S_IROTH|S_IWOTH|S_IXOTH);
        fileIdNumber = [NSNumber numberWithInt:fileid];
        opendFiles[file] = fileIdNumber;
    }
    write(fileIdNumber.intValue, string.UTF8String, strlen(string.UTF8String));
}
void closeAllFile(NSMutableDictionary* opendFiles)
{
    [opendFiles enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSNumber *obj, BOOL * _Nonnull stop) {
        close(obj.intValue);
    }];
}

static void printHeaders(NSMutableDictionary *opendFileId,
                         NSString *outputPath,
                         NSArray *items) {
    for (NSInteger printAction = 0 ; printAction < 2 ; printAction++)
    {
        for (LJRegistExportItem *item in items)
        {
            // 先输出page再输出action
            if (printAction == 0 && item.isAction)
            {
                continue;
            }
            if (printAction == 1 && !item.isAction)
            {
                continue;
            }
            NSString *path = getHeaderFilePathWithFilePath(outputPath,item.filepath, YES);

            NSMutableString *string = [[NSMutableString alloc] init];

            NSString *processedName = [item.keyDescription stringByReplacingOccurrencesOfString:@"//" withString:@"\n//"];

            [string appendFormat:@"// %@ : %@ \n",item.isAction ? @"action":@"页面",processedName];

            [string appendFormat:@"%@(%@",item.isAction ? @"LJRouterUseAction":@"LJRouterUsePage",
             item.key];

            if (item.isAction)
            {
                [string appendFormat:@", %@",item.returnTypeName];
            }

            for (LJRegistExportItemParam *param in item.params)
            {
                [string appendFormat:@", (%@)%@",param.typeName,param.name];
            }
            [string appendString:@");\n"];

            writeStringToFile(string, path, opendFileId);
        }
    }
}

static void printJson(NSArray<LJRegistExportItem*>*items,NSString *exportPath)
{


    NSMutableArray *pageArray = [[NSMutableArray alloc] init];
    NSMutableArray *actionArray = [[NSMutableArray alloc] init];
    [items enumerateObjectsUsingBlock:^(LJRegistExportItem * _Nonnull obj,
                                        NSUInteger idx,
                                        BOOL * _Nonnull stop) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        if (obj.isAction)
        {
            [actionArray addObject:dict];
        }
        else
        {
            [pageArray addObject:dict];
        }

        dict[@"key"] = obj.key;
        dict[@"actionDesc"] = obj.keyDescription;
        NSMutableArray *params = [[NSMutableArray alloc] init];
        dict[@"parameters"] = params;

        [obj.params enumerateObjectsUsingBlock:^(LJRegistExportItemParam * _Nonnull param, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
            [params addObject:paramDict];
            paramDict[@"name"] = param.name;
        }];
    }];

    NSError *parseError = nil;
    NSData *pageData = [NSJSONSerialization dataWithJSONObject:pageArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&parseError];
    [pageData writeToFile:[exportPath stringByAppendingString:@"/page.json"] atomically:YES];

    NSData *actionData = [NSJSONSerialization dataWithJSONObject:actionArray
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:&parseError];
    [actionData writeToFile:[exportPath stringByAppendingString:@"/action.json"] atomically:YES];
}

int main(int argc, const char **argv)
{
    char* buildDir = getenv("TARGET_BUILD_DIR");
    char* execPath = getenv("EXECUTABLE_PATH");
    char* projectDir = getenv("PROJECT_DIR");

    if (!buildDir || !execPath || !projectDir || argc < 2)
    {
        NSLog(@"没有参数");
        return 0;
    }
    BOOL exportJson = NO;
    const char *outputDir = "outputHeaders";
    for (int i = 1; i < argc; i++)
    {
        if (strcmp(argv[i],"--json") == 0)
        {
            exportJson = YES;
        }
        else
        {
            outputDir = argv[i];
        }
    }


    NSString *path = [[NSString alloc] initWithFormat:@"%s/%s",buildDir,execPath];
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%s/%s",projectDir,outputDir];

    NSLog(@"二进制文件为 %@",path);
    NSLog(@"输出目录为 %@",outputPath);

    mkdir(outputPath.UTF8String,ALLPERMS);

    NSArray *allItems = loadAllRegItemByPath(path);

    NSMutableDictionary *opendFileId = [[NSMutableDictionary alloc] init];

    // 写页面
    printHeaders(opendFileId, outputPath, allItems);

    if (exportJson == YES)
    {
        printJson(allItems,outputPath);
    }

    closeAllFile(opendFileId);
}


