//
//  SSLocationManager.m
//  SSLocation
//
//  Created by Sanjit Saluja on 9/18/12.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "SSLocationManager.h"
#import "SSOneTimeLocationOperation.h"

#define DEFAULT_LOCATION_TIMEOUT_INTERVAL 10.0f

@interface SSLocationManager()
{
    BOOL notifyingObservers_;
}
// instance of the core location manager
@property (nonatomic, strong) CLLocationManager *locationManager;

// instance of the reverse geocoder
@property (nonatomic, strong) MKReverseGeocoder *reverseGeocoder;

// listeners who would like to know the location once
@property (nonatomic, strong) NSMutableSet *oneTimeLocationOperations;

// flag that indicates if CLLocationManager is running
@property (nonatomic, assign) BOOL isUpdatingLocation;

// timer to time the location process out
@property (nonatomic, strong) NSTimer *timeOutTimer;

// pending adds: listeners who would like to know the location once
@property (nonatomic, strong) NSMutableSet *pendingAddForOneTimeLocationOperations;

@end

@implementation SSLocationManager
@synthesize reverseGeocoder = reverseGeocoder_,
            locationManager = locationManager_,
            oneTimeLocationOperations = oneTimeLocationOperations_,
            isUpdatingLocation = isUpdatingLocation_,
            locationTimeoutInterval = locationTimeoutInterval_,
            timeOutTimer = timeOutTimer_,
            pendingAddForOneTimeLocationOperations = pendingAddForOneTimeLocationOperations_;

@dynamic desiredAccuracy;

+ (void)initialize
{
    kSSErrorDomain = @"com.sanjitsaluja.sslocation";
}

- (void)dealloc
{
    [self stopLocationAndGeocode];
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.oneTimeLocationOperations = [NSMutableSet set];
        self.pendingAddForOneTimeLocationOperations = [NSMutableSet set];
        self.locationTimeoutInterval = DEFAULT_LOCATION_TIMEOUT_INTERVAL;
    }
    return self;
}

#pragma mark -
#pragma mark Public properties
/*!
 * @method:     setDesiredAccuracy:
 * @abstract:   Set desired accuracy for location. Default accuracy is kCLLocationAccuracyHundredMeters
 */
- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy
{
    self.locationManager.desiredAccuracy = desiredAccuracy;
}

/*!
 * @method:     desiredAccuracy
 * @abstract:   Get desired accuracy for location. Default accuracy is kCLLocationAccuracyHundredMeters
 */
- (CLLocationAccuracy)desiredAccuracy
{
    return self.locationManager.desiredAccuracy;
}

/*!
 * @method:     setLocationTimeoutInterval:
 * @abstract:   Set location timer
 */
- (void)setLocationTimeoutInterval:(NSTimeInterval)locationTimeoutInterval
{
    if (locationTimeoutInterval_ != locationTimeoutInterval)
    {
        locationTimeoutInterval_ = locationTimeoutInterval;
        
        // Reschedule if a timer is already running
        if ([self.timeOutTimer isValid])
        {
            self.timeOutTimer = [NSTimer timerWithTimeInterval:self.locationTimeoutInterval target:self selector:@selector(timerExpired:) userInfo:nil repeats:NO];
        }
    }
}


#pragma mark -
#pragma mark Public methods

- (void)fetchGeocodedUserLocationOnCompletion:(SSLocationSuccessBlock)completionBlock onError:(SSLocationErrorBlock)errorBlock
{
    SSOneTimeLocationOperation *op = [SSOneTimeLocationOperation new];
    op.succesBlock = completionBlock;
    op.errorBlock = errorBlock;
    
    if (!notifyingObservers_)
    {        
        [self.oneTimeLocationOperations addObject:op];
        
        // Start locating if it is already isn't running.
        [self startLocationAndGeocode];
    }
    else
    {
        [self.pendingAddForOneTimeLocationOperations addObject:op];
    }
}


#pragma mark -
#pragma mark CLLocationManagerDelegate implementation
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    notifyingObservers_ = YES;
    
    // Inform all observers waiting for a location
    for (SSOneTimeLocationOperation *op in self.oneTimeLocationOperations)
    {
        op.errorBlock(error);
    }
    
    // Remove all objects that we just informed
    [self.oneTimeLocationOperations removeAllObjects];
    
    // stop location/timer/geocode
    [self stopLocationAndGeocode];
    
    notifyingObservers_ = NO;
    [self commitPending];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (self.locationManager == manager)
    {   
        // stop location
        [self.locationManager stopUpdatingLocation];
        
        // stop the old geocode
        self.reverseGeocoder.delegate = nil;
        self.reverseGeocoder = nil;
        [self.reverseGeocoder cancel];
        
        // start the new location geocode
        self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
        self.reverseGeocoder.delegate = self;
        [self.reverseGeocoder start];
    }
}

#pragma mark -
#pragma mark oneTimeLocationListeners

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    notifyingObservers_ = YES;
    
    // Inform all observers waiting for a location
    for (SSOneTimeLocationOperation *op in self.oneTimeLocationOperations)
    {
        op.errorBlock(error);
    }
    
    // Remove all objects that we just informed
    [self.oneTimeLocationOperations removeAllObjects];
    
    // stop location/timer/geocode
    [self stopLocationAndGeocode];
    
    notifyingObservers_ = NO;
    [self commitPending];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    // Inform all observers waiting for a location
    notifyingObservers_ = YES;
    
    for (SSOneTimeLocationOperation *op in self.oneTimeLocationOperations)
    {
        op.succesBlock(placemark);
    }
    
    // Remove all objects that we just informed
    [self.oneTimeLocationOperations removeAllObjects];
    
    // stop location/timer/geocode
    [self stopLocationAndGeocode];
    
    notifyingObservers_ = NO;
    [self commitPending];
}

#pragma mark -
#pragma mark Timer
- (void)scheduleTimer
{
    [self.timeOutTimer invalidate];
    self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:self.locationTimeoutInterval target:self selector:@selector(timerExpired:) userInfo:nil repeats:NO];
}

- (void)timerExpired:(NSTimer *)timer
{
    if (self.timeOutTimer == timer)
    {
        // stop location/timer/geocode
        [self stopLocationAndGeocode];
        
        // Inform all observers waiting for a location
        for (SSOneTimeLocationOperation *op in self.oneTimeLocationOperations)
        {
            NSError *timeOutError = [NSError errorWithDomain:kSSErrorDomain code:ssLocationTimedOut userInfo:nil];
            op.errorBlock(timeOutError);
        }        
    }
}

#pragma mark -
#pragma mark Private methods
- (void)stopLocationAndGeocode
{
    [self.timeOutTimer invalidate];

    self.isUpdatingLocation = NO;
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    
    self.reverseGeocoder.delegate = nil;
    [self.reverseGeocoder cancel];
}

- (void)commitPending
{
	NSAssert(!notifyingObservers_, @"Tried to commit pending observers while notifying");
	for (id observer in self.pendingAddForOneTimeLocationOperations)
    {
		[self.oneTimeLocationOperations addObject:observer];
    }
	[self.pendingAddForOneTimeLocationOperations removeAllObjects];
    
    if ([self.oneTimeLocationOperations count] > 0)
    {
        [self startLocationAndGeocode];
    }
}

- (void)startLocationAndGeocode
{
    if (!self.isUpdatingLocation)
    {
        self.isUpdatingLocation = YES;
        
        // start location timer
        [self scheduleTimer];
        
        // Start core location
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    }
}

@end
