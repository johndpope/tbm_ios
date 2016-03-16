//
//  ZZGridWireframe.h
//  Versoos
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuWireframe.h"
#import "ANMessageDomainModel.h"

@class ZZGridPresenter;

@interface ZZGridWireframe : NSObject

@property (nonatomic, strong) ZZGridPresenter* presenter;
@property (nonatomic, strong) ZZMenuWireframe* menuWireFrame;
@property (nonatomic, strong) UIViewController* gridController;

#pragma mark - Menu Events

- (void)toggleMenu;
- (void)closeMenu;

- (void)attachAdditionalPanGestureToMenu:(UIPanGestureRecognizer*)pan;


#pragma mark - Details

- (void)presentEditFriendsController;
- (void)presentSendFeedbackWithModel:(ANMessageDomainModel*)model;

- (void)presentSMSDialogWithModel:(ANMessageDomainModel*)model success:(ANCodeBlock)success fail:(ANCodeBlock)fail;
- (void)presentSharingDialogWithModel:(ANMessageDomainModel*)model success:(ANCodeBlock)success fail:(ANCodeBlock)fail;

@end
