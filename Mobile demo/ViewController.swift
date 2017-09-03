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
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let map = API.instance.getMap("main") {
        
            let options = [
                "ZOOM_INCREMENT":"1", // Add extra to zoom level corresponding to scale
                "VIEWPORT_REDUCE_FACTOR":"1.5" // Reduce viewport width and height to decrease memory usage
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
            
            let bbox = BBox(minx: -20037508.34,
                            miny: -20037508.34,
                            maxx: 20037508.34,
                            maxy: 20037508.34)
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
            // We expected datastore has points feature class
            if let pointsFC = dataStore.child(name: "points") {
                // Create layer from points feature class
                let pointsLayer = map.addLayer(name: "Points", source: pointsFC)
                // Set layer style
                if let style = pointsLayer?.style {
                    _ = style.set(string: uiColorToHexString(
                        color: UIColor(red: 0.0, green: 0.0, blue: 1.0,
                                       alpha: 1.0)), for: "color")
                    
                    _ = style.set(double: 5.0, for: "size")
                    
                   pointsLayer!.style = style
                }
            }
        }
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

