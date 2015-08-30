//
//  TBMAppDelegate.m
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMHomeViewController.h"
#import "TBMAppDelegate.h"
#import "TBMAppDelegate+Boot.h"
#import "TBMAppDelegate+PushNotification.h"
#import "TBMAppDelegate+AppSync.h"
#import "TBMStringUtils.h"
#import "OBFileTransferManager.h"
#import "TBMUser.h"
#import "TBMHttpManager.h"
#import "AVAudioSession+TBMAudioSession.h"
#import "TBMDispatch.h"
#import "TBMDependencies.h"
#import "ZZAppDependencies.h"

@interface TBMAppDelegate()

@property id <TBMAppDelegateEventNotificationProtocol> eventNotificationDelegate;
@property (nonatomic, copy) void (^registredToNotifications)(void);

@end

@implementation TBMAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Lifecycle callbacks

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    OB_INFO(@"willFinishLaunchingWithOptions:");
    // See doc/notification.txt for why we dont use this in our app for processing notifications.
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [TBMDispatch startRollBar];
    self.pushAlreadyFailed = NO;
    [self setupLogger];
    [self addObservers];
    
    OB_INFO(@"didFinishLaunchingWithOptions:");
    
    [self.appDependencies initialApplicationSetup:application launchOptions:launchOptions];
    [self.window makeKeyAndVisible];
    [self.appDependencies installRootViewControllerIntoWindow:self.window];
    
    [self boot];

    // See doc/notification.txt for why we handle the payload here as well as in didReceiveRemoteNotification:fetchCompletionHandler
    // for the case where app is launching from a terminated state due to user clicking on notification. Even though both this method
    // and the didReceiveRemoteNotification:fetchCompletionHandler are called in that case.
    NSDictionary *remoteNotificationUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationUserInfo){
        [self requestBackground];
        [self handleNotificationPayload:remoteNotificationUserInfo];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
    OB_INFO(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self setBadgeNumberDownloadedUnviewed];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    OB_INFO(@"applicationDidEnterBackground: backgroundTimeRemaining = %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
    self.isForeground = NO;
    [self saveContext];
    [[OBLogger instance] logEvent:OBLogEventAppBackground];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    OB_INFO(@"applicationWillEnterForeground");
    self.isForeground = YES;

    if (self.eventNotificationDelegate != nil)
        [self.eventNotificationDelegate appWillEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    OB_INFO(@"applicationDidBecomeActive");
    [self.appDependencies handleApplicationDidBecomeActive];
    self.isForeground = YES;
    
    if (self.eventNotificationDelegate !=  nil)
        [self.eventNotificationDelegate appDidBecomeActive];
    
    [self performDidBecomeActiveActions];
    [[OBLogger instance] logEvent:OBLogEventAppForeground];
}

- (void)applicationWillTerminate:(UIApplication *)application{
    OB_INFO(@"applicationWillTerminate: backgroundTimeRemaining = %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
    // Saves changes in the application's managed object context before the application terminates.
    [self.appDependencies handleApplicationWillTerminate];
    [self saveContext];
    [self removeObservers];
}





#pragma mark - Notification Observers

- (void)addObservers{
    [self addVideoProcessorObservers];
    [self addVideoRecordingObservers];
    
}


- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Logger
- (void)setupLogger{
    [OBLogger instance].writeToConsole = YES;
    if ([[OBLogger instance] logLines].count > 3000)
        [[OBLogger instance] reset];
}

//------------------------------------------------------
// Allow other object to register for event notification
//------------------------------------------------------
- (void)setLifeCycleEventNotificationDelegate:(id)delegate{
    self.eventNotificationDelegate = delegate;
}



//---------
// CoreData
//---------

#pragma mark - Core Data stack

- (void)saveContext{
    OB_INFO(@"saveContext");
    __block NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    __block NSError *error = nil;
    
    if (managedObjectContext != nil){
        [managedObjectContext performBlockAndWait:^{
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                OB_ERROR(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }];
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"tbm" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"tbm.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSDictionary *migrationOptions = @{
            NSMigratePersistentStoresAutomaticallyOption : @YES,
            NSInferMappingModelAutomaticallyOption : @YES
    };
    
    // Determine if a migration is needed
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error];
    NSManagedObjectModel *destinationModel = [_persistentStoreCoordinator managedObjectModel];
    BOOL pscCompatibile = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:migrationOptions error:&error]) {
        DebugLog(@"CoreData # Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else if (!pscCompatibile) {
        [self fillDataBaseAfterMigration];
    }
    
    return _persistentStoreCoordinator;
}

- (void)fillDataBaseAfterMigration {
    OB_INFO(@"Successfull Core Data migration. Trying to fill new fields");
    [TBMFriend fillAfterMigration];

}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


//----------------------------------
// Background URL Session Completion
//----------------------------------
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    OB_INFO(@"handleEventsForBackgroundURLSession: for sessionId=%@",identifier);
    OBFileTransferManager *tm = [OBFileTransferManager instance];
    if ([[tm session].configuration.identifier isEqual:identifier]){
        tm.backgroundSessionCompletionHandler = completionHandler;
    } else {
        OB_ERROR(@"handleEventsForBakcgroundURLSession passed us a different identifier from the one we instantiated our background session with.");
    }
}

//-------------------
// Request Background
//-------------------
-(void) requestBackground{
    OB_INFO(@"AppDelegate: requestBackground: called:");
    if ( self.backgroundTaskId == UIBackgroundTaskInvalid ) {
        OB_INFO(@"AppDelegate: requestBackground: requesting background.");
        self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            OB_INFO(@"AppDelegate: Ending background");
            // The apple docs say you must terminate the background task you requested when they call the expiration handler
            // or before or they will terminate your app. I have found however that if I dont terminate and if
            // the usage of the phone is low by other apps they will let us run in the background indefinitely
            // even after the backgroundTimeRemaining has long gone to 0. This is good for our users as it allows us
            // to continue retries in the background for a long time in the case of poor coverage.
            
            // Actually on iphone4s 7.0 I encountered this:
            // Feb 18 20:34:28 Sanis-iPhone backboardd[28] <Warning>: Zazo[272] has active assertions beyond permitted time:
            //            {(
            //              <BKProcessAssertion: 0x15ebf2a0> identifier: Called by Zazo, from -[TBMAppDelegate requestBackground] process: Zazo[272] permittedBackgroundDuration: 40.000000 reason: finishTaskAfterBackgroundContentFetching owner pid:272 preventSuspend  preventIdleSleep  preventSuspendOnSleep
            //              )}
            //            Feb 18 20:34:28 Sanis-iPhone backboardd[28] <Warning>: Forcing crash report of Zazo[272]...
            
        
            // So as of 2/19/2005 I have uncommented the line below.
            [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTaskId];
            [self saveContext];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
        }];
    }
    OB_INFO(@"AppDelegate: RequestBackground: exiting: refresh status = %ld, time Remaining = %f", (long)[UIApplication sharedApplication].backgroundRefreshStatus, [UIApplication sharedApplication].backgroundTimeRemaining);
}

- (void)onGrantedPushAccess
{
    [self _onGrantedPushAccess];
}

- (void)onFailPushAccess
{
    [self _onFailPushAccess];
}


#pragma mark - Lazy Load

- (UIWindow *)window
{
    if (!_window)
    {
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return _window;
}

- (ZZAppDependencies *)appDependencies
{
    if (!_appDependencies)
    {
        _appDependencies = [ZZAppDependencies new];
    }
    return _appDependencies;
}

@end