//
//  WebServiceConnector.m
//  ThingsToDo
//
//  Created by Jesse Curry on 6/22/10.
//  Copyright 2010 St. Pete Times. All rights reserved.
//

#import "SSWebServiceConnector.h"
#import "SSWebServiceConnectorDelegate.h"

#import "shareSDKDefines.h"
#import "HTTPStatusCodes.h"

static BOOL verboseOutput = NO;
static NSInteger connectionCount = 0;
static NSUInteger maxConnectionCount = 0;
static NSMutableArray* webServiceConnectorQueue = nil;
static NSMutableArray* activeConnectors = nil;

static NSDictionary* defaultRequestHeaders = nil;


@interface SSWebServiceConnector ()
@property (nonatomic, copy) WebServiceConnectorCompletionHandler completionHandler;
@property (nonatomic, unsafe_unretained) id<SSWebServiceConnectorDelegate> delegate;
@property (nonatomic, strong) NSURLConnection*	urlConnection;
@property (nonatomic, strong) NSMutableData*	receivedData;
@property (unsafe_unretained, nonatomic, readonly) NSString*		webServiceRoot;
@property (unsafe_unretained, nonatomic, readonly) NSString*		webServiceFormatSpecifier;

+ (NSMutableArray*)webServiceConnectorQueue;
+ (NSMutableArray*)activeConnectors;
+ (void)processQueue;
- (void)reallyStart;

+ (NSString*)reallyEncodeString: (NSString*)unencodedString;

// Completion Handling
- (void)handleSuccess: (id)result;
- (void)handleFailure: (NSError*)error;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SSWebServiceConnector
@synthesize parameters=_parameters;
@synthesize requestHeaderFields=_requestHeaderFields;
@synthesize httpBody=_httpBody;
@synthesize httpMethod=_httpMethod;
@synthesize tag=_tag;
@synthesize context=_context;
@synthesize statusCode=_statusCode;
@synthesize responseHeaderFields=_responseHeaderFields;

@synthesize completionHandler=_completionHandler;
@synthesize delegate=_delegate;
@synthesize urlConnection=_urlConnection;
@synthesize receivedData=_receivedData;

// Pagination
@synthesize currentPage=_currentPage;
@synthesize numberOfPages=_numberOfPages;
@synthesize resultsPerPage=_resultsPerPage;

- (id)init
{
	return nil;
}

- (id)initWithURLString: (NSString*)urlString
						 parameters: (NSDictionary*)parameters
							 httpBody: (NSData*)httpBody
{
	if ( self = [super init] )
	{
		_statusCode = -1; //
		_urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		self.parameters = parameters;
		self.httpBody = httpBody;
		self.httpMethod = HTTP_GET;
	}
	return self;
}

- (id)initWithPathString: (NSString*)pathString
							parameters: (NSDictionary*)parameters
								httpBody: (NSData*)httpBody
{
	NSString* generatedUrlString = [self.webServiceRoot stringByAppendingString: pathString];
	return [self initWithURLString: generatedUrlString
											parameters: parameters
												httpBody: httpBody];
}

// Completion Handler
- (id)initWithURLString: (NSString*)urlString
						 parameters: (NSDictionary*)parameters
							 httpBody: (NSData*)httpBody
      completionHandler: (WebServiceConnectorCompletionHandler)completionHandler
{
	self = [self initWithURLString: urlString
											parameters: parameters
												httpBody: httpBody];
	if ( self )
	{
		self.completionHandler = completionHandler;
	}
	
	return self;
}

- (id)initWithPathString: (NSString*)pathString
							parameters: (NSDictionary*)parameters
								httpBody: (NSData*)httpBody
       completionHandler: (WebServiceConnectorCompletionHandler)completionHandler
{
	self = [self initWithPathString: pathString
											 parameters: parameters
												 httpBody: httpBody];
	if ( self )
	{
		self.completionHandler = completionHandler;
	}
	
	return self;
}

- (id)initWithURLString: (NSString*)urlString
						 parameters: (NSDictionary*)parameters
							 httpBody: (NSData*)httpBody
							 delegate: (id<SSWebServiceConnectorDelegate>)delegate
{
	self = [self initWithURLString: urlString
											parameters: parameters
												httpBody: httpBody];
	if ( self )
	{
		self.delegate = delegate;
	}
	
	return self;
}

- (id)initWithPathString: (NSString*)pathString
							parameters: (NSDictionary*)parameters
								httpBody: (NSData*)httpBody
								delegate: (id<SSWebServiceConnectorDelegate>)delegate
{
	self = [self initWithPathString: pathString
											 parameters: parameters
												 httpBody: httpBody];
	if ( self )
	{
		self.delegate = delegate;
	}
	
	return self;
}

- (void)dealloc
{
	[self.urlConnection cancel];
}

