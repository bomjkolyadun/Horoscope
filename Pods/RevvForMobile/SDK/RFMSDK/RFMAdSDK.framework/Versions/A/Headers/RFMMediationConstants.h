//
//  RFMMediationConstants.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/17/14.
//  Copyright (c) 2014 Rubicon Project. All rights reserved.
//

#ifndef RFMAdSDK_RFMMediationConstants_h
#define RFMAdSDK_RFMMediationConstants_h

#define kAdParamsAdFrameKey @"adFrame"
#define kAdParamsAdContentKey @"rspData"
#define kAdParamsCreativeApiKey @"creativeApiType"
#define kAdParamsBaseUrlKey @"adurl"
#define kAdParamsAdContentTypeKey @"adContentType"
#define kAdParamsClickUrlKey @"clickURL"
#define kAdParamsAdViewInfoKey @"adViewInfo"
#define kAdParamsAdRequestKey @"adRequest"

#define kAdParamsAdPreCacheKey @"shouldPrecache"

#define AdViewInfoFullScreen @"fullScreen"
#define AdViewInfoSizePortraitWidth @"pwd"
#define AdViewInfoSizePortraitHeight @"pht"
#define AdViewInfoSizeLandscapeWidth @"lwd"
#define AdViewInfoSizeLandscapeHeight @"lht"

#define AdViewInfoShouldPrecache kAdParamsAdPreCacheKey

#define AdViewInfoCtInc @"ctInc"
#define AdviewInfoVastVideoPosition @"videopos"

#define kAdContentTypeHtml @"html"
#define kAdContentTypeJson @"json"
#define kAdContentTypeJavascript @"js"


//Mediation Names
#define kMediationTypeRfm @"rfm"
#define kMediationTypeMraid @"MRAID"
#define kMediationTypeRfmCaching @"cache"
#define kMediationTypeVast @"VAST"
//Third party mediations
#define kMediationTypeAdmob @"adm"
#define kMediationTypeDFP   @"dfp"
#define kMediationTypeiAd   @"iAd"

//Mediation class names
#define kMediationClassNameRfm @"RFMMediator"
#define kMediationClassNameMraid @"RFMMraidMediator"
#define kMediationClassNameRfmCaching @"RFMCachingMediator"
#define kMediationClassNameVast @"RFMVastMediator"

//Status enums for the AdView
typedef enum
{
    AD_INIT = 0,
    AD_BANNER_REQUESTED,
    AD_BANNER_DISPLAYED,
    AD_LANDING_DISPLAYED,
    AD_MODAL_LANDING_DISPLAYED,
    AD_INTERSTITIAL_REQUESTED,
    AD_INTERSTITIAL_DISPLAYED,
    AD_READY_TO_DISPLAY
}adLoadingStatusTypes;


#endif
