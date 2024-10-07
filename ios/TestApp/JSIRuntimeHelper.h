// JSIRuntimeHelper.h
#import <Foundation/Foundation.h>
#import <React/RCTBridge+Private.h>

@interface JSIRuntimeHelper : NSObject
+ (void) installJSIHelpers:(RCTBridge*)bridge;
@end
