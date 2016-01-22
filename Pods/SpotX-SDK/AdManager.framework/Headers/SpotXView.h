//
//  Copyright (c) 2015 spotxchange. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SpotXAdDelegate;
@protocol SpotXAdSettings;


/**
 SpotXView is the UIView subclass used to issue an ad request and play the
 returned video. After creating a SpotXView instance, call the -startLoading
 method to initiate the ad request. The SpotXView will notify its delegate
 of progress updates. You may present the view at any time, but the ad will
 not play until it has been loaded.
 */
@interface SpotXView : UIView

/**
 SpotXAdDelegate to receive ad notifications
 */
@property (nonatomic, assign) id<SpotXAdDelegate> delegate;

/**
 "Tunable" ad settings. Initialized as a copy of the [SpotX defaultSettings].
 */
@property (nonatomic, readonly) id<SpotXAdSettings> settings;

/**
 SpotX channel id. Initialized as a copy of [SpotX defaultChannelID].
 */
@property (nonatomic, strong) NSString *channelID;

/**
 Additional "pass-thru" parameters. Initialized as a copy of [SpotX defaultParameters].
 */
@property (nonatomic, strong) NSDictionary *params;


/**
 Initiates an ad request and starts the loading process.
 */
- (void)startLoading;

/**
 Presents this SpotXView as an interstitial. You must provide a delegate implementation.
 */
- (void)show;

@end
