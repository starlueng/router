//
//  DHRouterHelper.m
//  Dating
//
//  Created by Stanleung on 2019/8/19.
//  Copyright © 2019 大好科技. All rights reserved.
//

#import "DHRouterHelper.h"
#import "DHRouter.h"
@implementation DHRouterHelper
+ (void)loadRouterOfFile:(NSString *)path
{
    NSDictionary *routerDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    [routerDict enumerateKeysAndObjectsUsingBlock:^(NSString *router, NSString *vc, BOOL * _Nonnull stop) {
        [DHRouter registerURLPattern:router toController:NSClassFromString(vc)];
    }];
}
@end
