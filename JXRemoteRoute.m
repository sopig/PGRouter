//
//  JXRemoteRoute.m
//  jiuxian
//
//  Created by 张正超 on 16/3/15.
//  Copyright © 2016年 jiuxian.com. All rights reserved.
//

#import "JXRemoteRoute.h"
#import "JXInternelRoute.h"
#import "JXViewControllers.h"

@implementation JXRemoteRoute

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    return [self routeURL:url];

}


- (BOOL)routeURL:(NSURL *)url{
    
    NSString *scheme = url.scheme;
    NSString *absoluteString = url.absoluteString;
    NSString *resourceSpec = url.resourceSpecifier;

    if ([scheme isEqualToString:@"jiuxian"]) {
        
        //统计渠道来源
        NSString *from = url.query;
        if (from) {
            NSArray *p = [from componentsSeparatedByString:@"="];
            if (p && [p containsObject:@"from"]) {
                [MobClick event:[NSString stringWithFormat:@"from_%@_jump",[p safeObjectAtIndex:1]] label:@""];
            }
        }
        
        //webview页
        if ([absoluteString rangeOfString:JX_WEBREQUEST_URL_ACTIVITYPAGE].location != NSNotFound ||
            [absoluteString rangeOfString:JX_WEBREQUEST_URL_BAIJIU].location != NSNotFound ||
            [absoluteString rangeOfString:JX_WEBREQUEST_URL_YANGJIU].location != NSNotFound ||
            [absoluteString rangeOfString:JX_WEBREQUEST_URL_PUTAOJIU].location != NSNotFound ) {
            JXWebViewController *web =[JXWebViewController new];
            web.webTitle = @"加载中...";
            web.urlString = [NSString stringWithFormat:@"http:%@",resourceSpec];
            JXPushViewController(web);
        }
        
        //手机专享
        else if ([absoluteString rangeOfString:JX_WEBREQUEST_URL_SHOUJIZHUANXIANG].location != NSNotFound) {
            JXPhoneExclusiveController *vc = [JXPhoneExclusiveController new];
            JXPushViewController(vc);
        }
        //掌上秒拍
        else if ([absoluteString rangeOfString:JX_WEBREQUEST_URL_MIAOPAI].location != NSNotFound) {
            JXMSViewController *msvc = [JXMSViewController new];
            JXPushViewController(msvc);
        }
        //商品详情页
        else if ([absoluteString rangeOfString:JX_WEBREQUEST_URL_GOODSDETAIL].location != NSNotFound) {
        
            NSString *string = [absoluteString lastPathComponent];
            NSArray *array = [string componentsSeparatedByString:@"?"];
            NSString *goodsId = [array firstObject];
            [JXProductBrowseHistoryClient ADD_ProductBrowseHistory:@{@"proId" : goodsId} result:nil];
            
            JXGoodsDetailPageViewController *JXGDVC = [JXGoodsDetailPageViewController new];
            JXGDVC.goodsId = goodsId;
            JXPushViewController(JXGDVC);
            
            [[JXUMLinkStatisticsManager shareManager] umEventWithPage:@"active" event:@"event"];
        }
    
 }
    return YES;
}

@end
