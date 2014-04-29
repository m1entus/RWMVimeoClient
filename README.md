# RWMViemoClient

`RWMViemoClient` is an `AFHTTPRequestOperationManager` subclass for interacting with the [Vimeo Advanced API](https://developer.vimeo.com/apis/advanced/methods).

## Example Usage

### Register Custom Redirect URL Scheme in Info.plist

```
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>custom_scheme</string>
		</array>
	</dict>
</array>
```

### OAuth Vimeo Authentication

```objective-c
[[RWMVimeoOperationManager sharedOperationManager] setClientId:@"YOUR_CLIENT_ID"
                                         secret:@"YOUR_SECRET"
                                    redirectURL:[NSURL URLWithString:@"custom_scheme://login"]];

// Check if authentication token was storen in user default
OAToken *token = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"VimeoClient" prefix:@"RWM"];

if (token) {
    // Set authenticator token for API Calls
    [RWMVimeoOperationManager sharedOperationManager].authenticationToken = token;
    [self searchQuery];
} else {
    // Authenticate user
    [[RWMVimeoOperationManager sharedOperationManager] authenticateWithBlock:^(NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }
    }];
}
```

### Handle OpenURL

```objective-c
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[RWMVimeoOperationManager sharedOperationManager] handleOpenURL:url fallbackHandler:^(OAToken *token, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            [token storeInUserDefaultsWithServiceProviderName:@"VimeoClient" prefix:@"RWM"];
            [self searchQuery];
        }
    }];
}
```

### API Usage

```objective-c
NSDictionary *paramters = @{
                            @"page" : @2,
                            @"per_page" : @5,
                            @"query" : @"test",
                            @"full_response" : @1
                            };

[[RWMVimeoOperationManager sharedOperationManager] vimeoRequestOperationWithHTTPMethod:@"GET" APIMethod:@"vimeo.videos.search" parameters:paramters success:^(AFHTTPRequestOperation *operation, id responseObject) {

} failure:^(AFHTTPRequestOperation *operation, NSError *error) {

}];
```

## Contact

Michał Zaborowski

- http://github.com/m1entus
- http://twitter.com/iMientus

## License

RWMViemoClient is available under the MIT license. See the LICENSE file for more info.
