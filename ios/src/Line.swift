//
//  Line.swift
//  app
//
//  Created by GT4W on 8/23/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import ArcGIS
import Foundation
import UIColor_Hex_Swift

public class Line{
  let referenceId : NSString?
  let points : [AGSPoint]
  let outline : UIColor
  
  let alert: Alert?
  
  init(_points:[AGSPoint], _outline: String, _referenceId:NSString, _alert:Alert){
    self.points = _points
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
    self.outline = UIColor(rawData["outlineColor"] as! String)
    self.referenceId = rawData["referenceId"] as? NSString ?? nil
    
    if let tempAlert  = rawData["alert"] as! NSDictionary? {
      self.alert = Alert(rawData: tempAlert)
    }
    else {
      self.alert = nil
    }
  }
  
  func toAGSPolyline() -> AGSPolyline{
    let polyline : AGSPolyline = AGSPolyline(points: points)
    return polyline
  }
  
  func toAGSGraphic() -> AGSGraphic{
    let polyline : AGSPolyline = self.toAGSPolyline()
    let polylineSymbol = AGSSimpleLineSymbol(style: .solid, color: outline, width: 3.0)
    let polylineGraphic = AGSGraphic(geometry: polyline, symbol: polylineSymbol, attributes: nil)
    
    if let referenceId = self.referenceId
    {
      polylineGraphic.attributes["referenceId"] = referenceId
    }
    if let alert = self.alert {
      polylineGraphic.attributes["alert"] = alert
    }
    
    return polylineGraphic
  }
}

