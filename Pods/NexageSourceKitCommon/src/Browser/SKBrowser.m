//
//  SKBrowser.m
//  Nexage
//
//  Created by Thomas Poland on 6/20/14.
//  Copyright (c) 2014 Nexage Inc. All rights reserved.
//

#import "SKBrowser.h"
#import "SKLogger.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

// Features
NSString * const kSourceKitBrowserFeatureDisableStatusBar = @"disableStatusBar";
NSString * const kSourceKitBrowserFeatureScalePagesToFit = @"scalePagesToFit";
NSString * const kSourceKitBrowserFeatureSupportInlineMediaPlayback = @"supportInlineMediaPlayback";
NSString * const kSourceKitBrowserTelPrefix = @"tel://";

@interface SKBrowser () <UIWebViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    SKBrowserControlsView *browserControlsView;
    NSURLRequest *currrentRequest;
    UIViewController *currentViewController;
    NSArray *sourceKitBrowserFeatures;
    UIWebView *browserWebView;
    UIActivityIndicatorView *loadingIndicator;
    BOOL disableStatusBar;
    BOOL scalePagesToFit;
    BOOL statusBarHidden;
    BOOL supportInlineMediaPlayback;
}

@end

@implementation SKBrowser

#pragma mark - Init & dealloc

