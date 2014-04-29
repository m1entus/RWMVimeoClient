//
//  RWMVimeoAuthenticator.h
//  oauthTwitterApp
//
//  Created by Michał Zaborowski on 28.04.2014.
//
//

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
