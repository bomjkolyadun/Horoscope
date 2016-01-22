//
//  MTRGNativeTeaserAd.h
//  myTargetSDK 4.3.0
//
//  Created by Anton Bulankin on 10.11.14.
//  Copyright (c) 2014 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MTRGNativeTeaserBanner.h>
#import <MyTargetSDK/MTRGNativeBaseAd.h>

@class MTRGNativeTeaserAd;

@protocol MTRGNativeTeaserAdDelegate <NSObject>

-(void)onLoadWithNativeTeaserBanner:(MTRGNativeTeaserBanner *)teaserBanner teaserAd:(MTRGNativeTeaserAd *)teaserAd;
-(void)onNoAdWithReason:(NSString *)reason teaserAd:(MTRGNativeTeaserAd *)teaserAd;

@optional

-(void)onAdClickWithNativeTeaserAd:(MTRGNativeTeaserAd *)teaserAd;
@end


@interface MTRGNativeTeaserAd : MTRGNativeBaseAd

//
-(instancetype) initWithSlotId:(NSString*)slotId;
//Делегат
@property (weak, nonatomic) id<MTRGNativeTeaserAdDelegate> delegate;
//Загрузить Иконку в UIImageView
-(void) loadIconToView:(UIImageView*) imageView;

@property (strong, nonatomic, readonly) MTRGNativeTeaserBanner * banner;

@end


