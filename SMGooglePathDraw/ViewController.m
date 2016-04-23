//
//  ViewController.m
//  SMGooglePathDraw
//
//  Created by Shankar on 14/04/16.
//  Copyright © 2016 Shankar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end
#define MAX_HEADER_HEIGHt_GrpDETAILS 0//144
#define MIN_TABLE_HEIGHT 72
#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.routeType=@"driving";
    //loaction----
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter=200;
    //-----
    _routePoint=[NSMutableArray array];
    [self calculateRoutesFromLat:@"22.5726" AndLng:@"88.3639" toLat:@"19.0760" toLng:@"72.8777" withforWhich:@"PathDraw"];
    annotation4CrntLctn = nil;
    annotation4CrntLctn = [[ZSAnnotation alloc] init];
    [self addAnotation];
    [locationManager startUpdatingLocation];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(SYSTEM_VERSION>=8.0){
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        // show the map
    } else {
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
       // [self ShowAlertWithMessage:@"Please on your gps"];
    }
    [locationManager startUpdatingLocation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [locationManager stopUpdatingLocation];
}

#pragma mark ------------------------Start-------------------------------------------------------------
#pragma mark ------------------------
#pragma mark Map Draw
//--- Calculate or fetching coordinate points from google direction API to draw the route ----//
-(void) calculateRoutesFromLat:(NSString *)startLat AndLng:(NSString *)StartLng toLat:(NSString *)DesLat toLng:(NSString *)DesLng withforWhich:(NSString *)str4which
{
//RLAppDelegate *appdelegate=(RLAppDelegate *)[[UIApplication sharedApplication] delegate];
    @try {
        
        NSString* saddr = [NSString stringWithFormat:@"%@,%@", startLat, StartLng];
        NSString* daddr = [NSString stringWithFormat:@"%@,%@", DesLat, DesLng];
            // creating a request to fetch route coordinate
            NSMutableArray *arrplylinePoint=[NSMutableArray array];
            NSURLRequest *request=  [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=true&mode=%@",saddr,daddr,self.routeType]]];
            // Call Asynchronously url request with completeion block
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (connectionError==nil) {
                    NSError* error;
                    NSDictionary* locationResult = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:kNilOptions
                                                                                     error:&error];
                    if([str4which isEqualToString:@"PathDraw"])
                    {
                        NSString *status = [locationResult objectForKey:@"status"];
                        if ([status isEqualToString:@"OK"]) {
                            
                            
                            //                        dispatch_queue_t myBackgroundQueue;
                            //
                            //                        myBackgroundQueue = dispatch_queue_create("com.company.subsystem.task", NULL);
                            //                        dispatch_async(myBackgroundQueue, ^(void) {
                            //                         dispatch_async(dispatch_get_main_queue(),^{
                            NSArray *routeArr=locationResult[@"routes"];
                            for (int i=0; i<routeArr.count; i++) {
                                NSDictionary *dic=[routeArr objectAtIndex:i];
                                NSArray *arrlegs=[dic objectForKey:@"legs"];
                                for(int j=0;j<arrlegs.count;j++)
                                {
                                    NSDictionary *dic4leg=[arrlegs objectAtIndex:j];
                                    NSArray *arr4steps=[dic4leg objectForKey:@"steps"];
                                    for (int k=0; k<arr4steps.count; k++)
                                    {
                                        NSDictionary *dic4step=[arr4steps objectAtIndex:k];
                                        NSString *strPoly=[[dic4step objectForKey:@"polyline"] valueForKey:@"points"];
                                        [arrplylinePoint addObject:strPoly];
                                    }
                                }
                            }
                            // });
                            //                            dispatch_async(dispatch_get_main_queue(),^{
                            for (int i = 0; i < arrplylinePoint.count; i++) {
                                [self decodePolyLine:[[arrplylinePoint objectAtIndex:i] mutableCopy]];
                            }
                            
                            //dispatch_async(dispatch_get_main_queue(), ^{
                                [self updateRouteView];
                            //});
                            
                            // });
                        }
                        else
                        {
                        }
                        
                        
                    }else{
                        //This part not for path draw....
                        NSString *status = [locationResult objectForKey:@"status"];
                        
                        if([status isEqualToString:@"OK"])
                        {
                            
                            NSArray* array = [locationResult objectForKey:@"routes"];
                            
                            ////NSLog(@"legs: %@", array);
                            
                            NSDictionary* dic = [array objectAtIndex:0];
                            
                            //NSString* duration = [dic objectForKey:@"duration"];
                            NSArray *legsArr = [dic valueForKey:@"legs"];
                            NSDictionary *legsDict = [legsArr objectAtIndex:0];
                            NSDictionary *durationDict = [legsDict valueForKey:@"duration"];
                            
                            NSString *time = [durationDict objectForKey:@"value"];
                            int hr=[time integerValue]/3600;
                            int mint=([time integerValue]%3600)/60;
                            NSString *strETA=[NSString stringWithFormat:@"%d : %d",hr,mint];
                            
                            NSLog(@"%@",strETA);
                            NSString *distance=[[legsDict valueForKey:@"distance"] valueForKey:@"value"];
                            float mtr=[distance floatValue];
                            float kilometers4Rmng=mtr/1000;
                            //float miles=kilometers4Rmng*0.62137;
                            NSString *str=[NSString stringWithFormat:@"%.2f miles", kilometers4Rmng*0.62137];
                            NSLog(@"%@",str);
                            
                        }
                        
                        //Some Error
                        
                        if (error != nil)
                        {
                            NSLog(@"%@",[error localizedDescription]);
                            
                        }
                        
                    }
                    
                }
                
            }];
            // });
            
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s-%@",__PRETTY_FUNCTION__,exception.description);
    }
    
}

