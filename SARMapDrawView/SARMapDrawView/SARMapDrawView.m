//
//  SARMapDrawView.m
//  SARMapDrawView
//
//  Created by Saravanan on 03/05/15.
//  Copyright (c) 2015 Saravanan. All rights reserved.
//

#import "SARMapDrawView.h"
#import "NSArray+Extensions.h"

@interface SARMapDrawView (){
    NSArray *_polys;
    NSMutableArray *polys;
    CGPoint lowestPoint;
    CGPoint leftMostPoint;
    CGPoint rightMostPoint;
    
    //    Zone
    NSInteger zoneId;
    NSString *zoneName;
    int selectedRegions;
    int unSelectedRegions;
}

@property (nonatomic) MGLShapeSource *polylineSource;
@property (nonatomic) MGLShapeSource *polygonSource;

@end

@implementation SARMapDrawView
@synthesize mapView = mapView;
@synthesize polygons = polygons;

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initialize];
}

-(void)initialize{
    self.coordinates = [NSMutableArray array];
    polygons = [NSArray array];
    _polys = [NSArray array];
    polys = [NSMutableArray array];

//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:13.08
//                                                            longitude:80.20
//                                                                 zoom:18];//Hardcoding to some Location in Chennai
    
    // Set the map's center coordinate
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(45.520486, -122.673541)
                            zoomLevel:11
                             animated:NO];

    if (!mapView)
        mapView = [[MGLMapView alloc] initWithFrame:self.bounds];

    mapView.delegate = self;
    
}

#pragma mark - MapView Configuration
// Wait until the map is loaded before adding to the map.
- (void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
    [self addPolylineLayer];
    [self addPolygonLayer];
}

- (void)addPolylineLayer {
    // Add an empty MGLShapeSource, we’ll keep a reference to this and add points to this later.
    MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"polyline" features:@[] options:nil];
    [self.mapView.style addSource:source];
    self.polylineSource = source;
    
    // Add a layer to style our polyline.
    MGLLineStyleLayer *layer = [[MGLLineStyleLayer alloc] initWithIdentifier:@"polyline" source:source];
    layer.lineJoin = [MGLStyleValue valueWithRawValue:[NSValue valueWithMGLLineJoin:MGLLineJoinRound]];
    layer.lineCap = [MGLStyleValue valueWithRawValue:[NSValue valueWithMGLLineCap:MGLLineCapRound]];
    layer.lineColor = [MGLStyleValue valueWithRawValue:[UIColor redColor]];
    layer.lineWidth = [MGLStyleValue valueWithRawValue:@2];
//    layer.lineWidth = [MGLStyleValue valueWithInterpolationMode:MGLInterpolationModeExponential
//                                                    cameraStops: @{
//                                                                   @14: [MGLStyleValue valueWithRawValue:@5],
//                                                                   @18: [MGLStyleValue valueWithRawValue:@20]
//                                                                   }
//                                                        options:@{MGLStyleFunctionOptionDefaultValue:@1.75}];
    
    [self.mapView.style addLayer:layer];
}

- (void)addPolygonLayer {
    // Add an empty MGLShapeSource, we’ll keep a reference to this and add points to this later.
    MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"polygon" features:@[] options:nil];
    [self.mapView.style addSource:source];
    self.polygonSource = source;
    
    MGLLineStyleLayer *layer = [[MGLLineStyleLayer alloc] initWithIdentifier:@"polygon" source:source];
    layer.lineJoin = [MGLStyleValue valueWithRawValue:[NSValue valueWithMGLLineJoin:MGLLineJoinRound]];
    layer.lineCap = [MGLStyleValue valueWithRawValue:[NSValue valueWithMGLLineCap:MGLLineCapRound]];
    layer.lineColor = [MGLStyleValue valueWithRawValue:[UIColor greenColor]];
    layer.lineWidth = [MGLStyleValue valueWithRawValue:@2];
    [self.mapView.style addLayer:layer];
}

