//
//  SKVASTControls.h
//  VAST
//
//  Created by Thomas Poland on 11/13/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//
//  VASTControls manages a UIToolbar which allows for end user control of the video.
//  The toolbar appears for kControlTimerInterval seconds when the screen is touched.
//  3 controls are available:"  pause/play (depends on context), info (to 'clickthrough' url), and 'X', stop and close.

#import <UIKit/UIKit.h>
#import "SKVASTViewController.h"

@interface SKVASTControls : UIView

- (id)initWithVASTPlayer:(SKVASTViewController *)vastPlayer;       // designated initializer
- (void)toggleToPlayButton:(BOOL)toggleToPlay;                   // toggle the pause/play button YES=play, NO=pause
- (void)showControls;                                            // showControls, used by VASTViewController, for example at initial start of playback
- (void)hideControls;                                            // hideControls, used by VASTViewController, for example at initial start of playback
- (void)updateProgressBar:(float)progress withPlayedSeconds:(float)playedSeconds withTotalDuration:(float)totalDuration;   // update the progress bar with the supplied value
- (BOOL)controlsPaused;                                          // used by the player to detect manual pause

@end
