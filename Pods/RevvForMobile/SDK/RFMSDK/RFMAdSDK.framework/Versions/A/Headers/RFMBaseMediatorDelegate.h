//
//  RFMBaseMediatorDelegate.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/17/14.
//  Copyright (c) 2014 Rubicon Project. All rights reserved.
//

#import "RFMMediationConstants.h"
@class RFMAdView;
@class RFMBaseMediator;

@protocol RFMBaseMediatorDelegate <NSObject>

@required
-(UIViewController *)viewControllerForPresentingModalView;
-(void)mediator:(RFMBaseMediator *)mediator didFailToLoadAdWithReason:(NSString *)errorReason;
-(void)mediator:(RFMBaseMediator *)mediator didFinishLoadingAd:(UIView *)adView;

-(RFMAdView *)rfmAdView;

-(adLoadingStatusTypes)getAdLoadingStatus;
-(void)changeAdLoadingStatus:(adLoadingStatusTypes)newStatus;
-(void)changeAdLoadingStatusToPrevious;
-(BOOL)isPlacementInterstitial;


// Sent just before presenting a full ad landing view, in response to clicking
// on an ad. Use this opportunity to stop animations, time sensitive interactions, etc.
-(void)mediator:(RFMBaseMediator *)mediator willPresentFullScreenModalFromAd:(UIView *)adView
      withFrame:(CGRect)frame isEmbedded:(BOOL)embedded;
// Sent just after presenting a full ad landing view, in response to clicking
// on an ad
-(void)mediator:(RFMBaseMediator *)mediator didPresentFullScreenModalFromAd:(UIView *)adView
      withFrame:(CGRect)frame isEmbedded:(BOOL)embedded;

// Sent just before dismissing the full ad landing view, in response to clicking
// of close/done button on the landing view
-(void)mediator:(RFMBaseMediator *)mediator willDismissFullScreenModalFromAd:(UIView *)adView
     isEmbedded:(BOOL)embedded;

// Sent just after dismissing a full screen view. Use this opportunity to
// restart anything you may have stopped as part of -willPresentFullScreenModalFromAd:.
-(void)mediator:(RFMBaseMediator *)mediator didDismissFullScreenModalFromAd:(UIView *)adView
     isEmbedded:(BOOL)embedded;

//Interstitial
-(void)mediator:(RFMBaseMediator *)mediator willDismissInterstitial:(UIView *)adView;
-(void)mediator:(RFMBaseMediator *)mediator didDismissInterstitial:(UIView *)adView;

-(void)mediator:(RFMBaseMediator *)mediator swapAdViewWithNewView:(UIView *)adView;
-(void)mediator:(RFMBaseMediator *)mediator willResizeAdView:(UIView *)view
        toFrame:(CGRect)newFrame isModal:(BOOL)modal;

-(void)mediator:(RFMBaseMediator *)mediator didFailToDisplayAdWithReason:(NSString *)errorReason;
-(void)mediator:(RFMBaseMediator *)mediator didDisplayAd:(UIView *)adView;


@end