#pragma mark - Other Methods
-(void)enableDrawing{
    self.isDrawingPolygon = YES;
    self.disableInteraction = YES;
    self.coordinates = [NSMutableArray array];
    //Clearing out the existing polygon object
    if (self.polygon) {
        [mapView removeAnnotation:self.polygon];
        self.polygon = nil;
    }
    for (MGLPolylineFeature *polyline in _polys) {
        [mapView removeAnnotation:polyline];
    }
    
    [self showPolylineLayer:YES];
}

-(void)disableDrawing{
    self.isDrawingPolygon = NO;
    self.disableInteraction = NO;
    self.coordinates = nil;
}

-(void)changeUserInteraction{
    if (self.disableInteraction) {
        self.mapView.userInteractionEnabled = NO;
    }
    else{
        self.mapView.userInteractionEnabled = YES;
    }
}

#pragma mark - Polygon Methods
-(void)removeSelectedPolygon{
    NSMutableArray *polygonsArray = [NSMutableArray arrayWithArray:self.polygons];
    for (MGLPolygon *polygon in self.polygons){
        if (polygon == self.polygon) {
            [polygonsArray removeObject:polygon];
            break;
        }
    }
    self.polygons = polygonsArray;
}

-(void)handleCoordinate:(CLLocationCoordinate2D)coordinate{
    MGLPolylineFeature *polyLine = [self.mapView addCoordinate:coordinate replaceLastObject:NO inCoordinates:self.coordinates withPolylineSource:self.polylineSource];
    if (polyLine) {
        self.polyLine = polyLine;
        [polys addObject:polyLine];
        _polys = polys;
    }
    
}

-(void)showPolylineLayer:(BOOL)show {
    for (MGLStyleLayer *styleLayer in self.mapView.style.layers) {
        if ([styleLayer.identifier isEqualToString:@"polyline"]) {
            styleLayer.visible = show;//This is to hide the polyline layer, actually it should be removed rather than hidden
        }
    }
}

-(void)drawPolygon{
    NSInteger numberOfPoints = [self.coordinates count];
    
    [self showPolylineLayer:NO];
    //        Removing the last drawn polygon
    //    self.polygon.map = nil;
    
//    for (MGLPolylineFeature *poly in _polys) {
//        poly.map = nil;
//    }
    
//    runOnMainQueueWithoutDeadlocking(^{
//        //Do stuff
//    });

//    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"inside dispatch async block main thread from main thread");

        CLLocationCoordinate2D points[self.coordinates.count];
        //    NSUInteger numberOfCoords = sizeof(self.coordinates) / sizeof(CLLocationCoordinate2D);
        
        //    CLLocationCoordinate2D points[numberOfCoords]; //array to hold all the points
        for (NSInteger i = 0; i < self.coordinates.count; i++){
            SARCoordinate *coordinateObject = self.coordinates[i];
            points[i] = coordinateObject.coordinate;
            NSLog(@"latitude is: %@", [NSNumber numberWithDouble:points[i].latitude]);
        }
    
//    NSLog(@"points: %@", points);
    NSLog(@"numberOfPoints: %ld", (long)numberOfPoints);
        //    const CLLocationCoordinate2D northWorldCoords[4] = { {0, -180}, {0, 180}, {90, 180}, {90, -180}};
        //    self.polygon = [MGLPolygon polygonWithCoordinates:northWorldCoords count:numberOfCoords];
        

        //    const CLLocationCoordinate2D points_const = points;
        self.polygon = [MGLPolygon polygonWithCoordinates:points count:numberOfPoints];
        //    NSLog(@"self.polygon bounds: %@", NSStringFromCGRect([self.polygon bounds:mapView]));
        
        // Add the shape to the map
        //    [self.mapView addAnnotation:self.polygon];
        self.polygonSource.shape = self.polygon;
        
        NSLog(@"self.polygon: %@", self.polygon);
        NSLog(@"self.polygonSource.shape: %@", self.polygonSource.shape);
//    });


//    if (self.polygonDrawnBlock) {
//        self.polygonDrawnBlock(self.polygon);
//    }
    
//    CLLocationCoordinate2D coordinates[] = {
//        CLLocationCoordinate2DMake(45.522585, -122.685699),
//        CLLocationCoordinate2DMake(45.534611, -122.708873),
//        CLLocationCoordinate2DMake(45.530883, -122.678833),
//        CLLocationCoordinate2DMake(45.547115, -122.667503),
//        CLLocationCoordinate2DMake(45.530643, -122.660121),
//        CLLocationCoordinate2DMake(45.533529, -122.636260),
//        CLLocationCoordinate2DMake(45.521743, -122.659091),
//        CLLocationCoordinate2DMake(45.510677, -122.648792),
//        CLLocationCoordinate2DMake(45.515008, -122.664070),
//        CLLocationCoordinate2DMake(45.502496, -122.669048),
//        CLLocationCoordinate2DMake(45.515369, -122.678489),
//        CLLocationCoordinate2DMake(45.506346, -122.702007),
//        CLLocationCoordinate2DMake(45.522585, -122.685699),
//    };
//    NSUInteger numberOfCoordinates = sizeof(coordinates) / sizeof(CLLocationCoordinate2D);
//
//    // Create our shape with the formatted coordinates array
//    MGLPolygon *shape = [MGLPolygon polygonWithCoordinates:coordinates count:numberOfCoordinates];
//
//    // Add the shape to the map
//    [self.mapView addAnnotation:shape];

}

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

