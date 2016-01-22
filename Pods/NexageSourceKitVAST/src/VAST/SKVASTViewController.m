//
//  SKVASTViewController.m
//  VAST
//
//  Created by Thomas Poland on 9/30/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

#import "SKVASTViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VASTSettings.h"
#import "SKLogger.h"
#import "SKVAST2Parser.h"
#import "SKVASTModel.h"
#import "SKVASTEventProcessor.h"
#import "SKVASTUrlWithId.h"
#import "SKVASTMediaFile.h"
#import "SKVASTControls.h"
#import "SKVASTMediaFilePicker.h"
#import "SKReachability.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

static const NSString* kPlaybackFinishedUserInfoErrorKey=@"error";

typedef enum {
    VASTFirstQuartile,
    VASTSecondQuartile,
    VASTThirdQuartile,
    VASTFourtQuartile,
} CurrentVASTQuartile;

@interface SKVASTViewController() <UIGestureRecognizerDelegate>
{
    NSURL *mediaFileURL;
    NSArray *clickTracking;
    NSArray *vastErrors;
    NSArray *impressions;
    NSTimer *playbackTimer;
    NSTimer *initialDelayTimer;
    NSTimer *videoLoadTimeoutTimer;
    NSTimeInterval movieDuration;
    NSTimeInterval playedSeconds;
    
    SKVASTControls *controls;
    
    float currentPlayedPercentage;
    BOOL isPlaying;
    BOOL isViewOnScreen;
    BOOL hasPlayerStarted;
    BOOL isLoadCalled;
    BOOL vastReady;
    BOOL statusBarHidden;
    CurrentVASTQuartile currentQuartile;
    UIActivityIndicatorView *loadingIndicator;
    UIViewController *presentingViewController;
    
    SKReachability *reachabilityForVAST;
    NetworkReachable networkReachableBlock;
    NetworkUnreachable networkUnreachableBlock;
}

@property(nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property(nonatomic, strong) UITapGestureRecognizer *touchGestureRecognizer;
@property(nonatomic, strong) SKVASTEventProcessor *eventProcessor;
@property(nonatomic, strong) NSMutableArray *videoHangTest;
@property(nonatomic, assign) BOOL networkCurrentlyReachable;

@end

@implementation SKVASTViewController

#pragma mark - Init & dealloc

- (id)init
{
    return [self initWithDelegate:nil withViewController:nil];
}

// designated initializer
- (id)initWithDelegate:(id<SKVASTViewControllerDelegate>)delegate withViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        presentingViewController = viewController;
        currentQuartile=VASTFirstQuartile;
        self.videoHangTest=[NSMutableArray arrayWithCapacity:20];
        [self setupReachability];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(applicationDidBecomeActive:)
													 name: UIApplicationDidBecomeActiveNotification
												   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieDuration:)
                                                     name:MPMovieDurationAvailableNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStateChangeNotification:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerLoadStateChanged:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieSourceType:)
                                                     name:MPMovieSourceTypeAvailableNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [reachabilityForVAST stopNotifier];
    [self removeObservers];
}

#pragma mark - Load methods

- (void)loadVideoWithURL:(NSURL *)url
{
    [self loadVideoUsingSource:url];
}

- (void)loadVideoWithData:(NSData *)xmlContent
{
    [self loadVideoUsingSource:xmlContent];
}

