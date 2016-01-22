//
//  SKVASTControls.m
//  VAST
//
//  Created by Thomas Poland on 11/13/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

#import "SKVASTControls.h"
#import "SKLogger.h"

static const float kControlTimerInterval = 2.0;
static const float kControlsToobarFixedLeftWidth = 16.0;
static const float kControlsToobarFixedPauseWidth = 42.0;
static const float kControlsToobarFixedInfoWidth = 22.0;
static const float kControlsToobarHeight = 44.0;

#define SYSTEM_VERSION_LESS_THAN(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface SKVASTControls ()
{
    NSTimer *controlsTimer;
    UIToolbar *controlsToolbar;
    UIBarButtonItem *fixedLeft;
    UIBarButtonItem *playButton;
    UIBarButtonItem *pauseButton;
    UIBarButtonItem *fixedPause;
    UIBarButtonItem *playbackTimeLabel;
    UIBarButtonItem *flexPlayback;
    UIBarButtonItem *infoButton;
    UIBarButtonItem *fixedInfo;
    UIBarButtonItem *stopButton;
    UIProgressView *progressBar;
}

@property (nonatomic, unsafe_unretained) SKVASTViewController *player;

- (IBAction)pausePlay:(id)sender;
- (IBAction)info:(id)sender;
- (IBAction)stopButtonTouched:(id)sender;

@end

@implementation SKVASTControls

- (id)initWithVASTPlayer:(SKVASTViewController *)vastPlayer
{
    self = [super initWithFrame:vastPlayer.view.frame];
    
    if (self) {
        CGRect toolbarFrame = CGRectMake(0, 0, vastPlayer.view.bounds.size.width, kControlsToobarHeight);
        controlsToolbar = [[ UIToolbar alloc] initWithFrame:toolbarFrame];
       
        // In left to right order, to make layout on screen more clear
        fixedLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedLeft.width = kControlsToobarFixedLeftWidth;
        pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:(self) action:@selector(pausePlay:)];
        playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:(self) action:@selector(pausePlay:)];
        fixedPause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedPause.width = kControlsToobarFixedPauseWidth;
        playbackTimeLabel = [[UIBarButtonItem alloc] initWithCustomView:nil];
        flexPlayback = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        infoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:(self) action:@selector(info:)];
        fixedInfo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedInfo.width = kControlsToobarFixedInfoWidth;
        stopButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:(self) action:@selector(stopButtonTouched:)];
        NSArray *toolbarButtons = @[fixedLeft, pauseButton, playButton, fixedPause, playbackTimeLabel, flexPlayback, infoButton, fixedInfo, stopButton];
        [controlsToolbar setItems:toolbarButtons animated:NO];
        
        _player = vastPlayer;
        self.frame = controlsToolbar.frame;
        [self addSubview:controlsToolbar];
        [self toggleToPlayButton:NO];
        self.frame = CGRectMake(0, vastPlayer.view.bounds.size.height-self.frame.size.height, vastPlayer.view.bounds.size.width, self.frame.size.height);
        
        if (!vastPlayer.clickThrough) {
            NSMutableArray *toolbarButtons = [controlsToolbar.items mutableCopy];
            [toolbarButtons removeObject:infoButton];
            [controlsToolbar setItems:toolbarButtons animated:NO];
        }
        
        // Hide progress bar + time display in iOS 6.1 and below
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            NSMutableArray *toolbarButtons = [controlsToolbar.items mutableCopy];
            [toolbarButtons removeObject:playbackTimeLabel];
            [controlsToolbar setItems:toolbarButtons animated:NO];
            
            // Set toolbar color
            [controlsToolbar setTintColor:[UIColor blackColor]];
        } else {
            progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
            progressBar.frame = CGRectMake(0,0, self.frame.size.width, 10);
            progressBar.trackTintColor = [UIColor lightGrayColor];
            [self updateProgressBar:0 withPlayedSeconds:0 withTotalDuration:0];
            [self addSubview:progressBar];
        }
    }
    return self;
}

- (IBAction)pausePlay:(id)sender
{
    if ([self.player isPlaying]) {
        [self.player pause];
        [self toggleToPlayButton:YES];
    }
    else {
        [self toggleToPlayButton:NO];
        [self.player resume];
    }
}

- (BOOL)controlsPaused
{
    return [controlsToolbar.items containsObject:playButton];
}

- (IBAction)info:(id)sender
{
    [self.player info];
}

- (IBAction)stopButtonTouched:(id)sender
{
    [self.player close];
}

-(void)toggleToPlayButton:(BOOL)toggleToPlay
{
    @synchronized (self) {
        NSMutableArray *toolbarButtons = [controlsToolbar.items mutableCopy];
        if (toggleToPlay) {  // show play button
            [toolbarButtons removeObject:pauseButton];
            if( [toolbarButtons containsObject: playButton ]) {
                [toolbarButtons removeObject: playButton];    // handle initial case
            }
            [toolbarButtons insertObject:playButton atIndex:1];
            [self stopControlsTimer];
            self.hidden = NO;  // always show the controls toobar when paused
            [SKLogger debug:@"VAST-Toolbar" withMessage:@"Toggle to playButton visible"];
        } else {             // show pause button
            [toolbarButtons removeObject:playButton];
            if ([toolbarButtons containsObject: pauseButton]) {
                [toolbarButtons removeObject: pauseButton];    // handle initial case
            }
            [toolbarButtons insertObject:pauseButton atIndex:1];
            [self startControlsTimer];
            [SKLogger debug:@"VAST-Toolbar" withMessage:@"Toggle to pauseButton visible"];
        }
        [controlsToolbar setItems:toolbarButtons animated:NO];
    }
}

// controlsTimer - removes controls toolbar after the defined interval
- (void)startControlsTimer
{
    [self stopControlsTimer];

    controlsTimer = [NSTimer scheduledTimerWithTimeInterval:kControlTimerInterval
                                                     target:self
                                                   selector:@selector(hideControls)
                                                   userInfo:nil
                                                    repeats:NO];
}

- (void)showControls
{
    self.hidden = NO;
    [self startControlsTimer];
}

- (void)hideControls
{
    self.hidden = YES;
}

- (void)stopControlsTimer
{
    [controlsTimer invalidate];
    controlsTimer = nil;
}

- (void)updateProgressBar:(float)progress withPlayedSeconds:(float)playerSeconds withTotalDuration:(float)totalDuration
{
    [progressBar setProgress:progress animated:YES];
    int totalSeconds =  (int)totalDuration % 60;
    int totalMinutes = ((int)totalDuration / 60) % 60;
    int playedSeconds =  (int)playerSeconds % 60;
    int playedMinutes = (int)(playerSeconds / 60) % 60;
    playbackTimeLabel.title = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d",playedMinutes, playedSeconds, totalMinutes, totalSeconds];
}

- (void)dealloc
{
    [self stopControlsTimer];
}

@end
