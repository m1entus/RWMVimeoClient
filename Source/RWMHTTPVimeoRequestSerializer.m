//
//  RWMHTTPVimeoRequestSerializer.m
//  RWMHTTPVimeoRequestSerializer
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

#import "RWMHTTPVimeoRequestSerializer.h"
#import "OAMutableURLRequest.h"

@interface RWMHTTPVimeoRequestSerializer ()
@property (nonatomic, strong) OAConsumer *consumer;
@end

@implementation RWMHTTPVimeoRequestSerializer

- (instancetype)initWithConsumer:(OAConsumer *)consumer
{
    if (self = [super init]) {
        _consumer = consumer;
    }
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                     error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(method);
    NSParameterAssert(URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSParameterAssert(url);
    NSParameterAssert(self.consumer);
    NSParameterAssert(self.token);
    
    OAMutableURLRequest *mutableRequest = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:self.token
                                                                      realm:nil
                                                          signatureProvider:nil];
    mutableRequest.HTTPMethod = method;
    mutableRequest.allowsCellularAccess = self.allowsCellularAccess;
    mutableRequest.cachePolicy = self.cachePolicy;
    mutableRequest.HTTPShouldHandleCookies = self.HTTPShouldHandleCookies;
    mutableRequest.HTTPShouldUsePipelining = self.HTTPShouldUsePipelining;
    mutableRequest.networkServiceType = self.networkServiceType;
    mutableRequest.timeoutInterval = self.timeoutInterval;
    
    
    NSMutableArray *serializedParameters = [NSMutableArray array];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        OARequestParameter *param = [[OARequestParameter alloc] initWithName:key
                                                                    value:obj];
        [serializedParameters addObject:param];
    }];
    

    [mutableRequest setParameters:serializedParameters];
    [mutableRequest prepare];
    
	return mutableRequest;
}

@end
