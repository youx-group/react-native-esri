//
//  Point.swift
//  app
//
//  Created by GT4W on 8/23/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import ArcGIS
import Foundation

public class Point {
  let latitude: NSNumber
  let longitude: NSNumber
  let rotation: NSNumber?
  let referenceId: NSString?
  let imageId: NSString?
  init(_latitude: NSNumber, _longitude: NSNumber, _rotation: NSNumber?, _attributes: [String: Any]?, _referenceId: NSString?, _imageId: NSString?) {
    self.latitude = _latitude
    self.longitude = _longitude
    self.rotation = _rotation
    self.referenceId = _referenceId
    self.imageId = _imageId
  }
  
  init(rawData: NSDictionary) {
      self.latitude = rawData["latitude"] as! NSNumber
      self.longitude = rawData["longitude"] as! NSNumber
      self.rotation = rawData["rotation"] as? NSNumber ?? 0
      self.referenceId = rawData["referenceId"] as? NSString ?? nil
      self.imageId = rawData["graphicId"] as? NSString
  }
  
  func toAGSPoint () -> AGSPoint{
    let graphicPoint = CLLocationCoordinate2D(latitude: self.latitude.doubleValue, longitude: self.longitude.doubleValue)
    return AGSPoint(clLocationCoordinate2D: graphicPoint)
  }
  
  func toAGSGraphic (pointImageDictionary:[NSString: UIImage]?) -> AGSGraphic{
    
    let agsPoint = self.toAGSPoint()
    let agsGraphic: AGSGraphic
    
    if let imageId = self.imageId, let image = pointImageDictionary?[imageId] {
      let symbol = AGSPictureMarkerSymbol(image: image)
      agsGraphic = AGSGraphic(geometry: agsPoint, symbol: symbol, attributes: nil)
    } else {
      let symbol = AGSSimpleMarkerSymbol(style: .circle, color: UIColor.green, size: 10)
      agsGraphic = AGSGraphic(geometry: agsPoint, symbol: symbol, attributes: nil)
    }
    
    if let referenceId = self.referenceId
    {
      agsGraphic.attributes["referenceId"] = referenceId
    }
    
    return agsGraphic
  }
}