- (void)loadVideoUsingSource:(id)source
{
    if ([source isKindOfClass:[NSURL class]])
    {
        [SKLogger debug:@"VAST - View Controller" withMessage:@"Starting loadVideoWithURL"];
    } else {
        [SKLogger debug:@"VAST - View Controller" withMessage:@"Starting loadVideoWithData"];
    }
    
    if (isLoadCalled) {
        [SKLogger debug:@"VAST - View Controller" withMessage:@"Ignoring loadVideo because a load is in progress."];
        return;
    }
    isLoadCalled = YES;

    void (^parserCompletionBlock)(SKVASTModel *vastModel, SKVASTError vastError) = ^(SKVASTModel *vastModel, SKVASTError vastError) {
        [SKLogger debug:@"VAST - View Controller" withMessage:@"back from block in loadVideoFromData"];
        
        if (!vastModel) {
            [SKLogger error:@"VAST - View Controller" withMessage:@"parser error"];
            if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {  // The VAST document was not readable, so no Error urls exist, thus none are sent.
                [self.delegate vastError:self error:vastError];
            }
            return;
        }
        
        self.eventProcessor = [[SKVASTEventProcessor alloc] initWithTrackingEvents:[vastModel trackingEvents] withDelegate:_delegate];
        impressions = [vastModel impressions];
        vastErrors = [vastModel errors];
        self.clickThrough = [[vastModel clickThrough] url];
        clickTracking = [vastModel clickTracking];
        mediaFileURL = [SKVASTMediaFilePicker pick:[vastModel mediaFiles]].url;
        
        if(!mediaFileURL) {
            [SKLogger error:@"VAST - View Controller" withMessage:@"Error - VASTMediaFilePicker did not find a compatible mediaFile - VASTViewcontroller will not be presented"];
            if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {
                [self.delegate vastError:self error:VASTErrorNoCompatibleMediaFile];
            }
            if (vastErrors) {
                [SKLogger debug:@"VAST - View Controller" withMessage:@"Sending Error requests"];
                [self.eventProcessor sendVASTUrlsWithId:vastErrors];
            }
            return;
        }
        
        // VAST document parsing OK, player ready to attempt play, so send vastReady
        [SKLogger debug:@"VAST - View Controller" withMessage:@"Sending vastReady: callback"];
        vastReady = YES;
        [self.delegate vastReady:self];
    };
    
    SKVAST2Parser *parser = [[SKVAST2Parser alloc] init];
    if ([source isKindOfClass:[NSURL class]]) {
        if (!self.networkCurrentlyReachable) {
            [SKLogger error:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"No network available - VASTViewcontroller will not be presented"]];
            if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {
                [self.delegate vastError:self error:VASTErrorNoInternetConnection];  // There is network so no requests can be sent, we don't queue errors, so no external Error event is sent.
            }
            return;
        }
        [parser parseWithUrl:(NSURL *)source completion:parserCompletionBlock];     // Load the and parse the VAST document at the supplied URL
    } else {
        [parser parseWithData:(NSData *)source completion:parserCompletionBlock];   // Parse a VAST document in supplied data
    }
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isViewOnScreen=YES;
    if (!hasPlayerStarted) {
        loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ) {
            loadingIndicator.frame = CGRectMake( (self.view.frame.size.width/2)-25.0, (self.view.frame.size.height/2)-25.0,50,50);
        }
        else {
            loadingIndicator.frame = CGRectMake( (self.view.frame.size.height/2)-25.0, (self.view.frame.size.width/2)-25.0,50,50);
        }
        [loadingIndicator startAnimating];
        [self.view addSubview:loadingIndicator];
    } else {
        // resuming from background or phone call, so resume if was playing, stay paused if manually paused
        [self handleResumeState];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden withAnimation:UIStatusBarAnimationNone];
    }
}

#pragma mark - App lifecycle

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [SKLogger debug:@"VAST - View Controller" withMessage:@"applicationDidBecomeActive"];
    [self handleResumeState];
}

#pragma mark - MPMoviePlayerController notifications

- (void)playbackStateChangeNotification:(NSNotification *)notification
{
    @synchronized (self) {
        MPMoviePlaybackState state = [self.moviePlayer playbackState];
        [SKLogger debug:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"playback state change to %li", (long)state]];
        
        switch (state) {
            case MPMoviePlaybackStateStopped:  // 0
                [SKLogger debug:@"VAST - View Controller" withMessage:@"video stopped"];
                break;
            case MPMoviePlaybackStatePlaying:  // 1
                isPlaying=YES;
                if (loadingIndicator) {
                    [self stopVideoLoadTimeoutTimer];
                    [loadingIndicator stopAnimating];
                    [loadingIndicator removeFromSuperview];
                    loadingIndicator = nil;
                }
                if (isViewOnScreen) {
                    [SKLogger debug:@"VAST - View Controller" withMessage:@"video is playing"];
                    [self startPlaybackTimer];
                }
                break;
            case MPMoviePlaybackStatePaused:  // 2
                [self stopPlaybackTimer];
                [SKLogger debug:@"VAST - View Controller" withMessage:@"video paused"];
                isPlaying=NO;
                break;
            case MPMoviePlaybackStateInterrupted:  // 3
                [SKLogger debug:@"VAST - View Controller" withMessage:@"video interrupt"];
                break;
            case MPMoviePlaybackStateSeekingForward:  // 4
                [SKLogger debug:@"VAST - View Controller" withMessage:@"video seeking forward"];
                break;
            case MPMoviePlaybackStateSeekingBackward:  // 5
                [SKLogger debug:@"VAST - View Controller" withMessage:@"video seeking backward"];
                break;
            default:
                [SKLogger debug:@"VAST - View Controller" withMessage:@"undefined state change"];
                break;
        }
    }
}

