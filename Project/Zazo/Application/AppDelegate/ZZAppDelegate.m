//
//  ANAppDelegate.m
//  Zazo
//
//  Created by ANODA on 4/27/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAppDelegate.h"
#import "ZZAppDependencies.h"

@interface ZZAppDelegate ()

@property (nonatomic, strong) ZZAppDependencies * appDependencies;

@end

@implementation ZZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.appDependencies initialApplicationSetup:application launchOptions:launchOptions];
    [self.appDependencies installRootViewControllerIntoWindow:self.window];
    [self.appDependencies installAppDependences];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication*)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)newDeviceToken
{
    [self.appDependencies handleApplicationDidRegisterForPushWithToken:newDeviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    ANLogError(error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self.appDependencies handleApplication:application didRecievePushNotification:userInfo];
}

- (BOOL)application:(UIApplication*)application
            openURL:(NSURL*)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [self.appDependencies handleOpenURL:url inApplication:sourceApplication];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.appDependencies handleApplicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.appDependencies handleApplicationWillTerminate];
}


#pragma mark - Private

- (ZZAppDependencies *)appDependencies
{
    if (!_appDependencies)
    {
        _appDependencies = [ZZAppDependencies new];
    }
    return _appDependencies;
}

@end
