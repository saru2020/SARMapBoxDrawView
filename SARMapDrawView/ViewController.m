//
//  ViewController.m
//  SARMapDrawView
//
//  Created by Saravanan on 03/05/15.
//  Copyright (c) 2015 Saravanan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize mapDrawView = mapDrawView;

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak ViewController *weakSelf = self;
//    mapDrawView = [[[NSBundle mainBundle] loadNibNamed:@"ETMapDrawView" owner:self options:nil] firstObject];
//    self.view = mapDrawView;
//    mapDrawView = [[SARMapDrawView alloc]initWithFrame:self.view.bounds];
    [self.view bringSubviewToFront:self.penButton];
    mapDrawView.polygonDrawnBlock = ^(MGLPolygon *polygon_Drawn){
        NSLog(@"Polygon Drawing Done.");
        [weakSelf penButtonTapped:weakSelf.penButton];
    };
//    mapDrawView.MapViewIdleAtCameraPositionBlock = ^(GMSCameraPosition *cameraPosition){
//    };
    mapDrawView.MapViewDidTapOverlayBlock = ^(MGLPolygon *polygon_Tapped){
    };
    mapDrawView.ViewEnabledBlock = ^(){
    };
    

}

- (IBAction)penButtonTapped:(id)sender {
    if (!mapDrawView.isDrawingPolygon)
    {
        // We're starting the drawing of our polyline/polygon, so
        // let's initialize everything
        
        [self.mapDrawView enableDrawing];
        [self.penButton setSelected:YES];
    }
    else
    {
        [self.mapDrawView disableDrawing];
        [self.penButton setSelected:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