#pragma mark -
#pragma mark API
- (void)start
{
	[[SSWebServiceConnector webServiceConnectorQueue] addObject: self];
	[SSWebServiceConnector processQueue];
}

- (void)cancel
{
	[self.urlConnection cancel];
	self.urlConnection = nil;
}

#pragma mark -
#pragma mark Private
+ (NSMutableArray*)webServiceConnectorQueue
{
	if ( webServiceConnectorQueue == nil )
	{
		webServiceConnectorQueue = [[NSMutableArray alloc] init];
	}
	return webServiceConnectorQueue;
}

+ (NSMutableArray*)activeConnectors
{
	if ( activeConnectors == nil )
	{
		activeConnectors = [[NSMutableArray alloc] init];
	}
	return activeConnectors;
}

+ (void)processQueue
{
	// If the maxConnectionCount == 0 we'll assume that no connection queueing is desired.
	if ( ([SSWebServiceConnector connectionCount] < maxConnectionCount || maxConnectionCount == 0)
			&& [[SSWebServiceConnector webServiceConnectorQueue] count] )
	{
		SSWebServiceConnector* wsc = [[SSWebServiceConnector webServiceConnectorQueue]
																	objectAtIndex: 0];
		[wsc reallyStart];
		
		[[SSWebServiceConnector webServiceConnectorQueue] removeObject: wsc];
		[[SSWebServiceConnector activeConnectors] addObject: wsc];
	}
}

- (void)reallyStart
{
	if ( self.urlConnection != nil )
		return;
	
	NSString* fullURLString = self.urlStringWithParameters;
	
	SS_LOG( @"WebServiceConnector: %@", fullURLString);
	
	// Create the request.
	NSURL* url = [NSURL URLWithString: fullURLString];
	NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL: url
																														cachePolicy: NSURLRequestUseProtocolCachePolicy
																												timeoutInterval: 60.0];
	
	if ( self.requestHeaderFields )
		[theRequest setAllHTTPHeaderFields: self.requestHeaderFields];
	else
		[theRequest setAllHTTPHeaderFields: defaultRequestHeaders];
	
	[theRequest setHTTPBody: self.httpBody];
	[theRequest setHTTPMethod: self.httpMethod];
	
	// create the connection with the request
	// and start loading the data
	self.urlConnection = [NSURLConnection connectionWithRequest: theRequest
																										 delegate: self];
	if ( self.urlConnection )
	{
		// Create the NSMutableData to hold the received data.
		self.receivedData = [NSMutableData data];
		
		// Update the connectionCount
		[[self class] willChangeValueForKey: @"connectionCount"];
		++connectionCount;
		[[self class] didChangeValueForKey: @"connectionCount"];
		
		startTime = [NSDate timeIntervalSinceReferenceDate];
	}
	else
	{
		// Inform the user that the connection failed.
		[self handleFailure: [NSError errorWithDomain: @"WebServiceConnectorErrorDomain"
																						 code: 0
																				 userInfo: nil]];
		
		[SSWebServiceConnector processQueue]; // since this connection failed we can try to kick off others
	}
}

#pragma mark -
#pragma mark Properties
+ (NSInteger)connectionCount
{
	return connectionCount;
}

+ (BOOL)verbose
{
	return verboseOutput;
}

+ (void)setVerbose: (BOOL)verbose
{
	verboseOutput = verbose;
}

+ (void)setDefaultRequestHeaderFields: (NSDictionary*)drc
{
	if ( defaultRequestHeaders != drc )
	{
		defaultRequestHeaders = drc;
	}
}

- (void)setVerbose: (BOOL)verbose
{
	[[self class] setVerbose: verbose];
}

- (NSString*)webServiceRoot
{
	return [[self class] webServiceRoot];
}

+ (NSString*)webServiceRoot
{
	NSString* webServiceRoot = [[NSUserDefaults standardUserDefaults] valueForKey: @"webServiceRoot"];
	
	// Remove a trailing slash if there is not one.
	if ( [webServiceRoot length]
			&& [[webServiceRoot substringFromIndex: [webServiceRoot length] - 1] isEqual: @"/"] )
	{
		webServiceRoot = [webServiceRoot substringToIndex: [webServiceRoot length] - 1];
	}
	
	return webServiceRoot;
}

- (NSString*)webServiceFormatSpecifier
{
	return [[self class] webServiceFormatSpecifier];
}

+ (NSString*)webServiceFormatSpecifier
{
	NSString* webServiceFormatSpecifier = [[NSUserDefaults standardUserDefaults] valueForKey: @"webServiceFormatSpecifier"];
	return SS_FORCE_STRING(webServiceFormatSpecifier);
}

#pragma mark -
#pragma mark Connection Queueing
+ (NSInteger)maxConnectionCount
{
	return maxConnectionCount;
}

+ (void)setMaxConnectionCount: (NSInteger)theMaxConnectionCount
{
	maxConnectionCount = theMaxConnectionCount;
}

