//
//  NSArray+Extensions.m
//  SARMapDrawView
//
//  Created by Saravanan Vijayakumar on 01/03/18.
//  Copyright © 2018 Saravanan. All rights reserved.
//

#import "NSArray+Extensions.h"
#import "SARCoordinate.h"

@implementation NSArray (Extensions)

-(NSArray*)coordinatesArray_CLLocationObjects {
    CLLocationCoordinate2D coordinatesArray[self.count];
    NSMutableArray *coordsArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.count; i++) {
        SARCoordinate *coordinateObj = (SARCoordinate*)self[i];
        coordinatesArray[i] = coordinateObj.coordinate;
        [coordsArray addObject:[[CLLocation alloc] initWithLatitude:coordinateObj.coordinate.latitude longitude:coordinateObj.coordinate.longitude]];
    }
    return coordsArray;
}

@end
