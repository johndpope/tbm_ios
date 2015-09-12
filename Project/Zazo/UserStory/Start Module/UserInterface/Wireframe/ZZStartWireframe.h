//
//  ZZStartWireframe.h
//  Versoos
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZStartWireframe : NSObject

- (void)presentStartControllerFromWindow:(UIWindow*)window;
- (void)presentStartControllerFromNavigationController:(UINavigationController*)nc;
- (void)dismissStartController;


#pragma mark - Details

- (void)presentMenuControllerWithGrid;
- (void)presentRegistrationController;

@end