- (void)moviePlayerLoadStateChanged:(NSNotification *)notification
{
    [SKLogger debug:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"movie player load state is %li", (long)self.moviePlayer.loadState]];
    
    if ((self.moviePlayer.loadState & MPMovieLoadStatePlaythroughOK) == MPMovieLoadStatePlaythroughOK )
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        [self showAndPlayVideo];
    }
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification
{
    @synchronized(self) {
        [SKLogger debug:@"VAST - View Controller" withMessage:@"playback did finish"];
        
        NSDictionary* userInfo=[notification userInfo];
        NSString* error= userInfo[kPlaybackFinishedUserInfoErrorKey];
        
        if (error) {
            [self stopVideoLoadTimeoutTimer];  // don't time out if there was a playback error
            [SKLogger error:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"playback error:  %@", error]];
            if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {
                [self.delegate vastError:self error:VASTErrorPlaybackError];
            }
            if (vastErrors) {
                [SKLogger debug:@"VAST - View Controller" withMessage:@"Sending Error requests"];
                [self.eventProcessor sendVASTUrlsWithId:vastErrors];
            }
            [self close];
        } else {
            // no error, clean finish, so send track complete
            [self.eventProcessor trackEvent:VASTEventTrackComplete];
            [self updatePlayedSeconds];
            [self showControls];
            [controls toggleToPlayButton:YES];
        }
    }
}

- (void)movieDuration:(NSNotification *)notification
{
    @try {
        movieDuration = self.moviePlayer.duration;
    }
    @catch (NSException *e) {
        [SKLogger error:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"Exception - movieDuration: %@", e]];
        // The movie too short error will fire if movieDuration is < 0.5 or is a NaN value, so no need for further action here.
    }
    
    [SKLogger debug:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"playback duration is %f", movieDuration]];
    
    if (movieDuration < 0.5 || isnan(movieDuration)) {
        // movie too short - ignore it
        [self stopVideoLoadTimeoutTimer];  // don't time out in this case
        [SKLogger warning:@"VAST - View Controller" withMessage:@"Movie too short - will dismiss player"];
        if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {
            [self.delegate vastError:self error:VASTErrorMovieTooShort];
        }
        if (vastErrors) {
            [SKLogger debug:@"VAST - View Controller" withMessage:@"Sending Error requests"];
            [self.eventProcessor sendVASTUrlsWithId:vastErrors];
        }
        [self close];
    }
}

- (void)movieSourceType:(NSNotification *)notification
{
    MPMovieSourceType sourceType;
    @try {
        sourceType = self.moviePlayer.movieSourceType;
    }
    @catch (NSException *e) {
        [SKLogger error:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"Exception - movieSourceType: %@", e]];
        // sourceType is used for info only - any player related error will be handled otherwise, ultimately by videoTimeout, so no other action needed here.
    }
    
    [SKLogger debug:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"movie source type is %li", (long)sourceType]];
}

#pragma mark - Orientation handling

// force to always play in Landscape
- (BOOL)shouldAutorotate
{
    NSArray *supportedOrientationsInPlist = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
    BOOL isLandscapeLeftSupported = [supportedOrientationsInPlist containsObject:@"UIInterfaceOrientationLandscapeLeft"];
    BOOL isLandscapeRightSupported = [supportedOrientationsInPlist containsObject:@"UIInterfaceOrientationLandscapeRight"];
    return isLandscapeLeftSupported && isLandscapeRightSupported;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    return UIInterfaceOrientationIsLandscape(currentInterfaceOrientation) ? currentInterfaceOrientation : UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Timers

// playbackTimer - keeps track of currentPlayedPercentage
- (void)startPlaybackTimer
{
    @synchronized (self) {
        [self stopPlaybackTimer];
        [SKLogger debug:@"VAST - View Controller" withMessage:@"start playback timer"];
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:kPlayTimeCounterInterval
                                                         target:self
                                                       selector:@selector(updatePlayedSeconds)
                                                       userInfo:nil
                                                        repeats:YES];
    }
}

