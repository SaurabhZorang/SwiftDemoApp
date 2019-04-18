/* Copyright (c) 2016 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import GoogleMaps
import UIKit

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
  var position: CLLocationCoordinate2D
  var name: String!

  init(position: CLLocationCoordinate2D, name: String) {
    self.position = position
    self.name = name
  }
}



let kClusterItemCount = 10000
let kCameraLatitude = -33.8
let kCameraLongitude = 151.2

class ClusteringViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate,GMUClusterRendererDelegate {

     let isClustering : Bool = true
     let isCustom : Bool = false
    
  private var mapView: GMSMapView!
  private var clusterManager: GMUClusterManager!

  override func loadView() {
    let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
      longitude: kCameraLongitude, zoom: 10)
    mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    
    self.view = mapView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up the cluster manager with default icon generator and renderer.
    let iconGenerator:GMUDefaultClusterIconGenerator =  GMUDefaultClusterIconGenerator()
    
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
    renderer.delegate=self
    clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)

    // Generate and add random items to the cluster manager.
    generateClusterItems()

    // Call cluster() after items have been added to perform the clustering and rendering on map.
    clusterManager.cluster()

    // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
    clusterManager.setDelegate(self, mapDelegate: self)
    
  }

    //MARK: - GMUClusterRenderer
//    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
//
////        let markerImage = UIImage(named: "qaddo")!.withRenderingMode(.alwaysTemplate)
////        //creating a marker view
////        let markerView = UIImageView(image: markerImage)
////        let text = UILabel()
////        text.center=markerView.center
////        text.text="23"
////        text.textColor=UIColor.red
////        markerView.addSubview(text)
//
//        let marker = GMSMarker()
////        marker.title = "Jolla"
////        marker.iconView=markerView
//        marker.icon = UIImage(named: "qaddo")
//
//        return marker
//    }
    
    
    func textToImage(drawText: NSString, inImage: UIImage) -> UIImage{
        
        // Setup the font specific variables
        let textColor = UIColor.red
        let textFont = UIFont(name: "Helvetica Bold", size: 18)!
        
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
//        let textFontAttributes = [
//            NSFontAttributeName: textFont,
//            NSForegroundColorAttributeName: textColor,
//            NSTextAlignment:NSTextAlignment.center
//            ]
        
        //text attributes
        let font=UIFont(name: "Helvetica-Bold", size: 12)!
        let text_style=NSMutableParagraphStyle()
        text_style.alignment=NSTextAlignment.center
        let text_color=UIColor.red
        let textFontAttributes=[NSFontAttributeName:font, NSParagraphStyleAttributeName:text_style, NSForegroundColorAttributeName:text_color]
        
        // Put the image into a rectangle as large as the original image
        inImage.draw(in:CGRect(x:0, y:0, width:inImage.size.width,height: inImage.size.height))
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x:0, y:0, width:inImage.size.width,height: inImage.size.height)
        
        
        let text_h=font.lineHeight
        let text_y=((inImage.size.height-text_h)/2) - 3
        let text_rect=CGRect(x: 0, y: text_y, width: inImage.size.width, height: text_h)
        // Draw the text into an image
        drawText.draw(in: text_rect.integral, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
        
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let _ = marker.userData as? POIItem {
            marker.icon = UIImage(named: "qaddo")
        } else {
            let image = textToImage(drawText: "123", inImage: UIImage(named: "new_pinvisted")!)
                    let markerView = UIImageView(image:image )
                    marker.iconView=markerView
        }
    }
    
    
  // MARK: - GMUClusterManagerDelegate

  func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
    let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
      zoom: mapView.camera.zoom + 1)
    let update = GMSCameraUpdate.setCamera(newCamera)
    mapView.moveCamera(update)
    return false
  }

  // MARK: - GMUMapViewDelegate

  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    
    if let poiItem = marker.userData as? POIItem {
      NSLog("Did tap marker for cluster item \(poiItem.name)")
    } else {
      NSLog("Did tap a normal marker")
    }
    return false
    
  }

  // MARK: - Private

  /// Randomly generates cluster items within some extent of the camera and adds them to the
  /// cluster manager.
  private func generateClusterItems() {
    let extent = 0.2
    for index in 1...kClusterItemCount {
      let lat = kCameraLatitude + extent * randomScale()
      let lng = kCameraLongitude + extent * randomScale()
      let name = "Item \(index)"
      let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
      
        clusterManager.add(item)
        
     
    }
    
//    for _ in 1...30 {
//        let lat = kCameraLatitude + extent * randomScale()
//        let lng = kCameraLongitude + extent * randomScale()
//        var marker = GMSMarker()
//        marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
//        marker.title = "singleElement.tanName"
//        marker.icon = UIImage(named: "new_pinvisted")
//        marker.map = mapView
//
//
//    }
//
//
    
  }

  /// Returns a random value between -1.0 and 1.0.
  private func randomScale() -> Double {
    return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
  }
}

class CustomClusterIconGenerator:GMUDefaultClusterIconGenerator
{
    override init() {
        super.init()
    }
    override  func icon(forSize size: UInt) -> UIImage {
      return  UIImage(named: "new_pinvisted")!
    }
    
    func iconForMarker()->UIImage!{
        
         return  UIImage(named: "new_pinvisted")!
    }
   
}

