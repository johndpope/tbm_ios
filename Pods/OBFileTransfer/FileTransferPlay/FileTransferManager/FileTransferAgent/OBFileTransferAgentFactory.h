//
//  OBFileTransferAgentFactory.h
//  FileTransferPlay
//
//  Created by Farhad on 7/18/14.
//  Copyright (c) 2014 NoPlanBees. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBFileTransferAgent.h"

@protocol OBFileTransferDelegate <NSObject>

-(void) fileTransferCompleted: (NSString *)markerId isUpload:(BOOL)isUpload withError: (NSError *)error;
-(void) fileTransferProgress: (NSString *)markerId isUpload:(BOOL)isUpload percent: (NSUInteger) progress;
-(void) fileTransferRetrying: (NSString *)markerId isUpload:(BOOL)isUpload attemptCount:(NSInteger)attemptCount withError: (NSError *)error;

@optional
-(void) transferProgress: (float) progress withMarker:(NSString *)markerId;

@end


@interface OBFileTransferAgentFactory : NSObject

+(OBFileTransferAgent *) fileTransferAgentInstance: (NSString *) remoteUrl;

@end
