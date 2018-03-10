//
//  SARCoordinate.h
//  SARMapDrawView
//
//  Created by Saravanan on 03/05/15.
//  Copyright (c) 2015 Saravanan. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreLocation/CoreLocation.h>

@interface SARCoordinate : NSObject

@property(nonatomic)CLLocationCoordinate2D coordinate;

-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;


@end
