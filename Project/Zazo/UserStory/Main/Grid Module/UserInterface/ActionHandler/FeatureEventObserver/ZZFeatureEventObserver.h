//
//  ZZFeatureEventObserver.h
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionHandlerEnums.h"
#import "ZZGridCellViewModel.h"

typedef NS_ENUM(NSInteger, ZZUnlockFeatureType) {
    ZZUnlockFeatureTypeNone,
    ZZUnlockFeatureTypeBothCameraEnabled
};

@protocol ZZFeatureEventObserverDelegate <NSObject>

- (void)handleUnlockFeatureWithType:(ZZGridActionFeatureType)type;

@end


@interface ZZFeatureEventObserver : NSObject


@property (nonatomic, weak) id <ZZFeatureEventObserverDelegate> delegate;

- (void)handleEvent:(ZZGridActionEventType)event withModel:(ZZGridCellViewModel*)model;

@end