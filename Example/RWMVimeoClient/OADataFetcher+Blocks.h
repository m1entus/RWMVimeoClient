//
//  OADataFetcher+Blocks.h
//  oauthTwitterApp
//
//  Created by Michał Zaborowski on 28.04.2014.
//
//

#import "OADataFetcher.h"

@interface OADataFetcher (Blocks)
- (void)fetchRequest:(OAMutableURLRequest *)aRequest completionBlock:(void(^)(OAServiceTicket *ticket, NSData *responseData, NSError *error))completionBlock;
@end
