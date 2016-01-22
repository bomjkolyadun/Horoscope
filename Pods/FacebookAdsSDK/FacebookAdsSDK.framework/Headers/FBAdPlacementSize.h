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

#import <StoreKit/StoreKit.h>
#import <UIKit/UIKit.h>

/*!
 @abstract Represents the flexible banner ad size, where banner width depends on
 its container width, and banner height is fixed as 50pt.
 */
extern CGSize const FBAdPlacementSizeHeight50Banner;

/*!
 @abstract Represents the flexible banner ad size, where banner width depends on
 its container width, and banner height is fixed as 90pt.
 */
extern CGSize const FBAdPlacementSizeHeight90Banner;

/*!
 @abstract Represents the flexible rectangle ad size, where width depends on
 its container width, and height is fixed as 250pt.
 */
extern CGSize const FBAdPlacementSizeHeight250Rectangle;

/*!
 @abstract Represents a fixed banner ad size - 320pt by 50pt.
 */
extern CGSize const FBAdPlacementSize320x50;

/*!
 @abstract Represents a fixed banner ad size - 300pt by 250pt.
 */
extern CGSize const FBAdPlacementSize300x250;

/*!
 @abstract Represents a fixed banner ad size - 728pt by 90pt.
 */
extern CGSize const FBAdPlacementSize728x90;

/*!
 @abstract Represents the interstitial ad size.
 */
extern CGSize const FBAdPlacementSizeInterstital;
