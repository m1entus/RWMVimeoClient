//
//  RWMVimeoOperationManager.h
//  RWMVimeoOperationManager
//
//  Created by Michał Zaborowski on 25.04.2014.
//  Copyright (c) 2014 Railwaymen. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "RWMVimeoAuthenticator.h"

@interface RWMVimeoOperationManager : AFHTTPRequestOperationManager
@property (nonatomic, strong) OAToken *authenticationToken;

+ (instancetype)sharedOperationManager;

- (void)setClientId:(NSString *)clientId secret:(NSString *)secret redirectURL:(NSURL *)url;
- (void)authenticateWithBlock:(void(^)(NSError *error))errorHandler;

- (void)authenticateWithPreparedAuthorizationRequestHandler:(void(^)(OAMutableURLRequest *request))handler
                                               errorHandler:(void(^)(NSError *error))errorHandler;

- (BOOL)handleOpenURL:(NSURL *)URL fallbackHandler:(void(^)(OAToken *authenticationToken, NSError *error))fallbackHandler;


- (AFHTTPRequestOperation *)vimeoRequestOperationWithHTTPMethod:(NSString *)method
                                                      APIMethod:(NSString *)APIMethod
                                                     parameters:(NSDictionary *)parameters
                                                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
