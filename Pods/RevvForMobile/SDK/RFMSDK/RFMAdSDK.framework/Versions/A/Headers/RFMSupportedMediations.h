//
//  RFMSupportedMediations.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 4/8/14.
//  Copyright (c) 2014 Rubicon Project. All rights reserved.
//

@import Foundation;
@import UIKit;


@interface RFMSupportedMediations : NSObject

+(RFMSupportedMediations *)sharedInstance;
-(Class)mediatorClassForMediationType:(NSString *)mediationType;
-(BOOL)isRFMMediationSupported:(NSString *)mediationType;
-(NSArray *)getSupportedMediations;

-(void)addMediationWithCode:(NSString *)mediatorCode
          mediatorClassName:(NSString *)mediatorClassName;
@end

