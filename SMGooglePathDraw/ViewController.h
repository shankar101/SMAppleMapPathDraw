//
//  ViewController.h
//  SMGooglePathDraw
//
//  Created by Shankar on 14/04/16.
//  Copyright © 2016 Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ZSPinAnnotation.h"
#import "ZSAnnotation.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate>
{
    ZSAnnotation *annotation4CrntLctn;
    CLLocationManager *locationManager;

}
@property (nonatomic,strong)NSString *routeType;
@property (nonatomic,retain) NSMutableArray *routePoint;
@property (weak, nonatomic) MKPolyline *routeline;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tblVw4data;
@property (retain, nonatomic) MKPolylineView *routelineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constant4MapVwHght;

@end

