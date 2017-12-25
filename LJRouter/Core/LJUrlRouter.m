//
//  LJUrlRouter.m
//  invocation
//
//  Created by fover0 on 2017/6/6.
//  Copyright(c) 2017 Lianjia, Inc. All Rights Reserved
//

#import "LJUrlRouter.h"

@implementation LJRouter(LJUrlRouterConfig)

static char LJUrlRouter_urlProcessorBlock_Key;
- (void)setUrlProcessorBlock:(NSURL *(^)(NSURL *))urlProcessorBlock
{
    objc_setAssociatedObject(self, &LJUrlRouter_urlProcessorBlock_Key, [urlProcessorBlock copy], OBJC_ASSOCIATION_RETAIN);
}
- (NSURL *(^)(NSURL *))urlProcessorBlock
{
    return objc_getAssociatedObject(self, &LJUrlRouter_urlProcessorBlock_Key);
}

static char LJUrlRouter_createWebviewBlock_Key;
- (void)setCreateWebviewBlock:(UIViewController *(^)(NSString *))createWebviewBlock
{
    objc_setAssociatedObject(self, &LJUrlRouter_createWebviewBlock_Key, [createWebviewBlock copy], OBJC_ASSOCIATION_RETAIN);
}
- (UIViewController *(^)(NSString *))createWebviewBlock
{
    return objc_getAssociatedObject(self, &LJUrlRouter_createWebviewBlock_Key);
}

@end


@implementation UIViewController(LJUrlRouter)

+ (void)LJSetWebViewControllerBlock:(__kindof UIViewController *(^)(NSString *))block
{
    LJRouter.sharedInstance.createWebviewBlock = block;
}


- (BOOL)LJOpenUrlString:(NSString *)url
{
    if (url.length == 0)
    {
        return NO;
    }

    BOOL canRout =
    [[LJRouter sharedInstance] routerUrlString:url
                                        sender:self
                                     pageBlock:^(__kindof UIViewController *viewController) {
                                         [[LJRouter sharedInstance] openViewController:viewController withSender:self];
                                     }
                                 callbackBlock:nil
                             canNotRouterBlock:nil];
    if (!canRout)
    {
        UIViewController *(^webviewBlock)(NSString *) = [LJRouter sharedInstance].createWebviewBlock;

        UIViewController *webVC = webviewBlock ? webviewBlock(url) : nil;
        if (webVC)
        {
            canRout = YES;
            [[LJRouter sharedInstance] openViewController:webVC withSender:self];
        }
    }
    return canRout;
}

@end



static NSString *const uq_URLReservedChars  = @"￼=,!$&'()*+;@?\r\n\"<>#\t :/";
static NSString *const kQuerySeparator      = @"&";
static NSString *const kQueryDivider        = @"=";
static NSString *const kQueryBegin          = @"?";
static NSString *const kFragmentBegin       = @"#";

@implementation LJRouter(LJUrlRouter)

- (NSDictionary*)uq_URLQueryDictionary:(NSString*)string {
    NSMutableDictionary *mute = @{}.mutableCopy;
    for (NSString *query in [string componentsSeparatedByString:kQuerySeparator]) {
        NSArray *components = [query componentsSeparatedByString:kQueryDivider];
        if (components.count == 0) {
            continue;
        }
        NSString *key = [components[0] stringByRemovingPercentEncoding];
        id value = nil;
        if (components.count == 1) {
            // key with no value
            value = [NSNull null];
        }
        if (components.count == 2) {
            value = [components[1] stringByRemovingPercentEncoding];
            // cover case where there is a separator, but no actual value
            value = [value length] ? value : [NSNull null];
        }
        if (components.count > 2) {
            // invalid - ignore this pair. is this best, though?
            continue;
        }
        mute[key.lowercaseString] = value ?: [NSNull null];
    }
    return mute.count ? mute.copy : nil;
}

- (void)decodeUrlString:(NSString*)urlString
				 outkey:(NSString**)outKey
				outData:(NSDictionary**)outData
{
	if (urlString.length == 0)
	{
		*outKey = nil;
		*outData = @{};
		return;
	}

	NSURL * url = [NSURL URLWithString:urlString];
	if (!url)
	{
		urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		url = [NSURL URLWithString:urlString];
	}

    NSURL* (^urlProcessor)(NSURL*) = [LJRouter sharedInstance].urlProcessorBlock;
    if (urlProcessor && url.absoluteString.length)
    {
        url = urlProcessor(url);
    }

    if (url.absoluteString.length == 0 || url.host.length == 0)
    {
        *outKey = nil;
        *outData = @{};
        return;
    }

    NSMutableString *key = [[NSMutableString alloc] initWithString:url.host];
    for (NSString *path in url.pathComponents)
    {
        if (![path isEqualToString:@"/"])
        {
            [key appendFormat:@"_%@",path];
        }
    }
    NSDictionary *data = [self uq_URLQueryDictionary:url.query];

    *outKey = key;
    *outData = data;
}

- (BOOL)canOpenUrlString:(NSString *)url
{
    NSString *key = nil;
    NSDictionary *data = nil;
    [self decodeUrlString:url outkey:&key outData:&data];
    return [self canRouterKey:key data:data];
}

- (BOOL)routerUrlString:(NSString *)url
				 sender:(UIResponder *)sender
			  pageBlock:(void (^)(__kindof UIViewController *))pageBlock
          callbackBlock:(void (^)(NSString *, NSString *, NSString *, BOOL))callbackBlock
      canNotRouterBlock:(void (^)(void))canNotRouterBlock
{
    NSString *key = nil;
    NSDictionary *data = nil;
    [self decodeUrlString:url outkey:&key outData:&data];
    return [self routerKey:key
                      data:data
                    sender:sender
                 pageBlock:pageBlock
             callbackBlock:callbackBlock
         canNotRouterBlock:canNotRouterBlock];
}

@end


