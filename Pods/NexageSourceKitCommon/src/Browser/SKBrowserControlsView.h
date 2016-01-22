//
//  SKBrowserControlsView.h
//  Nexage
//
//  Created by Tom Poland on 6/23/14.
//  Copyright (c) 2014 Nexage Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKBrowser;
@protocol SourceKitBrowserControlsViewDelegate <NSObject>

@required

- (void)back;
- (void)forward;
- (void)refresh;
- (void)launchSafari;
- (void)dismiss;

@end

@interface SKBrowserControlsView : UIView

@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIToolbar *controlsToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *loadingIndicator;

- (id)initWithSourceKitBrowser:(SKBrowser *)p_skBrowser;

@end
