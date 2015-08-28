//
//  ZZSecretScreenWireframe.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenWireframe.h"
#import "ZZSecretScreenInteractor.h"
#import "ZZSecretScreenVC.h"
#import "ZZSecretScreenPresenter.h"
#import "ZZStrategyNavigationLeftRight.h"
#import "ZZEnvelopStrategy.h"
#import "ZZTouchControllerWithTouchDelay.h"
#import "ZZTouchControllerWithoutDelay.h"
#import "OBLogViewController.h"
#import "ZZDebugStateWireframe.h"

@interface ZZSecretScreenWireframe ()

@property (nonatomic, strong) ZZSecretScreenPresenter* presenter;
@property (nonatomic, strong) ZZSecretScreenVC* secretScreenController;
@property (nonatomic, strong) UINavigationController* presentedController;
@property (nonatomic, strong) UINavigationController* presentingController;
@property (nonatomic, strong) UIWindow* observedWindow;
@property (nonatomic, strong) ZZBaseTouchController* touchController;

@end

@implementation ZZSecretScreenWireframe

- (void)presentSecretScreenControllerFromNavigationController:(UINavigationController *)nc
{
    ZZSecretScreenVC* secretScreenController = [ZZSecretScreenVC new];
    ZZSecretScreenInteractor* interactor = [ZZSecretScreenInteractor new];
    ZZSecretScreenPresenter* presenter = [ZZSecretScreenPresenter new];
    
    self.presentingController = [[UINavigationController alloc] initWithRootViewController:secretScreenController];
    interactor.output = presenter;
    
    secretScreenController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:secretScreenController];
    
    self.presentedController = nc;
    
    ANDispatchBlockToMainQueue(^{
        [self.presentedController presentViewController:self.presentingController animated:YES completion:nil];
    });
    
    self.presenter = presenter;
    self.secretScreenController = secretScreenController;
}

- (void)dismissSecretScreenController
{
    [self.presentedController dismissViewControllerAnimated:YES completion:nil];
}

- (void)startSecretScreenObservingWithFirstTouchDelay:(CGFloat)delay
                                             withType:(ZZSecretScreenObserveType)type
                                           withWindow:(UIWindow*)window
{
    
    self.touchController = [[ZZTouchControllerWithTouchDelay alloc] initWithDelay:1 withStrategy:[self strategyWithType:type] withCompletionBlock:^{
            [self presentSecretScreenControllerFromNavigationController:(UINavigationController*)window.rootViewController];
    }];
    
    [self startObserveWithWindow:window];
}


- (void)startSecretScreenObserveWithType:(ZZSecretScreenObserveType)type withWindow:(UIWindow*)window
{
    self.touchController = [[ZZTouchControllerWithoutDelay alloc] initWithStrategy:[self strategyWithType:type] withCompletionBlock:^{
        [self presentSecretScreenControllerFromNavigationController:(UINavigationController*)window.rootViewController];
    }];
    [self startObserveWithWindow:window];
}

- (id<ZZSecretScreenStrategy>)strategyWithType:(ZZSecretScreenObserveType)type
{
    id <ZZSecretScreenStrategy> strategy;
    switch (type)
    {
        case ZZNavigationBarLeftRightObserveType:
        {
            strategy = [ZZStrategyNavigationLeftRight new];
        } break;
            
        case ZZEnvelopObserveType:
        {
            strategy = [ZZEnvelopStrategy new];
        } break;
            
        default: break;
    }
    return strategy;
}

- (void)startObserveWithWindow:(UIWindow*)window
{
    [[window rac_signalForSelector:@selector(sendEvent:)] subscribeNext:^(RACTuple *touches) {
        for (id event in touches)
        {
            NSSet* touches = [event allTouches];
            UITouch* touch = [touches anyObject];
            [self.touchController observeTouch:touch withEvent:event];
        };
    }];
}


#pragma mark - Detail Controllers

- (void)presentLogsController
{
    OBLogViewController* vc = [OBLogViewController instance];
    [self.secretScreenController.navigationController pushViewController:vc animated:YES];
}

- (void)presentStateController
{
    ZZDebugStateWireframe* wireframe = [ZZDebugStateWireframe new];
    [wireframe presentDebugStateControllerFromNavigationController:self.secretScreenController.navigationController];
}

@end