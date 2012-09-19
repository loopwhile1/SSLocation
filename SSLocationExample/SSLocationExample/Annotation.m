//
//  Annotation.m
//  SSLocationExample
//
//  Created by Sanjit Saluja on 9/18/12.
//  Copyright (c) 2012 Sanjit Saluja. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation
@synthesize placeMark;
@dynamic coordinate;

- (CLLocationCoordinate2D)coordinate
{
    return self.placeMark.coordinate;
}

- (NSString *)subtitle
{
    NSMutableString *description = [NSMutableString stringWithCapacity:10];
    if (placeMark.locality != nil || placeMark.postalCode != nil)
    {
        if (placeMark.locality != nil)
        {
            [description appendFormat:@"%@ ", placeMark.locality];
        }
        
        if (placeMark.postalCode != nil)
        {
            [description appendFormat:@"%@", placeMark.postalCode];
        }
    }

    
    return description;
}

- (NSString *)title
{
    return [NSString stringWithFormat:@"%@ %@", placeMark.subThoroughfare, placeMark.thoroughfare];
}
    
@end
