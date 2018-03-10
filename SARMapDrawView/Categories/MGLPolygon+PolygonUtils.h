//
//  MGLPolygon+PolygonUtils.h
//  SARMapDrawView
//
//  Created by Saravanan on 03/05/15.
//  Copyright (c) 2015 Saravanan. All rights reserved.
//

@import Mapbox;

@interface MGLPolygon(PolygonUtils)

-(NSArray*)coordinatesArray;
//-(CGRect)bounds;
//-(CGPoint)centre;

-(CGRect)bounds:(MGLMapView*)map;
-(CGPoint)centre:(MGLMapView*)map;

@end
