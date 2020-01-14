//
//  DHRouter.h
//  Dating
//
//  Created by Stanleung on 2019/8/19.
//  Copyright © 2019 大好科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGJRouter.h"
@interface DHRouter : MGJRouter
+ (instancetype)shared;
@end

/**
 *  路由功能针对控制器的扩展
 *  示例:
 *  注册 [DHRouter registerURLPattern:@"hq://order" toController:[OrderViewController class]];
 *  使用 [HQRouter pushURL:@"hq://order?orderno=002" animated:YES];
 */
@interface DHRouter (UIViewController)
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) Class failViewController;

/** 注册 URLPattern 对应的 controller */
+ (void)registerURLPattern:(NSString *)URLPattern toController:(Class)controller;

/** 设置导航控制器 */
+ (void)setNavigationController:(UINavigationController *)navigationController;

+ (void)setFailClass:(Class)failViewController;

/** 返回一个控制器 !找不到返回一个默认控制器*/
+ (UIViewController *)controllerForURL:(NSString *)URL;

/** Push一个页面 */
+ (void)pushURL:(NSString *)URL animated:(BOOL)animated;
+ (void)pushURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo animated:(BOOL)animated;

/** Present一个页面 */
+ (void)presentURL:(NSString *)URL animated:(BOOL)animated;
+ (void)presentURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo animated:(BOOL)animated;
@end


@interface UIViewController (DHRouter)
@property (nonatomic, strong) NSDictionary * routerParams;

/** 注册路由 */
- (void)hq_registerRouter;

/** 注销路由 */
- (void)hq_deregisterRouter;
@end