- (void)stopPlaybackTimer
{
    [SKLogger debug:@"VAST - View Controller" withMessage:@"stop playback timer"];
    [playbackTimer invalidate];
    playbackTimer = nil;
}

- (void)updatePlayedSeconds
{
    @try {
        playedSeconds = self.moviePlayer.currentPlaybackTime;
    }
    @catch (NSException *e) {
        [SKLogger warning:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"Exception - updatePlayedSeconds: %@", e]];
        // The hang test below will fire if playedSeconds doesn't update (including a NaN value), so no need for further action here.
    }

    [self.videoHangTest addObject:@((int) (playedSeconds * 10.0))];     // add new number to end of hang test buffer
    
    if ([self.videoHangTest count]>20) {  // only check for hang if we have at least 20 elements or about 5 seconds of played video, to prevent false positives
        if ([[self.videoHangTest firstObject] integerValue]==[[self.videoHangTest lastObject] integerValue]) {
            [SKLogger error:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"Video error - video player hung at playedSeconds: %f", playedSeconds]];
            if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {
                [self.delegate vastError:self error:VASTErrorPlayerHung];
            }
            if (vastErrors) {
                [SKLogger debug:@"VAST - View Controller" withMessage:@"Sending Error requests"];
                [self.eventProcessor sendVASTUrlsWithId:vastErrors];
            }
            [self close];
        }
        [self.videoHangTest removeObjectAtIndex:0];   // remove oldest number from start of hang test buffer
    }
    
   	currentPlayedPercentage = (float)100.0*(playedSeconds/movieDuration);
    [controls updateProgressBar: currentPlayedPercentage/100.0 withPlayedSeconds:playedSeconds withTotalDuration:movieDuration];
    
    switch (currentQuartile) {
            
        case VASTFirstQuartile:
            if (currentPlayedPercentage>25.0) {
                [self.eventProcessor trackEvent:VASTEventTrackFirstQuartile];
                currentQuartile=VASTSecondQuartile;
            }
            break;
            
        case VASTSecondQuartile:
            if (currentPlayedPercentage>50.0) {
                [self.eventProcessor trackEvent:VASTEventTrackMidpoint];
                currentQuartile=VASTThirdQuartile;
            }
            break;
            
        case VASTThirdQuartile:
            if (currentPlayedPercentage>75.0) {
                [self.eventProcessor trackEvent:VASTEventTrackThirdQuartile];
                currentQuartile=VASTFourtQuartile;
            }
            break;
            
        default:
            break;
    }
}

// Reports error if vast video document times out while loading
- (void)startVideoLoadTimeoutTimer
{
    [SKLogger error:@"VAST - View Controller" withMessage:@"Start Video Load Timer"];
    videoLoadTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:[VASTSettings vastVideoLoadTimeout]
                                                             target:self
                                                           selector:@selector(videoLoadTimerFired)
                                                           userInfo:nil
                                                            repeats:NO];
}

- (void)stopVideoLoadTimeoutTimer
{
    [videoLoadTimeoutTimer invalidate];
    videoLoadTimeoutTimer = nil;
    [SKLogger error:@"VAST - View Controller" withMessage:@"Stop Video Load Timer"];
}

- (void)videoLoadTimerFired
{
    [SKLogger error:@"VAST - View Controller" withMessage:@"Video Load Timeout"];
    [self close];
    
    if (vastErrors) {
       [SKLogger debug:@"VAST - View Controller" withMessage:@"Sending Error requests"];
        [self.eventProcessor sendVASTUrlsWithId:vastErrors];
    }
    if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {
        [self.delegate vastError:self error:VASTErrorLoadTimeout];
    }
}

- (void)killTimers
{
    [self stopPlaybackTimer];
    [self stopVideoLoadTimeoutTimer];
}

#pragma mark - Methods needed to support toolbar buttons

