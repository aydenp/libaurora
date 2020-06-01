#import <Foundation/Foundation.h>
#import "Private.h"
#import "Protocol.h"

@interface APAuroraWeatherManager : NSObject <NSXPCListenerDelegate, CityUpdateObserver, APAuroraWeatherProviding>
+ (instancetype)sharedManager;
- (void)updateIfNeeded;
@end