// designated initializer
- (id)initWithDelegate:(id<SKBrowserDelegate>)delegate withFeatures:(NSArray *)p_sourceKitBrowserFeatures
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _delegate = delegate;
        sourceKitBrowserFeatures = p_sourceKitBrowserFeatures;
        
        if (p_sourceKitBrowserFeatures != nil && [p_sourceKitBrowserFeatures count] > 0)
        {
            for (NSString *feature in p_sourceKitBrowserFeatures)
            {
                if ([feature isEqualToString:kSourceKitBrowserFeatureDisableStatusBar]) {
                    disableStatusBar = YES;
                }
                else if ([feature isEqualToString:kSourceKitBrowserFeatureSupportInlineMediaPlayback]) {
                    supportInlineMediaPlayback = YES;
                }
                else if ([feature isEqualToString:kSourceKitBrowserFeatureScalePagesToFit]) {
                    scalePagesToFit = YES;
                }
                
                [SKLogger debug:@"SKBrowser" withMessage:[NSString stringWithFormat:@"Requesting SourceKitBrowser feature: %@", feature]];
            }
        }
    }
    return self;
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class SourceKitBrowser"
                                 userInfo:nil];
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithNibName:bundle: is not a valid initializer for the class SourceKitBrowser"
                                 userInfo:nil];
    return nil;
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!browserWebView) {
        browserWebView = [[UIWebView alloc] initWithFrame: self.view.bounds];
        browserWebView.delegate = self;
        browserWebView.scalesPageToFit = scalePagesToFit;
        browserWebView.allowsInlineMediaPlayback = supportInlineMediaPlayback;
        browserWebView.mediaPlaybackRequiresUserAction = NO;
        browserWebView.autoresizesSubviews=YES;
        browserWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:browserWebView];
        browserControlsView = [[SKBrowserControlsView  alloc] initWithSourceKitBrowser:self];
        browserControlsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin;
        
        // screenSize is ALWAYS for portrait orientation, so we need to figure out the
        // actual interface orientation.
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        BOOL isLandscape = UIInterfaceOrientationIsLandscape(interfaceOrientation);
  
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            browserControlsView.frame  = CGRectMake(0, self.view.frame.size.height-browserControlsView.frame.size.height, self.view.frame.size.width,browserControlsView.frame.size.height);
        } else {
            if (isLandscape) {
                browserControlsView.frame  = CGRectMake(0, self.view.frame.size.width-browserControlsView.frame.size.width, self.view.frame.size.height,browserControlsView.frame.size.width);
            } else {
                browserControlsView.frame  = CGRectMake(0, self.view.frame.size.height-browserControlsView.frame.size.height, self.view.frame.size.width,browserControlsView.frame.size.height);
            }
        }
        
        loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingIndicator.frame = CGRectMake(0,0,30,30);
        loadingIndicator.hidesWhenStopped = YES;
        [browserControlsView.loadingIndicator.customView addSubview:loadingIndicator];
        [self.view addSubview:browserControlsView];
        [browserWebView loadRequest:currrentRequest];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    if (disableStatusBar && SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (disableStatusBar && SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden withAnimation:UIStatusBarAnimationNone];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return disableStatusBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

#pragma mark - SourceKitBrowser public methods

- (void)loadRequest:(NSURLRequest *)request
{
    currentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (currentViewController.presentedViewController) {
        currentViewController = currentViewController.presentedViewController;
    }
    
    self.view.frame = currentViewController.view.bounds;
    
    NSURL *url = [request URL];
    NSString *scheme = [url scheme];
    NSString *host = [url host];
    NSString *absUrlString = [url absoluteString];
    
    BOOL openSystemBrowserDirectly = NO;
    if ([absUrlString hasPrefix:@"tel"]) {
        [self getTelPermission:absUrlString];
        return;
    } else if ([host isEqualToString:@"itunes.apple.com"] || [host isEqualToString:@"phobos.apple.com"] || [host isEqualToString:@"maps.google.com"]) {
        // Handle known URL hosts
        openSystemBrowserDirectly = YES;
    } else if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
        // Deep Links
        openSystemBrowserDirectly = YES;
    }

    if (openSystemBrowserDirectly) {
        // Notify the callers that the app will exit
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if ([self.delegate respondsToSelector:@selector(sourceKitBrowserWillExitApp:)]) {
                [self.delegate sourceKitBrowserWillExitApp:self];
            }
            
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        currrentRequest = request;
        [SKLogger debug:@"SKBrowser" withMessage:[NSString stringWithFormat:@"presenting browser from viewController: %@", currentViewController]];
        
        if ([currentViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            // used if running >= iOS 6
            [currentViewController presentViewController:self animated:YES completion:nil];
        } else {
            // Turn off the warning about using a deprecated method.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [currentViewController presentModalViewController:self animated:YES];
#pragma clang diagnostic pop
        }
    }
}

- (void)getTelPermission:(NSString *)telString
{
    if ([self.delegate respondsToSelector:@selector(sourceKitTelPopupOpen:)]) {
        [self.delegate sourceKitTelPopupOpen:self];
    }
    
    telString = [telString stringByReplacingOccurrencesOfString:kSourceKitBrowserTelPrefix withString:@""];
    
    UIAlertView *telPermissionAlert = [[UIAlertView alloc] initWithTitle:telString
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Call",nil];
    
    [telPermissionAlert show];
}

#pragma mark - Telephone call permission AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonLabel = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([self.delegate respondsToSelector:@selector(sourceKitTelPopupClosed:)]) {
        [self.delegate sourceKitTelPopupClosed:self];
    }

    if([buttonLabel isEqualToString:@"Call"])
    {
        // Notify listener
        if ([self.delegate respondsToSelector:@selector(sourceKitBrowserWillExitApp:)]) {
            [self.delegate sourceKitBrowserWillExitApp:self];
        }
        
        // Parse phone number and dial
        NSString *toCall = [kSourceKitBrowserTelPrefix stringByAppendingString:alertView.title];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:toCall]];
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSString *scheme = [url scheme];
    NSString *host = [url host];
    NSString *absUrlString = [url absoluteString];
    
    // Ignore about:blank
    if (![absUrlString isEqualToString:@"about:blank"]) {
        
        BOOL openSystemBrowserDirectly = NO;
        if ([absUrlString hasPrefix:@"tel"]) {
            [self getTelPermission:absUrlString];
            return NO;
        } else if ([host isEqualToString:@"itunes.apple.com"] || [host isEqualToString:@"phobos.apple.com"] || [host isEqualToString:@"maps.google.com"]) {
            // Handle known URL hosts
            openSystemBrowserDirectly = YES;
        } else if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
            // Deep Links
            openSystemBrowserDirectly = YES;
        }
        
        if (openSystemBrowserDirectly) {
            // Notify the callers that the app will exit
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                if ([self.delegate respondsToSelector:@selector(sourceKitBrowserWillExitApp:)]) {
                    [self.delegate sourceKitBrowserWillExitApp:self];
                }
                [self dismiss];
                [[UIApplication sharedApplication] openURL:url];
                return NO;
            } else {
                [self dismiss];
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    browserControlsView.backButton.enabled = [webView canGoBack];
    browserControlsView.forwardButton.enabled = [webView canGoForward];
    [loadingIndicator stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [loadingIndicator startAnimating];
}

#pragma mark -
#pragma mark SourceKitBrowserControlsView actions

- (void)back
{
    if([browserWebView canGoBack]) {
        [browserWebView goBack];
    }
}

- (void)dismiss
{
    [SKLogger debug:@"SKBrowser" withMessage:@"Dismissing SourceKitBrowser"];
    if ([self.delegate respondsToSelector:@selector(sourceKitBrowserClosed:)]) {
        [self.delegate sourceKitBrowserClosed:self];
    }
    
    self.delegate = nil;
    browserWebView = nil;
    browserControlsView = nil;
    currrentRequest = nil;
    loadingIndicator = nil;
    sourceKitBrowserFeatures = nil;
    
    [currentViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)forward
{
    if([browserWebView canGoForward]) {
        [browserWebView goForward];
    }
}

#define ACTION_SHEET_TOOLBAR_ACTION 32000
- (void)launchSafari
{
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Launch Safari",nil];
        actionSheet.tag = ACTION_SHEET_TOOLBAR_ACTION;
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
}

- (void)refresh
{
     [browserWebView reload];
}

#pragma mark -
#pragma mark UIActionSheetDelegate
    
#define ACTION_LAUNCH_SAFARI 0
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == ACTION_SHEET_TOOLBAR_ACTION) {
        if (buttonIndex == 0) {
            NSURL *currentRequestURL = [browserWebView.request URL];
            if ([self.delegate respondsToSelector:@selector(sourceKitBrowserWillExitApp:)]) {
                [self.delegate sourceKitBrowserWillExitApp:self];
            }
            [self dismiss];
            [[UIApplication sharedApplication] openURL:currentRequestURL];
        }
    }
}

@end
