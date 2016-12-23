//
//  AppDelegate.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/14.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "AppDelegate.h"
#import "Configure.h"
#import "FileManager.h"
#import "PathUtils.h"
#import "HomeTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    HomeTableViewController *vc=[[HomeTableViewController alloc]init];
    self.window.rootViewController=[[UINavigationController alloc]initWithRootViewController:vc];
    [self.window makeKeyAndVisible];
    
    /* -------- 全局UI设置 -------- */
    //文本框通用设置
    [[UITextField appearance] setTintColor:FIRST_FONTCOLOR];
    //导航栏通用设置
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc]init] ];
    [[UINavigationBar appearance] setTintColor:FIRST_FONTCOLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          FIRST_FONTCOLOR,NSForegroundColorAttributeName,
                                                          [UIFont boldSystemFontOfSize:20],
                                                          NSFontAttributeName
                                                          ,nil]];
    //设置自定义返回按钮图片
    [self setNaviBack];
//    [Configure sharedConfigure];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSString *tempPath = [documentPath() stringByAppendingPathComponent:@"temp"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
        for (NSString *path in paths) {
            NSError *err = nil;
            [[NSFileManager defaultManager] removeItemAtPath:[tempPath stringByAppendingPathComponent:path] error:&err];
            NSLog(@"%@",err);
        }
    });

    return YES;
}

/**
 *  设置自定义返回按钮图片
 */
- (void)setNaviBack{
    UINavigationBar * navigationBar = [UINavigationBar appearance];
    //设置返回样式图片
    UIImage *image = [UIImage imageNamed:@"arrow_left"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navigationBar.backIndicatorImage = image;
    navigationBar.backIndicatorTransitionMaskImage = image;
    UIBarButtonItem *buttonItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]];
    UIOffset offset;
    offset.horizontal = - 500;
    offset.vertical =  - 500;
    [buttonItem setBackButtonTitlePositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *path = url.path;
    NSString *name = [path componentsSeparatedByString:@"/"].lastObject;
    NSData *content = [NSData dataWithContentsOfURL:url];
    FileManager *fm = [FileManager sharedManager];
    
    NSString *parentPath = [localWorkspace() stringByAppendingPathComponent:ZHLS(@"Recieved")];
    [fm createFolder:parentPath];
    
    Item *i = [[Item alloc]init];
    i.path = [ZHLS(@"Recieved") stringByAppendingPathComponent:name];
    i.cloud = NO;
    
    NSString *ret = [fm createFile:i.fullPath Content:content];
    if (ret == nil) {
        showToast(ZHLS(@"Error"));
        return YES;
    }
    i.path = ret;

    fm.currentItem = i;
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[Configure sharedConfigure] saveToFile];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[Configure sharedConfigure] saveToFile];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}




@end