-(void)decodePolyLine:(NSMutableString *)encoded
{
    @try {
        
        //        [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
        //                                    options:NSLiteralSearch
        //                                      range:NSMakeRange(0, [encoded length])];
        NSInteger len = [encoded length];
        NSInteger index = 0;
        
        //[_routePoint removeAllObjects];
        
        NSInteger lat=0;
        NSInteger lng=0;
        while (index < len) {
            NSInteger b;
            NSInteger shift = 0;
            NSInteger result = 0;
            do {
                b = [encoded characterAtIndex:index++] - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
            lat += dlat;
            shift = 0;
            result = 0;
            do {
                b = [encoded characterAtIndex:index++] - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
            lng += dlng;
            NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat];
            NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng];
            NSString *LOC = [[NSString alloc] initWithFormat:@"%f,%f",[latitude doubleValue]/100000,[longitude doubleValue]/100000];
            
            [_routePoint addObject:LOC];
            
            LOC = nil;
        }
        NSLog(@"Path Location found:%lu",(unsigned long)[_routePoint count]);
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s-%@",__PRETTY_FUNCTION__,exception.description);
    }
    
}
// Drawing or update the route direction with a line
-(void) updateRouteView{
    @try {
        // Initialize location coordinate arr with index count
        MKMapPoint *pointArr = malloc(sizeof(CLLocationCoordinate2D)  * _routePoint.count);
        for(int idx = 0; idx < _routePoint.count; idx++){
            NSString* currentPointString = [[NSString alloc] initWithString:[_routePoint objectAtIndex:idx]];
            NSArray* latLonArr = [[NSArray alloc] initWithArray:[currentPointString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]]];
            currentPointString = nil;
            CLLocationDegrees latitude  = [[latLonArr objectAtIndex:0] doubleValue];
            CLLocationDegrees longitude = [[latLonArr objectAtIndex:1] doubleValue];
            latLonArr = nil;
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            MKMapPoint point = MKMapPointForCoordinate(coordinate);
            pointArr[idx] = point;
            
        }
        if (self.routeline){
            [_mapView removeOverlay:self.routeline];
            self.routeline = nil;
        }
        self.routeline = nil;
        
        self.routeline = [MKPolyline polylineWithPoints:pointArr count:_routePoint.count];
        // after adding polygon releasing the array
        free(pointArr);
        if (self.routelineView) {
            
            self.routelineView = nil;
        }
        if (nil != self.routeline) {
            [_mapView addOverlay:self.routeline];
        }
        
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"%s-%@",__PRETTY_FUNCTION__,exception.description);
    }
}
#pragma mark----------------------
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        // creating polygon line to draw the direction route
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:2.0];
        return renderer;
    }
    else if([overlay isKindOfClass:[MKPolygon class]])
    {
        // creating polygon view to draw the region of the syncspot
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:overlay];
        polygonView.lineWidth = 2; // set line width of polygon
        polygonView.strokeColor = [UIColor blueColor]; // set stroke color of polygon
        polygonView.fillColor = [UIColor yellowColor]; // set fill color of polygon
        mapView.userInteractionEnabled = YES;
        return (MKOverlayRenderer *)polygonView;
    }
    return nil;
}
#pragma mark -----------------------------------END----------------------------------------------------

#pragma mark----------------------
#pragma mark TbleVw delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cellidentifire"];
    cell.textLabel.text=@"Path Draw";
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
    
}

