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

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FBAdLinearSkinOption) {
    FBAdLinearSkinOptionNone,
    FBAdLinearSkinOptionDefault
};

/*!
 @class FBAdParameters

 @abstract FBAdParameters contains optional load parameters for
 FBAdBannerView, FBAdInterstitial, and FBAdInstreamView.
 */
@interface FBAdParameters : NSObject

/*!
 Number of times to retry failed ad creatives for a given opportunity.
 Default value is 1.
 */
@property (nonatomic, assign) NSUInteger maximumRetry;

/*!
 Timeout in seconds for client-side requests to ad sources.
 Default value is 10.0.
 */
@property (nonatomic, assign) NSTimeInterval adRequestTimeout;

/*!
 Timeout in seconds for loading ad creatives.
 Default value is 10.0.
 */
@property (nonatomic, assign) NSTimeInterval adCreativeTimeout;

/*!
 Maximum number of VAST wrapper responses to resolve (applies to video ad sources only).
 Default value is 3.
 */
@property (nonatomic, assign) NSUInteger wrapperLimit;

/*!
 Target bitrate to when selecting a creative media file.
 Default value is -1 (optimize based on network connection).
 */
@property (nonatomic, assign) NSInteger desiredBitrate;

/*!
 Current content position.
 Default value is 0.0 (pre-roll).
 */
@property (nonatomic, assign) NSTimeInterval contentPosition;

/*!
 Current content duration.
 Default value is 0.0 (no specified duration).
 */
@property (nonatomic, assign) NSTimeInterval contentDuration;

/*!
 Skin to use for linear ad creative rendering.
 Default value is FBAdLinearSkinOptionDefault.
 */
@property (nonatomic, assign) FBAdLinearSkinOption linearSkin;

/*!
 Custom message to use for communicating linear ad remaining time to the user.
 Default behavior is a localized message based on the user's language settings.
 */
@property (nonatomic, copy) NSString *countdownMessage;

/*!
 Custom message to use for noting linear ad pod position.
 Default behavior is a localized message based on the user's language settings.
 */
@property (nonatomic, copy) NSString *indexMessage;

/*!
 Custom message to use for the click element in the linear ad skin.
 Default behavior is a localized message based on the user's language settings.
 */
@property (nonatomic, copy) NSString *clickthroughMessage;

/*!
 Custom element to use for triggering click on a linear ad.  The SDK handles gesture recognition.
 Default is nil.
 */
@property (nonatomic, strong) UIView *clickElement;

/*!
 Custom message to use for communicating the remaining time until skip for linear ads.
 Default behavior is a localized message based on the user's language settings.
 */
@property (nonatomic, copy) NSString *skipCountdownMessage;

/*!
 Custom message to use for the skip element in the linear ad skin.
 Default behavior is a localized message based on the user's language settings.
 */
@property (nonatomic, copy) NSString *skipMessage;

/*!
 Custom message to use for the skip element in the linear ad skin.
 Default behavior is a localized message based on the user's language settings.
 */
@property (nonatomic, copy) NSString *storePicturePromptMessage;

/*!
 Custom message to use for the save action in a user confirmation dialog.
 Default behavior is a localized message based on the user's language settings.
 */
@property (nonatomic, copy) NSString *saveMessage;

/*!
 Custom message to use for the cancel action in a user confirmation dialog.
 Default behavior is a localized message based on the user's language settings.
 */
@property (nonatomic, copy) NSString *cancelMessage;

/*!
 Horizontal position for the skip control in a linear ad skin.
 Range is 0.0 (full left) to 1.0 (full right).
 Default is 1.0.
 */
@property (nonatomic, assign) CGFloat skipLayoutHorizontalPosition;

/*!
 Horizontal offset in points for the skip control in a linear ad skin.
 Default is 1.0.
 */
@property (nonatomic, assign) CGFloat skipLayoutHorizontalOffset;

/*!
 Vertical position for the skip control in a linear ad skin.
 Range is 0.0 (full top) to 1.0 (full bottom).
 Default is 1.0.
 */
@property (nonatomic, assign) CGFloat skipLayoutVerticalPosition;

/*!
 Vertical offset in points for the skip control in a linear ad skin.
 Default is based on UI_USER_INTERFACE_IDIOM() for the device.
 */
@property (nonatomic, assign) CGFloat skipLayoutVerticalOffset;

/*!
 Flag indicating whether the integration prefers to handle rendering of
 click-through landing pages, when possible.  This capability is not supported
 by all creatives.  The integration must refer to the url and appHandles arguments
 of the onAdClickThrough delegate method when this parameter is set to YES.
 Default is NO.
 */
@property (nonatomic, assign) BOOL appHandlesClick;

/*!
 Indicates whether you would like your ad control to be treated as child-directed
 Note that you may have other legal obligations under the Children's Online Privacy Protection Act (COPPA).
 Please review the FTC's guidance and consult with your own legal counsel.
 */
@property (nonatomic, assign) BOOL isChildDirected;

/*!
 Custom key-value pairs to use in ad requests.
 */
@property (nonatomic, strong) NSDictionary *customParameters;

@end
