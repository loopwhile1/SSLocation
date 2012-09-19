//
//  Annotation.h
//  SSLocationExample
//
//  Created by Sanjit Saluja on 9/18/12.
//  Copyright (c) 2012 Sanjit Saluja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface Annotation : NSObject <MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) MKPlacemark *placeMark;
@end
