//
//  ZZAppDependencies.h
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZAppDependencies : NSObject

- (void)initialApplicationSetup:(UIApplication *)application launchOptions:(NSDictionary*)options;


#pragma mark - Application States

- (void)handleWillResignActive;
- (void)handleApplicationDidBecomeActive;
- (void)handleApplicationWillTerminate;
- (void)handleApplicationDidEnterInBackground;
- (void)handleApplicationWillEnterForeground;

#pragma mark - Open External URL

- (BOOL)handleOpenURL:(NSURL*)url inApplication:(NSString*)application;


#pragma mark - Notifications

- (void)handleApplicationDidRegisterForPushWithToken:(NSData*)token;
- (void)handlePushNotification:(NSDictionary*)userInfo;
- (void)handleNotificationSettings:(UIUserNotificationSettings*)settings;

- (void)handleApplicationDidFailToRegisterForRemoteNotifications;


#pragma mark - UI

- (void)installRootViewControllerIntoWindow:(UIWindow *)window;


#pragma mark - Background

- (void)handleBackgroundSessionWithIdentifier:(NSString*)identifier completionHandler:(ANCodeBlock)completionHandler;

@end
