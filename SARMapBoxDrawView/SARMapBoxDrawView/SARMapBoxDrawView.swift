//
//  SARMapBoxDrawView.swift
//  SARMapBoxDrawView
//
//  Created by Saravanan Vijayakumar on 06/03/18.
//  Copyright © 2018 Saravanan Vijayakumar. All rights reserved.
//

import Foundation
import Mapbox

enum MapState {
    case Draw, Pan
}

class SARCoordinate {
    var coordinate: CLLocationCoordinate2D!
    
    init(withCoordinate coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class SARMapBoxDrawView: UIView, MGLMapViewDelegate {
    var mapView: MGLMapView!
    var mapState: MapState = .Pan {
        didSet {
            changeUserInteraction()
        }
    }

    //Map Related Objects
    var polylineSource: MGLShapeSource!
    var polygonSource: MGLShapeSource!
    var allCoordinates: [SARCoordinate]!
    var polylines: [MGLPolylineFeature]!
    var polygonDrawn: ((MGLPolygon)->Void)?
    var mapViewFinishedLoading: (()->Void)?
    var userLocationUpdated: ((MGLUserLocation?)->Void)?
    var viewEnabled: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    func initialize() {
        polylines = [MGLPolylineFeature]()
        allCoordinates = [SARCoordinate]()
//        return
        
        if mapView == nil {
            mapView = MGLMapView(frame: self.bounds)
            mapView.showsUserLocation = true
            self.addSubview(mapView)
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }

        mapView.setCenter(
            CLLocationCoordinate2D(latitude: 45.5076, longitude: -122.6736),
            zoomLevel: 11,
            animated: false)

        mapView.delegate = self
        
    }
    
    func currentLocation() -> CLLocation? {
        return mapView.userLocation?.location
    }
    
    func addPolylineLayer() {
        // Add an empty MGLShapeSource, we’ll keep a reference to this and add points to this later.
        let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
        mapView.style?.addSource(source)
        polylineSource = source
        
        // Add a layer to style our polyline.
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = MGLStyleValue(rawValue: NSValue(mglLineJoin: .round))
        layer.lineCap = MGLStyleValue(rawValue: NSValue(mglLineCap: .square))
        layer.lineColor = MGLStyleValue(rawValue: UIColor.red)
        layer.lineWidth = MGLStyleFunction(interpolationMode: .exponential,
                                           cameraStops: [14: MGLConstantStyleValue<NSNumber>(rawValue: 1),
                                                         18: MGLConstantStyleValue<NSNumber>(rawValue: 2)],
                                           options: [.defaultValue : MGLConstantStyleValue<NSNumber>(rawValue: 0.5)])
        mapView.style?.addLayer(layer)
    }

    func addPolygonLayer() {
        let source = MGLShapeSource(identifier: "polygon", shape: nil, options: nil)
        mapView.style?.addSource(source)
        polygonSource = source
        
        let layer = MGLLineStyleLayer(identifier: "polygon", source: source)
        layer.lineJoin = MGLStyleValue(rawValue: NSValue(mglLineJoin: .round))
        layer.lineCap = MGLStyleValue(rawValue: NSValue(mglLineCap: .butt))
        layer.lineColor = MGLStyleValue(rawValue: UIColor.orange)
        layer.lineWidth = MGLStyleFunction(interpolationMode: .exponential,
                                           cameraStops: [14: MGLConstantStyleValue<NSNumber>(rawValue: 2),
                                                         18: MGLConstantStyleValue<NSNumber>(rawValue: 10)],
                                           options: [.defaultValue : MGLConstantStyleValue<NSNumber>(rawValue: 1.5)])
        mapView.style?.addLayer(layer)
    }

//    MARK: Other Methods
    func enableDrawing() {
        mapState = .Draw
        mapView.isUserInteractionEnabled = false
        polylineSource.shape = nil
        polygonSource.shape = nil
    }
    
    func disableDrawing() {
        mapState = .Pan
        allCoordinates.removeAll()
        mapView.isUserInteractionEnabled = true
    }
    
//    MARK: MapView Delegates
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if let callback = mapViewFinishedLoading {
            callback()
        }

        addPolylineLayer()
        addPolygonLayer()
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        
        if let callback = userLocationUpdated {
            callback(userLocation)
        }

//        print("didUpdate userLocation: \(userLocation)")
        if let loc = mapView.userLocation {
            mapView.setCenter(loc.coordinate, animated: true)
        }
    }

//    MARK: Other Methods
    func changeUserInteraction() {
        if mapState == .Draw {
            mapView.isUserInteractionEnabled = false
        }
        else {
            mapView.isUserInteractionEnabled = true
        }
        if let callback = viewEnabled {
            callback()
        }
    }
    
    func handleCoordinate(coordinate: CLLocationCoordinate2D) {
        let polyline = mapView.addCoordinate(coordinate: coordinate, replaceLastObject: false, inCoordinates: &allCoordinates!, withPolylineSource: self.polylineSource)
        polylines.append(polyline)

    }
    
    func drawPolygon() {
        let points:[CLLocationCoordinate2D] = allCoordinates.coordinatesArray_CLLocationCoordinates()
        let polygon = MGLPolygon(coordinates: points, count: UInt(allCoordinates.count))
        polygonSource.shape = polygon
        
        print(polygon)
        print(polygonSource.shape!)
        
        if let callback = polygonDrawn {
            callback(polygon)
        }
    }
    
}

extension SARMapBoxDrawView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mapState == .Pan {
            return
        }
        handleTouch(touch: touches.first!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mapState == .Pan {
            return
        }
        handleTouch(touch: touches.first!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mapState == .Pan {
            return
        }
        handleTouch(touch: touches.first!)
        
        drawPolygon()
    }
    
    func handleTouch(touch: UITouch) {
        let location = touch.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        handleCoordinate(coordinate: coordinate)
    }
    
}

extension MGLMapView {
    func addCoordinate(coordinate: CLLocationCoordinate2D, replaceLastObject replaceLast:Bool, inCoordinates  coordinates:inout [SARCoordinate], withPolylineSource polylineSource:MGLShapeSource) -> MGLPolylineFeature {
        if replaceLast && coordinates.count > 0 {
            coordinates.removeLast()
        }
        coordinates.append(SARCoordinate(withCoordinate: coordinate))
        
        let points:[CLLocationCoordinate2D] = coordinates.coordinatesArray_CLLocationCoordinates()
        
        let polyline = MGLPolylineFeature(coordinates: points, count: UInt(coordinates.count))
        polylineSource.shape = polyline
        
        return polyline
    }
    
}

extension CGPoint {
    func distance(from point:CGPoint) -> Float {
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        return Float(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}

extension CLLocationCoordinate2D {
    func distanceInKM(from coordinate: CLLocationCoordinate2D) -> Float {
        let selfLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = selfLocation.distance(from: location)/1000
        return Float(distance)
    }
}

extension Array where Iterator.Element: SARCoordinate {
    func coordinatesArray_CLLocationObjects() -> [CLLocation] {
        var coordsArray = [CLLocation]()
        for coordObj in self {
                let location = CLLocation(latitude: coordObj.coordinate.latitude, longitude: coordObj.coordinate.longitude)
                coordsArray.append(location)
            }
        return coordsArray
    }

    func coordinatesArray_CLLocationCoordinates() -> [CLLocationCoordinate2D] {
        var points = [CLLocationCoordinate2D]()
        for (_, coordObj) in self.enumerated() {
            points.append(coordObj.coordinate)
        }
        return points
    }
}
