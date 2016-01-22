![PNLogo](PNLogo.png)

PubNative is an API-based publisher platform dedicated to native advertising which does not require the integration of an SDK. Through PubNative, publishers can request over 20 parameters to enrich their ads and thereby create any number of combinations for unique and truly native ad units.

# pubnative-ios-library

pubnative-ios-library is a collection of Open Source tools to implement API based native ads in iOS.

##Contents

* [Requirements](#requirements)
* [Install](#install)
* [Usage](#usage)
    * [Native](#native)
        * [WatchKit](#native_watchkit)
    * [In-feed](#in_feed)
    * [Predefined](#predefined)
* [Misc](#misc)
    * [Dependencies](#misc_dependencies)
    * [License](#misc_license)
    * [Contribution guidelines](#misc_contributing)

<a name="requirements"></a>
## Requirements

* ARC only; iOS 6.1+
* An App Token provided in pubnative dashboard

<a name="install"></a>
## Install

* Download the latest PubNativeLibrary.framework
* Drag and drop the framework into the "Embeded Binaries" section of your desired target.

**WatchKit support**

* Copy WKPubNative folder into your WatchKit extension project target
* Add this to your application AppDelegate

```objective-c
#import <PubNativeLibrary/Pubnative.h>
//==================================================================
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    [PubnativeExtension application:application handleWatchKitExtensionRequest:userInfo reply:reply];
}
//==================================================================
```

<a name="usage"></a>
## Usage

PubNative library is a lean yet complete library that allow you request and show ads in different ways.

In general, it requeres you to

* **[Native](#native)**: Use native ads if you want to manually control requests and fully customize your ads appearance.
* **[In-feed](#in_feed)**: Use in feed ads if you want completely integrated ads into your UITableView.
* **[Predefined](#predefined)**: Use predefined for direct usage of the library if you don't want to mess up creating your own ad format.

<a name="native"></a>
## Native

1. **[Request](#native_request)**: Using `PNAdRequest` and `PNAdRequestParameters`
2. **[Show](#native_show)**: Manually, or using `PNAdRenderingManager` and `PNNativeAdRenderItem`
3. **[Confirm Impression](#native_confirm_impression)**: By using `PNTrackingManager`

<a name="native_request"></a>
### 1) Request 

You will need to create a PNAdRequestParameters for configuration and (like setting up your App token) and request the type of ad you need.

You just need to control that the returned type in the array of ads is different depending on the request type:

* `PNAdRequest_Native`: returns `PNNativeAdModel`
* `PNAdRequest_Native_Video`: returns `PNNativeVideoAdModel`
* `PNAdRequest_Image`: returns `PNImageAdModel`

```objective-c
#import <PubNativeLibrary/Pubnative.h>
//==================================================================
// Create a new request parameters and set it up configuring at least your app token
PNAdRequestParameters *parameters = [PNAdRequestParameters requestParameters];
parameters.app_token = @"YOUR_APP_TOKEN_HERE";
// TODO: Fill other parameters specified as you wish

// Create the request and start it
__weak typeof(self) weakSelf = self;
self.request = [PNAdRequest request:<YOUR_SELECTED_REQUEST_TYPE>
                    withParameters:parameters
                     andCompletion:^(NSArray *ads, NSError *error)
{
   if(error)
   {
       NSLog(@"Pubnative - error requesting ads: %@", [error description]);
   }
   else
   {
       NSLog(@"Pubnative - loaded PNNativeAdModel ads: %d", [ads count]);
   }
}];
[self.request startRequest];
//==================================================================
```

<a name="native_show"></a>
### 2) Show

Once the ads are downloaded, you can use them manually by accessing properties inside the model. Although, we've developed a tool that will work for most cases `PNAdRenderingManager` and `PNNativeAdRenderItem`. It downloads the needed resources and ensures that the data is correctly downlaoded. 

Simply create and stick a `PNNativeAdRenderItem` to your custom view and make the `PNAdRenderingManager` fill it with the ad model.

```objective-c
#import <PubNativeLibrary/Pubnative.h>
//==================================================================
PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
renderItem.icon = self.iconView;
renderItem.title = self.titleLabel;
renderItem.cta_text = self.ctaLaxbel;

[PNAdRenderingManager renderNativeAdItem:renderItem withAd:<YOUR_AD_MODEL>];
//==================================================================
```

Since the image downlaod process is asynchronous there are 3 notifications from where you can listen when the resources have finished downloading.

```objective-c
FOUNDATION_EXPORT NSString *kPNAdRenderingManagerIconNotification;
FOUNDATION_EXPORT NSString *kPNAdRenderingManagerBannerNotification;
FOUNDATION_EXPORT NSString *kPNAdRenderingManagerPortraitBannerNotification;
```

<a name="native_confirm_impression"></a>
### 3) Confirm impressions

We developed an utility to make you confirm impressions easier and safer, just send the ad you want to confirm to `PNTrackingManager` and it will get confirmed.

```objective-c
#import <PubNativeLibrary/Pubnative.h>
//==================================================================
[PNTrackingManager trackImpressionWithAd:self.ad
                              completion:^(id result, NSError *error)
{
    // TODO: Do whatever you want once the ad is confirmed
}];
//==================================================================
```

<a name="native_watchkit"></a>
### WatchKit Support

Inside your application extension target you will have limited access to the library using `WKPubnative` class. The normal use of the extension will be

1. Import `WKPubnative` class
* Make your class to implement `WKPubnativeDelegate` and set your class as request delegate
* Request an ad with an Application Token
* Use the returned model in the callback as you wish
* Track an impression when the ad is shown in the iWatch using the returned model
* Open the offer in your phone when it's touched by the user

Please, take a look on the provided demo for further details

```objective-c
#import "WKPubnative.h"
//==================================================================
// ** Implement WKPubnativeDelegate **
@interface MyClass ()<WKPubnativeDelegate>
@end
//------------------------------------------------------------------   
// ** Set delegate **
[WKPubnative setDelegate:self];
//------------------------------------------------------------------
// ** Request **
[WKPubnative requestWithAppToken:<YOUR_AD_MODEL>];
//------------------------------------------------------------------
// ** Track impression **
[WKPubnative trackImpressionWithModel:self.model];
//------------------------------------------------------------------
// ** Open **
[WKPubnative openOffer:<YOUR_AD_MODEL>];
//------------------------------------------------------------------
// ** Implement delegate **
- (void)wkPNRequestDidLoad:(WKPNNativeAdModel *)model{ }
- (void)wkPNRequestDidFail:(NSError *)error { }
- (void)wkPNTrackDidEnd { }
- (void)wkPNTrackDidFail:(NSError *)error { }
//==================================================================
```

Please, note that the model resources are already downlaoded and all calbacks are always returned in the main thread, so you can directly assign the icon or banner

<a name="in_feed"></a>
## In-Feed

There are 5 different cell types to be used

```objective-c
typedef NS_ENUM(NSInteger, Pubnative_FeedType)
{
    Pubnative_FeedType_Banner,
    Pubnative_FeedType_Icon,
    Pubnative_FeedType_Video,
    Pubnative_FeedType_Carousel,
    Pubnative_FeedType_Native
};
```

So, in short, the usage is:

* Set up the PNTableViewManager to manage your UITableView

```objective-c
#import "Pubnative.h"
//==================================================================
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [PNTableViewManager controlTable:self.tableView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [PNTableViewManager controlTable:nil];
}
//==================================================================
```

* [Do a manual request](#native_request)
* Dequeue ad cells from Pubnative class helper method when you want and set the model (depending on the type requested).
    * **`PNNativeAdModel`** accepted by Banner, Icon and Native cells
    * **`PNNativeVideoAdModel`** by the Video cell only
    * **`NSArray` of ads** for the Carousel cell

```objective-c
#import <PubNativeLibrary/Pubnative.h>
//==================================================================
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(<IS_AD_CELL>)
    {
        PNTableViewCell *cell = [Pubnative dequeueFeedType:<YOUR_SELECTED_FEEDTYPE>];
        cell.model = <YOUR_REQUESTED_AD_MODEL>;
        return cell;
    }
    else
    {
        <YOUR_CELL_DEQUEUE>
    }
}
//==================================================================
```

* Ensure to specify the right tableView cell height

```objective-c
#import <PubNativeLibrary/Pubnative.h>
//==================================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(<IS_AD_CELL>)
    {
        return [Pubnative heightForRowType:<YOUR_SELECTED_FEEDTYPE>];
    }
    else
    {
        return <YOUR_CELL_HEIGHT>
    }
}
//==================================================================
```    

**Feed ads automatically confirms their impression and open when the user interacts, so there is no need to do it manually**

Please, check the repository Demo for further details

<a name="predefined"></a>
## Predefined ads

1. Your class must implement `PubnativeAdDelegate`.
2. Request an ad using `Pubnative` class
3. Wait for the callback with `PubnativeAdDelegate`. 

There are 5 types of predefined ads that you can request

```objective-c
typedef NS_ENUM(NSInteger, Pubnative_AdType) 
{
    Pubnative_AdType_Banner             = 0,
    Pubnative_AdType_VideoBanner        = 1,
    Pubnative_AdType_Interstitial       = 2,
    Pubnative_AdType_Icon               = 3,
    Pubnative_AdType_VideoInterstitial  = 4,
    Pubnative_AdType_GameList           = 5
};
```

Fullscreen ads: 

* Pubnative\_AdType_Interstitial
* Pubnative\_AdType_VideoInterstitial
* Pubnative\_AdType_GameList

Manual frame ads:

* Pubnative\_AdType_Banner
* Pubnative\_AdType_VideoBanner
* Pubnative\_AdType_Icon

**Please see the included sample to have more info on how to operate with each**

Here is a sample request code

```objective-c
#import <PubNativeLibrary/Pubnative.h>
//==================================================================

@property (nonatomic, strong)UIViewControllerViewController *adVC;

//------------------------------------------------------------------

#pragma mark Pubnative Methods

- (void)showPubnativeAd
{
    [Pubnative requestAdType:<YOUR_SELECTED_ADTYPE>
                withAppToken:@"YOUR_APP_TOKEN_HERE"
                 andDelegate:self];
}

#pragma mark PubnativeAdDelegate Methods

- (void)pnAdDidLoad:(UIViewController*)adVC
{
    // Hold an instance of the ad view controller
    self.adVC = adVC;
    
//  If fullscreen ad
//  {
//      presentViewController
//  }
//  If manual ad
//  {
//      Assign the frame to self.adVC
//      Add self.adVC.view as subview into your view
//  }
}

- (void)pnAdReady:(UIViewController*)ad;
- (void)pnAdDidFail:(NSError*)error;
- (void)pnAdWillShow;
- (void)pnAdDidShow;
- (void)pnAdWillClose;
- (void)pnAdDidClose
{
    // Release the ViewController
    self.adVC = nil;
}

@end

//==================================================================
```

<a name="misc"></a>
## Misc

<a name="misc_dependencies"></a>
### Dependencies

* [YADMLib](https://github.com/cnagy/YADMLib) for networking and JSON to data model mapping.
* [Croissant](https://github.com/cerberillo/Croissant) for resource cache 
* [KAProgressLabel](https://github.com/kirualex/KAProgressLabel) for video time counter
* [AMRatingControl](https://github.com/amseddi/AMRatingControl) for star rating UI

<a name="misc_license"></a>
### License

This code is distributed under the terms and conditions of the MIT license.

<a name="misc_contributing"></a>
### Contributing

**NB!** If you fix a bug you discovered or have development ideas, feel free to make a pull request.

