//
//  SKVAST2Parser.m
//  VAST
//
//  Created by Jay Tucker on 10/2/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

#import "SKVAST2Parser.h"
#import "VASTXMLUtil.h"
#import "SKVASTModel.h"
#import "VASTSchema.h"
#import "VASTSettings.h"
#import "SKLogger.h"

@interface SKVAST2Parser ()
{
    SKVASTModel *vastModel;
}

- (SKVASTError)parseRecursivelyWithData:(NSData *)vastData depth:(int)depth;

@end

@implementation SKVAST2Parser

- (id)init
{
    self = [super init];
    if (self) {
        vastModel = [[SKVASTModel alloc] init];
    }
    return self;
}

#pragma mark - "public" methods

- (void)parseWithUrl:(NSURL *)url completion:(void (^)(SKVASTModel *, SKVASTError))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *vastData = [NSData dataWithContentsOfURL:url];
        SKVASTError vastError = [self parseRecursivelyWithData:vastData depth:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(vastModel, vastError);
        });
    });
}

- (void)parseWithData:(NSData *)vastData completion:(void (^)(SKVASTModel *, SKVASTError))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SKVASTError vastError = [self parseRecursivelyWithData:vastData depth:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(vastModel, vastError);
        });
    });
}

#pragma mark - "private" method

- (SKVASTError)parseRecursivelyWithData:(NSData *)vastData depth:(int)depth
{
    if (depth >= kMaxRecursiveDepth) {
        vastModel = nil;
        return VASTErrorTooManyWrappers;
    }
    
    // sanity check
    NSString *content = [[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding];
    [SKLogger debug:@"VAST-Parser" withMessage:[NSString stringWithFormat:@"VAST file\n%@", content]];

    // Validate the basic XML syntax of the VAST document.
    BOOL isValid;
    isValid = validateXMLDocSyntax(vastData);
    if (!isValid) {
        vastModel = nil;
        return VASTErrorXMLParse;
    }

    if (kValidateWithSchema) {
        [SKLogger debug:@"VAST-Parser" withMessage:@"Validating against schema"];
        
        // Using header data
        NSData *vastSchemaData = [NSData dataWithBytesNoCopy:nexage_vast_2_0_1_xsd
                                                      length:nexage_vast_2_0_1_xsd_len
                                                freeWhenDone:NO];
        isValid = validateXMLDocAgainstSchema(vastData, vastSchemaData);
        if (!isValid) {
            vastModel = nil;
            return VASTErrorSchemaValidation;
        }
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [vastModel performSelector:@selector(addVASTDocument:) withObject:vastData];
#pragma clang diagnostic pop
    
    // Check to see whether this is a wrapper ad. If so, process it.
    NSString *query = @"//VASTAdTagURI";
    NSArray *results = performXMLXPathQuery(vastData, query);
    if ([results count] > 0) {
        NSString *url;
        NSDictionary *node = results[0];
        if ([node[@"nodeContent"] length] > 0) {
            // this is for string data
            url =  node[@"nodeContent"];
        } else {
            // this is for CDATA
            NSArray *childArray = node[@"nodeChildArray"];
            if ([childArray count] > 0) {
                // we assume that there's only one element in the array
                url = ((NSDictionary *)childArray[0])[@"nodeContent"];
            }
        }
        vastData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        return [self parseRecursivelyWithData:vastData depth:(depth + 1)];
    }
    
    return VASTErrorNone;
}

- (NSString *)content:(NSDictionary *)node
{
    // this is for string data
    if ([node[@"nodeContent"] length] > 0) {
        return node[@"nodeContent"];
    }
    
    // this is for CDATA
    NSArray *childArray = node[@"nodeChildArray"];
    if ([childArray count] > 0) {
        // we assume that there's only one element in the array
        return ((NSDictionary *)childArray[0])[@"nodeContent"];
    }
    
    return nil;
}

@end
