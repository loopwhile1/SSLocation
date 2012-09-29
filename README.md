# SSLocation 1.0
Purpose
-------
SSLocation provides a convenient block based interface to get the user's geo-coded location.

Usage
-----
	// Instantiate a location manager
	self.ssLocationManager = [[SSLocationManager alloc] init];

	// Optional. configure accuracy. Default 100 meters
	self.ssLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;

	// Optional. configure time out. Default 10 seconds
	self.ssLocationManager.locationTimeoutInterval = 20.f;
	
	// Request user's location
	[self.locationManager fetchGeocodedUserLocationOnCompletion:^(MKPlacemark *placeMark) {
		// Use MKPlacemark
	} onError:^(NSError *error) {
		// Handle error
	}];
	
Supported OS & SDK Versions
-----------------------------
* Supported build SDK - iOS 6.0
* Earliest supported deployment target - iOS 4.3

ARC Compatibility
------------------
SSLocation requires ARC compatibility.