- (void)play
{
    @synchronized (self) {
        [SKLogger debug:@"VAST - View Controller" withMessage:@"playVideo"];
        
        if (!vastReady) {
            if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {
                [self.delegate vastError:self error:VASTErrorPlayerNotReady];                  // This is not a VAST player error, so no external Error event is sent.
                [SKLogger warning:@"VAST - View Controller" withMessage:@"Ignoring call to playVideo before the player has sent vastReady."];
                return;
            }
        }
        
        if (isViewOnScreen) {
            if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {
                [self.delegate vastError:self error:VASTErrorPlaybackAlreadyInProgress];       // This is not a VAST player error, so no external Error event is sent.
                [SKLogger warning:@"VAST - View Controller" withMessage:@"Ignoring call to playVideo while playback is already in progress"];
                return;
            }
        }
        
        if (!self.networkCurrentlyReachable) {
            [SKLogger error:@"VAST - View Controller" withMessage:@"No network available - VASTViewcontroller will not be presented"];
            if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {
                [self.delegate vastError:self error:VASTErrorNoInternetConnection];   // There is network so no requests can be sent, we don't queue errors, so no external Error event is sent.
            }
            return;
        }
        
        // Now we are ready to launch the player and start buffering the content
        // It will throw error if the url is invalid for any reason. In this case, we don't even need to open ViewController.
        [SKLogger debug:@"VAST - View Controller" withMessage:@"initializing player"];
        
        @try {
            playedSeconds = 0.0;
            currentPlayedPercentage = 0.0;
            
            // Create and prepare the player to confirm the video is playable (or not) as early as possible
            [self startVideoLoadTimeoutTimer];
            self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: mediaFileURL];
            self.moviePlayer.shouldAutoplay = NO; // YES by default - But we don't want to autoplay
            self.moviePlayer.controlStyle=MPMovieControlStyleNone;  // To use custom control toolbar
            [self.moviePlayer prepareToPlay];
            [self presentPlayer];
        }
        @catch (NSException *e) {
            [SKLogger error:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"Exception - moviePlayer.prepareToPlay: %@", e]];
            if ([self.delegate respondsToSelector:@selector(vastError:error:)]) {
                [self.delegate vastError:self error:VASTErrorPlaybackError];
            }
            if (vastErrors) {
                [SKLogger debug:@"VAST - View Controller" withMessage:@"Sending Error requests"];
                [self.eventProcessor sendVASTUrlsWithId:vastErrors];
            }
            return;
        }
    }
}

- (void)pause
{
    [SKLogger debug:@"VAST - View Controller" withMessage:@"pause"];
    [self handlePauseState];
}

- (void)resume
{
    [SKLogger debug:@"VAST - View Controller" withMessage:@"resume"];
    [self handleResumeState];
}

- (void)info
{
    if (clickTracking) {
        [SKLogger debug:@"VAST - View Controller" withMessage:@"Sending clickTracking requests"];
        [self.eventProcessor sendVASTUrlsWithId:clickTracking];
    }
    if ([self.delegate respondsToSelector:@selector(vastOpenBrowseWithUrl:)]) {
        [self.delegate vastOpenBrowseWithUrl:self.clickThrough];
    }
}

- (void)close
{
    @synchronized (self) {
        [self removeObservers];
        [self killTimers];
        [self.moviePlayer stop];
        
        self.moviePlayer=nil;
        
        if (isViewOnScreen) {
            // send close any time the player has been dismissed
            [self.eventProcessor trackEvent:VASTEventTrackClose];
            [SKLogger debug:@"VAST - View Controller" withMessage:@"Dismissing VASTViewController"];
            [self dismissViewControllerAnimated:NO completion:nil];
            
            if ([self.delegate respondsToSelector:@selector(vastDidDismissFullScreen:)]) {
                [self.delegate vastDidDismissFullScreen:self];
            }
        }
    }
}

//
// Handle touches
//
#pragma mark - Gesture setup & delegate

