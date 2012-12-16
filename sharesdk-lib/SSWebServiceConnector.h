//
//  WebServiceConnector.h
//  ThingsToDo
//
//  Created by Jesse Curry on 6/22/10.
//  Copyright 2010 St. Pete Times. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SSWebServiceConnector;
@protocol SSWebServiceConnectorDelegate;
typedef void (^WebServiceConnectorCompletionHandler)(SSWebServiceConnector* webServiceConnector, id result, NSError* error);

////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 Simple class for connecting to web services.
 
 WebServiceConnector will reach out to a web ser
 */
@interface SSWebServiceConnector : NSObject
{	
    NSString*               _urlString;
    
	NSTimeInterval			startTime;
	NSTimeInterval			responseTime;
	NSTimeInterval			postParseTime;
}
@property (nonatomic, strong) NSDictionary* parameters;
@property (nonatomic, strong) NSDictionary* requestHeaderFields;
@property (nonatomic, strong) NSData* httpBody;
@property (nonatomic, strong) NSString* httpMethod;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) id context;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, strong) NSDictionary* responseHeaderFields;

@property (nonatomic, assign) NSUInteger  currentPage;
@property (nonatomic, assign) NSUInteger  numberOfPages;
@property (nonatomic, assign) NSUInteger  resultsPerPage;

+ (NSInteger)connectionCount;

+ (BOOL)verbose;
+ (void)setVerbose: (BOOL)verbose;

+ (void)setDefaultRequestHeaderFields: (NSDictionary*)defaultRequestHeaders;
+ (NSString*)webServiceRoot;
+ (NSString*)webServiceFormatSpecifier;

// Connection queue
+ (NSInteger)maxConnectionCount;
+ (void)setMaxConnectionCount: (NSInteger)maxConnectionCount;

@property (unsafe_unretained, nonatomic, readonly) NSString*		urlStringWithParameters;

- (id)initWithURLString: (NSString*)aUrlString
			 parameters: (NSDictionary*)someParameters
			   httpBody: (NSData*)theHttpBody;
- (id)initWithPathString: (NSString*)pathString
			  parameters: (NSDictionary*)parameters
				httpBody: (NSData*)httpBody;

// Completion Handler
- (id)initWithURLString: (NSString*)urlString
			 parameters: (NSDictionary*)parameters
			   httpBody: (NSData*)httpBody
      completionHandler: (WebServiceConnectorCompletionHandler)completionHandler;
- (id)initWithPathString: (NSString*)pathString
			  parameters: (NSDictionary*)parameters
				httpBody: (NSData*)httpBody
       completionHandler: (WebServiceConnectorCompletionHandler)completionHandler;

// Delegate based
- (id)initWithURLString: (NSString*)urlString
			 parameters: (NSDictionary*)parameters
			   httpBody: (NSData*)httpBody
			   delegate: (id<SSWebServiceConnectorDelegate>)delegate;
- (id)initWithPathString: (NSString*)pathString
			  parameters: (NSDictionary*)parameters
				httpBody: (NSData*)httpBody
				delegate: (id<SSWebServiceConnectorDelegate>)delegate;
- (void)start;
- (void)cancel; // TODO: make this more robust
@end