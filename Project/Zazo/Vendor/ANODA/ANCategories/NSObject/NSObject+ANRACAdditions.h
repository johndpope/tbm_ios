//
//  NSObject+ANRACAdditions.h
//  Zazo
//
//  Created by ANODA on 1/4/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface NSObject (ANRACAdditions)

+ (void)an_handleSubcriber:(id <RACSubscriber>)subscriber withObject:(id)object error:(NSError *)error;

@end
