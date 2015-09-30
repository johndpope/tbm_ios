//
//  ZZGridPresenter+UserDialogs.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/29/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridPresenter.h"

@interface ZZGridPresenter (UserDialogs)

- (void)_showSendInvitationDialogForUser:(ZZContactDomainModel*)user;
- (void)_showConnectedDialogForModel:(ZZFriendDomainModel*)friendModel;
- (void)_showSmsDialogForModel:(ZZFriendDomainModel*)friendModel;
- (void)_showCantSendSmsErrorForModel:(ZZFriendDomainModel*)friendModel;
- (void)_nudgeUser:(ZZFriendDomainModel*)userModel;

@end