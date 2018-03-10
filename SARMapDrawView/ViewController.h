//
//  ViewController.h
//  SARMapDrawView
//
//  Created by Saravanan on 03/05/15.
//  Copyright (c) 2015 Saravanan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SARMapDrawView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet SARMapDrawView *mapDrawView;

@property (weak, nonatomic) IBOutlet UIButton *penButton;

@end

