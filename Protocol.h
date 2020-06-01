//  This file is copied from libaurora/Protocol.h
//  Update it if Aurora's API changes.

#define kAPAuroraMachServiceName @"dev.ayden.ios.lib.sys.aurora"
#define kAPAuroraWeatherManagerDataTemperatureKelvinKey @"temp-k"
#define kAPAuroraWeatherManagerDataConditionCodeKey @"cond-code"

@protocol APAuroraWeatherProviding <NSObject>
- (void)updateIfNeeded;
@end

@protocol APAuroraWeatherConsuming <NSObject>
- (void)didReceiveWeatherData:(NSDictionary *)weatherData;
@end