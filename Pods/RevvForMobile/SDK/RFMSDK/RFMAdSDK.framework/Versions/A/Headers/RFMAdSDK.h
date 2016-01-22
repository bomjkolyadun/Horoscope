//
//  RFMAdSDK.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 5/19/14.
//  Copyright (c) 2014 Rubicon Project. All rights reserved.
//

@import UIKit;

#import <RFMAdSDK/RFMAdConstants.h>
#import <RFMAdSDK/RFMAdView.h>
#import <RFMAdSDK/RFMAdRequest.h>
#import <RFMAdSDK/RFMAdDelegate.h>
#import <RFMAdSDK/RFMSupportedMediations.h>
#import <RFMAdSDK/RFMBaseMediator.h>
#import <RFMAdSDK/RFMMediationHelper.h>
#import <RFMAdSDK/RFMBaseMediatorDelegate.h>

/**
 * Main interface for including RFMAdSDK headers
 *
 */

@interface RFMAdSDK : NSObject

/** @name Logging */

/**
 * Set log level
 *
 * Use this method to enable logging in RFMAdSDK. Logging is disabled by default ( kRFMSDKLogLevelOff ).
 *
 * @param logLevel See RFMSDKLogLevel for allowed logging levels.
 *
 */
+(void)setLogLevel:(enum RFMSDKLogLevel)logLevel;

@end
