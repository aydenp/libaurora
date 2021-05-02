# libaurora

libaurora is a daemon and library that makes accessing weather data from SpringBoard easier.

To access the user's weather data, we need their location. After much testing on many different devices, I found that accessing this data in SpringBoard was very inconsistent. iOS requires user permission to retrieve the location, which is difficult when you are the user-visible system UI process of the OS. In some cases, developers would pretend to be the weather app. This would fail, of course, on iPads - which don't have the weather app. On iOS 13, this got even harder.

To work around this, I created a separate daemon which gives itself location access using entitlements. It then sends very select weather data over XPC in a dictionary.

Currently, the data that the daemon sends is quite limited. I would have liked to extend it to send full models or just include more. Pull requests are encouraged!

## How do I use it?

TODO: Document this with examples & boilerplate communication code.

You will need to create a class that implements the `APAuroraWeatherConsuming` protocol in Protocol.h, and assign it as the `exportedObject` of an XPC connection to the mach service. You will receive the method outlined in that protocol with a dictionary of weather data containing the following keys:

- `kAPAuroraWeatherManagerDataTemperatureKelvinKey`: the temperature in degrees Kelvin, as a decimal NSNumber.
- `kAPAuroraWeatherManagerDataConditionCodeKey`: a condition code corresponding with that of the weather framework.

You can also request a weather data update by sending the connection's `remoteObjectProxy` (which conforms to `APAuroraWeatherProviding`).

## Contributing

Feel free to contribute to the source code to make it something even better! Just try to adhere to the general coding style throughout, to make it as readable as possible.

## License

This project is licensed under the [MIT license](/LICENSE). Please make sure you comply with its terms while using it in any way.
