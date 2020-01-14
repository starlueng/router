//
//  DHRouter.m
//  Dating
//
//  Created by Stanleung on 2019/8/19.
//  Copyright © 2019 大好科技. All rights reserved.
//

#import "DHRouter.h"
#import <objc/runtime.h>
#import "Aspects.h"

NSString *const HQRouterResultController = @"_vc";
NSString *const HQRouterResultParameters = @"_p";
@interface DHRouter()

@end
@implementation DHRouter
+ (instancetype)shared
{
    static DHRouter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
@end
@implementation DHRouter (UIViewController)
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.failViewController = [UIViewController class];
    }
    return self;
}

static char kAssociatedFailViewControllerKey;
static char kAssociatedNavigationObjectKey;

+ (void)setFailClass:(Class)failViewController {
    [[DHRouter shared] setFailViewController:failViewController];
}

- (void)setFailViewController:(Class)failViewController
{
    objc_setAssociatedObject(self, &kAssociatedFailViewControllerKey, failViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Class)failViewController
{
    return objc_getAssociatedObject(self, &kAssociatedFailViewControllerKey);
}

+ (void)registerURLPattern:(NSString *)URLPattern toController:(Class)controller
{
    [self registerURLPattern:URLPattern toObjectHandler:^id(NSDictionary *routerParameters) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        if(controller)
        {
            [result setObject:controller forKey:HQRouterResultController];
        }
        
        if(routerParameters)
        {
            [result setObject:routerParameters forKey:HQRouterResultParameters];
        }
        return result;
    }];
}

+ (void)setNavigationController:(UINavigationController *)navigationController
{
    [[DHRouter shared] setNavigationController:navigationController];
}

- (void)setNavigationController:(UINavigationController *)navigationController
{
    objc_setAssociatedObject(self, &kAssociatedNavigationObjectKey, navigationController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationController *)navigationController
{
    return objc_getAssociatedObject(self, &kAssociatedNavigationObjectKey);
}

+ (UIViewController *)controllerForURL:(NSString *)URL
{
    return [self controllerForURL:URL withUserInfo:nil];
}

+ (UIViewController *)controllerForURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo
{
    NSDictionary *result = [DHRouter objectForURL:URL];
    Class cls;
    NSMutableDictionary *parameters;
    if([result isKindOfClass:[NSDictionary class]])
    {
        cls = result[HQRouterResultController];
        parameters = result[HQRouterResultParameters];
    }
    
    if(cls == nil)
    {
        cls = [DHRouter shared].failViewController;
    }
    
    if(userInfo)
    {
        [parameters setObject:userInfo forKey:MGJRouterParameterUserInfo];
    }
    
    UIViewController *vc;
    vc = [[cls alloc] init];
    vc.routerParams = parameters;
    return vc;
}

+ (void)pushURL:(NSString *)URL animated:(BOOL)animated
{
    [self pushURL:URL withUserInfo:nil animated:YES];
}

+ (void)presentURL:(NSString *)URL animated:(BOOL)animated
{
    [self presentURL:URL withUserInfo:nil animated:YES];
}

+ (void)pushURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo animated:(BOOL)animated
{
    DHRouter *router = [DHRouter shared];
    [router.navigationController pushViewController:[self controllerForURL:URL withUserInfo:userInfo] animated:animated];
}

+ (void)presentURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo animated:(BOOL)animated
{
    [[DHRouter shared].navigationController presentViewController:[self controllerForURL:URL withUserInfo:userInfo] animated:animated completion:nil];
}

@end

@implementation UIViewController (DHRouter)
static char kAssociatedHQRouterParamsObjectKey;

+ (void)load
{
    [self aspect_hookSelector:@selector(viewDidLoad) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){
        [aspectInfo.instance hq_registerRouter];
    } error:NULL];
    
    
    [self aspect_hookSelector:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo){
        [aspectInfo.instance hq_deregisterRouter];
    } error:NULL];
    
}


- (void)setRouterParams:(NSDictionary *)paramsDictionary
{
    objc_setAssociatedObject(self, &kAssociatedHQRouterParamsObjectKey, paramsDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)routerParams
{
    return objc_getAssociatedObject(self, &kAssociatedHQRouterParamsObjectKey);
}

- (void)hq_registerRouter {};

- (void)hq_deregisterRouter {};

@end
