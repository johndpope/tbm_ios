//
//  ZZKeyStoreOutgoingVideoStatusDomainModel.m
//  Zazo
//
//  Created by Sani Elfishawy on 10/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZKeyStoreOutgoingVideoStatusDomainModel.h"
#import "FEMObjectMapping.h"

const struct ZZKeyStoreOutgoingVideoStatusDomainModelAttributes ZZKeyStoreOutgoingVideoStatusDomainModelAttributes = {
    .friendMkey     = @"friendMkey",
    .statusNumber   = @"statusNumber",
    .videoId        = @"videoId",
};

const struct ZZKeyStoreOutgoingVideoStatusValues ZZKeyStoreOutgoingVideoStatusValues = {
    .outgoingVideoStatusDownloaded = @"downloaded",
    .outgoingVideoStatusViewed     = @"viewed",
};

@implementation ZZKeyStoreOutgoingVideoStatusDomainModel

+ (FEMObjectMapping*)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {
        
        [mapping addAttributesFromDictionary:@{
           ZZKeyStoreOutgoingVideoStatusDomainModelAttributes.friendMkey   : @"mkey",
           ZZKeyStoreOutgoingVideoStatusDomainModelAttributes.videoId      : @"video_id",
        }];
        
        FEMAttribute* statusAttr =
            [FEMAttribute mappingOfProperty:ZZKeyStoreOutgoingVideoStatusDomainModelAttributes.statusNumber
                                  toKeyPath:@"status"
                                        map:^NSNumber * (NSString* value){
                                            return [self outgoingVideoStatusWithRemoteStatus:value];
                                        }];
        
        [mapping addAttribute:statusAttr];
    }];
}

+ (NSNumber *)outgoingVideoStatusWithRemoteStatus:(NSString *)remoteStatus
{
    if ([remoteStatus isEqualToString:ZZKeyStoreOutgoingVideoStatusValues.outgoingVideoStatusDownloaded])
    {
        return [NSNumber numberWithInteger:OUTGOING_VIDEO_STATUS_DOWNLOADED];
    }
    
    if ([remoteStatus isEqualToString:ZZKeyStoreOutgoingVideoStatusValues.outgoingVideoStatusViewed])
    {
        return [NSNumber numberWithInteger:OUTGOING_VIDEO_STATUS_VIEWED];
    }
    if (ANIsEmpty(remoteStatus))
    {
        return [NSNumber numberWithInt:OUTGOING_VIDEO_STATUS_NONE];
    }
    return [NSNumber numberWithInt:OUTGOING_VIDEO_STATUS_UNKNOWN];
}

- (TBMOutgoingVideoStatus) status{
    return [self.statusNumber integerValue];
}

@end