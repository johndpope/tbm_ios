//
//  ZZMenuDataSource.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuDataSource.h"
#import "ANMemoryStorage.h"

@implementation ZZMenuDataSource

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.storage = [ANMemoryStorage storage];
    }
    return self;
}

- (void)setupAddressbookItems:(NSArray*)items
{
    [self _addItems:items toSection:ZZMenuSectionsAddressbook];
}

- (void)setupFriendsItems:(NSArray*)items
{
    [self _addItems:items toSection:ZZMenuSectionsFriends];
}


#pragma mark - Private

- (void)_addItems:(NSArray*)items toSection:(NSUInteger)sectionIndex
{
    items = [[items.rac_sequence map:^id(id value) {
        return [ZZMenuCellViewModel viewModelWithItem:value];
    }] array];
    
    [self.storage removeSections:[NSIndexSet indexSetWithIndex:sectionIndex]]; // TODO: handle animations
    if (!ANIsEmpty(items))
    {
        [self.storage addItems:items toSection:sectionIndex];
    }
}

@end