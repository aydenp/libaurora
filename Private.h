// #import "NSXPCConnection.h"
#import <CoreLocation/CoreLocation.h>

@interface CLLocationManager (Private)
- (instancetype)initWithEffectiveBundle:(NSBundle *)bundle;
+ (void)setAuthorizationStatusByType:(CLAuthorizationStatus)status forBundle:(NSBundle *)bundle;
+ (CLAuthorizationStatus)authorizationStatusForBundle:(NSBundle *)bundle;
@end

@interface WFTemperature : NSObject
@property (assign,nonatomic) double celsius; 
@property (assign,nonatomic) double fahrenheit; 
@property (assign,nonatomic) double kelvin; 
@end

@interface WAHourlyForecast : NSObject
@property (nonatomic,copy) NSString *forecastDetail;
@end

@protocol CityUpdateObserver <NSObject>
@optional
-(void)cityDidStartWeatherUpdate:(id)arg1;
-(void)cityDidFinishWeatherUpdate:(id)arg1;
@end

@interface City : NSObject
@property (nonatomic,retain) NSDate * updateTime;
@property (assign,nonatomic) long long updateInterval;
@property (assign,nonatomic) long long conditionCode;
@property (nonatomic,readonly) NSString * locationID;
-(NSArray <WAHourlyForecast *>*)hourlyForecasts;
- (WFTemperature *)temperature;
-(void)addUpdateObserver:(NSObject <CityUpdateObserver>*)observer;
-(void)removeUpdateObserver:(NSObject <CityUpdateObserver>*)observer;
- (BOOL)update;
-(void)setAutoUpdate:(BOOL)arg1;
@end

@interface WeatherPreferences : NSObject
+(instancetype)sharedPreferences;
-(City *)localWeatherCity;
@end

@interface WAForecastModel : NSObject
@property (nonatomic,retain) City *city;
@end

@interface WATodayModel : NSObject
@property (nonatomic,retain) WAForecastModel *forecastModel;
-(BOOL)executeModelUpdateWithCompletion:(/*^block*/id)arg1;
+(id)autoupdatingLocationModelWithPreferences:(id)arg1 effectiveBundleIdentifier:(id)arg2 ;
@end

@interface WeatherLocationManager : NSObject <CLLocationManagerDelegate>
@property(retain, nonatomic) CLLocationManager *locationManager; // @synthesize locationManager=_locationManager;
@property(readonly, nonatomic) double distanceFilter;
@end

@interface WATodayAutoupdatingLocationModel : WATodayModel
@property(retain, nonatomic) WeatherLocationManager *locationManager; // @synthesize locationManager=_locationManager;
-(void)setIsLocationTrackingEnabled:(BOOL)arg1 ;
-(void)setLocationServicesActive:(BOOL)arg1 ;
@end