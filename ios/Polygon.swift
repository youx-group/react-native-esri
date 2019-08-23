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
  let color : UIColor
  let outline : UIColor
  
  init(_points:[AGSPoint], _color: String, _outline: String){
    points = _points
    color = UIColor(_color)
    outline = UIColor(_outline)
  }
  
  init(rawData: NSDictionary){
    var _points : [AGSPoint] = []
    let rawDataPoints : [NSDictionary] =  rawData["points"] as! [NSDictionary]
    for rawDataPoint in rawDataPoints{
      _points.append(Point(rawData: rawDataPoint).toAGSPoint())
    }
    self.points = _points
    self.color = UIColor(rawData["color"] as! String)
    self.outline = UIColor(rawData["outline"] as! String)
  }
  
  func toAGSPolygon() -> AGSPolygon{
    let polygon : AGSPolygon = AGSPolygon(points: points)
    return polygon
  }
  
  func toAGSGraphic() -> AGSGraphic{
    let polygonOutlineSymbol = AGSSimpleLineSymbol(style: .solid, color: self.outline, width: 2.0)
    let polygonSymbol = AGSSimpleFillSymbol(style: .solid, color: self.color, outline: polygonOutlineSymbol)
    let polygon = self.toAGSPolygon()
    let polygonGraphic = AGSGraphic(geometry: polygon, symbol: polygonSymbol, attributes: nil)
    return polygonGraphic
  }
}
