//
//  SSLocationManager.h
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKReverseGeocoder.h>

typedef void (^SSLocationSuccessBlock)(MKPlacemark *placeMark);
typedef void (^SSLocationErrorBlock)(NSError *error);


static NSString *kSSErrorDomain;
#pragma unused(kSSErrorDomain)

enum SSErrorCodes {
    ssLocationTimedOut
    };

/*!
 * @class:      SSLocationManager
 * @abstract:   Object provides bulk of SSLocation functinality.
 */
@interface SSLocationManager : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate>

/*!
 * @property:   desiredAccuracy
 * @abstract:   Set/Get desired accuracy for location. 
 * @notes:      Default accuracy is kCLLocationAccuracyHundredMeters.
 */
@property (nonatomic, assign) CLLocationAccuracy desiredAccuracy;

/*!
 * @property:   locationTimeoutInterval
 * @abstract:   Maximum amount of time before the location process times out.
 * @notes:      Resets the timer if one is already running. Default interval is 10 seconds
 */
@property (nonatomic, assign) NSTimeInterval locationTimeoutInterval;

/*!
 * @property:   fetchGeocodedUserLocationOnCompletion:onError:
 * @abstract:   Get the user's location. Thread safe.
 * @notes:      Multiple clients can request location from the same manager.
 */
- (void)fetchGeocodedUserLocationOnCompletion:(SSLocationSuccessBlock)completionBlock onError:(SSLocationErrorBlock)errorBlock;

@end
