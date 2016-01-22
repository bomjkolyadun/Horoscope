//
//  SKBrowser.h
//  Nexage
//
//  Created by Thomas Poland on 6/20/14.
//  Copyright (c) 2014 Nexage Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKBrowserControlsView.h"

extern NSString * const kSourceKitBrowserFeatureSupportInlineMediaPlayback;
extern NSString * const kSourceKitBrowserFeatureDisableStatusBar;
extern NSString * const kSourceKitBrowserFeatureScalePagesToFit;

@class SKBrowser;

@protocol SKBrowserDelegate <NSObject>

@required

- (void)sourceKitBrowserClosed:(SKBrowser *)sourceKitBrowser;  // sent when the SourceKitBrowser viewController has dismissed - required
- (void)sourceKitBrowserWillExitApp:(SKBrowser *)sourceKitBrowser;  // sent when the SourceKitBrowser exits by opening the system openURL command

@optional

- (void)sourceKitTelPopupOpen:(SKBrowser *)sourceKitBrowser; // sent when the telephone dial confirmation popup is on the screen
- (void)sourceKitTelPopupClosed:(SKBrowser *)sourceKitBrowser; // sent when the telephone dial confirmation popip is dismissed

@end

@interface SKBrowser : UIViewController <SourceKitBrowserControlsViewDelegate>

@property (nonatomic, unsafe_unretained) id<SKBrowserDelegate>delegate;

- (id)initWithDelegate:(id<SKBrowserDelegate>)delegate withFeatures:(NSArray *)sourceKitBrowserFeatures;  // designated initializer for SourceKitBrowser

- (void)loadRequest:(NSURLRequest *)urlRequest;   // load urlRequest and present the souceKitBrowserViewController Note: requests such as tel: will immediately be presented using the UIApplication openURL: method without presenting the SourceKitBrowser's viewController

@end