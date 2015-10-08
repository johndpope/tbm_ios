//
//  ZZGridPresenter+ActionHandler.m
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridPresenter+ActionHandler.h"
#import "ZZGridPresenterInterface.h"
#import "ZZGridDataSource.h"
#import "ZZGridActionHandler.h"

@implementation ZZGridPresenter (ActionHandler)


- (void)_handleEvent:(ZZGridActionEventType)event withDomainModel:(ZZGridDomainModel*)model
{
    ANDispatchBlockToMainQueue(^{
        NSInteger index = [[self dataSource] indexForUpdatedDomainModel:model];
        if (index != NSNotFound)
        {
            [[self actionHandler] handleEvent:event withIndex:index];
        }
    });
}

- (void)_handleInviteEvent
{
    ANDispatchBlockToMainQueue(^{
        CGFloat delayAfterViewDownloaded = 2.0f;
        ANDispatchBlockAfter(delayAfterViewDownloaded, ^{
            if ([[self dataSource] frindsOnGridNumber] == 0)
            {
                NSInteger indexForInviteEvent = 5;
                [[self actionHandler] handleEvent:ZZGridActionEventTypeDontHaveFriends withIndex:indexForInviteEvent];
            }
        });
    });
}

- (void)_handleRecordHintWithCellViewModel:(ZZFriendDomainModel*)model
{
    ANDispatchBlockToMainQueue(^{
        NSInteger index = [[self dataSource] indexForFriendDomainModel:model];
        if (index != NSNotFound)
        {
            [[self actionHandler] handleEvent:ZZGridActionEventTypeMessageDidPlayed withIndex:index];
        }
    });
}

- (void)_handleSentMessageEventWithCellViewModel:(ZZGridCellViewModel*)cellViewModel
{
    ANDispatchBlockToMainQueue(^{
//        if ([[self dataSource] frindsOnGridNumber] == 1)
//        {
            CGFloat delayAfterUploadAnimationStopped = 0.5f;
            ANDispatchBlockAfter(delayAfterUploadAnimationStopped, ^{
                NSInteger index = [[self dataSource] indexForViewModel:cellViewModel];
                if (index != NSNotFound)
                {
                    [[self actionHandler] handleEvent:ZZGridActionEventTypeMessageDidSent withIndex:index];
                }
            });
//        }
    });
}

- (void)_handleSentWelcomeHintWithFriendDomainModel:(ZZFriendDomainModel*)model
{
    ANDispatchBlockToMainQueue(^{
        NSInteger index = [[self dataSource] indexForFriendDomainModel:model];
        if (index != NSNotFound)
        {
            CGFloat delayAfterAddFriendToGridAnimation = 1.7f;
            ANDispatchBlockAfter(delayAfterAddFriendToGridAnimation, ^{
                [[self actionHandler] handleEvent:ZZGridActionEventTypeFriendDidInvited withIndex:index];
            });
        }
    });
}

@end