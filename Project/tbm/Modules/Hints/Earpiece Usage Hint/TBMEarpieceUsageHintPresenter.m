//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEarpieceUsageHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMEarpieceUsageHintView.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMEarpieceUsageHintPresenter
- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMEarpieceUsageHintView new];
        [self.dialogView setupDialogViewDelegate:self];
        self.eventHandlerDataSource.persistentStateKey = @"kEarpieceUsageUsageHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 1300;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    return event == TBMEventFlowEventEarpieceUnlockDialogDidDismiss;
}

- (void)dialogDidDismiss
{
    [super dialogDidDismiss];

    [self.eventFlowModule throwEvent:TBMEventFlowEventFeatureUsageHintDidDismiss];
}

@end