//
//  RWMVimeoOperationManager.m
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

#import "RWMVimeoOperationManager.h"
#import "OAuthConsumer.h"
#import "RWMHTTPVimeoRequestSerializer.h"

NSString *const RWMVimeoClientBaseURL = @"http://vimeo.com/api/rest";

@interface RWMVimeoOperationManager ()
@property (nonatomic, strong) RWMVimeoAuthenticator *authenticator;

@property (nonatomic, strong) OAToken *temporaryToken;
@end

@implementation RWMVimeoOperationManager

+ (instancetype)sharedOperationManager {
    static RWMVimeoOperationManager *_sharedVimeoClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedVimeoClient = [[RWMVimeoOperationManager alloc] init];
    });
    
    return _sharedVimeoClient;
}


- (void)setAuthenticationToken:(OAToken *)authenticationToken
{
    if (_authenticationToken != authenticationToken) {
        
        _authenticationToken = authenticationToken;
        RWMHTTPVimeoRequestSerializer *serializer = (RWMHTTPVimeoRequestSerializer *)self.requestSerializer;
        serializer.token = authenticationToken;
    }
}

- (instancetype)init
{
    if (self = [super initWithBaseURL:[NSURL URLWithString:RWMVimeoClientBaseURL]]) {
    }
    return self;
}

- (void)setClientId:(NSString *)clientId secret:(NSString *)secret redirectURL:(NSURL *)url
{
    self.authenticator = [[RWMVimeoAuthenticator alloc] initWithClientId:clientId secret:secret redirectURL:url];
    self.requestSerializer = [[RWMHTTPVimeoRequestSerializer alloc] initWithConsumer:self.authenticator.consumer];
}

- (void)authenticateWithPreparedAuthorizationRequestHandler:(void(^)(OAMutableURLRequest *request))handler
                                               errorHandler:(void(^)(NSError *error))errorHandler
{
    NSParameterAssert(self.authenticator);
    
    __weak RWMVimeoAuthenticator *weakAuthenticator = self.authenticator;
    
    [self.authenticator requestTokenWithCompletionHandler:^(OAToken *token, NSError *error) {
        if (error) {
            if (errorHandler) {
                errorHandler(error);
            }
        } else {
            self.temporaryToken = token;
            [weakAuthenticator authorizeWithToken:token withPreparedAuthorizationRequestHandler:handler];
        }
    }];
}

- (void)authenticateWithBlock:(void(^)(NSError *error))errorHandler
{
    [self authenticateWithPreparedAuthorizationRequestHandler:nil errorHandler:errorHandler];
}

- (BOOL)handleOpenURL:(NSURL *)URL fallbackHandler:(void(^)(OAToken *token, NSError *error))fallbackHandler
{
    if ([self.authenticator canHandleRedirectOpenURL:URL]) {
        [self.authenticator requestAccessTokenWithToken:self.temporaryToken redirectURL:URL completionHandler:^(OAToken *token, NSError *error) {
            self.temporaryToken = nil;
            
            if (!error) {
                self.authenticationToken = token;
            }
            if (fallbackHandler) {
                fallbackHandler(self.authenticationToken, error);
            }
        }];
        
        return YES;
    }
    
    return NO;
}

- (AFHTTPRequestOperation *)vimeoRequestOperationWithHTTPMethod:(NSString *)method
                                                      APIMethod:(NSString *)APIMethod
                                                     parameters:(NSDictionary *)parameters
                                                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSParameterAssert(APIMethod);
    
    NSMutableDictionary *additionalParameters = [parameters mutableCopy];
    if (!additionalParameters[@"format"]) {
        [additionalParameters setObject:@"json" forKey:@"format"];
    }
    
    [additionalParameters setObject:APIMethod forKey:@"method"];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:@"v2" relativeToURL:self.baseURL] absoluteString] parameters:additionalParameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

@end