//#pragma mark - MGLMapViewDelegate Methods
//- (UIColor *)mapView:(MGLMapView *)mapView fillColorForPolygonAnnotation:(MGLPolygon *)annotation {
////    if (self.polygon == annotation) {
//        return UIColor.lightGrayColor;
////    }
//}
//
//- (CGFloat)mapView:(MGLMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation {
//    return 0.6;
//}
//- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation {
//    return UIColor.orangeColor;
//}
//
//- (CGFloat)mapView:(MGLMapView *)mapView lineWidthForPolylineAnnotation:(MGLPolyline *)annotation {
//    return 2.0;
//}

#pragma mark - UITouches Delegates
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //    NSLog(@"touchesBegan");
    
    if (self.disableInteraction){
        self.disableInteraction = !self.disableInteraction;
        return;
    }
    
    if (!self.isDrawingPolygon)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [mapView convertPoint:location toCoordinateFromView:mapView];
//    CLLocationCoordinate2D coordinate = [self.mapView.projection coordinateForPoint:location];
    
    [self handleCoordinate:coordinate];
    
    lowestPoint = location;
    leftMostPoint = location;
    rightMostPoint = location;
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //    NSLog(@"touchesMoved");
    if (!self.isDrawingPolygon) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [mapView convertPoint:location toCoordinateFromView:mapView];
//    CLLocationCoordinate2D coordinate = [self.mapView.projection coordinateForPoint:location];
    
    [self handleCoordinate:coordinate];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //    NSLog(@"touchesEnded");
    if (!self.isDrawingPolygon)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [mapView convertPoint:location toCoordinateFromView:mapView];
//    CLLocationCoordinate2D coordinate = [self.mapView.projection coordinateForPoint:location];
    
    [self handleCoordinate:coordinate];
    
    
    // detect if this coordinate is close enough to starting
    // coordinate to qualify as closing the polygon
    
    //    if ([self isClosingPolygonWithCoordinate:coordinate])
    
    NSInteger numberOfPoints = [self.coordinates count];
    NSLog(@"touchesEnded: numberOfPoints: %lu", numberOfPoints);
    
//    if (!self.isconfirmationView) {
//        [self togglePopupView];
//    }
    
    if (self.isDrawingPolygon) {
        [self drawPolygon];
//        [self calculatePoints:NO];
    }

}

#pragma mark - Setters
-(void)setDisableInteraction:(BOOL)disableInteraction{
    _disableInteraction = disableInteraction;
    [self changeUserInteraction];
    if (disableInteraction == NO) {
        if (self.ViewEnabledBlock) {
            self.ViewEnabledBlock();
        }
    }
}

@end
