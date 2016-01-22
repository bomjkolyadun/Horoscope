// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

#import <FacebookAdsSDK/FBAdParameters.h>

@protocol FBAdInterstitialDelegate;

/*!
 An object to represent an interstitial ad. This
 is a full-screen ad shown in your application.
 */
@interface FBAdInterstitial : NSObject

/*!
 The delegate
 */
@property (nonatomic, weak) id<FBAdInterstitialDelegate> delegate;

/*!
 Initializes and returns an instance of FBAdInterstitial.

 @param placementId The id of the ad placement.
 */
- (instancetype)initWithPlacementId:(NSString *)placementId NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/*!
 Begins loading ad content.
 You can implement `onAdLoaded:` and `onAdError:error:` methods of `FBAdInterstitialDelegate`,
 if you would like to be notified as loading succeeds or fails.
 */
- (void)loadAd;

/*!
 Begins loading ad content, with optional parameters. Provides the ability to override default SDK behavior.

 @param parameters Configuration parameters to be used
 */
- (void)loadAdWithParameters:(FBAdParameters *)parameters;

/*!
 Presents the interstitial ad modally.  Specify the presenting view controller
 using the `rootViewController` method of `FBAdInterstitialDelegate`
 The `onAdStopped:` method of `FBAdInterstitialDelegate` is called when
 the interstitial has completed and been removed from the view hierarchy
 */
- (void)startAd;

@end

/*!
 The methods declared by the FBAdInterstitialDelegate protocol enable the adopting delegate to respond
 to messages from an FBAdBannerView instance, and thus respond to events such as whether the ad has
 been loaded, the user has clicked the ad, etc.
 */
@protocol FBAdInterstitialDelegate <NSObject>

@optional

/*!
 Sent when an ad has been successfully loaded.

 @param interstitial The FBAdInterstitial object sending the message.
 */
- (void)onAdLoaded:(FBAdInterstitial *)interstitial;

/*!
 Sent when an FBAdInterstitial is presenting an ad modally.

 @param interstitial The FBAdInterstitial object sending the message.
 */
- (void)onAdStarted:(FBAdInterstitial *)interstitial;

/*!
 Sent on ad impression.

 @param interstitial The FBAdInterstitial object sending the message.
 */
- (void)onAdImpression:(FBAdInterstitial *)interstitial;

/*!
 Sent when an ad has been clicked by the user.

 @param interstitial The FBAdInterstitial object sending the message.
 @param url The URL of the landing page, if any
 @param appHandles Whether the app code must handle display of the landing page
 */
- (void)onAdClickThrough:(FBAdInterstitial *)interstitial
                     url:(NSString *)url
              appHandles:(BOOL)appHandles;

/*!
 Sent when the FBAdInterstitial ad has been dismissed from the screen,
 returning control to the application.

 @param interstitial The FBAdInterstitial object sending the message.
 */
- (void)onAdStopped:(FBAdInterstitial *)interstitial;

/*!
 Sent when an FBAdInterstitial fails to load or show an ad.

 @param interstitial The FBAdInterstitial object sending the message.
 @param error An error object describing the error.
 */
- (void)onAdError:(FBAdInterstitial *)interstitial
            error:(NSError *)error;

/*!
 Asks the delegate for a view controller to present modal content.

 @return A view controller that is used to present modal content.
 */
- (UIViewController *)rootViewController;


@end
