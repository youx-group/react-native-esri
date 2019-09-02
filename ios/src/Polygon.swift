//
//  Polygon.swift
//  app
//
//  Created by GT4W on 8/23/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import ArcGIS
import Foundation
import UIColor_Hex_Swift

public class Polygon{
  let points : [AGSPoint]
  let fill : UIColor
  let outline : UIColor
  let referenceId : NSString?
  
  let alert: Alert?
  
  init(_points:[AGSPoint], _color: String, _outline: String, _referenceId:NSString, _alert:Alert){
    self.points = _points
    self.fill = UIColor(_color)
    self.outline = UIColor(_outline)
    self.referenceId = _referenceId
    self.alert = _alert
  }
  
  init(rawData: NSDictionary){
    var _points : [AGSPoint] = []
    let rawDataPoints : [NSDictionary] =  rawData["points"] as! [NSDictionary]
    for rawDataPoint in rawDataPoints{
      _points.append(Point(rawData: rawDataPoint).toAGSPoint())
    }
    self.points = _points
    self.fill = UIColor(rawData["fillColor"] as! String)
    self.outline = UIColor(rawData["outlineColor"] as! String)
    self.referenceId = rawData["referenceId"] as? NSString ?? nil
    
    if let tempAlert  = rawData["alert"] as! NSDictionary? {
      self.alert = Alert(rawData: tempAlert)
    }
    else {
      self.alert = nil
    }
  }
  
  func toAGSPolygon() -> AGSPolygon{
    let polygon : AGSPolygon = AGSPolygon(points: points)
    return polygon
  }
  
  func toAGSGraphic() -> AGSGraphic{
    let polygonOutlineSymbol = AGSSimpleLineSymbol(style: .solid, color: self.outline, width: 2.0)
    let polygonSymbol = AGSSimpleFillSymbol(style: .solid, color: self.fill, outline: polygonOutlineSymbol)
    let polygon = self.toAGSPolygon()
    let polygonGraphic = AGSGraphic(geometry: polygon, symbol: polygonSymbol, attributes: nil)
    
    if let referenceId = self.referenceId
    {
      polygonGraphic.attributes["referenceId"] = referenceId
    }
    if let alert = self.alert {
      polygonGraphic.attributes["alert"] = alert
    }
    
    return polygonGraphic
  }
}
