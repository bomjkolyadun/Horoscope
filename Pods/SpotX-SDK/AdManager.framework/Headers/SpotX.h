//
//  Copyright (c) 2015 spotxchange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotXView.h"

/**
 SpotX serves as a single entry point to initializing the SDK
 and optionally configuring some default settings.

 ## Usage

 // File: AppDelegate.m

 #import <UIKit/UIKit.h>
 #import <AdManager/SpotX.h>

 @implementation AppDelegate

 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
	// Required: Initialize SpotX SDK
	[SpotX initializeWithApiKey:nil category:@"IAB1" section:@"Fiction"
         domain:@"www.spotxchange.com"
         url:@"https://itunes.apple.com/us/app/spotxchange_advertisments/id123456789"];

	// Optional: Set default channel id
	[SpotX setDefaultChannelID:"110681"];

	// Optional: Configure default settings
	id<SpotXAdSettings> settings = [SpotX defaultSettings];
	settings.useHTTPS = @YES;
	settings.useNativeBrowser = @YES;
	settings.allowCalendar = @NO;

	// Optional: Configure default custom parameters (Custom Taxonomy)
	[SpotX setDefaultParameters:@{
    @"custom_param": @"custom_value"
	}];

	return YES;
 }

 @end
 */
@interface SpotX : NSObject

/**
 Initializes the SpotX SDK.

 @param key Reserved for future use. May be nil.
 @param category IAB category of your app. May be nil.
 @param section IAB category subsection of your app. May be nil.
 @param domain WWW domain of your app's website. May be nil.
 @param url Apple App Store url of your app. May be nil.
 */
+ (NSString *)version;

+ (void)initializeWithApiKey:(NSString *)key
                    category:(NSString *)category
                     section:(NSString *)section
                      domain:(NSString *)domain
                         url:(NSString *)url;

/**
 Reserved for future use.
 */
+ (NSString *)apiKey;

/**
 IAB category
 */
+ (NSString *)category;

/**
 IAB category subsection
 */
+ (NSString *)section;

/**
 WWW domain of your app's website
 */
+ (NSString *)domain;

/**
 Apple App Store url of your app.
 */
+ (NSString *)appStoreUrl;

/**
 Default settings used to initialize SpotXView instances.
 */
+ (id<SpotXAdSettings>)defaultSettings;

/**
 Sets a default channel id, used to initialize new SpotXView instances.
 */
+ (void)setDefaultChannelID:(NSString *)channelID;

/**
 Dictionary of additional parameters to "pass-thru" when making the ad request,
 also referred to as custom taxonomy.
 */
+ (void)setDefaultParameters:(NSDictionary *)parameters;

@end


/**
 SpotXAdSettings encapsulates all of the "tunable" settings for ad playback.
 */
@protocol SpotXAdSettings <NSObject>

@property (nonatomic, strong) NSNumber *useHTTPS;
@property (nonatomic, strong) NSNumber *useNativeBrowser;
@property (nonatomic, strong) NSNumber *allowCalendar;
@property (nonatomic, strong) NSNumber *allowPhone;
@property (nonatomic, strong) NSNumber *allowSMS;
@property (nonatomic, strong) NSNumber *allowStorage;
@property (nonatomic, strong) NSNumber *autoplay;
@property (nonatomic, strong) NSNumber *skippable;
@property (nonatomic, strong) NSNumber *muted;
@property (nonatomic, strong) NSNumber *trackable;

@end


/**
 SpotXAdDelegate defines all of the callbacks available for the ad lifecycle.

 ## Required

 There is one required method: -presentViewController:. The SDK will call this
 method when it needs to show a particular UIViewController instance. Examples
 include interstitial ads, SMS composer, builtin browser.
 */
@protocol SpotXAdDelegate <NSObject>

@required
- (void)presentViewController:(UIViewController *)viewControllerToPresent;

@optional
- (void)adLoaded;
- (void)adStarted;
- (void)adSkipped;
- (void)adVolumeChanged;
- (void)adClosed;
- (void)adCompleted;
- (void)adClicked;
- (void)adError:(NSString *)error;
- (void)adFailedWithError:(NSError *)error;
@end