//
//  SKVAST2Parser.h
//  VAST
//
//  Created by Jay Tucker on 10/2/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//
//  VAST2Parser parses a supplied VAST 2.0 URL or document and returns the result in VASTModel.

#import <Foundation/Foundation.h>
#import "SKVASTError.h"

@class SKVASTModel;

@interface SKVAST2Parser : NSObject

- (void)parseWithUrl:(NSURL *)url completion:(void (^)(SKVASTModel *, SKVASTError))block;
- (void)parseWithData:(NSData *)vastData completion:(void (^)(SKVASTModel *, SKVASTError))block;;

@end
