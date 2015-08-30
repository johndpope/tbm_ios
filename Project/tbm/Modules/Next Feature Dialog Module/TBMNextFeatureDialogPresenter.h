//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleEventHandler.h"
#import "TBMEventHandlerPresenter.h"

@protocol TBMHomeModuleInterface;
@protocol TBMFeatureUnlockModuleInterface;


@interface TBMNextFeatureDialogPresenter : TBMEventHandlerPresenter <TBMEventsFlowModuleEventHandler, TBMDialogViewDelegate>

/**
 * Home module needs for present bench
 */
- (void)setupHomeModule:(id <TBMHomeModuleInterface>)homeModule;

- (void)setupInviteSomeOneElseHintModule:(id <TBMEventsFlowModuleEventHandler>)inviteSomeOneElseHintModule;
/**
 * Feature unlock  module needs for check locked features
 */
- (void)setupFeatureUnlockModule:(id <TBMFeatureUnlockModuleInterface>)featureUnlockModule;

/**
 * View callback
 */
- (void)dialogDidTap;

@end