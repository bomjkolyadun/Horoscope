//
//  SKVASTMediaFilePicker.m
//  VAST
//
//  Created by Muthu on 11/20/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

#import "SKVASTMediaFilePicker.h"
#import "SKReachability.h"
#import "VASTSettings.h"
#import "SKLogger.h"
#import <UIKit/UIKit.h>

// This enum will be of more use if we ever decide to include the media files'
// delivery type and/or bitrate into the picking algorithm.
typedef enum {
    NetworkTypeCellular,
    NetworkTypeNone,
    NetworkTypeWiFi
} NetworkType;

@interface SKVASTMediaFilePicker()

+ (NetworkType)networkType;
+ (BOOL)isMIMETypeCompatible:(SKVASTMediaFile *)vastMediaFile;

@end

@implementation SKVASTMediaFilePicker

+ (SKVASTMediaFile *)pick:(NSArray *)mediaFiles
{
    // Check whether we even have a network connection.
    // If not, return a nil.
    NetworkType networkType = [self networkType];
    
    [SKLogger debug:@"VAST - Mediafile Picker" withMessage:[NSString stringWithFormat:@"NetworkType: %d", networkType]];
    if (networkType == NetworkTypeNone) {
        return nil;
    }
    
    // Go through the provided media files and only those that have a compatible MIME type.
    NSMutableArray *compatibleMediaFiles = [[NSMutableArray alloc] init];
    for (SKVASTMediaFile *vastMediaFile in mediaFiles) {
        // Make sure that you have type specified for mediafile and ignore accordingly
        if (vastMediaFile.type != nil && [self isMIMETypeCompatible:vastMediaFile]) {
            [compatibleMediaFiles addObject:vastMediaFile];
        }
    }
    if ([compatibleMediaFiles count] == 0) {
        return nil;
    }
    
    // Sort the media files based on their video size (in square pixels).
    NSArray *sortedMediaFiles = [compatibleMediaFiles sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        SKVASTMediaFile *mf1 = (SKVASTMediaFile *)a;
        SKVASTMediaFile *mf2 = (SKVASTMediaFile *)b;
        int area1 = mf1.width * mf1.height;
        int area2 = mf2.width * mf2.height;
        if (area1 < area2) {
            return NSOrderedAscending;
        } else if (area1 > area2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    // Pick the media file with the video size closes to the device's screen size.
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    int screenArea = screenSize.width * screenSize.height;
    int bestMatch = 0;
    int bestMatchDiff = INT_MAX;
    int len = (int)[sortedMediaFiles count];
    
    for (int i = 0; i < len; i++) {
        int videoArea = ((SKVASTMediaFile *)sortedMediaFiles[i]).width * ((SKVASTMediaFile *)sortedMediaFiles[i]).height;
        int diff = abs(screenArea - videoArea);
       if (diff >= bestMatchDiff) {
            break;
        }
        bestMatch = i;
        bestMatchDiff = diff;
    }
    
    SKVASTMediaFile *toReturn = (SKVASTMediaFile *)sortedMediaFiles[bestMatch];
    [SKLogger debug:@"VAST - Mediafile Picker" withMessage:[NSString stringWithFormat:@"Selected Media File: %@", toReturn.url]];
    return toReturn;
}

+ (NetworkType)networkType
{
    SKReachability* reach = [SKReachability reachabilityWithHostname:@"www.google.com"];
    NetworkType reachableState = NetworkTypeNone;
    if ([reach isReachable]) {
        if ([reach isReachableViaWiFi]) {
            reachableState = NetworkTypeWiFi;
        } else if ([reach isReachableViaWWAN]) {
            reachableState = NetworkTypeCellular;
        }
    }
    return reachableState;
}

+ (BOOL)isMIMETypeCompatible:(SKVASTMediaFile *)vastMediaFile
{
    NSString *pattern = @"(mp4|m4v|quicktime|3gpp)";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:vastMediaFile.type
                                      options:0
                                        range:NSMakeRange(0, [vastMediaFile.type length])];
    
    return ([matches count] > 0);
}

@end
