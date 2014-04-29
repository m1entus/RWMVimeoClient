//
//  RWMVimeoAuthenticator.h
//  RWMVimeoAuthenticator
//
//  Created by Michał Zaborowski on 28.04.2014.
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

#import "OAuthConsumer.h"
#import "OADataFetcher+Blocks.h"
#import "NSURL+QueryComponents.h"

typedef void(^RWMVimeoAuthenticatorRequestTokenCompletionHandler)(OAToken *token, NSError *error);

@interface RWMVimeoAuthenticator : NSObject

@property (nonatomic, readonly) OAConsumer *consumer;
@property (nonatomic, readonly) OAToken *accessToken;

@property (nonatomic, strong) NSURL *redirectURL;

- (instancetype)initWithClientId:(NSString *)clientId secret:(NSString *)secret redirectURL:(NSURL *)url;

- (BOOL)canHandleRedirectOpenURL:(NSURL *)url;

- (void)requestAccessTokenWithToken:(OAToken *)token redirectURL:(NSURL *)URL completionHandler:(RWMVimeoAuthenticatorRequestTokenCompletionHandler)completionHandler;

- (void)authorizeWithToken:(OAToken *)token withPreparedAuthorizationRequestHandler:(void(^)(OAMutableURLRequest *request))handler;

- (void)requestTokenWithCompletionHandler:(RWMVimeoAuthenticatorRequestTokenCompletionHandler)completionHandler;

@end
