Nexage Integration SourceKit for VAST
=====================================

Nexage Integration SourceKit for VAST is an easy to use library which implements the [IAB VAST 2.0 spec] (http://www.iab.net/guidelines/508676/digitalvideo/vsuite/vast/vast_copy). It is 
written in Objective-C and works in both iPhone and iPad applications.

**Features:**

- VAST 2 implementation
- Handles VAST & VAST Wrapper
- 4 level logging
- Integrates with just a few lines of code
- ARC support

Please look at our [Wiki](https://github.com/nexage/sourcekit-vast-ios/wiki) for additional information & FAQ.

**Requirements:**

- iOS 5.0+
- Xcode: 5.0+
- SourceKitCommon Github project (https://github.com/nexage/sourcekit-common-ios)

Getting Started
===============

Step 1: Include the "VAST" & "SourceKitCommon" Xcode projects.  Please make sure that you clone the SourceKitCommon Github repository in the same folder level as VAST.

Step 2: Copy or include the following header files into your project;

	SKVASTError.h
    VASTSettings.h
	SKVASTViewController.h
	
Step 3: Import these header files into the class which will use a VASTViewController (step 7):

	#import "VASTError.h"
	#import "VASTViewController.h"
	#import "VASTSettings.h"

Step 4: Edit Build Settings

	Header Search Paths => /usr/include/libxml2
	Other Linker Flags => -lxml2

    Edit Build Phases under target

	Target Dependencies - Add VAST & SourceKitCommon projects
	Link Binary with Libraries - Add libVAST.a, libSourceKitCommon.a, MediaPlayer.framework & SystemConfiguration.framework
	
Step 5: Create a SKVASTViewController and implement SKVASTViewControllerDelegate delegate. Then call the loadVideoWithURL: method with a url that will return valid VAST XML formatted content, as in this example:

    self.vastVC = [[SKVASTViewController alloc] initWithDelegate: self];
   	NSURL* url = [NSURL URLWithString:@"...valid url for a VAST XML document..."];
    [self.vastVC loadVideoWithURL:url];
    
Step 6: Listen for SKVASTViewControllerDelegate callbacks. Please look into SKVASTViewControllerDelegate.h for more information.  To play the video, you must wait for the 'vastReady' callback, then send the playVideo message, as follows:

	- (void)vastReady:(SKVASTViewController *)vc
	{
    	[vc play];
	}
	
Optional: If you are interested in listening for different events (start, firstquartile, complete, etc.), use the following:

	-(void)vastTrackingEvent:(NSString *)eventName
	{
		NSLog(@"callback for event %@", eventName);
	}
    
Optional: To enable 4 level logging, insert this code in your AppDelegate. Its settings affect both MRAID & VAST if you have it in your app:
	
	[SKLogger setLogLevel:SourceKitLogLevelDebug];   // select desired log level


That's it! 


LICENSE
=======

Copyright (c) 2013, Nexage, Inc.<br/> 
All rights reserved.<br/>
Provided under BSD-3 license as follows:<br/>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1.  Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

3.  Neither the name of Nexage nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
