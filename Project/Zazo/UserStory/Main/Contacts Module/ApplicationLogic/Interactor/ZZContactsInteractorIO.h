//
//  ZZMenuInteractorIO.h
//  zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZContactsInteractorInput <NSObject>

- (void)loadDataIncludeAddressBookRequest;
- (void)resetAddressBookData;
- (void)enableUpdateContactData;

@end


@protocol ZZContactsInteractorOutput <NSObject>

- (void)addressBookDataLoaded:(NSArray *)data;
- (void)addressBookDataLoadingDidFailWithError:(NSError *)error;
- (void)friendsThatHasAppLoaded:(NSArray *)friendsData;
- (void)friendsDataLoaded:(NSArray *)friendsData;
- (void)friendsDataLoadingDidFailWithError:(NSError *)error;
- (void)needsPermissionForAddressBook;

@end