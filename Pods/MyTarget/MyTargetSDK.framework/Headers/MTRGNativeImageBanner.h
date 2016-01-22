//
//  MTRGNativeImageBanner.h
//  myTargetSDK 4.3.0
//
//  Created by Anton Bulankin on 10.11.14.
//  Copyright (c) 2014 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MyTargetSDK/MTRGImageData.h>
#import <MyTargetSDK/MTRGTypes.h>


@interface MTRGNativeImageBanner : NSObject

//Текст реклама
@property (nonatomic, strong) NSString * advertisingLabel;
//Возрастные ограничения
@property (nonatomic, strong) NSString * ageRestrictions;
//Тип навигации
@property (nonatomic) MTRGNavigationType navigationType;
//Рисунок
@property (nonatomic,strong) MTRGImageData * image;

@end
