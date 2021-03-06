//
//  ZZHintsViewModel.m
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsViewModel.h"
#import "ZZHintsDomainModel.h"
#import "ZZHintArrowConfigurationModel.h"

@interface ZZHintsViewModel ()

@property (nonatomic, strong) ZZHintsDomainModel *item;
@property (nonatomic, assign) CGRect focusFrame;
@property (nonatomic, assign) CGPoint arrowFocusPoint;

@end

@implementation ZZHintsViewModel

+ (instancetype)viewModelWithItem:(ZZHintsDomainModel *)item
{
    ZZHintsViewModel *model = [self new];
    model.item = item;

    return model;
}

- (void)updateFocusFrame:(CGRect)focusFrame
{
    self.focusFrame = focusFrame;
}

- (ZZHintsType)hintType
{
    return self.item.type;
}

- (CGPoint)generateArrowFocusPointForIndex:(NSInteger)index
{
    ZZHintArrowConfigurationModel *configurationModel = [self _modelDependsOnTypeWithIndex:index];
    return configurationModel.focusPoint;
}

- (NSArray *)_configurationModelsForShowCellBehavior
{
    return @[
            //0
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionBottomRight
                                                       arrowDirection:ZZArrowDirectionRight
                                                                angle:90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //1
            [ZZHintArrowConfigurationModel configureWithFocusPosition:kMiddleTopArrowFocusPositionDependsOnDevice()
                                                       arrowDirection:ZZArrowDirectionRight
                                                                angle:180
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //2
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionBottomLeft
                                                       arrowDirection:ZZArrowDirectionLeft
                                                                angle:-90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //3
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopRight
                                                       arrowDirection:ZZArrowDirectionLeft
                                                                angle:90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //4
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionMiddleRight
                                                       arrowDirection:ZZArrowDirectionLeft
                                                                angle:30
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //5
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopLeft
                                                       arrowDirection:ZZArrowDirectionRight
                                                                angle:-90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //6
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopRight
                                                       arrowDirection:ZZArrowDirectionLeft
                                                                angle:90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],

            //7
            [ZZHintArrowConfigurationModel configureWithFocusPosition:kMiddleBottomArrowFocusPositionDopendsOnDevice()
                                                       arrowDirection:ZZArrowDirectionLeft
                                                                angle:30
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],

            //8
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopLeft
                                                       arrowDirection:ZZArrowDirectionRight
                                                                angle:-90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],

    ];

}

- (NSArray *)_configuratoinModelsForSentAndViewedState
{
    return @[
            //0
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopRight
                                                       arrowDirection:ZZArrowDirectionRight
                                                                angle:90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //1
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopRight
                                                       arrowDirection:ZZArrowDirectionRight
                                                                angle:180
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //2
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopLeft
                                                       arrowDirection:ZZArrowDirectionLeft
                                                                angle:-90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //3
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopRight
                                                       arrowDirection:ZZArrowDirectionLeft
                                                                angle:90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //4 TODO://
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionMiddleRight
                                                       arrowDirection:ZZArrowDirectionLeft
                                                                angle:30
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //5
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopLeft
                                                       arrowDirection:ZZArrowDirectionRight
                                                                angle:-90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
            //6
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopRight
                                                       arrowDirection:ZZArrowDirectionLeft
                                                                angle:90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],

            //7
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopRight
                                                       arrowDirection:ZZArrowDirectionLeft
                                                                angle:30
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],

            //8
            [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionTopLeft
                                                       arrowDirection:ZZArrowDirectionRight
                                                                angle:-90
                                                           focusFrame:self.focusFrame
                                                             itemType:self.item.type],
    ];
}

- (ZZHintArrowConfigurationModel *)_modelDependsOnTypeWithIndex:(NSInteger)index
{
    ZZHintArrowConfigurationModel *configurationModel;

    switch (self.item.type)
    {
        case ZZHintsTypeInviteHint:
        case ZZHintsTypeRecordHint:
        case ZZHintsTypeRecrodWelcomeHint:
        case ZZHintsTypeSendWelcomeHint:
        case ZZHintsTypeAbortRecordingUsageHint:
        case ZZHintsTypeEarpieceUsageHint:
        case ZZHintsTypePlayHint:
        case ZZHintsTypeInviteSomeElseHint:
        case ZZHintsTypeFrontCameraUsageHint:
        case ZZHintsTypeFullscreenUsageHint:
        case ZZHintsTypePlaybackControlsUsageHint:            
        case ZZHintsTypeSpinUsageHint:
        case ZZHintsTypeSendWelcomeHintForFriendWithoutApp:
        case ZZHintsTypeRecordAndTapToPlay:
        {
            configurationModel = [self _configurationModelsForShowCellBehavior][index];

        }
            break;

        case ZZHintsTypeViewedHint:
        case ZZHintsTypeSentHint:
        {
            configurationModel = [self _configuratoinModelsForSentAndViewedState][index];

        }
            break;

//        case ZZHintsTypeGiftIsWaiting:
        case ZZHintsTypeDeleteFriendUsageHint:
        {
            configurationModel = [ZZHintArrowConfigurationModel configureWithFocusPosition:ZZHintArrowFocusPositionBottomLeft
                                                                            arrowDirection:ZZArrowDirectionLeft
                                                                                     angle:-90
                                                                                focusFrame:self.focusFrame
                                                                                  itemType:self.item.type];

        }
            break;

        case ZZHintsTypeWelcomeNudgeUser:
        {

        }
            break;

        default:
            break;
    }

    return configurationModel;
}


- (BOOL)hidesArrow
{
    return self.item.hidesArrow;
}

- (CGFloat)arrowAngle
{
    return self.item.angle;
}

- (CGFloat)arrowAngleForIndex:(NSInteger)index
{
    ZZHintArrowConfigurationModel *configurationModel = [self _modelDependsOnTypeWithIndex:index];
    return configurationModel.angle;
}


- (ZZArrowDirection)arrowDirection
{
    return self.item.arrowDirection;
}

- (ZZArrowDirection)arrowDirectionForIndex:(NSInteger)index
{
    ZZArrowDirection direction;
    ZZHintArrowConfigurationModel *configurationModel = [self _modelDependsOnTypeWithIndex:index];
    direction = configurationModel.arrowDirection;

    return direction;
}

- (NSString *)text
{
    if (self.item.formatParameter)
    {
        NSString *fulltext = [NSString stringWithFormat:NSLocalizedString(self.item.title, @""), self.item.formatParameter];
        return fulltext;
    }
    else
    {
        return self.item.title;
    }
}

- (ZZHintsBottomImageType)bottomImageType
{
    return self.item.imageType;
}


@end
