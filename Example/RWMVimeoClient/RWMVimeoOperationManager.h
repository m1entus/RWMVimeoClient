//
//  RWMVimeoClient.h
//  RWMVimeoClient
//
//  Created by Michał Zaborowski on 25.04.2014.
//  Copyright (c) 2014 Railwaymen. All rights reserved.
//

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
