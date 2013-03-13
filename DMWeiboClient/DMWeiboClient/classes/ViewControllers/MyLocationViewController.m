//
//  MyLocationViewController.m
//  DMWeiboClient
//
//  Created by Blank on 13-1-17.
//  Copyright (c) 2013年 戴 立慧. All rights reserved.
//

#import "MyLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface MyLocationViewController ()<CLLocationManagerDelegate, SinaWeiboRequestDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CLLocationCoordinate2D coordinate;
    BOOL didGetAddress;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *pois;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSString *address;
@end

@implementation MyLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    didGetAddress = NO;
	// Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
	[self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[self.locationManager setDelegate:self];
    [self.locationManager startUpdatingLocation];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableview.frame.size.width, 44)];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(140, 4, 40, 40)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicator startAnimating];
    [tableHeaderView addSubview:activityIndicator];
    self.tableview.tableHeaderView = tableHeaderView;
    
    
    
}
- (void)viewDidUnload {
    [self setMapView:nil];
    [self setTableview:nil];
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnBack:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)didSelectLocation
{
    if ([self.delegate respondsToSelector:@selector(myLocationViewController:didSelectedLocationWithCoordinate:andAddress:)]) {
        [self.delegate myLocationViewController:self didSelectedLocationWithCoordinate:coordinate andAddress:self.address];
    }
}

- (SinaWeibo *)sinaweibo
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.sinaweibo;
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    DebugLog(@"%f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    
    
    
    if (!didGetAddress) {
        didGetAddress = YES;
        coordinate = newLocation.coordinate;
        MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
        theRegion.center=newLocation.coordinate;
        theRegion.span.longitudeDelta = 0.01f;
        theRegion.span.latitudeDelta = 0.01f;
        [self.mapView setRegion:theRegion animated:YES];
        SinaWeibo *sinaweibo = [self sinaweibo];
        [sinaweibo requestWithURL:@"location/geo/gps_to_offset.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f,%f",newLocation.coordinate.longitude,newLocation.coordinate.latitude ], @"coordinate", nil]
                       httpMethod:@"GET"
                         delegate:self];
    }
    

    
}


#pragma mark - SinaWeiboRequestDelegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"location/geo/geo_to_address.json"])
    {
        
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if([request.url hasSuffix:@"location/geo/gps_to_offset.json"])//坐标偏移
    {
        NSArray *array = [result valueForKeyPath:@"geos"];
        NSArray *geo = [array objectAtIndex:0];
        coordinate.latitude = [[geo valueForKeyPath:@"latitude"] doubleValue];
        coordinate.longitude = [[geo valueForKeyPath:@"longitude"] doubleValue];
        
        SinaWeibo *sinaweibo = [self sinaweibo];
        [sinaweibo requestWithURL:@"location/geo/geo_to_address.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f,%f",coordinate.longitude,coordinate.latitude ], @"coordinate", nil]
                       httpMethod:@"GET"
                         delegate:self];
    }
    else if ([request.url hasSuffix:@"location/geo/geo_to_address.json"])//获取地址
    {
        DebugLog(@"%@",result);
        NSArray *array = [result valueForKeyPath:@"geos"];
        NSArray *geo = [array objectAtIndex:0];
        self.address = [geo valueForKeyPath:@"address"];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = coordinate;
        annotation.title = self.address;
        annotation.subtitle = @"当前所在区域";
        DebugLog(@"%@",annotation.title);
        [self.mapView addAnnotation:annotation];
        
        SinaWeibo *sinaweibo = [self sinaweibo];
        [sinaweibo requestWithURL:@"place/nearby/pois.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",coordinate.latitude], @"lat", [NSString stringWithFormat:@"%f",coordinate.longitude], @"long", @"1", @"offset", nil]
                       httpMethod:@"GET"
                         delegate:self];
    }
    else if([request.url hasSuffix:@"place/nearby/pois.json"])//附近地点
    {
        self.tableview.tableHeaderView = nil;
        self.pois = [result valueForKeyPath:@"pois"];
        [self.tableview reloadData];
    }
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString* BridgeAnnotationIdentifier = @"bridgeAnnotationIdentifier";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)
    [mapView dequeueReusableAnnotationViewWithIdentifier:BridgeAnnotationIdentifier];
    if (!pinView)
    {
        // if an existing pin view was not available, create one
        MKPinAnnotationView* customPinView = [[MKPinAnnotationView alloc]
                                               initWithAnnotation:annotation reuseIdentifier:BridgeAnnotationIdentifier];
        customPinView.pinColor = MKPinAnnotationColorRed;
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        
        // add a detail disclosure button to the callout which will open a new view controller page
        //
        // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
        //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
        //
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self
                        action:@selector(didSelectLocation)
              forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = rightButton;
        
        return customPinView;
    }
    else
    {
        pinView.annotation = annotation;
    }
    return pinView;

}



- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    //
    MKPointAnnotation *annotation = mapView.annotations.lastObject;
    [mapView selectAnnotation:annotation animated:YES];
}


#pragma mark - UITableViewDelegate & UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pois.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"POICell"];
    cell.textLabel.text = [[self.pois objectAtIndex:indexPath.row] valueForKeyPath:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.address = [[self.pois objectAtIndex:indexPath.row] valueForKeyPath:@"title"];
    coordinate.latitude = [[[self.pois objectAtIndex:indexPath.row] valueForKeyPath:@"lat"] doubleValue];
    coordinate.longitude = [[[self.pois objectAtIndex:indexPath.row] valueForKeyPath:@"lon"] doubleValue];
    [self didSelectLocation];
}


@end