#pragma mark----------------------
#pragma mark Location manager Mthd

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //[[Common SharedInstance] ShowAlertWithMessage:@"ese gchi"];
        //NSLog(@"didUpdateToLocation: %@", newLocation);
        CLLocation *currentLocation = newLocation;
        
        if (currentLocation != nil) {
            NSString *text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
            NSString *text1 = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
            //NSLog(@"log-%@ lat %@",text,text1);
            // CLLocation *locstrt = [[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
            [self addAnotatioForCurrentLocationwithLat:currentLocation.coordinate.latitude withLong:currentLocation.coordinate.longitude];
            CLGeocoder *geocoderes = [[CLGeocoder alloc] init] ;
            [geocoderes reverseGeocodeLocation: newLocation completionHandler: ^(NSArray *placemarks, NSError *error)
             {
                 //Get nearby address
                 CLPlacemark *placemarkes = [placemarks objectAtIndex:0];
                 
                 NSString *address = [placemarkes.addressDictionary valueForKey:@"City"];
                 // annotation4CrntLctn.title=;
                 annotation4CrntLctn.title=address;
                 //NSLog(@"address:%@",address);
             }];
            
            CLLocation *CrntLoc = [[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
           // CLLocation *locEnd = [[CLLocation alloc] initWithLatitude:[self.str4Details isEqualToString:@"RideDetails"]?[self.objRideList.rideendlocationlat floatValue]:[self.objMyRideList.rideendlocationlat floatValue] longitude:[self.str4Details isEqualToString:@"RideDetails"]?[self.objRideList.rideendlocationlon floatValue]:[self.objMyRideList.rideendlocationlon floatValue]];
            CLLocation *locEnd = [[CLLocation alloc]initWithLatitude:19.0760 longitude:72.8777];
            CLLocationDistance distance4Rmng = [CrntLoc distanceFromLocation:locEnd];
            CLLocationDistance kilometers4Rmng = distance4Rmng / 1000.0;
            NSLog(@"kilometers :%f", kilometers4Rmng);
           
            NSString *str=[newLocation speed]<0?@"0 mph":[NSString stringWithFormat:@"%0.2f mph",[newLocation speed]*2.23693629];
            //lbl4DstncLft.text=[NSString stringWithFormat:@"%.2f miles", kilometers4Rmng*0.62137];
            NSLog(@"mph %@",str);
        }
        
        
    
}
#pragma mark----------------------
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (self.constant4MapVwHght.constant - scrollView.contentOffset.y <= MAX_HEADER_HEIGHt_GrpDETAILS) {
        self.constant4MapVwHght.constant = MAX_HEADER_HEIGHt_GrpDETAILS;
        
        [self.view layoutIfNeeded];
        [self.view setNeedsUpdateConstraints];
        NSLog(@"1st %f",self.constant4MapVwHght.constant);
    }
    else {
        CGFloat cHeight =  self.constant4MapVwHght.constant;
        cHeight = cHeight - scrollView.contentOffset.y;
        NSLog(@"contentofset %f",scrollView.contentOffset.y);
        self.constant4MapVwHght.constant = MIN(cHeight, (self.view.bounds.size.height-53-76)-MIN_TABLE_HEIGHT);
        NSLog(@"2nd %f",self.constant4MapVwHght.constant);
    }
}
#pragma mark ------------------
#pragma mark add point
-(void)addAnotation
{
    NSMutableArray *annotationArray = [NSMutableArray array];
    ZSAnnotation *annotation = nil;
    
    annotation = [[ZSAnnotation alloc] init];
    
    annotation.coordinate =CLLocationCoordinate2DMake(22.5726,88.3639);
    annotation.color = [UIColor redColor];//RGB(13, 0, 182);
    annotation.title = @"Kolkata";
    annotation.type = ZSPinAnnotationTypeTagStroke;
    [annotationArray addObject:annotation];
    
    annotation = [[ZSAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(19.0760,72.8777);
    annotation.color = [UIColor greenColor];//RGB(0, 182, 146);
    annotation.type = ZSPinAnnotationTypeTagStroke;
    annotation.title = @"Mumbai";
    [annotationArray addObject:annotation];
    // Center map
    self.mapView.visibleMapRect = [self makeMapRectWithAnnotations:annotationArray];
    
    [self.mapView setVisibleMapRect:[self makeMapRectWithAnnotations:annotationArray] edgePadding:UIEdgeInsetsMake(20,10,10,10) animated:YES];
    // Add to map
    [self.mapView addAnnotations:annotationArray];
}
#pragma mark----------------------
#pragma mark addpinForCurrentLocation
-(void)addAnotatioForCurrentLocationwithLat:(float)lat withLong:(float)log{
        [self.mapView removeAnnotation:annotation4CrntLctn];
        annotation4CrntLctn.coordinate = CLLocationCoordinate2DMake(lat,log);
        annotation4CrntLctn.type = ZSPinAnnotationTypeTagBike;
        [self.mapView addAnnotation:annotation4CrntLctn];
}
#pragma mark --------------------
#pragma mark Map Delegate
#pragma mark - MapKit
- (MKMapRect)makeMapRectWithAnnotations:(NSArray *)annotations {
    
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    return flyTo;
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
    
    // Don't mess with user location
    if(![annotation isKindOfClass:[ZSAnnotation class]])
        return nil;
    
    ZSAnnotation *a = (ZSAnnotation *)annotation;
    static NSString *defaultPinID = @"StandardIdentifier";
    
    // Create the ZSPinAnnotation object and reuse it
    ZSPinAnnotation *pinView = (ZSPinAnnotation *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if (pinView == nil){
        pinView = [[ZSPinAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    }
    
    // Set the type of pin to draw and the color
    pinView.annotationType = a.type;
    pinView.annotationColor = a.color;
    pinView.canShowCallout = YES;
    
    return pinView;
    
}
-(void)ShowAlertWithMessage:(NSString *)AlertMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SMPATHDRAW" message:AlertMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}
@end
