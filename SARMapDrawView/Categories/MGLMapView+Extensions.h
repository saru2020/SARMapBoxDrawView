//
//  MGLMapView+Extensions.h
//  SARMapDrawView
//
//  Created by Saravanan on 03/05/15.
//  Copyright (c) 2015 Saravanan. All rights reserved.
//

#import "SARCoordinate.h"
@import Mapbox;

@interface MGLMapView(Extension)

-(MGLPolylineFeature*)addCoordinate:(CLLocationCoordinate2D)coordinate replaceLastObject:(BOOL)replaceLast inCoordinates:(NSMutableArray*)coordinates withPolylineSource:(MGLShapeSource*)polylineSource;
//-(void)drawPolyLineForPreviousCoordinates:(NSMutableArray*)coordinates;
-(void)drawPolyLineForPreviousCoordinates:(NSMutableArray*)coordinates withPolylineSource:(MGLShapeSource*)polylineSource;
-(BOOL)isClosingPolygonWithCoordinate:(CLLocationCoordinate2D)coordinate inCoordinates:(NSMutableArray*)coordinates;

@end
