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
    
    referenceId = referenceIdRaw
    pointImageDictionary = [:]
    super.init()
    
    if let pointImagesRaw = rawData["pointGraphics"] as? [NSDictionary] {
      for item in pointImagesRaw {
        if let graphicId = item["graphicId"] as? NSString, let graphic = RCTConvert.uiImage(item["graphic"]) {
          pointImageDictionary[graphicId] = graphic
        }
      }
    }
    
    if let rawDataPoints = rawData["points"] as? [NSDictionary] {
      for item in rawDataPoints {
        let point = Point(rawData: item)
        let agsGraphic = point.toAGSGraphic(pointImageDictionary: pointImageDictionary)
        self.graphics.add(agsGraphic)
      }
    }
    
    if let rawDataPolygons = rawData["polygons"] as? [NSDictionary] {
      for item in rawDataPolygons {
        let polygon = Polygon(rawData: item)
        let agsGraphic = polygon.toAGSGraphic()
        self.graphics.add(agsGraphic)
      }
    }
    
    if let rawDataLines = rawData["lines"] as? [NSDictionary]{
      for item in rawDataLines {
        let line = Line(rawData: item)
        let agsGraphic = line.toAGSGraphic()
        self.graphics.add(agsGraphic)
      }
    }
  }
  
//  let timerDuration: Double = 0.5
//  var timer = Timer()
//  private static let timerFireMax:NSNumber = 10.0
//  // Here we will animate the movement of a point - both position and angle
//  private func update(graphic: AGSGraphic, fromPoint: AGSPoint, toPoint:AGSPoint, fromRotation: Float, toRotation: Float){
//    let dx = (toPoint.x - fromPoint.x) / RNEsriGraphicsOverlay.timerFireMax.doubleValue
//    let dy = (toPoint.y - fromPoint.y) / RNEsriGraphicsOverlay.timerFireMax.doubleValue
//    let dTheta = (toRotation - fromRotation) / RNEsriGraphicsOverlay.timerFireMax.floatValue
//    let symbol = graphic.symbol as? AGSPictureMarkerSymbol
//    var timesFired = 0.0
//    Timer.scheduledTimer(withTimeInterval: timerDuration / RNEsriGraphicsOverlay.timerFireMax.doubleValue, repeats: true, block: {
//      if (timesFired < RNEsriGraphicsOverlay.timerFireMax.doubleValue) {
//        let x = fromPoint.x + (dx * timesFired)
//        let y = fromPoint.y + (dy * timesFired)
//        let rotation = Double(fromRotation) + (Double(dTheta) * timesFired)
//        graphic.geometry = AGSPoint(x: x, y: y, spatialReference: AGSSpatialReference.wgs84())
//        symbol?.angle = Float(rotation)
//        timesFired += 1.0
//      } else {
//        graphic.geometry = toPoint
//        symbol?.angle = toRotation
//        $0.invalidate()
//      }
//    })
//  }
}