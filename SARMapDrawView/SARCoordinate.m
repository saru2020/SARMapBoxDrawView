//
//  SARCoordinate.m
//  SARMapDrawView
//
//  Created by Saravanan on 03/05/15.
//  Copyright (c) 2015 Saravanan. All rights reserved.
//

#import "SARCoordinate.h"

@implementation SARCoordinate

-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    self.coordinate = coordinate;
    return self;
}

@end
