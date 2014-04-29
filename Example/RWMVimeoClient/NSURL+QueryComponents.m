//
//  NSURL+QueryComponents.m
//  oauthTwitterApp
//
//  Created by Michał Zaborowski on 28.04.2014.
//
//

#import "NSURL+QueryComponents.h"
#import "NSString+QueryComponents.h"

@implementation NSURL (QueryComponents)
- (NSMutableDictionary *)queryComponents
{
    return [[self query] dictionaryFromQueryComponents];
}
@end
