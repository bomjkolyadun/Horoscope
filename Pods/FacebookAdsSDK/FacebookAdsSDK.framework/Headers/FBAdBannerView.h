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

#import <UIKit/UIKit.h>

#import <FacebookAdsSDK/FBAdParameters.h>
#import <FacebookAdsSDK/FBAdPlacementSize.h>

@protocol FBAdBannerViewDelegate;

/*!
 A custom UIView representing a banner ad placement.
 */
@interface FBAdBannerView : UIView

/*!
 The placement id of the FBAdBannerView instance.
 */
@property (nonatomic, copy, readonly) NSString *placementId;

/*!
 The delegate
 */
@property (nonatomic, weak) id<FBAdBannerViewDelegate> delegate;
/*!
 Initializes an FBAdBannerView with the given placement id.

 @param placementId The id of the ad placement.
 @param placementSize The size of the ad placement.
 */

- (instancetype)initWithPlacementId:(NSString *)placementId
                      placementSize:(CGSize)placementSize;

/*!
 Begins loading ad content.
 You can implement `onAdLoaded:` and `onAdError:error:` methods
 of `FBAdBannerViewDelegate` if you would like to be notified as loading succeeds or fails.
 */
- (void)loadAd;

/*!
 Begins loading ad content, with optional parameters. Provides the ability to override default SDK behavior.

 @param parameters Configuration parameters to be used
 */
- (void)loadAdWithParameters:(FBAdParameters *)parameters;

@end


/*!
 The methods declared by the FBAdBannerViewDelegate protocol enable the adopting delegate to respond
 to messages from an FBAdBannerView instance, and thus respond to events such as whether the ad has
 been loaded, the user has clicked the ad, etc.
 */
@protocol FBAdBannerViewDelegate <NSObject>

@optional

/*!
 Sent when an ad has been successfully loaded.

 @param adView The FBAdBannerView object sending the message.
 */
- (void)onAdLoaded:(FBAdBannerView *)adView;

/*!
 Sent on ad impression.

 @param adView The FBAdBannerView object sending the message.
 */
- (void)onAdImpression:(FBAdBannerView *)adView;

/*!
 Sent when an ad has been clicked by the user.

 @param adView The FBAdBannerView object sending the message.
 @param url The URL of the landing page, if any
 @param appHandles Whether the app code must handle display of the landing page
 */
- (void)onAdClickThrough:(FBAdBannerView *)adView
                     url:(NSString *)url
              appHandles:(BOOL)appHandles;

/*!
 Sent after an FBAdBannerView fails to load the ad.

 @param adView The FBAdBannerView object sending the message.
 @param error An error object describing the error.
 */
- (void)onAdError:(FBAdBannerView *)adView
            error:(NSError *)error;

/*!
 Sent right before the ad will expand to a modal state

 @param adView The FBAdBannerView object sending the message.
 */
- (void)onAdExpanded:(FBAdBannerView *)adView;

/*!
 Sent when the ad has finished collapsing from a modal state

 @param adView The FBAdBannerView object sending the message.
 */
- (void)onAdCollapsed:(FBAdBannerView *)adView;

/*!
 Asks the delegate for a view controller to present modal content, such as the expanded
 state that can appear when an ad is clicked.

 @return A view controller that is used to present modal content.
 */
- (UIViewController *)rootViewController;

@end
