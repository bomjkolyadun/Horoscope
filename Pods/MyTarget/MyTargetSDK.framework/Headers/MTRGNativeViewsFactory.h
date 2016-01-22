//
//  MTRGNativeViewsFactory.h
//  myTargetSDK 4.3.0
//
//  Created by Anton Bulankin on 17.11.14.
//  Copyright (c) 2014 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <MyTargetSDK/MTRGNativeImageBanner.h>
#import <MyTargetSDK/MTRGNativeTeaserBanner.h>
#import <MyTargetSDK/MTRGNativePromoBanner.h>
#import <MyTargetSDK/MTRGNativeAppwallBanner.h>

#import <MyTargetSDK/MTRGNewsFeedAdView.h>
#import <MyTargetSDK/MTRGChatListAdView.h>
#import <MyTargetSDK/MTRGContentStreamAdView.h>
#import <MyTargetSDK/MTRGContentWallAdView.h>

#import <MyTargetSDK/MTRGAppwallBannerAdView.h>
#import <MyTargetSDK/MTRGAppwallAdView.h>

@interface MTRGNativeViewsFactory : NSObject

//Тизер с кнопкой
+(MTRGNewsFeedAdView *) createNewsFeedViewWithBanner:(MTRGNativeTeaserBanner *)teaserBanner;
//Тизер
+(MTRGChatListAdView *) createChatListViewWithBanner:(MTRGNativeTeaserBanner *)teaserBanner;
//Промо
+(MTRGContentStreamAdView *) createContentStreamViewWithBanner:(MTRGNativePromoBanner *)promoBanner;
//Картинка
+(MTRGContentWallAdView *) createContentWallViewWithBanner:(MTRGNativeImageBanner *)imageBanner;

//App-wall-баннер
+(MTRGAppwallBannerAdView *) createAppWallBannerViewWithBanner:(MTRGNativeAppwallBanner *) appWallBanner;
//App-wall-таблица
+(MTRGAppwallAdView *) createAppWallAdViewWithBanners:(NSArray*)banners;

@end
