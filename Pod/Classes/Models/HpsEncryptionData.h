//  Copyright (c) 2016 Heartland Payment Systems. All rights reserved.

#import <Foundation/Foundation.h>

@interface HpsEncryptionData : NSObject

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *encryptedTrackNumber;
@property (nonatomic, strong) NSString *ktb;
@property (nonatomic, strong) NSString *ksn;

@end
