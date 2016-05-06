//
//  SMTableContainerView.h
//  Zazo
//
//  Created by ANODA on 1/13/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ANTableContainerView : UIView

@property (nonatomic, strong) UITableView *tableView;

+ (instancetype)containerWithTableViewStyle:(UITableViewStyle)style;

- (instancetype)initWithStyle:(UITableViewStyle)style;

@end
