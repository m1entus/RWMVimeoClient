//
//  RWMVimeoAuthenticator.m
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

#import "RWMVimeoAuthenticator.h"

NSString *const RWMVimeoAuthenticatorRequestTokenURL = @"https://vimeo.com/oauth/request_token";
NSString *const RWMVimeoAuthenticatorAuthorizeURL = @"https://vimeo.com/oauth/authorize";
NSString *const RWMVimeoAuthenticatorAccessTokenURL = @"https://vimeo.com/oauth/access_token";

NSString *const RWMVimeoAuthenticatorErrorDomain = @"RWMVimeoAuthenticatorErrorDomain";

@interface RWMVimeoAuthenticator ()
@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) OAToken *accessToken;
@end

@implementation RWMVimeoAuthenticator

- (instancetype)initWithClientId:(NSString *)clientId secret:(NSString *)secret redirectURL:(NSURL *)url
{
    NSParameterAssert(url);
    NSParameterAssert(clientId);
    NSParameterAssert(secret);
    
    if (self = [super init]) {
        _consumer = [[OAConsumer alloc] initWithKey:clientId secret:secret];
        self.redirectURL = url;
    }
    return self;
}

- (BOOL)canHandleRedirectOpenURL:(NSURL *)url
{
    NSURL *fixedRedirectURL = nil;
    
    NSParameterAssert(self.redirectURL);
    
    if ([[[url absoluteString] lowercaseString] hasPrefix:[[self.redirectURL absoluteString] lowercaseString]]) {
        
        // WORKAROUND: The URL which is passed to this method may be lower case also the scheme is registered in camel case. Therefor replace the prefix with the stored redirectURL.
        if ([url.scheme isEqualToString:self.redirectURL.scheme]) {
            fixedRedirectURL = url;
        } else {
            NSRange prefixRange;
            prefixRange.location = 0;
            prefixRange.length = [self.redirectURL.absoluteString length];
            fixedRedirectURL = [NSURL URLWithString:[url.absoluteString stringByReplacingCharactersInRange:prefixRange
                                                                                                withString:self.redirectURL.absoluteString]];
        }
    }
    
    if (fixedRedirectURL) {
        return YES;
    }
    
    return NO;
}

- (void)requestAccessTokenWithToken:(OAToken *)token redirectURL:(NSURL *)URL completionHandler:(RWMVimeoAuthenticatorRequestTokenCompletionHandler)completionHandler
{
    
    NSURL *requestURL = [NSURL URLWithString:RWMVimeoAuthenticatorAccessTokenURL];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:requestURL
                                                                   consumer:self.consumer
                                                                      token:token
                                                                      realm:nil
                                                          signatureProvider:nil];
    
    NSDictionary *parameters = [URL queryComponents];
    
    OARequestParameter *verifierParameter = [[OARequestParameter alloc] initWithName:@"oauth_verifier"
                                                                value:parameters[@"oauth_verifier"]];
    [request setParameters:@[verifierParameter]];
    
    [request setOAuthParameterName:@"oauth_verifier" withValue:parameters[@"oauth_verifier"]];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchRequest:request completionBlock:^(OAServiceTicket *ticket, NSData *responseData, NSError *error) {
        if (error || !ticket.didSucceed) {
            if (completionHandler) {
                completionHandler(nil, error?:[NSError errorWithDomain:RWMVimeoAuthenticatorErrorDomain code:-101 userInfo:@{NSLocalizedDescriptionKey : @"Request access token failed."}]);
            }
        } else {
            NSString *responseBody = [[NSString alloc] initWithData:responseData
                                                           encoding:NSUTF8StringEncoding];
            
            
            OAToken *token = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
            self.accessToken = token;
            
            if (completionHandler) {
                completionHandler(token,nil);
            }
        }
    }];
}

- (void)authorizeWithToken:(OAToken *)token withPreparedAuthorizationRequestHandler:(void(^)(OAMutableURLRequest *request))handler
{
    NSURL *url = [NSURL URLWithString:RWMVimeoAuthenticatorAuthorizeURL];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                    consumer:self.consumer
                                                                       token:token
                                                                       realm:nil
                                                           signatureProvider:nil];
                                    
    OARequestParameter *tokenParameter = [[OARequestParameter alloc] initWithName:@"oauth_token"
                                                                value:token.key];
    [request setParameters:@[tokenParameter]];
    [request prepare];
    
    if (handler) {
        handler(request);
    } else {
        [[UIApplication sharedApplication] openURL:request.URL];
    }

}

- (void)requestTokenWithCompletionHandler:(RWMVimeoAuthenticatorRequestTokenCompletionHandler)completionBlock
{
    NSURL *url = [NSURL URLWithString:RWMVimeoAuthenticatorRequestTokenURL];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                    consumer:self.consumer
                                                                       token:nil
                                                                       realm:nil
                                                           signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    OARequestParameter *p0 = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:@"oob"];
    
    NSArray *params = [NSArray arrayWithObject:p0];
    [request setParameters:params];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];

    [fetcher fetchRequest:request completionBlock:^(OAServiceTicket *ticket, NSData *responseData, NSError *error) {
        if (error || !ticket.didSucceed) {
            if (completionBlock) {
                completionBlock(nil, error?:[NSError errorWithDomain:RWMVimeoAuthenticatorErrorDomain code:-101 userInfo:@{NSLocalizedDescriptionKey : @"Request token failed."}]);
            }
        } else {
            NSString *responseBody = [[NSString alloc] initWithData:responseData
                                                           encoding:NSUTF8StringEncoding];
            
            OAToken *token = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
            if (completionBlock) {
                completionBlock(token, nil);
            }
        }
    }];
                                    
}

@end
