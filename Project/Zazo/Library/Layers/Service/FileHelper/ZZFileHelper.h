//
//  ZZFileHelper.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@interface ZZFileHelper : NSObject


#pragma mark - Checks

+ (BOOL)isFileExistsAtURL:(NSURL*)fileURL;
+ (unsigned long long)fileSizeWithURL:(NSURL*)fileURL;
+ (BOOL)isFileValidWithFileURL:(NSURL*)fileURL;


#pragma mark - File Operations

+ (NSURL*)fileURLInDocumentsDirectoryWithName:(NSString*)fileName;
+ (void)deleteFileWithURL:(NSURL*)fileURL;

@end
