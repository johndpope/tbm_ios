//
//  ZZHintsModelGenerator.h
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//


#import "ZZHintsConstants.h"
@class ZZHintsDomainModel;

@interface ZZHintsModelGenerator : NSObject

+ (ZZHintsDomainModel*)generateHintModelForType:(ZZHintsType)hintType;

@end

