//
//  ViewController.swift
//  Mobile demo
//
//  Created by Дмитрий Барышников on 02.09.17.
//  Copyright © 2017 NextGIS. All rights reserved.
//

import UIKit
import ngmaplib

class ViewController: UIViewController, GestureDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MapView!
    weak var map: Map?
    var pointsFC: FeatureClass? = nil
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let map = API.instance.getMap("main") {
            
            let memSizeMb = ProcessInfo.processInfo.physicalMemory / 1048576
            var reduceFactor = 1.3
            if memSizeMb < 1024 {
                reduceFactor = 2.7
            }
        
            let options = [
                "ZOOM_INCREMENT":"1", // Add extra to zoom level corresponding to scale
                "VIEWPORT_REDUCE_FACTOR":"\(reduceFactor)" // Reduce viewport width and height to decrease memory usage
            ]
            map.setOptions(options: options)
            map.setExtentLimits(minX: -20037508.34,
                                minY: -20037508.34,
                                maxX: 20037508.34,
                                maxY: 20037508.34)
            if map.layerCount == 0 { // Map is just created   
                addPoints(to: map)
                addOSM(to: map)

                
                _ = map.save()
            }
        
            mapView.setMap(map: map)
            mapView.registerGestureRecognizers(self)
            
            self.map = map
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.freeze = false
        mapView.refresh()
    }
    
    func onSingleTap(sender: UIGestureRecognizer) {
    }
    
    func onDoubleTap(sender: UIGestureRecognizer) {
    }
    
    func onPanGesture(sender: UIPanGestureRecognizer) {
    }
    
    func onPinchGesture(sender: UIPinchGestureRecognizer) {
    }

    
    func addOSM(to map: Map) {
        if let dataDir = API.instance.getDataDirectory() {
            
            let bbox = Envelope(minX: -20037508.34,
                                minY: -20037508.34,
                                maxX: 20037508.34,
                                maxY: 20037508.34)
            let baseMap = dataDir.createTMS(name: "osm.wconn",
                                        url: "http://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                        epsg: 3857,
                                        z_min: 0, z_max: 18,
                                        fullExtent: bbox,
                                        limitExtent: bbox,
                                        cacheExpires: 7)
            
            _ = map.addLayer(name: "OSM", source: baseMap)
        }
    }
    
    func addPoints(to map: Map) {
        // Get or create data store
        if let dataStore = API.instance.getStore("store") {
            // Create points feature class
            
            let options = [
                "CREATE_OVERVIEWS" : "ON",
                "ZOOM_LEVELS" : "2,3,4,5,6,7,8,9,10,11,12,13,14"
            ]
            
            let fields = [
                Field(name: "long", alias: "long", type: .REAL),
                Field(name: "lat", alias: "lat", type: .REAL),
                Field(name: "datetime", alias: "datetime", type: .DATE, defaultValue: "CURRENT_TIMESTAMP"),
                Field(name: "name", alias: "name", type: .STRING)
            ]
            
            if let pointsFC = dataStore.createFeatureClass(name: "points",
                                                           geometryType: .POINT,
                                                           fields: fields,
                                                           options: options) {
            
                // Add geodata to points feature class from https://en.wikipedia.org
                let coordinates = [
                    (name: "Moscow", x: 37.616667, y: 55.75),
                    (name: "London", x: -0.1275, y: 51.507222),
                    (name: "Washington", x: -77.016389, y: 38.904722),
                    (name: "Beijing", x: 116.383333, y: 39.916667),
                ]
                
                let coordTransform = CoordinateTransformation.new(fromEPSG: 4326, toEPSG: 3857)
                
                for coordinate in coordinates {
                    if let feature = pointsFC.createFeature() {
                        if let geom = feature.createGeometry() as? GeoPoint {
                            let point = Point(x: coordinate.x, y: coordinate.y)
                            let transformPoint = coordTransform.transform(point)
                            geom.setCoordinates(point: transformPoint)
                            feature.geometry = geom
                            feature.setField(for: 0, double: coordinate.x)
                            feature.setField(for: 1, double: coordinate.y)
                            feature.setField(for: 3, string: coordinate.name)
                            _ = pointsFC.insertFeature(feature)
                        }
                    }
                }

                // Create layer from points feature class
                if let pointsLayer = map.addLayer(name: "Points", source: pointsFC) {
                
                    // Set layer style
                    pointsLayer.styleName = "pointsLayer"
                    let style = pointsLayer.style
                    _ = style.set(string: uiColorToHexString(
                                  color: UIColor(red: 0.0, green: 0.8, blue: 0.545,
                                                 alpha: 1.0)), for: "color")
                    
                    _ = style.set(double: 8.0, for: "size")
                    _ = style.set(int: 6, for: "type") // Star symbol
                    
                    pointsLayer.style = style
                }
            }
        }
    }
    
    func getPointsFeatureClass() -> FeatureClass? {
        return map?.getLayer(by: 0)?.dataSource as? FeatureClass
    }
    
   
    // MARK: Actions
    
    @IBAction func onInfo(_ sender: UIBarButtonItem) {
        let versionStr = API.instance.versionString(component: "self")
        let geosStr = API.instance.versionString(component: "geos")
        let gdalStr = API.instance.versionString(component: "gdal")
        let projStr = API.instance.versionString(component: "proj")
        let sqliteStr = API.instance.versionString(component: "sqlite")
        let tiffStr = API.instance.versionString(component: "tiff")
        let geotiffStr = API.instance.versionString(component: "geotiff")
        let jpegStr = API.instance.versionString(component: "jpeg")
        let pngStr = API.instance.versionString(component: "png")
        
        let infoStr = "NextGIS Demo application\nSDK version: \(versionStr)\nGDAL: \(gdalStr)\nGEOS: \(geosStr)\nPROJ.4: \(projStr)\nSqlite: \(sqliteStr)\nTIFF \(tiffStr) [GeoTIFF \(geotiffStr)]\nJPEG: \(jpegStr)\nPNG: \(pngStr)"
        
        let alert = UIAlertController(title: "Info",
                                      message: infoStr,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "Close",
                                      style: UIAlertActionStyle.cancel,
                                      handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onZoomIn(_ sender: UIButton) {
        mapView.zoomIn()
    }
    
    @IBAction func onZoomOut(_ sender: UIButton) {
        mapView.zoomOut()
    }
}

