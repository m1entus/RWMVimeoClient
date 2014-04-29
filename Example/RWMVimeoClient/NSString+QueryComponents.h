//
//  NSString+QueryComponents.h
//  oauthTwitterApp
//
//  Created by Michał Zaborowski on 28.04.2014.
//
//

#import <Foundation/Foundation.h>

@interface NSString (QueryComponents)
- (NSString *)stringByDecodingURLFormat;
- (NSString *)stringByEncodingURLFormat;
- (NSMutableDictionary *)dictionaryFromQueryComponents;
@end