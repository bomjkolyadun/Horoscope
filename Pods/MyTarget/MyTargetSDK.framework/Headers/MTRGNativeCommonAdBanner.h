//
//  MTRGNativeCommonAdBanner.h
//  myTargetSDK 4.3.0
//
//  Created by Anton Bulankin on 22.12.14.
//  Copyright (c) 2014 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MyTargetSDK/MTRGImageData.h>
#import <MyTargetSDK/MTRGNativeTeaserBanner.h>
#import <MyTargetSDK/MTRGNativePromoBanner.h>
#import <MyTargetSDK/MTRGNativeImageBanner.h>

typedef enum {
    MTRGNativeBannerTypeUnknown,
    MTRGNativeBannerTypeTeaser,
    MTRGNativeBannerTypePromo,
    MTRGNativeBannerTypeImage
} MTRGNativeBannerType;


@interface MTRGNativeCommonAdBanner : NSObject

//Текст реклама
@property (nonatomic, strong) NSString * advertisingLabel;
//Возрастные ограничения
@property (nonatomic, strong) NSString * ageRestrictions;
//Тип навигации
@property (nonatomic) MTRGNavigationType navigationType;
//
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * descriptionText;
@property (nonatomic, strong) NSString * disclaimer;
@property (nonatomic, strong) NSNumber * rating;
@property (nonatomic, strong) NSNumber * votes;
@property (nonatomic, strong) NSString * category;
@property (nonatomic, strong) NSString * subcategory;
@property (nonatomic, strong) NSString * domain;
@property (nonatomic, strong) NSString * ctaText;

//Иконка
@property (nonatomic,strong) MTRGImageData * icon;
//Рисунок
@property (nonatomic,strong) MTRGImageData * image;

//Тип банера
@property (nonatomic) MTRGNativeBannerType type;

-(MTRGNativeTeaserBanner *) getAsTeaserBanner;
-(MTRGNativePromoBanner *) getAsPromoBanner;
-(MTRGNativeImageBanner *) getAsImageBanner;

@end
