# SpotX SDK - Quick Start #


#### *Preliminary* ####
You'll need to apply to become a SpotX publisher if you haven't already. You'll receive the SpotXchange's SDK, a publisher channel ID, and an account to log in to [SpotXchange's Publisher Tools](https://publisher.spotxchange.com/).

- [Apply to become a SpotX Publisher](http://www.spotxchange.com/publishers/apply-to-become-a-spotx-publisher/)


## What You Need ##
- An IAB Category number that best categorizes your app (ex: "IAB1")
    - [IAB Specification](http://www.iab.net/media/file/OpenRTB_API_Specification_Version2.0_FINAL.PDF) (section 6.1 page 54)
    - [IAB Category List](https://gist.github.com/crowdmatt/5040911)
- Your App domain
    - ex: http://www.example.com
- Your App Store URL
    - ex: https://itunes.apple.com/us/app/example/id123456789
- Xcode 6


## Getting Started ##
### Installation with CocoaPods ###
Installation with [CocoaPods](https://cocoapods.org/) is an alternative to downloading the SDK. CocoaPods is a dependency manager for iOS and Mac apps, which automates and simplifies the process of using 3rd-party libraries in your projects.

``` ruby
pod 'SpotX-SDK'
```

### Manual Installation ###
Download the latest SDK from the SpotX [Github Repository](https://github.com/spotxmobile/spotx-sdk-ios).

The SpotX SDK makes use of many iOS core frameworks. Add the following frameworks to your app:

- AdManager.framework
- AdSupport.framework
- CoreData.framework
- CoreGraphics.framework
- CoreLocation.framework
- CoreTelephony.framework
- EventKit.framework
- Foundation.framework
- SystemConfiguration.framework
- Security.framework
- UIKit.framework

Under **Build Settings > Other Linker Flags** set the following flag:
```
-all_load
```

## Using the SDK ###
### Initialize the SpotX SDK ###
``` objective-c
// File: AppDelegate.m

#import <UIKit/UIKit.h>
#import <AdManager/SpotX.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	// Required: Initialize SpotX SDK
	[SpotX initializeWithApiKey:nil category:@"IAB1" section:@"Fiction" 
		domain:@"www.spotxchange.com"
			url:@"https://itunes.apple.com/us/app/spotxchange_advertisments/id123456789"];
	
	// Optional: Set default channel id
	[SpotX setDefaultChannelID:"110681"];
	
	// Optional: Configure default settings
	id<SpotXAdSettings> settings = [SpotX defaultSettings];
	settings.useHTTPS = @YES;
	settings.useNativeBrowser = @YES;
	settings.allowCalendar = @NO;
	
	// Optional: Configure default custom parameters (Custom Taxonomy)
	[SpotX setDefaultParameters:@{
		@"custom_param": @"custom_value"
	}];
	
	return YES;
}

@end
```

### Show an Ad ###
``` objective-c
// File: ViewController.m

#import "ViewController.h"

#import <AdManager/SpotX.h>


@interface ViewController () <SpotXAdDelegate>

@property (nonatomic, strong) SpotXAdView *adView;

@end


@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    // NOTE: We create a SpotXView and call -startLoading right away 
    //       so it is cached when we are ready to show it.
    _adView = [[SpotXView alloc] initWithFrame:self.view.bounds];
	 _adView.delegate = self;
	 [_adView startLoading];
}

- (void)showAd
{
	// Show the Ad. If the ad is still loading, it may take a 
	// few seconds for the video to start.
	[self.adView show];
}


#pragma mark - SpotXAdViewDelegate

- (void)presentViewController:(UIViewController *)viewControllerToPresent
{
	[self presentViewController:viewControllerToPresent animated:YES completion:nil];
}

- (void)adLoaded
{
  NSLog(@"Ad is cached and ready to play");
}

@end
```
