//
//  AppodealNativeAd.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 8/24/15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppodealNativeAd.h"

@class AppodealNativeAdService;

@protocol AppodealNativeAdServiceDelegate <NSObject>

@optional

- (void)nativeAdServiceDidLoad: (AppodealNativeAd*) nativeAd; // Use this method to get native ad instance
- (void)nativeAdServiceDidLoadSeveralAds __attribute__((deprecated));
- (void)nativeAdServiceDidFailedToLoad;

@end

@interface AppodealNativeAdService : NSObject

@property (weak, nonatomic) id<AppodealNativeAdServiceDelegate> delegate;
@property (assign, nonatomic, readonly, getter=isReady) BOOL ready;

- (void) loadAd;

- (AppodealNativeAd*) nextAd;

@end
