//
//  AppsAPIClient.h
//  VandyMobile
//
//  Created by Graham Gaylor on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AppsAPIClient : AFHTTPClient

+ (id)sharedInstance;

@end