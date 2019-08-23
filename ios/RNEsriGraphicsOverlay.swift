//
//  RNEsriGraphicsOverlay.swift
//  app
//
//  Created by GT4W on 8/23/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import ArcGIS
import Foundation

public class RNEsriGraphicsOverlay: AGSGraphicsOverlay {
  var pointImageDictionary: [NSString: UIImage]
  let referenceId: NSString
  var shouldAnimateUpdate: Bool = false
  
  // MARK: Initializer
  init(rawData: NSDictionary){
    
    
    guard let referenceIdRaw = rawData["referenceId"] as? NSString else {
      fatalError("The RNAGSGraphicsLayer needs a reference ID.")
    }
    
    guard let rawDataPoints = rawData["points"] as? [NSDictionary] else {
      fatalError("The RNAGSGraphicsLayer recieved invalid point data: \(rawData)")
    }
    
    guard let rawDataPolygons = rawData["polygons"] as? [NSDictionary] else {
      fatalError("The RNAGSGraphicsLayer recieved invalid poplygon data: \(rawData)")
    }
    
    guard let rawDataLines = rawData["lines"] as? [NSDictionary] else {
      fatalError("The RNAGSGraphicsLayer recieved invalid line data: \(rawData)")
    }
    
    referenceId = referenceIdRaw
    pointImageDictionary = [:]
    super.init()
    
    // Create image assets
    if let pointImagesRaw = rawData["pointGraphics"] as? [NSDictionary] {
      for item in pointImagesRaw {
        if let graphicId = item["graphicId"] as? NSString, let graphic = RCTConvert.uiImage(item["graphic"]) {
          pointImageDictionary[graphicId] = graphic
        }
      }
    }
    
    for item in rawDataPoints {
      let point = Point(rawData: item)
      let agsGraphic = point.toAGSGraphic(pointImageDictionary: pointImageDictionary)
      self.graphics.add(agsGraphic)
    }
    
    for item in rawDataPolygons {
      let polygon = Polygon(rawData: item)
      let agsGraphic = polygon.toAGSGraphic()
      self.graphics.add(agsGraphic)
    }
    
    for item in rawDataLines {
      let line = Line(rawData: item)
      let agsGraphic = line.toAGSGraphic()
      self.graphics.add(agsGraphic)
    }
  }
  
  func updateGraphic(with args: NSDictionary) {
    // First, find the graphic with the reference ID
    guard let referenceId = args["referenceId"] as? NSString else {
      return
    }
    // Look for graphic within graphics
    guard let graphic = self.graphics.first(where: { (item) -> Bool in
      return (item as! AGSGraphic).attributes["referenceId"] as! NSString == referenceId
    }) as? AGSGraphic else {
      // No result found, nothing to update
      return
    }
    // From here, we check for each attribute individually
    let latitude = args["latitude"] as? NSNumber
    let longitude = args["longitude"] as? NSNumber
    let originalPosition = graphic.geometry as! AGSPoint
    let attributes = args["attributes"] as? [NSString: Any]
    let rotation = args["rotation"] as? NSNumber
    let rawLocationData = CLLocationCoordinate2D(latitude: latitude?.doubleValue ?? originalPosition.x, longitude: longitude?.doubleValue ?? originalPosition.y)
    let graphicPoint = AGSPoint(clLocationCoordinate2D: rawLocationData)
    
    // Once we have all the possible update values, we change them
    if let graphicId = args["graphicId"] as? NSString, let newImage = pointImageDictionary[graphicId] {
      let symbol = AGSPictureMarkerSymbol(image: newImage)
      // update location and graphic
      graphic.symbol = symbol
      
    }
    // Update geometry here
    let fromPoint = graphic.geometry as! AGSPoint
    let fromRotation = (graphic.symbol as? AGSPictureMarkerSymbol)?.angle
    if (shouldAnimateUpdate) {
      update(graphic: graphic, fromPoint: fromPoint, toPoint: graphicPoint, fromRotation: fromRotation ?? 0, toRotation: rotation?.floatValue ?? 0)
    } else {
      // Update rotation and geometry without animation
      graphic.geometry = graphicPoint
      if let rotation = rotation?.floatValue {
        (graphic.symbol as? AGSPictureMarkerSymbol)?.angle = rotation
      }
    }
    // Attributes
    if let attributes = attributes {
      graphic.attributes.addEntries(from: attributes)
    }
    // End of updates
    
  }
  
  let timerDuration: Double = 0.5
  var timer = Timer()
  private static let timerFireMax:NSNumber = 10.0
  // Here we will animate the movement of a point - both position and angle
  private func update(graphic: AGSGraphic, fromPoint: AGSPoint, toPoint:AGSPoint, fromRotation: Float, toRotation: Float){
    let dx = (toPoint.x - fromPoint.x) / RNEsriGraphicsOverlay.timerFireMax.doubleValue
    let dy = (toPoint.y - fromPoint.y) / RNEsriGraphicsOverlay.timerFireMax.doubleValue
    let dTheta = (toRotation - fromRotation) / RNEsriGraphicsOverlay.timerFireMax.floatValue
    let symbol = graphic.symbol as? AGSPictureMarkerSymbol
    var timesFired = 0.0
    Timer.scheduledTimer(withTimeInterval: timerDuration / RNEsriGraphicsOverlay.timerFireMax.doubleValue, repeats: true, block: {
      if (timesFired < RNEsriGraphicsOverlay.timerFireMax.doubleValue) {
        let x = fromPoint.x + (dx * timesFired)
        let y = fromPoint.y + (dy * timesFired)
        let rotation = Double(fromRotation) + (Double(dTheta) * timesFired)
        graphic.geometry = AGSPoint(x: x, y: y, spatialReference: AGSSpatialReference.wgs84())
        symbol?.angle = Float(rotation)
        timesFired += 1.0
      } else {
        graphic.geometry = toPoint
        symbol?.angle = toRotation
        $0.invalidate()
      }
    })
  }
}