#pragma -
- (NSString*)urlStringWithParameters
{
	NSString* retStr = _urlString;
	
	if ( [self.parameters count] )
	{
		NSUInteger parametersAdded = 0;
		for ( NSString* key in self.parameters )
		{
			NSString* name = [[self class] reallyEncodeString: key];
			NSString* vv = [self.parameters objectForKey: key];
			NSString* value = [vv isKindOfClass: [NSString class]] ? vv : nil;
			value = [[self class] reallyEncodeString: value];
			
			if ( name && value )
			{
				retStr = [retStr stringByAppendingFormat: @"%@%@=%@",
									parametersAdded++ == 0 ? @"?" : @"&",
									name,
									value];
			}
		}
	}
	
	return retStr;
}

#pragma mark -
#pragma mark NSURLConnection Delegate
- (void)connection: (NSURLConnection*)connection
didReceiveResponse: (NSURLResponse*)response
{
	if ( [response isKindOfClass: [NSHTTPURLResponse class]] )
	{
		_statusCode = [(NSHTTPURLResponse*)response statusCode];
		self.responseHeaderFields = [(NSHTTPURLResponse*)response allHeaderFields];
		
		if ( verboseOutput )
			SS_LOG( @"(%d) %@", _statusCode, _urlString );
	}
	else
	{
		_statusCode = -1;
	}
	
	
	[self.receivedData setLength: 0];
}

- (void)connection: (NSURLConnection*)connection
		didReceiveData: (NSData*)data
{
	// Append the new data to receivedData.
	[self.receivedData appendData: data];
}

- (void)connection: (NSURLConnection*)connection
  didFailWithError: (NSError*)error
{
	// release the connection
	self.urlConnection = nil;
	self.receivedData = nil;
	
	// inform the user
	SS_LOG(@"Connection failed! Error - %@ %@",
				 [error localizedDescription],
				 [[error userInfo] objectForKey: NSURLErrorFailingURLStringErrorKey]);
	
	// Update the connectionCount
	[[self class] willChangeValueForKey: @"connectionCount"];
	--connectionCount;
	[[self class] didChangeValueForKey: @"connectionCount"];
	
	[self handleFailure: error];
	
	[SSWebServiceConnector processQueue]; // since this connection failed we can try to kick off others
	
	// Clean up.
	[[SSWebServiceConnector activeConnectors] removeObject: self];
}

- (void)connectionDidFinishLoading: (NSURLConnection*)connection
{
	responseTime = [NSDate timeIntervalSinceReferenceDate];
	
	//SS_LOG(@"Succeeded! Received %d bytes of data", [self.receivedData length]);
	
	if ( verboseOutput )
	{
		NSString* responseString = [[NSString alloc] initWithData: self.receivedData
																										 encoding: NSUTF8StringEncoding];
		SS_LOG( @"responseString:\n%@", responseString );
	}
	
	NSError* jsonError = nil;
	id jsonResponse = [NSJSONSerialization JSONObjectWithData: self.receivedData
																										options: 0
																											error: &jsonError];
	
	// release the connection, and the data object
	self.urlConnection = nil;
	self.receivedData = nil;
	
	// Update the connectionCount
	[[self class] willChangeValueForKey: @"connectionCount"];
	--connectionCount;
	[[self class] didChangeValueForKey: @"connectionCount"];
	
	if ( jsonResponse )//[responseString length] )
	{
		[self handleSuccess: jsonResponse];
		
		postParseTime = [NSDate timeIntervalSinceReferenceDate];
	}
	else
	{
		[self handleSuccess: [NSArray array]];
	}
	SS_LOG(@"[%@]response: %.5f - parse: %.5f", _urlString, responseTime - startTime, postParseTime - startTime);
	
	[SSWebServiceConnector processQueue]; // since this connection is done we can try to kick off others
	
	// Clean up
	[[SSWebServiceConnector activeConnectors] removeObject: self];
}

#pragma mark Utility
+ (NSString*)reallyEncodeString: (NSString*)unencodedString
{
	NSString* encodedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
																																																 (CFStringRef)unencodedString,
																																																 NULL,
																																																 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																																																 kCFStringEncodingUTF8 ));
	
	return encodedString;
}

#pragma mark Completion Handling
- (void)handleSuccess: (id)result
{
	if ( self.completionHandler )
	{
		// dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			self.completionHandler(self, result, nil);
		// });
	}
	
	if ( self.delegate )
	{
		[self.delegate webServiceConnector: self
									 didFinishWithResult: result];
	}
}

- (void)handleFailure: (NSError*)error
{
	if ( self.completionHandler )
	{
		// dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			self.completionHandler(self, nil, error);
		// });
	}
	
	if ( self.delegate )
	{
		[self.delegate webServiceConnector: self
											didFailWithError: error];
	}
}

@end
