//
//  OADataFetcher+Blocks.m
//  oauthTwitterApp
//
//  Created by Michał Zaborowski on 28.04.2014.
//
//

#import "OADataFetcher+Blocks.h"

NSString *const RWMOADataFetcherErrorDomain = @"RWMOADataFetcherErrorDomain";

@implementation OADataFetcher (Blocks)

- (void)fetchRequest:(OAMutableURLRequest *)aRequest completionBlock:(void(^)(OAServiceTicket *ticket, NSData *responseData, NSError *error))completionBlock
{
    request = aRequest;
    
    [request prepare];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *_response, NSData *_responseData, NSError *_error) {
        response = _response;
        error = _error;
        responseData = _responseData;
        
        if (response == nil || _responseData == nil || error != nil) {
            OAServiceTicket *ticket= [[OAServiceTicket alloc] initWithRequest:request
                                                                     response:response
                                                                   didSucceed:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(ticket,_responseData,error?:[NSError errorWithDomain:RWMOADataFetcherErrorDomain code:-101 userInfo:@{NSLocalizedDescriptionKey : @"Request token failed."}]);
                }
            });
        } else {
            OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
                                                                      response:response
                                                                    didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(ticket,_responseData,nil);
                }
            });
        }
    }];
    
}

@end
