//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <OBLogger/OBLogViewController.h>
#import "TBMSecretScreenPresenter.h"
#import "TBMSecretScreenViewController.h"
#import "TBMStateScreenViewController.h"
#import "TBMEventsFlowModuleInterface.h"
#import "TBMConfig.h"
#import "TBMDebugData.h"
#import "TBMStateDataSource.h"
#import "TBMDispatch.h"
#import "TBMEventsFlowModuleInterface.h"
#import "ZZStoredSettingsManager.h"

@interface TBMSecretScreenPresenter ()

@property(nonatomic, weak) UIViewController *presentedController;
@property(nonatomic, strong) UINavigationController *navigationController;
@property(nonatomic, strong) OBLogViewController *logScreen;
@property(nonatomic, strong) TBMSecretScreenViewController *secretScreen;
@property(nonatomic, strong) TBMStateScreenViewController *stateScreen;

@property(nonatomic, weak) id <TBMEventsFlowModuleInterface> tutorialModule;
@end

@implementation TBMSecretScreenPresenter

#pragma mark - Interface

- (void)presentSecretScreenFromController:(UIViewController *)presentedController
{
    OB_INFO(@"TBMSecretScreenPresenter: presentSecretScreenFromController");
    self.presentedController = presentedController;
    [presentedController presentViewController:self.navigationController animated:YES completion:nil];

}

- (void)assignTutorialModule:(id <TBMEventsFlowModuleInterface>)tutorialModule
{
    self.tutorialModule = tutorialModule;
}

#pragma mark - Initialization

- (UINavigationController *)navigationController
{
    if (!_navigationController)
    {
        _navigationController = [[UINavigationController alloc] initWithRootViewController:self.secretScreen];
    }
    return _navigationController;
}

- (OBLogViewController *)logScreen
{
    if (!_logScreen)
    {
        _logScreen = [OBLogViewController instance];
    }
    return _logScreen;
}

- (TBMSecretScreenViewController *)secretScreen
{
    if (!_secretScreen)
    {
        _secretScreen = [[TBMSecretScreenViewController alloc] initWithPresenter:self];
    }
    return _secretScreen;
}

- (TBMStateScreenViewController *)stateScreen
{
    if (!_stateScreen)
    {
        _stateScreen = [[TBMStateScreenViewController alloc] init];
    }
    return _stateScreen;
}

#pragma mark - Present child screens

- (void)presentLogScreen
{
    [self.navigationController pushViewController:self.logScreen animated:YES];
}

- (void)presentStateScreen
{
    TBMStateDataSource *data = [[TBMStateDataSource alloc] init];
    [data loadFriendsVideoObjects];
    [data loadVideos];
    [data excludeNonDanglingFiles];
    [self.stateScreen updateUserInterfaceWithData:data];
    [self.navigationController pushViewController:self.stateScreen animated:YES];
}

#pragma mark - Actions

- (void)reload
{
    [self.secretScreen reloadData];

}

- (void)dismiss
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - Event handling

- (void)backButtonDidPress
{
    [self dismiss];
}


- (void)dispatchButtonDidPress
{
    TBMDebugData *data = [[TBMDebugData alloc] init];
    [TBMDispatch dispatch:[data debugDescription]];
}

- (void)debugSwitchDidChangeTo:(BOOL)on
{
    [ZZStoredSettingsManager shared].debugModeEnabled = on;
    
    [self reload];
}

- (void)crashButtonDidPress
{
    TBMDebugData *data = [[TBMDebugData alloc] init];
    NSMutableString *crashReason = [@"!!!CRASH BUTTON EXCEPTION:" mutableCopy];
    [crashReason appendString:[data debugDescription]];
    NSArray *array = [NSArray array];
    [array objectAtIndex:2]; // forse crash!
}

- (void)logButtonDidPress
{
    [self presentLogScreen];
}

- (void)stateButtonDidPress
{

    [self presentStateScreen];
}

- (void)serverSegmentedControlDidChangeTo:(NSInteger)index {
    [ZZStoredSettingsManager shared].serverEndpointState = index;
    [self reload];
}

- (void)setCustomServerURL:(NSString *)url {
    
    [ZZStoredSettingsManager shared].serverURLString = url;
    [self reload];
}

- (void)resetHintsButtonDidPress
{
    [self.tutorialModule resetHintsState];
}
@end