//
// Created by Rinat on 01/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ZZAddContactButton : UIButton

@property(nonatomic, assign) BOOL isActive;

- (void)setPlusViewHidden:(BOOL)hidden animated:(BOOL)flag completion:(ANCodeBlock)completion;

@end