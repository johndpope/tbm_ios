//
//  TBMUploadManager.h
//  tbm
//
//  Created by Sani Elfishawy on 5/14/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMFileTransferManger.h"

@interface TBMUploadManager : TBMFileTransferManger
+ (instancetype)sharedManager;
@end
