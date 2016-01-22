//
//  SKVASTMediaFilePicker.h
//  VAST
//
//  Created by Muthu on 11/20/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKVASTMediaFile.h"

// An implementation of how to pick media file from one or more in a VAST Document. VASTMediaFilePicker looks for internet first and eliminate entries with mime type which we can't play in the phone. After that, the list is sorted by bit rate (if exists) along with hi or low speed connection + progressive/streaming attribute. Once we have the final list, we end up picking the first from the list. If you have no valid media file to pick, you will get a nil and that will generate an error to the caller.
@interface SKVASTMediaFilePicker : NSObject

+ (SKVASTMediaFile *)pick:(NSArray *)mediaFiles;

@end
