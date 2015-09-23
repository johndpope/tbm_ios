//
//  ZZHintsController.m
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsController.h"
#import "ZZHintsView.h"
#import "ZZHintsModelGenerator.h"
#import "ZZHintsViewModel.h"
#import "ZZHintsDomainModel.h"

@interface ZZHintsController ()

@property (nonatomic, strong) ZZHintsView* hintsView;

@end

@implementation ZZHintsController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.hintsView];
    }
    return self;
}

- (void)showHintWithType:(ZZHintsType)type focusOnView:(UIView*)view withIndex:(NSInteger)index formatParameter:(NSString*)parameter
{
    UIView* focusView = view;
    ZZHintsDomainModel *model = [ZZHintsModelGenerator generateHintModelForType:type];
    if (!ANIsEmpty(parameter))
    {
        model.formatParameter = parameter;
    }
    ZZHintsViewModel *viewModel = [ZZHintsViewModel viewModelWithItem:model];
    
    if (model.type == ZZHintsTypeEditFriends)
    {
        focusView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 44, 0, 44, 64)];
    }
    
    [viewModel updateFocusFrame:focusView.frame];
    
    if ((model.type == ZZHintsTypeWelcomeNudgeUser) || model.type == ZZHintsTypeWelcomeFor)
    {
        [self.hintsView updateWithHintsViewModel:viewModel andIndex:index];
    }
    else
    {
        [self.hintsView updateWithHintsViewModel:viewModel];
    }
}

#pragma mark - Lazy Load

- (ZZHintsView*)hintsView
{
    if (!_hintsView)
    {
        _hintsView = [[ZZHintsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    return _hintsView;
}

@end
