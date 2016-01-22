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

@protocol FBAdInstreamViewDelegate;

/*!
 A custom UIView representing an instream ad placement.
 */
@interface FBAdInstreamView : UIView

/*!
 The delegate
 */
@property (nonatomic, weak) id<FBAdInstreamViewDelegate> delegate;

/*!
 The placement id of the FBAdInstreamView instance.
 */
@property (nonatomic, copy, readonly) NSString *placementId;

/*!
 Returns the total duration of the ad video in seconds, or -2.0 if no ad is currently playing.
 */
@property (nonatomic, assign, readonly) NSTimeInterval adDuration;

/*!
 Returns the ad video remaining playback time in seconds, or -2.0 if no ad is currently playing.
 */
@property (nonatomic, assign, readonly) NSTimeInterval adRemainingTime;

/*!
 Returns the remaining time until an ad will be skippable, 0.0 if an ad is currently skippable,
 or -2.0 if an ad will never be skippable.
 */
@property (nonatomic, assign, readonly) NSTimeInterval adSkippableRemainingTime;

/*!
 Initializes an FBAdInstreamView with the given placement id.

 @param placementId The id of the ad placement.
 */
- (instancetype)initWithPlacementId:(NSString *)placementId;

/*!
 Begins loading ad content.

 You can implement `onAdLoaded:` and `onAdError:error:` methods
 of `FBAdInstreamViewDelegate` if you would like to be notified as loading succeeds or fails.
 */
- (void)loadAd;

/*!
 Begins loading ad content, with optional parameters. Provides the ability to override default SDK behavior.

 @param parameters Configuration parameters to be used
 */
- (void)loadAdWithParameters:(FBAdParameters *)parameters;

/*!
 This method may be called after the AdLoaded event notification is received, to begin ad playback.

 The `onAdStopped:` method of `FBAdInstreamViewDelegate` is called when the ad break has completed.
 */
- (void)startAd;

/*!
 This method should be called to communicate to the FBAdInstreamView instance that it must cease
 all ad playback immediately.

 This method must NOT be used to indicate user a user ad-skip request.  It should only be used to indicate
 that the parent layout is disappearing, for instance due to app navigation.
 */
- (void)stopAd;

/*!
 This method requests that playback of the current ad be paused.

 Calling this method has no effect if there is no ad showing, or if the ad is currently paused.
 */
- (void)pauseAd;

/*!
 This method requests that playback of the current ad be resumed.

 Calling this method has no effect if there is no ad showing, or if the ad is already playing.
 */
- (void)resumeAd;

/*!
 This method requests that the currently-playing ad be skipped.

 Calling this method has no effect if there is no ad showing, or if the ad currently showing is not skippable.
 */
- (void)skipAd;

@end


/*!
 The methods declared by the FBAdInstreamViewDelegate protocol enable the adopting delegate to respond
 to messages from an FBAdInstreamView instance, and thus respond to events such as whether the ad has
 been loaded, the user has clicked the ad, etc.
 */
@protocol FBAdInstreamViewDelegate <NSObject>

@required

/*!
 Called when an ad has been successfully loaded.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdLoaded:(FBAdInstreamView *)adView;

/*!
 Called when all ad operation has concluded, and it is time to return to content.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdStopped:(FBAdInstreamView *)adView;

/*!
 Can be called in place of onAdLoaded: or onAdStopped:, to indicate that an error
 occurred that halted ad loading or playback, and it is time to return to content.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdError:(FBAdInstreamView *)adView
            error:(NSError *)error;

@optional

/*!
 Called after startAd has been called, and ad playback is about to begin.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdStarted:(FBAdInstreamView *)adView;

/*!
 Called on each ad impression event.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdImpression:(FBAdInstreamView *)adView;

/*!
 Called when a video ad will begin playback.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdVideoStart:(FBAdInstreamView *)adView;

/*!
 Called when a video ad has reach 25% of its play time.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdVideoFirstQuartile:(FBAdInstreamView *)adView;

/*!
 Called when a video ad has reach 50% of its play time.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdVideoMidpoint:(FBAdInstreamView *)adView;

/*!
 Called when a video ad has reach 75% of its play time.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdVideoThirdQuartile:(FBAdInstreamView *)adView;

/*!
 Called when a video ad has completed playback.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdVideoComplete:(FBAdInstreamView *)adView;

/*!
 Sent when an ad has been clicked by the user.

 @param adView The FBAdInstreamView object sending the message.
 @param url The URL of the landing page, if any
 @param appHandles Whether the app code must handle display of the landing page
 */
- (void)onAdClickThrough:(FBAdInstreamView *)adView
                     url:(NSString *)url
              appHandles:(BOOL)appHandles;

/*!
 Called when a video ad has been skipped. Note that this event does not indicate
 that ad operation has concluded. The onAdStopped: and onAdError: methods are the only
 indicators that it is time to return to content.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdSkipped:(FBAdInstreamView *)adView;

/*!
 Called when a video ad has become skippable. After this call is received, the skipAd method
 of FBAdInstreamView may be called any time during the remaining duration of the ad.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdSkippable:(FBAdInstreamView *)adView;

/*!
 Called when the adDuration property has changed.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdDurationChange:(FBAdInstreamView *)adView;

/*!
 Called when ad playback has been paused.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdPaused:(FBAdInstreamView *)adView;

/*!
 Called when ad playback has resumed after being paused.

 @param adView The FBAdInstreamView object sending the message.
 */
- (void)onAdResumed:(FBAdInstreamView *)adView;

@end
