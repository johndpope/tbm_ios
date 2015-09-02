//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMRecordHintPresenter.h"
#import "TBMEventsFlowModuleDataSourceInterface.h"
#import "TBMHintView.h"
#import "TBMRecordHintView.h"
#import "TBMPlayHintPresenter.h"
#import "TBMEventHandlerDataSource.h"


@implementation TBMRecordHintPresenter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMRecordHintView new];
        self.eventHandlerDataSource.persistentStateKey = @"kRecordHintNSUDkey";
    }
    return self;
}

- (NSUInteger)priority
{
    return 900;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{

    if (event != TBMEventFlowEventMessageDidStopPlaying
            && event != TBMEventFlowEventFriendDidAdd
            && event != TBMEventFlowEventMessageDidReceive
            && event != TBMEventFlowEventApplicationDidLaunch)
    {
        return NO;
    }

    return ![dataSource messageRecordedState] && [dataSource friendsCount] == 1;

}

- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule
{
    if (![self.eventFlowModule isAnyHandlerActive])
    {
        [super presentWithGridModule:gridModule];
        [self setupRecordTip];
        [self didPresented];
    }
    else if ([[self.eventFlowModule currentHandler] respondsToSelector:@selector(addRecordHint)])
    {
        [[self.eventFlowModule currentHandler] performSelector:@selector(addRecordHint)];
        [self didPresented];
    }
}

#pragma mark Add play hint implementation

- (void)addPlayHint
{
    [(TBMRecordHintView *) self.dialogView addPlayTip];
}

- (void)setupRecordTip
{
    [(TBMRecordHintView *) self.dialogView setupRecordTip];
}
@end