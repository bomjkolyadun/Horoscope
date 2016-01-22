//
//  SKBrowserControlsView.m
//  Nexage
//
//  Created by Tom Poland on 6/23/14.
//  Copyright (c) 2014 Nexage Inc. All rights reserved.
//

#import "SKBrowserControlsView.h"
#import "SKBrowser.h"
#import "BackButton.h"
#import "ForwardButton.h"

static const float kControlsToobarHeight = 44.0;
static const float kControlsLoadingIndicatorWidthHeight = 30.0;

@interface SKBrowserControlsView ()
{
    // backButton is a property
    UIBarButtonItem *flexBack;
    // forwardButton is a property
    UIBarButtonItem *flexForward;
    // loadingIndicator is a property
    UIBarButtonItem *flexLoading;
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *flexRefresh;
    UIBarButtonItem *launchSafariButton;
    UIBarButtonItem *flexLaunch;
    UIBarButtonItem *stopButton;
    __unsafe_unretained SKBrowser *skBrowser;
}

@end

@implementation SKBrowserControlsView

- (id)initWithSourceKitBrowser:(SKBrowser *)p_skBrowser
{
    self = [super initWithFrame:CGRectMake(0, 0, p_skBrowser.view.bounds.size.width, kControlsToobarHeight)];
    
    if (self) {
        _controlsToolbar = [[ UIToolbar alloc] initWithFrame:CGRectMake(0, 0, p_skBrowser.view.bounds.size.width, kControlsToobarHeight)];
        skBrowser = p_skBrowser;
        // In left to right order, to make layout on screen more clear
        NSData* backButtonData = [NSData dataWithBytesNoCopy:__BackButton_png
                                                      length:__BackButton_png_len
                                                freeWhenDone:NO];
        UIImage *backButtonImage = [UIImage imageWithData:backButtonData];
        _backButton = [[UIBarButtonItem alloc] initWithImage:backButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
        _backButton.enabled = NO;
        flexBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSData* forwardButtonData = [NSData dataWithBytesNoCopy:__ForwardButton_png
                                                         length:__ForwardButton_png_len
                                                   freeWhenDone:NO];
        UIImage *forwardButtonImage = [UIImage imageWithData:forwardButtonData];
        _forwardButton = [[UIBarButtonItem alloc] initWithImage:forwardButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(forward:)];
        _forwardButton.enabled = NO;
        flexForward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIView *placeHolder = [[UIView alloc] initWithFrame:CGRectMake(0,0,kControlsLoadingIndicatorWidthHeight,kControlsLoadingIndicatorWidthHeight)];
        _loadingIndicator = [[UIBarButtonItem alloc] initWithCustomView:placeHolder];  // loadingIndicator will be added here by the browser
        flexLoading = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:(self) action:@selector(refresh:)];
        flexRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        launchSafariButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:(self) action:@selector(launchSafari:)];
        flexLaunch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        stopButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:(self) action:@selector(dismiss:)];
        NSArray *toolbarButtons = @[_backButton, flexBack, _forwardButton, flexForward, _loadingIndicator, flexLoading, refreshButton, flexRefresh, launchSafariButton, flexLaunch, stopButton];
        [_controlsToolbar setItems:toolbarButtons animated:NO];
        _controlsToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_controlsToolbar];
    }
    return  self;
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class SourceKitBrowserControlsView"
                                 userInfo:nil];
    return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithFrame: is not a valid initializer for the class SourceKitBrowserControlsView"
                                 userInfo:nil];
    return nil;
}

- (void)dealloc
{
    flexBack = nil;
    flexForward = nil;
    flexLoading = nil;
    refreshButton = nil;
    flexRefresh = nil;
    flexLaunch = nil;
    launchSafariButton = nil;
    stopButton = nil;
}

#pragma mark -
#pragma mark SourceKitBrowserControlsView actions

- (void)back:(id)sender
{
    [skBrowser back];
}

- (void)dismiss:(id)sender
{
    [skBrowser dismiss];
}

- (void)forward:(id)sender
{
    [skBrowser forward];
}

- (void)launchSafari:(id)sender
{
    [skBrowser launchSafari];
}

- (void)refresh:(id)sender
{
    [skBrowser refresh];
}

@end