- (void)setUpTapGestureRecognizer
{
    self.touchGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouches)];
    self.touchGestureRecognizer.delegate = self;
    [self.touchGestureRecognizer setNumberOfTouchesRequired:1];
    self.touchGestureRecognizer.cancelsTouchesInView=NO;  // required to enable controlToolbar buttons to receive touches
    [self.view addGestureRecognizer:self.touchGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handleTouches{
    if (!initialDelayTimer) {
        [self showControls];
    }
}

- (void)showControls
{
    initialDelayTimer = nil;
    [controls showControls];
}

#pragma mark - Reachability

- (void)setupReachability
{
    reachabilityForVAST = [SKReachability reachabilityForInternetConnection];
    reachabilityForVAST.reachableOnWWAN = YES;            // Do allow 3G/WWAN for reachablity
    
    __unsafe_unretained SKVASTViewController *self_ = self; // avoid block retain cycle
    
    networkReachableBlock  = ^(SKReachability*reachabilityForVAST){
        [SKLogger debug:@"VAST - View Controller" withMessage:@"Network reachable"];
        self_.networkCurrentlyReachable = YES;
    };
    
    networkUnreachableBlock = ^(SKReachability*reachabilityForVAST){
        [SKLogger debug:@"VAST - View Controller" withMessage:@"Network not reachable"];
        self_.networkCurrentlyReachable = NO;
    };
    
    reachabilityForVAST.reachableBlock = networkReachableBlock;
    reachabilityForVAST.unreachableBlock = networkUnreachableBlock;
    
    [reachabilityForVAST startNotifier];
    self.networkCurrentlyReachable = [reachabilityForVAST isReachable];
    [SKLogger debug:@"VAST - View Controller" withMessage:[NSString stringWithFormat:@"Network is reachable %d", self.networkCurrentlyReachable]];
}

#pragma mark - Other methods

- (BOOL)isPlaying
{
    return isPlaying;
}

- (void)showAndPlayVideo
{
    [SKLogger debug:@"VAST - View Controller" withMessage:@"adding player to on screen view and starting play sequence"];
    
    self.moviePlayer.view.frame=self.view.bounds;
    [self.view addSubview:self.moviePlayer.view];
    
    // N.B. The player has to be ready to play before controls may be added to the player's view
    [SKLogger debug:@"VAST - View Controller" withMessage:@"initializing player controls"];
    controls = [[SKVASTControls alloc] initWithVASTPlayer:self];
    [self.moviePlayer.view addSubview: controls];
    
    if (kFirstShowControlsDelay > 0) {
        [controls hideControls];
        initialDelayTimer = [NSTimer scheduledTimerWithTimeInterval:kFirstShowControlsDelay
                                                             target:self
                                                           selector:@selector(showControls)
                                                           userInfo:nil
                                                            repeats:NO];
    } else {
        [self showControls];
    }
    
    [self.moviePlayer play];
    hasPlayerStarted=YES;
    
    if (impressions) {
        [SKLogger debug:@"VAST - View Controller" withMessage:@"Sending Impressions requests"];
        [self.eventProcessor sendVASTUrlsWithId:impressions];
    }
    [self.eventProcessor trackEvent:VASTEventTrackStart];
    [self setUpTapGestureRecognizer];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMovieDurationAvailableNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMovieSourceTypeAvailableNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)handlePauseState
{
    @synchronized (self) {
    if (isPlaying) {
        [SKLogger debug:@"VAST - View Controller" withMessage:@"handle pausing player"];
        [self.moviePlayer pause];
        isPlaying = NO;
        [self.eventProcessor trackEvent:VASTEventTrackPause];
    }
    [self stopPlaybackTimer];
    }
}

- (void)handleResumeState
{
    @synchronized (self) {
    if (hasPlayerStarted) {
        if (![controls controlsPaused]) {
        // resuming from background or phone call, so resume if was playing, stay paused if manually paused by inspecting controls state
        [SKLogger debug:@"VAST - View Controller" withMessage:@"handleResumeState, resuming player"];
        [self.moviePlayer play];
        isPlaying = YES;
        [self.eventProcessor trackEvent:VASTEventTrackResume];
        [self startPlaybackTimer];
        }
    } else if (self.moviePlayer) {
        [self showAndPlayVideo];   // Edge case: loadState is playable but not playThroughOK and had resignedActive, so play immediately on resume
    }
    }
}

- (void)presentPlayer
{
    if ([self.delegate respondsToSelector:@selector(vastWillPresentFullScreen:)]) {
        [self.delegate vastWillPresentFullScreen:self];
    }
    
    if ([presentingViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        // used if running >= iOS 6
        [presentingViewController presentViewController:self animated:NO completion:nil];
    } else {
        // Turn off the warning about using a deprecated method.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [presentingViewController presentModalViewController:self animated:NO];
#pragma clang diagnostic pop
    }
}

@end
