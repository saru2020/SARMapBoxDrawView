//
//  MGLMapView+Extensions.m
//  SARMapDrawView
//
//  Created by Saravanan on 03/05/15.
//  Copyright (c) 2015 Saravanan. All rights reserved.
//

#import "MGLMapView+Extensions.h"
#import "NSArray+Extensions.h"

@implementation MGLMapView(Extension)

#pragma mark - Utils
-(float)kilometersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to {
    
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userloc distanceFromLocation:dest]/1000;
    
    //NSLog(@"%f",dist);
    NSString *distance = [NSString stringWithFormat:@"%f",dist];
    
    return [distance floatValue];
    
}

-(float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2
{
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

-(MGLPolylineFeature*)addCoordinate:(CLLocationCoordinate2D)coordinate replaceLastObject:(BOOL)replaceLast inCoordinates:(NSMutableArray*)coordinates withPolylineSource:(MGLShapeSource*)polylineSource
{
    if (replaceLast && [coordinates count] > 0)
        [coordinates removeLastObject];
    
    [coordinates addObject:[[SARCoordinate alloc] initWithCoordinate:coordinate]];
    
    // if we have more than one point, then we're drawing a line segment
    
    CLLocationCoordinate2D points[coordinates.count];
    for (NSInteger i = 0; i < coordinates.count; i++){
        SARCoordinate *coordinateObject = coordinates[i];
        points[i] = coordinateObject.coordinate;
    }
    MGLPolylineFeature *polyline = [MGLPolylineFeature polylineWithCoordinates:points count:coordinates.count];
    // Updating the MGLShapeSource’s shape will have the map redraw our polyline with the current coordinates.
    polylineSource.shape = polyline;

    return polyline;
}

-(void)drawPolyLineForPreviousCoordinates:(NSMutableArray*)coordinates withPolylineSource:(MGLShapeSource*)polylineSource {
    CLLocationCoordinate2D points[coordinates.count];
    for (NSInteger i = 0; i < coordinates.count; i++){
        SARCoordinate *coordinateObject = coordinates[i];
        points[i] = coordinateObject.coordinate;
    }

    MGLPolylineFeature *polyline = [MGLPolylineFeature polylineWithCoordinates:points count:coordinates.count];
    // Updating the MGLShapeSource’s shape will have the map redraw our polyline with the current coordinates.
    polylineSource.shape = polyline;

}


-(BOOL)isClosingPolygonWithCoordinate:(CLLocationCoordinate2D)coordinate inCoordinates:(NSMutableArray*)coordinates withMap:(MGLMapView*)map
{
    if ([coordinates count] > 2)
    {
        SARCoordinate *coordinateObject = coordinates[0];
        CLLocationCoordinate2D startCoordinate = coordinateObject.coordinate;
        
        //        CLLocationCoordinate2D startCoordinate = [coordinates[0] MKCoordinateValue];
        CGPoint start = [map convertCoordinate:startCoordinate toPointToView:map];
        CGPoint end = [map convertCoordinate:coordinate toPointToView:map];
        
        CGFloat xDiff = end.x - start.x;
        CGFloat yDiff = end.y - start.y;
        CGFloat distance = sqrtf(xDiff * xDiff + yDiff * yDiff);
        if (distance < 30.0)
        {
            //            [coordinates removeLastObject];
            return YES;
        }
    }
    
    return NO;
}



@end
