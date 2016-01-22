//
//  SKVASTViewController.h
//  VAST
//
//  Created by Thomas Poland on 9/30/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

// VASTViewController is the main component of the SourceKit VAST Implementation.
//
// This class creates and manages an iOS MPMediaPlayerViewController to playback a video from a VAST 2.0 document.
// The document may be loaded using a URL or directly from an exisitng XML document (as NSData).
//
// See the VASTViewControllerDelegate Protocol for the required vastReady: and other useful methods.
// Screen controls are exposed for play, pause, info, and dismiss, which are handled by the VASTControls class as an overlay toolbar.
//
// VASTEventProcessor handles tracking events and impressions.
// Errors encountered are listed in in VASTError.h
//
// Please note:  Only one video may be played at a time, you must wait for the vastReady: callback before sending the 'play' message.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SKVASTError.h"

@class SKVASTViewController;

@protocol SKVASTViewControllerDelegate <NSObject>

@required

- (void)vastReady:(SKVASTViewController *)vastVC;  // sent when the video is ready to play - required

@optional

- (void)vastError:(SKVASTViewController *)vastVC error:(SKVASTError)error;  // sent when any VASTError occurs - optional

// These optional callbacks are for basic presentation, dismissal, and calling video clickthrough url browser.
- (void)vastWillPresentFullScreen:(SKVASTViewController *)vastVC;
- (void)vastDidDismissFullScreen:(SKVASTViewController *)vastVC;
- (void)vastOpenBrowseWithUrl:(NSURL *)url;
- (void)vastTrackingEvent:(NSString *)eventName;

@end

@interface SKVASTViewController : UIViewController

@property (nonatomic, unsafe_unretained) id<SKVASTViewControllerDelegate>delegate;
@property (nonatomic, strong) NSURL *clickThrough;

- (id)initWithDelegate:(id<SKVASTViewControllerDelegate>)delegate withViewController:(UIViewController *)viewController;  // designated initializer for VASTViewController

- (void)loadVideoWithURL:(NSURL *)url;            // load and prepare to play a VAST video from a URL
- (void)loadVideoWithData:(NSData *)xmlContent;   // load and prepare to play a VAST video from existing XML data

// These actions are called by the VASTControls toolbar; the are exposed to enable an alternative custom VASTControls toolbar
- (void)play;                        // command to play the video, this is only valid after receiving the vastReady: callback
- (void)pause;                       // pause the video, useful when modally presenting a browser, for example
- (void)resume;                      // resume the video, useful when modally dismissing a browser, for example
- (void)info;                        // callback to host class for opening a browser to the URL specified in 'clickthrough'
- (void)close;                       // dismisses a video playing on screen
- (BOOL)isPlaying;                   // playing state

@end
