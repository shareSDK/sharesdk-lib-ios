/*
 *  WebServiceConnectorDelegate.h
 *  shareSDK
 *
 *  Created by Jesse Curry on 11/23/10.
 *  Copyright 2010 Jesse Curry. All rights reserved.
 *
 */

@class SSWebServiceConnector;
@protocol SSWebServiceConnectorDelegate
- (void)webServiceConnector: (SSWebServiceConnector*)webServiceConnector
		didFinishWithResult: (id)result;
- (void)webServiceConnector: (SSWebServiceConnector*)webServiceConnector
		   didFailWithError: (NSError*)error;
@end