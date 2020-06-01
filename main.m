#import "Private.h"
#import "APAuroraWeatherManager.h"
#import <dlfcn.h>
#include <sys/sysctl.h>
#include <sys/kern_memorystatus.h>
#include <errno.h>

@interface NSXPCListenerDoesntWorkInThisSDK : NSObject
- (instancetype)initWithMachServiceName:(NSString *)name;
@end

int main(void) { 
    if (memorystatus_control(MEMORYSTATUS_CMD_SET_JETSAM_HIGH_WATER_MARK, getpid(), 20, 0, 0) != 0 || memorystatus_control(MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT, getpid(), 50, 0, 0) != 0) {
        NSLog(@"Error setting jetsam limit: %s", strerror(errno));
        exit(1);
    }

    dlopen("/System/Library/PrivateFrameworks/Weather.framework/Weather", RTLD_NOW);

    if ([CLLocationManager authorizationStatusForBundle:[NSBundle mainBundle]] != kCLAuthorizationStatusDenied) {
        // If they didn't explicitly turn it off, we'll just hack it to on
        [CLLocationManager setAuthorizationStatusByType:kCLAuthorizationStatusAuthorizedAlways forBundle:[NSBundle mainBundle]];
    }

    // Attempt to create the server
    NSXPCListener *listener = (NSXPCListener *)[(NSXPCListenerDoesntWorkInThisSDK *)[NSXPCListener alloc] initWithMachServiceName:@"dev.ayden.ios.lib.sys.aurora"];
    listener.delegate = [APAuroraWeatherManager sharedManager];

    // Make connection live
    [listener resume];

    NSLog(@"aurorad, at your service. :(");
    [[APAuroraWeatherManager sharedManager] updateIfNeeded];

    [[NSRunLoop currentRunLoop] run];
    return 0;
}
