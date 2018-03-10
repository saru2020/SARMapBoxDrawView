//
//  ViewController.swift
//  SARMapBoxDrawView
//
//  Created by Saravanan Vijayakumar on 06/03/18.
//  Copyright © 2018 Saravanan Vijayakumar. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController {

    @IBOutlet weak var mapboxDrawView: SARMapBoxDrawView!
    @IBOutlet weak var penButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapboxDrawView.polygonDrawn = { polygon in
            self.penButtonTapped(self.penButton)
            print("polygon: \(polygon)")
        }
    }

    @IBAction func penButtonTapped(_ sender: Any) {
        if mapboxDrawView.mapState == .Draw {
            mapboxDrawView.disableDrawing()
            penButton.isSelected = false
        }
        else {
            mapboxDrawView.enableDrawing()
            penButton.isSelected = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

