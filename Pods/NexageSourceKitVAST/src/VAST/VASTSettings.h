//
//  VASTSettings.h
//  VAST
//
//  Created by Muthu on 6/12/14.
//  Copyright (c) 2014 Nexage. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString* kVASTKitVersion;
extern const int kMaxRecursiveDepth;
extern const float kPlayTimeCounterInterval;
extern const NSTimeInterval  kVideoLoadTimeoutInterval;
extern const NSTimeInterval kFirstShowControlsDelay;
extern const BOOL kValidateWithSchema;

@interface VASTSettings : NSObject

+ (NSTimeInterval)vastVideoLoadTimeout;

+ (void)setVastVideoLoadTimeout:(NSTimeInterval)newValue;

@end

