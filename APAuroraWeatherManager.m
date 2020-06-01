#import "APAuroraWeatherManager.h"

@implementation APAuroraWeatherManager {
	WeatherPreferences *prefs;
	NSDate *lastWeatherUpdate;
	WATodayAutoupdatingLocationModel *model;
	City *_lastCity;

	NSMutableArray<NSXPCConnection *> *connections;
}

+ (instancetype)sharedManager {
    static APAuroraWeatherManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		connections = [NSMutableArray array];

		prefs = [NSClassFromString(@"WeatherPreferences") sharedPreferences];
		model = [NSClassFromString(@"WATodayAutoupdatingLocationModel") autoupdatingLocationModelWithPreferences:prefs effectiveBundleIdentifier:[NSBundle mainBundle].bundleIdentifier];

		model.locationManager.locationManager = [[CLLocationManager alloc] initWithEffectiveBundle:[NSBundle mainBundle]];
		model.locationManager.locationManager.delegate = model.locationManager;
		model.locationManager.locationManager.distanceFilter = model.locationManager.distanceFilter;
		model.locationManager.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;

		[model setLocationServicesActive:YES];
		[model setIsLocationTrackingEnabled:YES];
	}
	return self;
}

- (City *)city {
	City *city = model.forecastModel.city ?: [prefs localWeatherCity];
	NSLog(@"%@ is my city", city.description);
	if (city != _lastCity) {
		if (_lastCity) [_lastCity removeUpdateObserver:self];
		_lastCity = city;
		[city setAutoUpdate:YES];
		[city addUpdateObserver:self];
	}
	return city;
}

- (void)updateIfNeeded {
	NSLog(@"I got asked to update!");

	// 1. Get new weather if we last updated it over 10 minutes ago
	BOOL needsWeatherUpdate = !lastWeatherUpdate || -[lastWeatherUpdate timeIntervalSinceNow] >= 60 * 10;
	if (needsWeatherUpdate) {
		NSLog(@"1. We need a model update.");
		[model executeModelUpdateWithCompletion:^(BOOL arg1, NSError *arg2) {
			if ([self hasWeatherData]) lastWeatherUpdate = [NSDate date];
			[self notifyObservers];
		}];
	}
	// 2. Check if iOS thinks there should be a new update and if so, force one.
	City *city = self.city;
	if (city && -[city.updateTime timeIntervalSinceNow] >= city.updateInterval) {
		NSLog(@"2. We need a city forecast update.");
		[city update];
	}
	// 3. Notify observers just in case the current conditions have changed due to the hour but there's no update
	NSLog(@"3. Notifying just in case.");
	[self notifyObservers];
}

- (BOOL)hasWeatherData {
	City *city = self.city;
	NSLog(@"Evaluating -hasWeatherData: %@, %@, %@", city ? @"Y" : @"N", city.temperature.kelvin != 0 ? @"Y" : @"N", city.conditionCode != 0 ? @"Y" : @"N");
	return city && city.temperature.kelvin != 0 && city.conditionCode != 0;
}

#pragma mark - City Observer

- (void)cityDidFinishWeatherUpdate:(id)arg1 {
	// An existing city has new weather for us! How exciting!@!!!
	[self notifyObservers];
}

#pragma mark - XPC

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(APAuroraWeatherConsuming)];
	[newConnection.remoteObjectInterface setClasses:[NSSet setWithObjects:[NSString class], [NSNumber class], [NSDictionary class], nil] forSelector:@selector(didReceiveWeatherData:) argumentIndex:0 ofReply:NO];

    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(APAuroraWeatherProviding)];
    newConnection.exportedObject = self;
    [newConnection resume];

	[connections addObject:newConnection];
	__weak NSXPCConnection *weakConnection = newConnection;
	newConnection.invalidationHandler = newConnection.interruptionHandler = ^{
		[connections removeObject:weakConnection];
	};

    return YES;
}

- (void)notifyObservers {
	NSLog(@"Considering notifying observers...");
	if (![self hasWeatherData]) return;
	City *city = self.city;
	WFTemperature *temp = city.temperature;
	NSLog(@"OK, notifying %lu observers...", connections.count);
	for (NSXPCConnection *connection in connections) {
		[connection.remoteObjectProxy didReceiveWeatherData:@{
			kAPAuroraWeatherManagerDataConditionCodeKey: @(city.conditionCode),
			kAPAuroraWeatherManagerDataTemperatureKelvinKey: @(temp.kelvin)
		}];
	}
	NSLog(@"Notify complete.");
}

@end
