//
//  ZZCommonModelsGenerator.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ANMessageDomainModel;
@class ZZUserDomainModel;

@interface ZZCommonModelsGenerator : NSObject

+ (ANMessageDomainModel*)feedbackModelWithUser:(ZZUserDomainModel*)user;

@end
