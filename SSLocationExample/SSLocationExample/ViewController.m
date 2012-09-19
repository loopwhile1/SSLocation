//
//  ViewController.m
//  SSLocationExample
//
//  Created by Sanjit Saluja on 9/18/12.
//  Copyright (c) 2012 Sanjit Saluja. All rights reserved.
//

#import "ViewController.h"
#import "SSLocation.h"
#import "Annotation.h"
#import <MapKit/MapKit.h>

@interface ViewController ()
- (IBAction)getUserLocationTapped:(id)sender;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) SSLocationManager *locationManager;
@end

@implementation ViewController
@synthesize mapView;
@synthesize locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.locationManager = [SSLocationManager new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)getUserLocationTapped:(id)sender
{
    [self.locationManager fetchGeocodedUserLocationOnCompletion:^(MKPlacemark *placeMark) {
        NSLog(@"%@", placeMark);
        [self.mapView setRegion:MKCoordinateRegionMake(placeMark.coordinate, MKCoordinateSpanMake(0.0001, 0.0001)) animated:YES];
        [self.mapView removeAnnotations:[self.mapView annotations]];
        
        Annotation *annotation = [Annotation new];
        annotation.placeMark = placeMark;
        [self.mapView addAnnotation:annotation];
        [self.mapView selectAnnotation:annotation animated:YES];
    } onError:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
