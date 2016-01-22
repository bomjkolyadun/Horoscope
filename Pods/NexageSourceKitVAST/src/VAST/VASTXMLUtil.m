//
//  VASTXMLUtil.m
//  VAST
//
//  Created by Jay Tucker on 10/15/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

#import "VASTXMLUtil.h"
#import "SKLogger.h"

#import <libxml/tree.h>
#import <libxml/xpath.h>
#include <libxml/xmlschemastypes.h>

#define LIBXML_SCHEMAS_ENABLED

#pragma mark - error/warning callback functions

void documentParserErrorCallback(void *ctx, const char *msg, ...)
{
    va_list args;
    va_start (args, msg);
    char *s = va_arg(args, char*);
    NSString *errMsg;
    if(s){
        errMsg = [[NSString stringWithCString:s encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    if ([errMsg length] > 0) {
        [SKLogger error:@"VAST - XML Util" withMessage:[NSString stringWithFormat:@"Document parser error: %@", errMsg]];
    }
    va_end(args);
}

void schemaParserErrorCallback(void *ctx, const char *msg, ...)
{
    va_list args;
	va_start (args, msg);
    char *s = va_arg(args, char*);
    NSString *errMsg = [[NSString stringWithCString:s encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([errMsg length] > 0) {
        [SKLogger error:@"VAST - XML Util" withMessage:[NSString stringWithFormat:@"Schema parser error: %@", errMsg]];
    }
    va_end(args);
}

void schemaParserWarningCallback(void *ctx, const char *msg, ...)
{
    va_list args;
	va_start (args, msg);
    char *s = va_arg(args, char*);
    NSString *errMsg = [[NSString stringWithCString:s encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([errMsg length] > 0) {
        [SKLogger warning:@"VAST - XML Util" withMessage:[NSString stringWithFormat:@"Schema parser warning: %@", errMsg]];
    }
    va_end(args);
}

void schemaValidationErrorCallback(void *ctx, const char *msg, ...)
{
    va_list args;
	va_start (args, msg);
    char *s = va_arg(args, char*);
    NSString *errMsg = [[NSString stringWithCString:s encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([errMsg length] > 0) {
        [SKLogger error:@"VAST - XML Util" withMessage:[NSString stringWithFormat:@"Schema validation error: %@", errMsg]];
    }
    va_end(args);
}

void schemaValidationWarningCallback(void *ctx, const char *msg, ...)
{
    va_list args;
	va_start (args, msg);
    char *s = va_arg(args, char*);
    NSString *errMsg = [[NSString stringWithCString:s encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([errMsg length] > 0) {
        [SKLogger warning:@"VAST - XML Util" withMessage:[NSString stringWithFormat:@"Schema validation warning: %@", errMsg]];
    }
    va_end(args);
}

#pragma mark - internal helper functions

NSDictionary *dictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult)
{
	NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];
	
	if (currentNode->name) {
		NSString *currentNodeContent = [NSString stringWithCString:(const char *)currentNode->name encoding:NSUTF8StringEncoding];
		resultForNode[@"nodeName"] = currentNodeContent;
	}
	
	if (currentNode->content && currentNode->type != XML_DOCUMENT_TYPE_NODE) {
		NSString *currentNodeContent = [NSString stringWithCString:(const char *)currentNode->content encoding:NSUTF8StringEncoding];
		
		if ([resultForNode[@"nodeName"] isEqual:@"text"] && parentResult) {
			currentNodeContent = [currentNodeContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			NSString *existingContent = parentResult[@"nodeContent"];
			NSString *newContent;
			if (existingContent) {
				newContent = [existingContent stringByAppendingString:currentNodeContent];
			} else {
				newContent = currentNodeContent;
			}
            
			parentResult[@"nodeContent"] = newContent;
			return nil;
		}
		
		resultForNode[@"nodeContent"] = currentNodeContent;
	}
	
	xmlAttr *attribute = currentNode->properties;
    
	if (attribute) {
		NSMutableArray *attributeArray = [NSMutableArray array];
		while (attribute) {
			NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
			NSString *attributeName = [NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
			if (attributeName) {
				attributeDictionary[@"attributeName"] = attributeName;
			}
			
			if (attribute->children) {
				NSDictionary *childDictionary = dictionaryForNode(attribute->children, attributeDictionary);
				if (childDictionary) {
					attributeDictionary[@"attributeContent"] = childDictionary;
				}
			}
			
			if ([attributeDictionary count] > 0) {
				[attributeArray addObject:attributeDictionary];
			}
			attribute = attribute->next;
		}
		
		if ([attributeArray count] > 0) {
			resultForNode[@"nodeAttributeArray"] = attributeArray;
		}
	}
    
	xmlNodePtr childNode = currentNode->children;
	if (childNode) {
		NSMutableArray *childContentArray = [NSMutableArray array];
		while (childNode) {
			NSDictionary *childDictionary = dictionaryForNode(childNode, resultForNode);
			if (childDictionary) {
				[childContentArray addObject:childDictionary];
			}
			childNode = childNode->next;
		}
		if ([childContentArray count] > 0) {
			resultForNode[@"nodeChildArray"] = childContentArray;
		}
	}
	
	return resultForNode;
}

NSArray *performXPathQuery(xmlDocPtr doc, NSString *query)
{
    xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    
    // Create xpath evaluation context
    xpathCtx = xmlXPathNewContext(doc);
    if (xpathCtx == NULL) {
        [SKLogger error:@"VAST - XML Util" withMessage:@"Unable to create XPath context."];
		return nil;
    }
    
    // Evaluate xpath expression
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if (xpathObj == NULL) {
        [SKLogger error:@"VAST - XML Util" withMessage:@"Unable to evaluate XPath."];
		return nil;
    }
	
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	if (!nodes) {
        [SKLogger debug:@"VAST - XML Util" withMessage:@"Nodes was nil."];
		return nil;
	}
	
	NSMutableArray *resultNodes = [NSMutableArray array];
	for (NSInteger i = 0; i < nodes->nodeNr; i++) {
		NSDictionary *nodeDictionary = dictionaryForNode(nodes->nodeTab[i], nil);
		if (nodeDictionary) {
			[resultNodes addObject:nodeDictionary];
		}
	}
    
    // Cleanup
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx);
    
    return resultNodes;
}

#pragma mark - "public" API

BOOL validateXMLDocSyntax(NSData *document)
{
    BOOL retval = YES;
    xmlSetGenericErrorFunc(NULL, (xmlGenericErrorFunc)documentParserErrorCallback);
	xmlDocPtr doc = xmlReadMemory([document bytes], (int)[document length], "", NULL, 0); // XML_PARSE_RECOVER);
    if (doc == NULL) {
        [SKLogger error:@"VAST - XML Util" withMessage:@"Unable to parse."];
		retval = NO;
    } else {
        xmlFreeDoc(doc);
    }
    xmlCleanupParser();
    return retval;
}

BOOL validateXMLDocAgainstSchema(NSData *document, NSData *schemaData)
{
    xmlSetGenericErrorFunc(NULL, (xmlGenericErrorFunc)documentParserErrorCallback);
    
    // load XML document
	xmlDocPtr doc = xmlReadMemory([document bytes], (int)[document length], "", NULL, 0); // XML_PARSE_RECOVER);
    if (doc == NULL) {
        [SKLogger error:@"VAST - XML Util" withMessage:@"Unable to parse."];
        xmlCleanupParser();
		return NO;
    }
    
    xmlLineNumbersDefault(1);
    
    xmlSchemaParserCtxtPtr parserCtxt = xmlSchemaNewMemParserCtxt([schemaData bytes], (int)[schemaData length]);
    
    xmlSchemaSetParserErrors(parserCtxt,
                             (xmlSchemaValidityErrorFunc)schemaParserErrorCallback,
                             (xmlSchemaValidityWarningFunc)schemaParserWarningCallback,
                             NULL);
    
    xmlSchemaPtr schema = xmlSchemaParse(parserCtxt);
    xmlSchemaFreeParserCtxt(parserCtxt);
    
    // xmlSchemaDump(stdout, schema); //To print schema dump
    
    xmlSchemaValidCtxtPtr validCtxt = xmlSchemaNewValidCtxt(schema);
    xmlSchemaSetValidErrors(validCtxt,
                            (xmlSchemaValidityErrorFunc)schemaValidationErrorCallback,
                            (xmlSchemaValidityWarningFunc)schemaValidationWarningCallback,
                            NULL);
    int ret = xmlSchemaValidateDoc(validCtxt, doc);
    if (ret == 0) {
        [SKLogger error:@"VAST - XML Util" withMessage:@"document is valid"];
    } else if (ret > 0) {
        [SKLogger error:@"VAST - XML Util" withMessage:@"document is invalid"];
    } else {
        [SKLogger error:@"VAST - XML Util" withMessage:@"validation generated an internal error"];
    }
    
    xmlSchemaFreeValidCtxt(validCtxt);
    xmlFreeDoc(doc);
    
    // free the resource
    if (schema != NULL) {
        xmlSchemaFree(schema);
    }
    
    xmlSchemaCleanupTypes();
    xmlCleanupParser();
    xmlMemoryDump();
    
    return (ret == 0);
}

NSArray *performXMLXPathQuery(NSData *document, NSString *query)
{
    xmlDocPtr doc;
	doc = xmlReadMemory([document bytes], (int)[document length], "", NULL, 0); // XML_PARSE_RECOVER);
    if (doc == NULL) {
        [SKLogger error:@"VAST - XML Util" withMessage:@"Unable to parse."];
		return nil;
    }
	NSArray *result = performXPathQuery(doc, query);
    xmlFreeDoc(doc);
	return result;
}
